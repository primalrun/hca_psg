import os
import pandas as pd
import glob
import sys
import teradata

path_source='C:/Liclipse_Workspace/medrec/file_source/gl_file/'
path_dest='C:/Liclipse_Workspace/medrec/file_converted/'
login_file='C:/Liclipse_Workspace/medrec/file_source/connection/teradata_login.txt' 
driver_td='Teradata'
authentication_td='LDAP'
ar_trxn_class=['1','2','7']
pe_date_str='2020-02-29'


trxn_class_str=','.join(ar_trxn_class)

#cd to source file
os.chdir(path_source)

df_list=[]
coid_sql_list=[]

for file in glob.glob('*.xls'):
    file_only=os.path.splitext(file)[0]
    coid=file_only[-5:]      
    coid_sql_list.append(coid)
    df=pd.read_excel(file)
    df2=df.dropna(axis=1,how='all').copy()
    col_new=[col.replace('\n','_').replace(' ','_') for col in df2.columns]
    col_suffix=col_new[1:]
    col_1=['Provider_Nbr']
    col_new_2=col_1+col_suffix    
    df2.columns=col_new_2
    df3=df2[df2['Provider_Nbr'].notnull()].copy()
    df_count=len(df3)
    coid_list=[coid]*df_count
    df3.insert(0,'COID',coid_list,True)
    
    df3['Adjustments_MTD']=(df3['Cont_WO_MTD']
                            +df3['Debits_MTD']
                            +df3['Bad_Debt_MTD']
                            +df3['Refunds_MTD']
                            +df3['NSF_MTD']
                            )

    df4=df3.groupby(['COID','Provider_Nbr']).agg({'Charges_MTD':'sum','Payments_MTD':'sum','Adjustments_MTD':'sum'}).fillna(0).reset_index()

    df_list.append(df4)

coid_str=','.join("'{}'".format(c) for c in coid_sql_list)

df_gl=pd.concat(df_list)

#out_file=path_dest+'source_gl_df.xlsx'
#df_gl.to_excel(out_file,index=False)
#os.startfile(out_file)     

#teradata
source_file=login_file
f=open(source_file, "r")
login_str=str(f.readline())
login_list=login_str.split(sep="|")
host_td, uname_td, pword_td=login_list[0], login_list[1], login_list[2]

#make connection
udaExec=teradata.UdaExec(appName="test", version="1.0", logConsole=False)
with udaExec.connect(method="odbc",
                      system=host_td,
                      username=uname_td, 
                      password=pword_td, 
                      driver=driver_td,
                      authentication=authentication_td) as connect:
    query="""
    select
        ar.coid as COID
        ,cast(t.trn_prv_cd as varchar(4)) as Provider_Nbr
        ,sum(case when transaction_class_dw_id = 2 then ar.transaction_amt else 0 end) as Charges_MTD
        ,sum(case when transaction_class_dw_id = 7 then ar.transaction_amt else 0 end) as Payments_MTD
        ,sum(case when transaction_class_dw_id = 1 then ar.transaction_amt else 0 end) as Adjustments_MTD
    from edwps_base_views.ar_transaction ar
    left join (
    select
        trn_num
        ,data_server_code
        ,max(trn_prv_cd) as trn_prv_cd
    from edwps_staging.mr_trn_file_hist
    group by 1,2
    ) t
        on ar.transaction_src_sys_key = t.trn_num
        and ar.data_server_code = t.data_server_code
    left join edwps_staging.lu_date ld
        on ar.entry_date = ld.date_id
    where
        ar.source_system_code = '9'
        and ar.transaction_class_dw_id in ({trxn_class})
        and ld.pe_date = date '{pe_date}'
        and ar.transaction_amt not = 0
        and ar.coid in ({coid})
    group by 1,2
    order by 1,2
    """.format(trxn_class=trxn_class_str
               ,pe_date=pe_date_str
               ,coid=coid_str)
    edw_trxn=pd.read_sql(query,connect)        
    

# out_file=path_dest+'edw_trxn_df.xlsx'
# df_gl.to_excel(out_file,index=False)
# os.startfile(out_file)
    
    
df_combo=pd.merge(
    df_gl
    ,edw_trxn
    ,how='outer'
    ,on=['COID','Provider_Nbr']
    ).fillna(0)


