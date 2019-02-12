USE [AccountingAutomation]
GO

--Update datetime variable @MaxModifiedDate

--drop tables in foreign key favorable sequence-----------------------------------------------------------------------------------------------------------------------
if object_id('AUDIT.GLJobRun', 'U') is not null 
	drop table AUDIT.GLJobRun
	go
if object_id('AUDIT.Region', 'U') is not null 
	drop table AUDIT.Region
	go
if object_id('AUDIT.SourceSystem', 'U') is not null 
	drop table AUDIT.SourceSystem
	go
if object_id('AUDIT.GLJobExclusion', 'U') is not null 
	drop table AUDIT.GLJobExclusion
	go
if object_id('AUDIT.GLJob', 'U') is not null 
	drop table AUDIT.GLJob
	go
if object_id('AUDIT.GLRegionJobRun', 'U') is not null 
	drop table AUDIT.GLRegionJobRun
	go

--create tables--------------------------------------------------------------------------------------------------------------------------------------------------------
create table AUDIT.SourceSystem(
	SourceSystemCode varchar(15) not null primary key
	,SourceSystemDescription varchar(75) null	
) on [primary]
go

insert into AUDIT.SourceSystem
(SourceSystemCode)
values('eCW');

create table AUDIT.Region(	
	RegionID varchar(25) not null primary key
	,SourceSystemCode varchar(15) not null
	,RegionDescription varchar(75) null
	,ServerName varchar(50) not null
	,DatabaseName varchar(50) not null
	,ActiveFlag int not null default 0	
) on [primary]
go

alter table AUDIT.Region
add constraint FK_Region_SourceSystem foreign key (SourceSystemCode) references AUDIT.SourceSystem (SourceSystemCode)
go

