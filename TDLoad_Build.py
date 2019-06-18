import os
import datetime

env_attr = {'prod': ['edwprod.dw.medcity.net', 'psload', 'loaddatalater']
            ,'qa': ['edwqa.dw.medcity.net', 'psload', 'psloadqa2']
            ,'dev': ['edwdev.dw.medcity.net', 'psload', 'devprovide7']}

source_env = 'prod'
target_env = 'dev'
out_file_path = r'c:/temp/'

#Tables to copy/move (Database, TableName)
tables = [('edwps_staging', 'stg_host_gl_detail')
    ,('edwps_staging', 'pv_mapped_location')
    ,('edwps_staging', 'aa_stghostgladjcodexwalk_pv')
    ,('edwps_staging', 'aa_stghostgltrtypelist')
    ,('edwps_staging', 'pv_physician')
    ,('edwps', 'hcaps_transaction_type')
    ,('edwps_staging', 'pv_logdetail_hist')
    ,('edwps_staging', 'pv_ent_coid_mgt')
    ,('edwps_staging', 'pv_patbilling_hist')
    ,('edwps_staging', 'pv_crgheader_hist')
    ,('edwps_staging', 'pv_insurance')
    ,('edwps_staging', 'ref_iplan_fin_class_map')
    ,('edwps_staging', 'pv_clinic_hist')
    ,('edwps_staging', 'pv_clinic_mgmt')
    ,('edwps_staging', 'aa_stghostglacctxwalk_pv')
    ,('edwps_staging', 'pv_ardetail_hist')
    ,('edwps_staging', 'pv_arheader_hist')
    ,('edwps_staging', 'pv_coid_xwalk')
    ,('edwps_staging', 'pv_crgdetail_hist')
    ]


for x in tables:
    with open(out_file_path + x[1] + '.txt', 'w') as f:
        f.write('SourceTable = ' + "'" + x[1] + "'" + ',' + ('\n' * 2))
        f.write('SourceTdpId = ' + "'" + 
                env_attr[source_env][0] + "'" +  ',' + ('\n' * 2))
        f.write('SourceWorkingDatabase = ' + "'" + x[0] + "'" +  ',' + ('\n' * 2))        
        f.write('SourceUserName = ' + "'" + 
                env_attr[source_env][1] + "'" +  ',' + ('\n' * 2))
        f.write('SourceUserPassword = ' + "'" + 
                env_attr[source_env][2] + "'" +  ',' + ('\n' * 2))        
        f.write('TargetTable = ' + "'" + x[1] + "'" +  ',' + ('\n' * 2))
        f.write('TargetTdpId = ' + "'" + 
                env_attr[target_env][0] + "'" +  ',' + ('\n' * 2))        
        f.write('TargetWorkingDatabase = ' + "'" + x[0] + "'" +  ',' + ('\n' * 2))
        f.write('TargetUserName = ' + "'" + 
                env_attr[target_env][1] + "'" +  ',' + ('\n' * 2))        
        f.write('TargetUserPassword = ' + "'" + 
                env_attr[target_env][2] + "'" +  ',' + ('\n' * 2))
        f.write('MaxDecimalDigits = 38,')                
f.close()

tdload_file = (out_file_path + 'TDLoad_Statements_' + 
          datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + '.txt'    
    )        
with open(tdload_file, 'w') as f:
    for x in tables:
        f.write('tdload -j ' + x[1] + '.txt' + '\n')
f.close()

print('Success, Output files are saved at ' + out_file_path)