df_combo.columns=['COID','Provider_Nbr','Charges_MTD_GL','Payments_MTD_GL'
                  ,'Adjustments_MTD_GL','Charges_MTD_EDW','Payments_MTD_EDW'
                  ,'Adjustments_MTD_EDW']

df_combo['Charges_MTD_Variance']=(
    df_combo['Charges_MTD_EDW']-df_combo['Charges_MTD_GL']
    )

df_combo['Payments_MTD_Variance']=(
    df_combo['Payments_MTD_EDW']-df_combo['Payments_MTD_GL']
    )

df_combo['Adjustments_MTD_Variance']=(
    df_combo['Adjustments_MTD_EDW']-df_combo['Adjustments_MTD_GL']
    )


for c in df_combo.columns[2:]:
    df_combo[c]=df_combo[c].apply(lambda x: round(x,3))

def f_charge(row):
    if row['Charges_MTD_Variance']!=0:
        val=1
    else:
        val=0
    return val

def f_payment(row):
    if row['Payments_MTD_Variance']!=0:
        val=1
    else:
        val=0
    return val

def f_adjustment(row):
    if row['Adjustments_MTD_Variance']!=0:
        val=1
    else:
        val=0
    return val

trxn_coll=[] #trxn_type, transaction_class_dw_id, coid, trn_prv_cd
df_combo_variance = df_combo.loc[
    ((df_combo['Charges_MTD_Variance']!=0)
    |(df_combo['Payments_MTD_Variance']!=0)
    |(df_combo['Adjustments_MTD_Variance']!=0)
    )
    ].copy()
df_combo_variance['chg_bool']=df_combo_variance.apply(f_charge,axis=1)
df_combo_variance['pmt_bool']=df_combo_variance.apply(f_payment,axis=1)
df_combo_variance['adj_bool']=df_combo_variance.apply(f_adjustment,axis=1)

for index,row in df_combo_variance.iterrows():
    if row['chg_bool']==1:
            trxn_coll.append(('charge','2',row['COID'],row['Provider_Nbr']))
    if row['pmt_bool']==1:
            trxn_coll.append(('payment','7',row['COID'],row['Provider_Nbr']))
    if row['adj_bool']==1:
            trxn_coll.append(('adjustment','1',row['COID'],row['Provider_Nbr']))        


#make connection
udaExec=teradata.UdaExec(appName="test", version="1.0", logConsole=False)
with udaExec.connect(method="odbc",
                      system=host_td,
                      username=uname_td, 
                      password=pword_td, 
                      driver=driver_td,
                      authentication=authentication_td) as connect:
    
    for x in trxn_coll:        
        
        trxn_type=x[0]
        trxn_class_dw_id=x[1]
        coid_str=x[2]
        prov_nbr=x[3]
        
        query="""
        select
            ar.coid
            ,t.trn_num
            ,t.data_server_code
            ,t.trn_prv_cd
            ,t.trn_svc_typ_cd
            ,t.trn_amt
        from edwps_base_views.ar_transaction ar
        left join (
        select
            trn_num
            ,data_server_code    
            ,max(trn_prv_cd) as trn_prv_cd
            ,max(trn_svc_typ_cd) as trn_svc_typ_cd
            ,sum(trn_amt) as trn_amt
        from edwps_staging.mr_trn_file_hist
        group by 1,2
        ) t
            on ar.transaction_src_sys_key = t.trn_num
            and ar.data_server_code = t.data_server_code
        left join edwps_staging.lu_date ld
            on ar.entry_date = ld.date_id
            where
                ar.source_system_code = '9'
                and ar.transaction_class_dw_id in ({trxn_class})
                and ld.pe_date = date '{pe_date}'
                and ar.transaction_amt not = 0
                and ar.coid in ({coid})
                and t.trn_prv_cd = '{prv_nbr}'
        """.format(trxn_class=trxn_class_dw_id
                   ,pe_date=pe_date_str
                   ,coid=coid_str
                   ,prv_nbr=prov_nbr)
        df_prv_trxn=pd.read_sql(query,connect)
        out_file_trxn=path_dest+coid_str+'_'+prov_nbr+'_'+trxn_type+'_.xlsx'
        df_prv_trxn.to_excel(out_file_trxn,index=False)




out_file_var=path_dest+'medrec_trxn_variance.xlsx'
df_combo_variance.to_excel(out_file_var,index=False,float_format='%.2f')
os.startfile(out_file_var)