insert into AUDIT.Region
(RegionID, SourceSystemCode, ServerName, DatabaseName, ActiveFlag)
values
	('1', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R01_SS', 1)
	,('2', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R02_SS', 0)
	,('3', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R03_SS', 0)
	,('4', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R04_SS', 0)
	,('5', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R05_SS', 0)
	,('6', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R06_SS', 0)
	,('7', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R07_SS', 0)
	,('8', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R08_SS', 0)
	,('9', 'eCW', '[NADCWDDBSECW02\ETLRPT]', 'MobileDoc_R09_SS', 0)

create table AUDIT.GLJob (
	JobName varchar(50) not null primary key
	,SchemaName varchar(25) not null	
	,JobType varchar(30) not null
	,JobDescription varchar(200)
	,RegionRunFlag int not null default 0
	,ActiveFlag int not null default 0
)

insert into AUDIT.GLJob
(JobName, SchemaName, JobType, RegionRunFlag, ActiveFlag)
values
	('HostGL_eCW_ADJUSTMENTS', 'ecwStage', 'SSIS Package', 1, 1)
	,('HostGL_eCW_CONTRACTUALWRITEOFF', 'ecwStage', 'SSIS Package', 1, 1)
	,('HostGL_eCW_DAILYAR', 'ECW', 'SSIS Package', 0, 1)
	,('HostGL_eCW_FIFTHTHIRD', 'ecwStage', 'SSIS Package', 0, 1)
	,('HostGL_eCW_FIFTHTHIRD_OP', 'ecwStage', 'SSIS Package', 0, 1)
	,('HostGL_eCW_MONTHLYARALLFIN', 'ecwStage', 'SSIS Package', 0, 1)
	,('HostGL_eCW_MONTHLYARBYFIN', 'ecwStage', 'SSIS Package', 0, 1)
	,('HostGL_eCW_PAYMENTS', 'ecwStage', 'SSIS Package', 1, 1)
	,('HostGL_eCW_REVENUE', 'ecwStage', 'SSIS Package', 1, 1)
	,('HostGL_eCW_UNAPPLIEDPAYMENTS', 'ecwStage', 'SSIS Package', 1, 1)
	,('HostGL_eCW_UNAPPLIEDPAYMENTSREVACCOUNT', 'ecwStage', 'SSIS Package', 0, 1);


create table [AUDIT].GLJobExclusion (
	JobNameExclusion varchar(50) not null primary key
	,JobName varchar(50) not null
);

alter table [AUDIT].GLJobExclusion
add constraint FK_GLJobExclusion_GLJob foreign key (JobName) references [AUDIT].GLJob (JobName)
go


insert into [AUDIT].GLJobExclusion
(JobNameExclusion, JobName)
values
('[ECW].[HostGL_eCW_ADJUSTMENTS_EX]', 'HostGL_eCW_ADJUSTMENTS')
,('[ECW].[HostGL_eCW_CONTRACTUALWRITEOFF_EX]', 'HostGL_eCW_CONTRACTUALWRITEOFF')
,('[ECW].[HostGL_eCW_PAYMENTS_EX]', 'HostGL_eCW_PAYMENTS')
,('[ECW].[HostGL_eCW_REVENUE_EX]', 'HostGL_eCW_REVENUE')
,('[ECW].[HostGL_eCW_UNAPPLIEDPAYMENTS_EX]', 'HostGL_eCW_UNAPPLIEDPAYMENTS')

;



create table AUDIT.GLRegionJobRun(	
	RegionID varchar(25)
	,ServerName varchar(75)
	,DatabaseName varchar(75)
	,JobName varchar(50)	
	,GLJobRunID int primary key
	,GLJobRunIDNew int
	,JobRunID int
	,MaxTransactionDate datetime	
	)
go




create table AUDIT.GLJobRun(
	ID int identity(1, 1) primary key
	,RegionID varchar(25) not null
	,JobName varchar(50) not null
	,JobStart datetime not null
	,JobEnd datetime
	,ETLDate datetime 
	,JobStatus varchar(25) not null
	,FailureReason varchar(100) null
	,MaxTransactionDate datetime
	,SourceRowCount int
	,SourceTransactionAmount decimal(12, 2)
	,DestinationRowCount int
	,DestinationTransactionAmount decimal(12, 2)
	,RowCountVariance int
	,TransactionAmountVariance decimal(12, 2)
	,constraint PK_RegionID_JobName_JobStart unique (RegionID, JobName, JobStart)
);

alter table AUDIT.GLJobRun
add constraint FK_GLJobRun_Region foreign key (RegionID) references AUDIT.Region (RegionID);

alter table AUDIT.GLJobRun
add constraint FK_GLJobRun_JobName foreign key (JobName) references AUDIT.GLJob (JobName);

declare @MaxModifiedDate datetime = '20190205';





insert into AUDIT.GLJobRun
(RegionID, JobName, JobStart, JobEnd, JobStatus, MaxTransactionDate, SourceRowCount, SourceTransactionAmount, DestinationRowCount, DestinationTransactionAmount, RowCountVariance, TransactionAmountVariance)
select
	reg1.RegionID
	,glj1.JobName
	,@MaxModifiedDate as JobStart
	,@MaxModifiedDate as JobEnd
	,'Success' as JobStatus
	,@MaxModifiedDate as MaxTransactionDate
	,0 as SourceRowCount
	,0 as SourceTransactionAmount
	,0 as DestinationRowCount
	,0 as DestinationTransactionAmount
	,0 as RowCountVariance
	,0 as TransactionAmountVariance
from (
select
	reg.RegionID
from AUDIT.Region reg
where
	reg.ActiveFlag = 1) reg1
	cross join (
	select
		glj.JobName
	from AUDIT.GLJob glj
	where
		glj.ActiveFlag = 1
		and glj.RegionRunFlag = 1) glj1
order by 1, 2



if object_id('[AUDIT].[GLGetRegionJobAttributes]', 'P') is not null
	drop proc [AUDIT].[GLGetRegionJobAttributes]
go

create proc [AUDIT].[GLGetRegionJobAttributes]
as
begin
	declare @YesterdayStart datetime = dateadd(day, datediff(day, 0, getdate()-1), 0);
	declare @TodayStart datetime = dateadd(day, datediff(day, 0, getdate()), 0);
	truncate table [AUDIT].GLRegionJobRun;

	insert into [AUDIT].GLRegionJobRun
	(RegionID, ServerName, DatabaseName, JobName, GLJobRunID, MaxTransactionDate)
	select
		reg1.RegionID
		,reg1.ServerName
		,reg1.DatabaseName
		,gl_job1.JobName		
		,max(job_run.ID) as GLJobRunID
		,job_run.MaxTransactionDate
	from (
	select
		reg.RegionID
		,reg.ServerName
		,reg.DatabaseName
	from AUDIT.Region reg
	where
		reg.ActiveFlag = 1) reg1
		cross join (
		select
			gl_job.JobName
		from AUDIT.GLJob gl_job
		where
			gl_job.ActiveFlag = 1
			and gl_job.RegionRunFlag = 1) gl_job1
		inner join (
			select
				(select max(ID) as ID from [AUDIT].GLJobRun g where g.RegionID = q1.RegionID and g.JobName = q1.JobName and g.MaxTransactionDate = q1.MaxTransactionDAte) as ID
				,q1.RegionID
				,q1.JobName
				,q1.ETLDate
				,q1.MaxTransactionDate	
			from (
			select	
				RegionID
				,JobName
				,max(ETLDate) as ETLDate
				,max(MaxTransactionDate) as MaxTransactionDate
			from [AUDIT].GLJobRun
			where
				JobStatus = 'Success'
			group by	
				RegionID
				,JobName
			) q1
			where
				MaxTransactionDate < @YesterdayStart
				and coalesce(ETLDate, @YesterdayStart) < @TodayStart
		) job_run		
			on reg1.RegionID = job_run.RegionID
			and gl_job1.JobName = job_run.JobName	
	group by
		reg1.RegionID
		,reg1.ServerName
		,reg1.DatabaseName
		,gl_job1.JobName
		,job_run.MaxTransactionDate;
		
	update r
	set r.JobRunID = r1.JobRunID
	from [AUDIT].GLRegionJobRun r
		inner join (
		select RegionID, JobName, ntile(5) over(order by RegionID) as JobRunID
		from [AUDIT].GLRegionJobRun) r1
			on r.RegionID = r1.RegionID
			and r.JobName =r1.JobName;

		select * from [AUDIT].GLRegionJobRun
end
go



if object_id('[AUDIT].[GLJobRunID_ByJobRunID]', 'P') is not null
	drop proc [AUDIT].[GLJobRunID_ByJobRunID]
go

create proc [AUDIT].GLJobRunID_ByJobRunID
	@JobRunID int	
as
begin	
	select
		GLJobRunID		
	from [AUDIT].GLRegionJobRun
	where
		JobRunID = @JobRunID		
end
go






if object_id('[AUDIT].[GLJobAttributes_ByJobRunID]', 'P') is not null
	drop proc [AUDIT].[GLJobAttributes_ByJobRunID]
go

create proc [AUDIT].GLJobAttributes_ByJobRunID
	@GLJobRunID int
as
begin
	set nocount on;

	select
		g.RegionID		
		,g.JobName		
		,g.ServerName
		,g.DatabaseName
		,(select r.SourceSystemCode from [AUDIT].Region r where r.RegionID = g.RegionID) as SourceSystemCode
		,(select JobNameExclusion from [AUDIT].GLJobExclusion je where je.JobName = g.JobName) as JobNameExclusion
		,convert(varchar, g.MaxTransactionDate, 121) as MaxTransactionDate
		,(select SchemaName	from [AUDIT].GLJob j where j.JobName = g.JobName) as SchemaName
	from [AUDIT].GLRegionJobRun g
	where
		g.GLJobRunID = @GLJobRunID
end
go



if object_id('[AUDIT].[GLInsertJobRun]', 'P') is not null
	drop proc [AUDIT].[GLInsertJobRun]
go

create proc [AUDIT].GLInsertJobRun
	@RegionID varchar(25)
	,@JobName varchar(50)
	,@GLJobRunID int	
as
begin

declare @ids table (id int);
insert into [AUDIT].GLJobRun
(RegionID, JobName, JobStart, ETLDate, JobStatus)
output inserted.ID into @ids(ID)
values
(@RegionID, @JobName, getdate(), (select DATEADD(dd, DATEDIFF(dd,0,GETDATE()), 0)), 'Running');


update [AUDIT].GLRegionJobRun
set GLJobRunIDNew = (select id from @ids)
where GLJobRunID = @GLJobRunID;

select id from @ids
end
go


if object_id('[AUDIT].UpdateSourceTransactionMeasures', 'P') is not null
	drop proc [AUDIT].UpdateSourceTransactionMeasures
go

create proc [AUDIT].UpdateSourceTransactionMeasures
	@GLJobRunID int
	,@RowCount int
	,@TrxnAmount decimal(12, 2)
as
begin
update [AUDIT].GLJobRun
set
	SourceRowCount = @RowCount
	,SourceTransactionAmount = @TrxnAmount
where ID = @GLJobRunID
end
go




if object_id('[AUDIT].UpdateDestinationTransactionMeasures', 'P') is not null
	drop proc [AUDIT].UpdateDestinationTransactionMeasures
go

create proc [AUDIT].UpdateDestinationTransactionMeasures
	@GLJobRunID int
	,@MaxTransactionDate varchar(23)
	,@DestinationRowCount int
	,@DestinationTransactionAmount decimal(12, 2)
as
begin
	update [AUDIT].GLJobRun
	set
		MaxTransactionDate = convert(datetime, @MaxTransactionDate, 121)
		,DestinationRowCount = @DestinationRowCount
		,DestinationTransactionAmount = @DestinationTransactionAmount
	where
		ID = @GLJobRunID
end
go



if object_id('[AUDIT].UpdateGLJobRunJobStatusMaxDateError', 'P') is not null
	drop proc [AUDIT].UpdateGLJobRunJobStatusMaxDateError
go

create proc [AUDIT].UpdateGLJobRunJobStatusMaxDateError
	@GLJobRunID int
as
begin
	update [AUDIT].GLJobRun
	set
		JobStatus = 'Failure'
		,FailureReason = 'MaxTransactionDate not newer'
		,MaxTransactionDate = null
		,DestinationRowCount = null
		,DestinationTransactionAmount = null
		,JobEnd = getdate()
	where
		ID = @GLJobRunID
end
go



if object_id('[AUDIT].UpdateGLJobRunJobStatusSuccess', 'P') is not null
	drop proc [AUDIT].UpdateGLJobRunJobStatusSuccess
go

create proc [AUDIT].UpdateGLJobRunJobStatusSuccess
	@GLJobRunID int
as
begin
	set nocount on;
	declare @ZeroRowCount int;
	set @ZeroRowCount = (select count(*) from [AUDIT].GLJobRun where ID = @GLJobRunID and SourceRowCount = 0);

	update [AUDIT].GLJobRun
	set
		JobStatus = 'Failure'
		,FailureReason = 'No records to retrieve'
		,MaxTransactionDate = null
		,DestinationRowCount = null
		,DestinationTransactionAmount = null
		,JobEnd = getdate()
	where
		ID = @GLJobRunID
		and SourceRowCount = 0;
	
	update [AUDIT].GLJobRun
	set
		RowCountVariance = DestinationRowCount - SourceRowCount
		,TransactionAmountVariance = DestinationTransactionAmount - SourceTransactionAmount
	where
		ID = @GLJobRunID
		and SourceRowCount > 0;

	update [AUDIT].GLJobRun
	set
		JobStatus = case when RowCountVariance = 0 and TransactionAmountVariance = 0 then 'Success'
			else 'Failure'
			end
		,FailureReason = case when RowCountVariance <> 0 or TransactionAmountVariance <> 0 then 'ETL Record Variance'
			end
		,JobEnd = getdate()
	where
		ID = @GLJobRunID
		and SourceRowCount > 0;

	declare @JobStatus varchar(15);
	set @JobStatus = (select JobStatus from [AUDIT].GLJobRun where ID = @GLJobRunID);
	select @JobStatus, @ZeroRowCount	
end
go



if object_id('[AUDIT].UpdateGLJobRunJobStatusFailure', 'P') is not null
	drop proc [AUDIT].UpdateGLJobRunJobStatusFailure
go

create proc [AUDIT].UpdateGLJobRunJobStatusFailure
	@GLJobRunID int
	,@FailureReason varchar(75) = 'Mid Process Failure, Check Logs'
as
begin
	update [AUDIT].GLJobRun
	set
		JobStatus = 'Failure'
		,FailureReason =  @FailureReason
		,MaxTransactionDate = null
		,DestinationRowCount = null
		,DestinationTransactionAmount = null
		,JobEnd = getdate()
	where
		ID = @GLJobRunID		
end
go



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------








if object_id('[dbo].[AuditItemStage]', 'U') is not null 
	drop table [dbo].[AuditItemStage]
	go

CREATE TABLE [dbo].[AuditItemStage](
	[Id] [uniqueidentifier] NOT NULL,
	[Created] [datetime] NOT NULL,
	GLJobRunId int NOT NULL default 1
 )


if object_id('[AUDIT].[StgHostGLDetail_Delete]', 'P') is not null
	drop proc [AUDIT].[StgHostGLDetail_Delete]
go

create proc [AUDIT].[StgHostGLDetail_Delete]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)	
as
begin
	declare @RecordCount int;
	set @RecordCount = (
		select count(*)
		from ECW.StgHostGLDetail gld
		where gld.SourceServer = @RegionID
		and gld.ETLPackageName = @ETLPackageName
		and gld.SourceSystemCode = @SourceSystemCode
		);

	if @RecordCount > 0
		delete from ECW.StgHostGLDetail
		where SourceServer = @RegionID
		and ETLPackageName = @ETLPackageName
		and SourceSystemCode = @SourceSystemCode
end
GO


if object_id('[AUDIT].[StgHostGLDetail_FK_AuditItem_Drop]', 'P') is not null
	drop proc [AUDIT].[StgHostGLDetail_FK_AuditItem_Drop]
go

create procedure [AUDIT].[StgHostGLDetail_FK_AuditItem_Drop]
as
begin
	IF EXISTS
		(SELECT
			*
		 FROM sys.foreign_keys
		 WHERE
		 object_id = OBJECT_ID(N'[ECW].[FK_StgHostGLDetail_AuditItem]')
		 AND parent_object_id = OBJECT_ID(N'[ECW].[StgHostGLDetail]'))
		
		ALTER TABLE [ECW].[StgHostGLDetail] DROP CONSTRAINT [FK_StgHostGLDetail_AuditItem]
end
GO



if object_id('[AUDIT].[StgHostGLDetail_FK_AuditItem_Add]', 'P') is not null
	drop proc [AUDIT].[StgHostGLDetail_FK_AuditItem_Add]
go

create procedure [AUDIT].[StgHostGLDetail_FK_AuditItem_Add]
as
begin
	alter table [ECW].[StgHostGLDetail]
	add constraint [FK_StgHostGLDetail_AuditItem] FOREIGN KEY([AuditItemId]) REFERENCES [dbo].[AuditItem] ([Id])
end
GO



if object_id('[AUDIT].StgHostGLDetailTransactionMeasures', 'P') is not null
	drop proc [AUDIT].StgHostGLDetailTransactionMeasures
go

create proc [AUDIT].StgHostGLDetailTransactionMeasures
	@SourceSystemCode varchar(15)
	,@SourceServer varchar(25)
	,@ETLPackageName varchar(50)
as
begin
select
	left(convert(varchar, max(TransactionDate), 121), 23) as MaxTransactionDate
	,count(*) as RecordCount
	,cast(sum(TransactionAmount) as float) as TransactionAmount
from ECW.StgHostGLDetail
where
	SourceSystemCode = @SourceSystemCode
	and SourceServer = @SourceServer
	and ETLPackageName = @ETLPackageName
end
go




ALTER PROCEDURE [ECW].[HostGL_eCW_DAILYAR]
@StartRunDate DATETIME
, @ETLPackageName VARCHAR(50)
, @Account VARCHAR(6) 
  
AS 
begin
   DECLARE @EndRunDate DATETIME, 
		--@SourceServer VARCHAR(25), --5/10/2010 VAM - Removed for MultiRegionID modification
		@LastDay DATETIME
	SET @EndRunDate = (select DATEADD(dd, DATEDIFF(dd,0,GETDATE()), 0))
	--SET @SourceServer = (SELECT SUBSTRING(@@SERVERNAME, 1,25)) --5/10/2010 VAM - Removed for MultiRegion ID modification
	SELECT @LastDay = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEDIFF(dd,1,@EndRunDate))+1,0)))

SELECT  'eCW' AS 'SourceSystemCode' ,
		COALESCE(A.SourceServer, B.SourceServer) AS 'SourceServer' ,
		'0'AS 'SourceTransactionID' ,
		@EndRunDate AS 'ETLDate' ,
		@EndRunDate AS 'TransactionDate' ,
		'AR' AS 'SourceTrType' ,
		'AR' AS 'FamiliarTrType' ,
		@LastDay AS 'PostingPeriod' ,
		ISNULL(A.revenueAggAmount, 0) - ISNULL(B.nonrevenueAggAmount, 0) AS 'TransactionAmount' ,
		0 AS 'ExceptionRecordFlag' ,
		0 AS 'ExcludedCOID' ,
		NEWID() AS 'AuditItemId' ,  --uniqueidentifier
		@ETLPackageName AS 'ETLPackageName' ,
		COALESCE(A.SourceCOID, B.SourceCOID) AS 'SourceCOID' ,
		NULL AS 'CoMastCOID' ,
		NULL AS 'DepartmentCode' ,
		@Account AS 'Account' ,
		NULL AS 'SourceAccount' ,
        NULL AS 'InvoiceId' ,
        NULL AS 'EncounterId' ,
        NULL AS 'FacilityId' ,
        NULL AS 'FacilityName' ,
        NULL AS 'PracticeId' ,
        NULL AS 'ApptEncProviderId' ,
        NULL AS 'ApptEncProviderName' ,
        NULL AS 'InvServicingProviderId' ,
        NULL AS 'InvServicingProviderName' ,
        NULL AS 'PatientId' ,
        NULL AS 'PatientName' ,
        NULL AS 'PatientPrimaryInsurance' ,
        NULL AS 'PaymentID' ,
        NULL AS 'PaymentIDDeleted' ,
        NULL AS 'PaymentCode' ,
        NULL AS 'PaymentCodeDeleted' ,
        NULL AS 'PayerName' ,
        NULL AS 'PayerFinClassCode' ,
        NULL AS 'AdjustmentCode' ,
        NULL AS 'AdjustmentCodeDeleted' ,
        NULL AS 'SourceCOIDLookupPath' ,
        NULL AS 'SourceCPTHCPCS' ,
        NULL AS 'SourceCPTModifier' ,
        NULL AS 'PaymentRateCode' ,
        NULL AS 'AncillaryRate' ,
        NULL AS 'ProfessionalRate' ,
        NULL AS 'InvoiceVoidFlag' ,
        NULL AS 'InvoiceFinClassCode' ,
        NULL AS 'InvoicePOSCode' ,
        NULL AS 'Unapplied_ParentOrgID' ,
        NULL AS 'Unapplied_ParentOrgName' ,
        NULL AS 'Unapplied_InsPaymentId'  
FROM ECW.DailyAR_Revenue as A
	FULL OUTER JOIN ECW.DailyAR_NonRevenue As B
		ON A.SourceCOID = B.SourceCOID
		AND A.PostingPeriod = B.PostingPeriod  
    	AND A.SourceServer = B.SourceServer    
		AND A.SourceSystemCode = B.SourceSystemCode

end
go


ALTER PROCEDURE [ECW].[HostGL_eCW_REVENUE_EX]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)	
AS
begin
	UPDATE ECW.StgHostGLDetail
	SET ExceptionRecordFlag = 
		Case When
			SourceCOID IS NULL
			OR SourceCOID = 0
			OR CoMastCOID IS NULL
			OR Account IS NULL
			OR Account = '0'
			-------------------------------
			--Department Code is only an exception if it is used to generate the Account
			OR (LEN(SourceAccount) = 4 AND DepartmentCode IS NULL)
			OR (LEN(SourceAccount) = 4 AND LEN(LTRIM(RTRIM(DepartmentCode))) < 2)
			OR (LEN(SourceAccount) = 4 AND ISNUMERIC(DepartmentCode) = 0)
		Then 1
		Else 0
	END 
	where ETLPackageName = @ETLPackageName
	and SourceSystemCode = @SourceSystemCode
	and SourceServer = @RegionID;

--Below is logic to capture enterprisecoidmgt duplicate facility to practice assignment errors
	update g
	set
		g.ExceptionRecordFlag = 1
	from ECW.StgHostGLDetail g
		left join (--query with duplicates
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,AncillaryRate
				,ProfessionalRate
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName = @ETLPackageName
			and SourceSystemCode = @SourceSystemCode
			and SourceServer = @RegionID
			and ExceptionRecordFlag <> 1	  
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,AncillaryRate
				,ProfessionalRate
			having COUNT(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID
				and g.AncillaryRate = g1.AncillaryRate
				and g.ProfessionalRate = g1.ProfessionalRate
	where
		g.ETLPackageName = @ETLPackageName
		and ExceptionRecordFlag <> 1
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null
		and g1.AncillaryRate is not null
		and g1.ProfessionalRate is not null;
end
go




ALTER PROCEDURE [ECW].[HostGL_eCW_PAYMENTS_EX]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)	
AS 
BEGIN
    UPDATE  ECW.StgHostGLDetail
	SET ExceptionRecordFlag = 
	Case When
		SourceCOID IS NULL
		OR SourceCOID = 0
		OR CoMastCOID IS NULL
		OR Account IS NULL
		OR Account = '0'
        THEN 1
        ELSE 0
    END
    where ETLPackageName = @ETLPackageName
	and SourceSystemCode = @SourceSystemCode
	and SourceServer = @RegionID;
	
	--Below is logic to capture enterprisecoidmgt duplicate facility to practice assignment errors
	update g
	set
		g.ExceptionRecordFlag = 1
	from ECW.StgHostGLDetail g
		left join (
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName = @ETLPackageName
			and SourceSystemCode = @SourceSystemCode
			and SourceServer = @RegionID
			and ExceptionRecordFlag <> 1	  
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
			having COUNT(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID		
	where
		g.ETLPackageName = @ETLPackageName
		and ExceptionRecordFlag <> 1
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null;
END
go




ALTER PROCEDURE [ECW].[HostGL_eCW_CONTRACTUALWRITEOFF_EX]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)
AS
BEGIN

UPDATE ECW.StgHostGLDetail 
	SET ExceptionRecordFlag = 
		Case When
			SourceCOID IS NULL
			OR SourceCOID = 0
			OR CoMastCOID IS NULL
			OR Account IS NULL
			OR Account = '0'
			-------------------------------
			--Department Code is only an exception if it is used to generate the Account
			OR (LEN(SourceAccount) = 4 AND DepartmentCode IS NULL)
			OR (LEN(SourceAccount) = 4 AND LEN(LTRIM(RTRIM(DepartmentCode))) < 2)
			OR (LEN(SourceAccount) = 4 AND ISNUMERIC(DepartmentCode) = 0)
			-------------------------------
		Then 1
		Else 0
	END 
	where ETLPackageName = @ETLPackageName
	and SourceSystemCode = @SourceSystemCode
	and SourceServer = @RegionID;


--Below is logic to capture enterprisecoidmgt duplicate facility to practice assignment errors
	update g
	set
		g.ExceptionRecordFlag = 1
	from ECW.StgHostGLDetail g
		left join (
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName = @ETLPackageName
			and SourceSystemCode = @SourceSystemCode
			and SourceServer = @RegionID
			and ExceptionRecordFlag <> 1
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
			having COUNT(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID		
	where
		g.ETLPackageName = @ETLPackageName
		and ExceptionRecordFlag <> 1
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null;

END
GO




ALTER PROCEDURE [ECW].[HostGL_eCW_TRANSACTIONDUPLICATE_EX]	
AS
begin

UPDATE ECW.StgHostGLDetail
SET ExceptionRecordFlag = 1
from ECW.StgHostGLDetail g
	left join (
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,FamiliarTrType
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName not in (
				'HostGL_eCW_UNAPPLIEDPAYMENTS'
				,'HostGL_eCW_UNAPPLPAYMENTSREV'
				,'HostGL_eCW_MONTHLYARALLFIN'
				,'HostGL_eCW_MONTHLYARBYFIN'
				,'HostGL_eCW_DAILYAR'
				)			
			and SourceTrType <> 'Unapplied Payment'
			and FamiliarTrType Not Like 'MONTHLY%'
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,FamiliarTrType
			having count(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID
				and g.FamiliarTrType = g1.FamiliarTrType
	where
		g.ETLPackageName not in (
			'HostGL_eCW_UNAPPLIEDPAYMENTS'
			,'HostGL_eCW_UNAPPLPAYMENTSREV'
			,'HostGL_eCW_MONTHLYARALLFIN'
			,'HostGL_eCW_MONTHLYARBYFIN'
			,'HostGL_eCW_DAILYAR'
			)
		and g.SourceTrType <> 'Unapplied Payment'
		and g.FamiliarTrType Not Like 'MONTHLY%'		
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null
		and g1.FamiliarTrType is not null;

end
go





ALTER procedure [ECW].[HostGL_eCW_ADJUSTMENTS_EX]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)	
as
begin

	update ECW.StgHostGLDetail
	set ExceptionRecordFlag = 
		case when
			SourceCOID IS NULL
			OR SourceCOID = 0
			OR CoMastCOID IS NULL
			OR Account IS NULL
			OR Account = '0'
			-------------------------------
			--Department Code is only an exception if it is used to generate the Account
			OR (len(SourceAccount) = 4 AND DepartmentCode IS NULL)
			OR (len(SourceAccount) = 4 AND len(ltrim(rtrim(DepartmentCode))) < 2)
			OR (len(SourceAccount) = 4 AND isnumeric(DepartmentCode) = 0)
			-------------------------------
		then 1
		else 0
	end 
	where ETLPackageName = @ETLPackageName
	and SourceSystemCode = @SourceSystemCode
	and SourceServer = @RegionID;

	--Below is logic to capture enterprisecoidmgt duplicate facility to practice assignment errors
	update g
	set
		g.ExceptionRecordFlag = 1
	from ECW.StgHostGLDetail g
		left join (
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName = @ETLPackageName
			and SourceSystemCode = @SourceSystemCode
			and SourceServer = @RegionID
			and ExceptionRecordFlag <> 1	  
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
			having count(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID		
	where
		g.ETLPackageName = @ETLPackageName
		and ExceptionRecordFlag <> 1
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null;

end
go




if object_id('[AUDIT].AuditItemInsert', 'P') is not null
	drop proc [AUDIT].AuditItemInsert
go

create proc [AUDIT].AuditItemInsert
	@GLJobRunID int = 1
as
begin
	declare @rc int = 1;
	while @rc > 0
	begin
	begin transaction;
		insert into dbo.AuditItem
		(Id, Created)
		select top 10000
			s.Id
			,s.Created	
		from
			dbo.AuditItemStage as s
			where
				GLJobRunID = @GLJobRunID
				and not exists (
					select 1 from dbo.AuditItem a
					where a.Id = s.Id
				)
		order by Id;

	set @rc = @@ROWCOUNT;
	commit transaction;
	end
end
go


ALTER PROCEDURE [ECW].[HostGL_eCW_UNAPPLIEDPAYMENTS_EX]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)	
AS 
begin
	UPDATE ECW.StgHostGLDetail
	SET ExceptionRecordFlag = 
		Case When
			SourceCOID IS NULL
			OR SourceCOID = 0
			OR CoMastCOID IS NULL
			OR Account IS NULL
			OR Account = '0'
			THEN 1
			ELSE 0
		END
	where ETLPackageName = @ETLPackageName
	and SourceSystemCode = @SourceSystemCode
	and SourceServer = @RegionID;

	--Below is logic to capture enterprisecoidmgt duplicate facility to practice assignment errors
	update g
	set
		g.ExceptionRecordFlag = 1
	from ECW.StgHostGLDetail g
		left join (
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,Account
				,FamiliarTrType
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName = @ETLPackageName
			and SourceSystemCode = @SourceSystemCode
			and SourceServer = @RegionID
			and ExceptionRecordFlag <> 1	  
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,Account
				,FamiliarTrType
			having COUNT(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID
				and g.Account = g1.Account
				and g.FamiliarTrType = g1.FamiliarTrType
	where
		g.ETLPackageName = @ETLPackageName
		and ExceptionRecordFlag <> 1
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null
		and g1.Account is not null
		and g1.FamiliarTrType is not null;
end
go


ALTER PROCEDURE [ECW].[HostGL_eCW_UNAPPLPAYMENTSREV_EX]	
	@ETLPackageName varchar(75)	
AS 
begin
	UPDATE ECW.StgHostGLDetail
	SET ExceptionRecordFlag = 
		Case When
			SourceCOID IS NULL
			OR SourceCOID = 0
			OR CoMastCOID IS NULL
			OR Account IS NULL
			OR Account = '0'
			THEN 1
			ELSE 0
		END
	where ETLPackageName = @ETLPackageName

	--Below is logic to capture enterprisecoidmgt duplicate facility to practice assignment errors
	update g
	set
		g.ExceptionRecordFlag = 1
	from ECW.StgHostGLDetail g
		left join (
			select	
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,Account
				,FamiliarTrType
			from ECW.StgHostGLDetail with(nolock)
			where ETLPackageName = @ETLPackageName
			and ExceptionRecordFlag <> 1	  
			group by
				SourceSystemCode
				,SourceServer
				,SourceTransactionID
				,Account
				,FamiliarTrType
			having COUNT(*) > 1
			) g1
				on g.SourceSystemCode = g1.SourceSystemCode
				and g.SourceServer = g1.SourceServer
				and g.SourceTransactionID = g1.SourceTransactionID
				and g.Account = g1.Account
				and g.FamiliarTrType = g1.FamiliarTrType
	where
		g.ETLPackageName = @ETLPackageName
		and ExceptionRecordFlag <> 1
		and g1.SourceSystemCode is not null
		and g1.SourceServer is not null
		and g1.SourceTransactionID is not null
		and g1.Account is not null
		and g1.FamiliarTrType is not null;
end
go


if object_id('[AUDIT].[StgHostGLDetail_LoadErrorInsert]', 'P') is not null
	drop proc [AUDIT].[StgHostGLDetail_LoadErrorInsert]
go

create proc [AUDIT].[StgHostGLDetail_LoadErrorInsert]
	@RegionID varchar(25)
	,@ETLPackageName varchar(75)
	,@SourceSystemCode varchar(15)	
as
begin
	insert into ecw.StgHostGLDetail_LoadErrors
	select *
	from ECW.StgHostGLDetail
	where SourceServer = @RegionID
	and ETLPackageName = @ETLPackageName
	and SourceSystemCode = @SourceSystemCode
end
go



if object_id('AUDIT.Epic_FifthThird_Instance', 'U') is not null 
	drop table [AUDIT].Epic_FifthThird_Instance
	go

create table [AUDIT].Epic_FifthThird_Instance (
	InstanceID int primary key identity(1, 1) not null
	,Instance varchar(15) not null
	,Active bit default 1
	constraint UC_Instance unique (Instance)
);

insert into [AUDIT].Epic_FifthThird_Instance
(Instance)
values 
	('Epic53CWT')
	,('Epic53MTN')
	,('Epic53SAV')


