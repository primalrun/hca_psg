--Update datetime variable @MaxModifiedDate

use [ecwStage]
go

set ansi_nulls on
go

set quoted_identifier on
go


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
	,FailureReason varchar(75) null
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

declare @MaxModifiedDate datetime = '20190121';





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
				(select ID from [AUDIT].GLJobRun g where g.RegionID = q1.RegionID and g.JobName = q1.JobName and g.MaxTransactionDate = q1.MaxTransactionDAte) as ID
				,q1.RegionID
				,q1.JobName
				,q1.MaxTransactionDate	
			from (
			select	
				RegionID
				,JobName
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
		select RegionID, JobName, ntile(4) over(order by RegionID) as JobRunID
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
	,@MaxTransactionDate varchar(25)
	,@DestinationRowCount int
	,@DestinationTransactionAmount decimal(12, 2)
as
begin
	update [AUDIT].GLJobRun
	set
		MaxTransactionDate = convert(datetime, @MaxTransactionDate, 120)
		,DestinationRowCount = @DestinationRowCount
		,DestinationTransactionAmount = @DestinationTransactionAmount
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





if object_id('ecwStage.HostGL_GetTransaction', 'P') is not null
	drop proc ecwStage.HostGL_GetTransaction
go

create proc ecwStage.HostGL_GetTransaction
	@GLJobRunID int
as
begin
	set nocount on;
	declare @SprocSchema varchar(25);
	declare @JobName varchar(50);
	declare @SQL varchar(100);

	declare @Trxn table (
		[SourceSystemCode] [varchar](15) NOT NULL,
		[SourceServer] [varchar](25) NOT NULL,
		[SourceTransactionID] [int] NOT NULL,
		[ETLDate] [datetime] NOT NULL,
		[TransactionDate] [datetime] NOT NULL,
		[SourceTrType] [varchar](50) NULL,
		[FamiliarTrType] [varchar](50) NULL,
		[PostingPeriod] [date] NOT NULL,
		[TransactionAmount] [money] NOT NULL,
		[ExceptionRecordFlag] [bit] NULL,
		[ExcludedCOID] [bit] NOT NULL,
		[AuditItemId] [uniqueidentifier] NOT NULL,
		[ETLPackageName] [varchar](50) NOT NULL,
		[SourceCOID] [char](8) NULL,
		[CoMastCOID] [char](8) NULL,
		[DepartmentCode] [char](8) NULL,
		[Account] [char](6) NULL,
		[SourceAccount] [char](6) NULL,
		[InvoiceID] [int] NULL,
		[EncounterID] [int] NULL,
		[FacilityID] [int] NULL,
		[FacilityName] [varchar](75) NULL,
		[PracticeID] [int] NULL,
		[ApptEncProviderID] [int] NULL,
		[ApptEncProviderName] [varchar](50) NULL,
		[InvServicingProviderID] [int] NULL,
		[InvServicingProviderName] [varchar](50) NULL,
		[PatientID] [int] NULL,
		[PatientName] [varchar](50) NULL,
		[PatientPrimaryInsurance] [varchar](40) NULL,
		[PaymentID] [int] NULL,
		[PaymentIDDeleted] [bit] NULL,
		[PaymentCode] [char](5) NULL,
		[PaymentCodeDeleted] [bit] NULL,
		[PayerName] [varchar](40) NULL,
		[PayerFinClassCode] [char](2) NULL,
		[AdjustmentCode] [char](5) NULL,
		[AdjustmentCodeDeleted] [bit] NULL,
		[SourceCOIDLookupPath] [varchar](25) NULL,
		[SourceCPTHCPCS] [char](5) NULL,
		[SourceCPTModifier] [char](2) NULL,
		[PaymentRateCode] [char](2) NULL,
		[AncillaryRate] [decimal](10, 7) NULL,
		[ProfessionalRate] [decimal](10, 7) NULL,
		[InvoiceFinClassCode] [char](2) NULL,
		[InvoicePOSCode] [smallint] NULL,
		[Unapplied_ParentOrgID] [int] NULL,
		[Unapplied_ParentOrgName] [varchar](50) NULL,
		[Unapplied_InsPaymentID] [int] NULL,
		[InvoiceVoidFlag] [tinyint] NULL	
	)

	set @JobName = (select
		JobName
	from [AUDIT].GLRegionJobRun
	where
		GLJobRunID = @GLJobRunID);

	set @SprocSchema = (select
		SchemaName
	from [AUDIT].GLJob
	where
		JobName = @JobName);

	set @SQL = 'exec ' + @SprocSchema + '.' + @JobName + ' ' + cast(@GLJobRunID as varchar(10)) + '';

	insert @Trxn
	exec(@SQL)
	
	select * from @Trxn

end
go



IF OBJECT_ID('[ecwStage].[HostGL_eCW_ADJUSTMENTS]', 'P') IS NOT NULL
	DROP PROC [ecwStage].[HostGL_eCW_ADJUSTMENTS]
GO

CREATE PROC [ecwStage].[HostGL_eCW_ADJUSTMENTS]
	@GLJobRunID int
	,@print_sql char(1) = 'n'
AS
BEGIN

/********************************************************************************************
Procedure: [ecwStage].[HostGL_eCW_ADJUSTMENTS]

Parameters: @GLJobRunID  INT    -- Record ID in table eCWStage.[AUDIT].GLRegionJobRun to reference for needed variables
			@print_sql char     -- argument to print sql statement rather than execute, default to 'n', enter 'y' for print

exOriginal Developer:	 

Original Purpose:	To extract eCW Adjustments
					
Original Date:		 

Unit Test/Execution Example:
	exec [ecwStage].[HostGL_eCW_ADJUSTMENTS] 1
	(to execute sql statement)
	or 
	exec [ecwStage].[HostGL_eCW_ADJUSTMENTS] 1, 'y'
	(to print sql statement instead of executing it)
Modification:
Date			Developer		Modification						
---------		---------		--------------------------------------------------
5/10/2010		VAM				Modified for MultiRegion changes
10/07/2010		ESH				Added code to null out bad COID 
12/06/2010		ESH				Changed RenProviderID to DOSProviderID, 
								changed output columns to InvServicingProviderID and InsServicingProviderName
9/12/2011		VAM				Added Exclusion in Where Clause for TrTypes of 24 Charity & 25 Uninsured, they are ContractualWriteoffs								
4/19/2012		BBA				Added @StartRunDate_R03, @EndRunDate_R03 for region 3 filter in Where Clause, region 3 is on Mountain time (-1hr) and rows entered between 11PM-12AM							  were not getting posted to the GL 
1/16/2019		JMW				Modified for Region Split
*********************************************************************************************/
SET NOCOUNT ON;
DECLARE @ServerName VARCHAR(256);
DECLARE @RegionID VARCHAR(25);
DECLARE @StartRunDate DATETIME;
DECLARE @DatabaseName VARCHAR(50);;
DECLARE @SQL1 VARCHAR(8000);
DECLARE @SQL2 VARCHAR(8000);	
DECLARE @SQL3 VARCHAR(8000);	
SET @RegionID = (select RegionID from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @StartRunDate = (select MaxTransactionDate from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @ServerName = (select ServerName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @DatabaseName = (select DatabaseName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);

SET @SQL1 = '
DECLARE @ETLPackageName VARCHAR(50);
DECLARE @EndRunDate DATETIME; 
DECLARE	@LastDay DATETIME;
DECLARE @StartRunDate_R03 DATETIME;
DECLARE @EndRunDate_R03 DATETIME;
SET @ETLPackageName = (select JobName from ' + @ServerName + '.eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = ' + CAST(@GLJobRunID AS VARCHAR(10)) + ');
SET @EndRunDate = dateadd(day, datediff(day, 0, getdate()), 0);
SELECT @LastDay = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEDIFF(dd,1,@EndRunDate))+1,0)));
SELECT @StartRunDate_R03 = DATEADD(hh,-1,''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''');
SELECT @EndRunDate_R03 = DATEADD(hh,-1,@EndRunDate) ';

SET @SQL2 = '	
SELECT
	''eCW'' AS SourceSystemCode
	, ''' + @RegionID + ''' AS SourceServer --5/10/2010 VAM - Modified for MultiRegion changes
	, T.id AS SourceTransactionID
	, @EndRunDate AS ETLDate
	, T.modifieddate AS TransactionDate
	, T.trtype AS SourceTrType
	, Case When Adj.Id Is Not Null Then AdjTrType.TrType
		When DelAdj.Id Is Not Null Then DelAdjTrType.TrType
		Else Null
		End AS FamiliarTrType
	, @LastDay AS PostingPeriod
	, T.amount AS TransactionAmount
	, NULL AS ExceptionRecordFlag
	, Case
		When AdjExc.COID Is Not Null AND AdjExc.[Enabled] = 1 Then 1
		When DelAdjExc.COID Is Not Null AND DelAdjExc.[Enabled] = 1 Then 1
		Else 0
		END AS ExcludedCOID
	, NEWID() AS AuditItemId --uniqueidentifier
	, @ETLPackageName As ETLPackageName
----------------------------------------
	, SUBSTRING(Case 
		When AdjEnt.COID Is Not Null Then AdjEnt.COID 
		When DelAdjEnt.COID Is Not Null Then DelAdjEnt.COID
		Else NULL
		END, 1, 8) AS SourceCOID
	, SUBSTRING(Case 
		When AdjEnt.COID Is Not Null Then AdjCoMast.COID 
		When DelAdjEnt.COID Is Not Null Then DelAdjCoMast.COID
		Else NULL
		END, 1, 8) AS CoMastCOID
	, SUBSTRING(Case 
		When AdjEnt.COID Is Not Null Then AdjEnt.DeptCode 
		When DelAdjEnt.COID Is Not Null Then DelAdjEnt.DeptCode
		Else NULL
		END, 1, 8) AS DepartmentCode
	, CAST(CASE 
		WHEN AdjInv.Id is not null 
				THEN 
					CASE WHEN LEN(AdjAcctX.Account) = 4 
						THEN LTRIM(RTRIM(AdjAcctX.Account)) + RIGHT(Cast(AdjEnt.DeptCode AS VarChar), 2)
						ELSE AdjAcctX.Account
					END
		WHEN DelAdjInv.Id is not null 
				THEN CASE WHEN LEN(DelAdjAcctX.Account) = 4
						THEN LTRIM(RTRIM(DelAdjAcctX.Account)) + RIGHT(Cast(DelAdjEnt.DeptCode AS VarChar), 2)
						ELSE DelAdjAcctX.Account
					END
		ELSE NULL
		END AS VARCHAR(6)) AS Account
	, Case when AdjInv.Id is not null then LTRIM(RTRIM(AdjAcctX.Account))
		When DelAdjInv.Id is not null then LTRIM(RTRIM(DelAdjAcctX.Account))
		Else NULL
		End As SourceAccount	
	, Case when AdjInv.Id is not null then AdjInv.Id
		When DelAdjInv.Id is not null then DelAdjInv.Id
		Else NULL
		End As InvoiceId
	, Case when AdjInv.Id is not null then AdjInv.EncounterId
		When DelAdjInv.Id is not null then DelAdjInv.EncounterId
		Else NULL
		End As EncounterId
	, Case when Adj.Id is not null then Fac.Id
		When DelAdj.Id is not null then DelFac.Id
		Else NULL
		End As FacilityId
	, Case when Adj.Id is not null then Fac.Name
		When DelAdj.Id is not null then DelFac.Name
		Else NULL
		End As FacilityName
	, Case when AdjInv.Id is not null then AdjInv.PracticeId
		When DelAdjInv.Id is not null then DelAdjInv.PracticeId
		Else NULL
		End As PracticeId
	, Case when AdjInv.Id is not null then Adj_U_EncProvider.uid
		When DelAdjInv.Id is not null then DelAdj_U_EncProvider.uid
		Else NULL
		End As ApptEncProviderId --Int
	, SUBSTRING(Case when AdjInv.Id is not null 
		then Adj_U_EncProvider.ulname + '', '' + Adj_U_EncProvider.ufname
		When DelAdjInv.Id is not null 
		then DelAdj_U_EncProvider.ulname + '', '' + DelAdj_U_EncProvider.ufname
		Else NULL
		End, 1, 50) As ApptEncProviderName --varchar (50)
	, Case when AdjInv.Id is not null then Adj_U_Provider.uid
		When DelAdjInv.Id is not null then DelAdj_U_Provider.uid
		Else NULL
		End As InvServicingProviderId --Int
	, SUBSTRING(Case when AdjInv.Id is not null 
		then Adj_U_Provider.ulname + '', '' + Adj_U_Provider.ufname
		When DelAdjInv.Id is not null 
		then DelAdj_U_Provider.ulname + '', '' + DelAdj_U_Provider.ufname
		Else NULL
		End, 1, 50) As InvServicingProviderName --varchar (50)
	, Case when AdjInv.Id is not null then Adj_U_Patient.uid
		When DelAdjInv.Id is not null then DelAdj_U_Patient.uid
		Else NULL
		End As PatientId --Int
	, SUBSTRING(Case when AdjInv.Id is not null 
		then Adj_U_Patient.ulname + '', '' + Adj_U_Patient.ufname
		When DelAdjInv.Id is not null 
		then DelAdj_U_Patient.ulname + '', '' + DelAdj_U_Patient.ufname
		Else NULL
		End, 1, 50) As PatientName --varchar (50)
	, CAST(Case when AdjInv.Id is not null then AdjIns.InsuranceName 
		When DelAdjInv.Id is not null then DelAdjIns.InsuranceName
		Else NULL
		End AS VARCHAR(40)) As PatientPrimaryInsurance	--varchar(40)
----------------------------------------
	, NULL As PaymentID --[int]
	, NULL As PaymentIDDeleted -- [bit]
	, NULL As PaymentCode --char(5)
	, NULL As PaymentCodeDeleted --bit
	, NULL As PayerName --varchar (40)
	, NULL As PayerFinClassCode --char(2)
	, SUBSTRING(case when Adj.Id is not null then Adj.code
		When DelAdj.Id is not null then DelAdj.code
		Else NULL
		End, 1, 5) As AdjustmentCode --char (5)
	, case when AdjInv.Id is not null then 0
		When DelAdjInv.Id is not null then 1
		Else NULL
		End As AdjustmentCodeDeleted --bit
	, Case when AdjInv.Id is not null then ''AdjustmentPath''
		When DelAdjInv.Id is not null then ''DeletedAdjustmentPath''
		Else NULL
		End As SourceCOIDLookupPath --varchar(25)
	, NULL As SourceCPTHCPCS -- [char] (5)
	, NULL As SourceCPTModifier -- [char] (2)
	, NULL As PaymentRateCode -- [char] (2)
	, NULL As AncillaryRate --[decimal] (10, 7)
	, NULL As ProfessionalRate -- [decimal] (10, 7)
	, CASE WHEN AdjInv.Id is not null THEN AdjInv.VoidFlag
		WHEN DelAdjInv.Id is not null THEN DelAdjInv.VoidFlag
		ELSE NULL
		END AS InvoiceVoidFlag --tinyint
	, CAST(Case when AdjInv.Id is not null then AdjInvIns.InsuranceClass
		When DelAdjInv.Id is not null then DelAdjInvIns.InsuranceClass
		Else NULL
		END AS CHAR(2)) As InvoiceFinClassCode  --char(2) 
	, Case when AdjInv.Id is not null then AdjInv.InvPOS
		When DelAdjInv.Id is not null then DelAdjInv.InvPOS
		Else NULL
		End As InvoicePOSCode --[smallint]
	, NULL As Unapplied_ParentOrgID -- [int]
	, NULL As Unapplied_ParentOrgName-- [varchar] (50)
	, NULL As Unapplied_InsPaymentId --[int] ';


SET @SQL3 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions as t
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_adjustments AS Adj
		ON t.trrefid = Adj.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS AdjInv
		ON Adj.InvId = AdjInv.Id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS AdjEnt
		ON AdjInv.invfacilityid = AdjEnt.facilityid
		AND AdjInv.dosproviderid = AdjEnt.providerid --ESH Changed 12/6 for Rendering to Servicing		
			--and AdjInv.PracticeId = AdjEnt.practiceid
	LEFT JOIN  ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS AdjCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(AdjEnt.COID))) = 1   ) AND (LEN(AdjEnt.COID) <= 5)    
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(AdjEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = AdjCoMast.COID
	LEFT JOIN ' + @ServerName + '. ecwstage.ecwstage.StgHostGLCOIDExclusion AS AdjExc
		ON AdjEnt.COID = AdjExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as Fac
		ON AdjInv.invfacilityid = Fac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As AdjEnc
		ON AdjInv.encounterid = AdjEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Adj_U_Patient
		ON Adj_U_Patient.uid = AdjInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Adj_U_Provider
		ON Adj_U_Provider.uid = AdjInv.DOSProviderID --ESH Changed 12/6 for Rendering to Servicing		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Adj_U_EncProvider
		ON Adj_U_EncProvider.uid = AdjEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLAdjCodeXwalk As AdjAdjX
		ON Adj.code = AdjAdjX.adjcode
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLAcctXwalk AS AdjAcctX
		ON AdjAdjX.TrtypeID = AdjAcctX.TrtypeID
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLTrTypeList As AdjTrType
		ON AdjAdjX.TrTypeId = AdjTrType.TrTypeId
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS AdjInsDet
		ON AdjInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = Adj_U_Patient.[uid]										
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS AdjIns
		ON AdjInsDet.[insid] = AdjIns.[insId]		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS AdjInvIns
		ON AdjInv.PrimaryInsId = AdjInvIns.[insId]		
-----------------------------------------------------------------
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_deleted_adj AS DelAdj
		ON t.trrefid = deladj.refid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS DelAdjInv
		ON DelAdj.InvId = DelAdjInv.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS DelAdjEnt
		ON DelAdjInv.invfacilityid = DelAdjEnt.facilityid
		AND DelAdjInv.Dosproviderid = DelAdjEnt.providerid --ESH Changed 12/6 for Rendering to Servicing		
			--and DelAdjInv.PracticeId = DelAdjEnt.practiceid
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS DelAdjCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(DelAdjEnt.COID))) = 1   ) AND (LEN(DelAdjEnt.COID) <= 5)    
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(DelAdjEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = DelAdjCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS DelAdjExc
		ON DelAdjEnt.COID = DelAdjExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as DelFac
		ON DelAdjInv.invfacilityid = DelFac.id		
	left outer join ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As DelAdjEnc
		ON DelAdjInv.encounterid = DelAdjEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS DelAdj_U_Patient
		ON DelAdj_U_Patient.uid = DelAdjInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS DelAdj_U_Provider
		ON DelAdj_U_Provider.uid = DelAdjInv.DOSProviderID --ESH Changed 12/6 for Rendering to Servicing		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS DelAdj_U_EncProvider
		ON DelAdj_U_EncProvider.uid = DelAdjEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLAdjCodeXwalk As DelAdjAdjX
		ON DelAdj.code = DelAdjAdjX.adjcode
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLAcctXwalk AS DelAdjAcctX
		ON DelAdjAdjX.TrtypeID = DelAdjAcctX.TrtypeID
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLTrTypeList As DelAdjTrType
		ON DelAdjAdjX.TrTypeId = DelAdjTrType.TrTypeId
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS DelAdjInsDet
		ON DelAdjInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = DelAdj_U_Patient.[uid]											
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelAdjIns
		ON DelAdjInsDet.[insid] = DelAdjIns.[insId]		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelAdjInvIns
		ON DelAdjInv.PrimaryInsId = DelAdjInvIns.[insId]		
----------------------------------------------------------
WHERE (
	(' + @RegionID + ' <> 3 AND t.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t.modifieddate < @EndRunDate)
	OR
	(' + @RegionID + ' = 3 AND t.modifiedDate > @StartRunDate_R03 AND t.modifiedDate < @EndRunDate_R03)
	)	
	AND (AdjTrType.TrTypeId NOT IN (8, 24, 25, 27) OR DelAdjTrType.TrTypeId NOT IN (8, 24, 25, 27)) --8/26/2013 JEW added 27
	AND t.trtype = ''adjustments'' ';

IF @print_sql = 'y'
	BEGIN
		PRINT @SQL1; 
		PRINT @SQL2;
		PRINT @SQL3;
	END
ELSE
	BEGIN
		EXEC(@SQL1 + @SQL2 + @SQL3);
	END

END
GO




IF OBJECT_ID('[ecwStage].[HostGL_eCW_CONTRACTUALWRITEOFF]', 'P') IS NOT NULL
	DROP PROC [ecwStage].[HostGL_eCW_CONTRACTUALWRITEOFF]
GO

CREATE PROC [ecwStage].[HostGL_eCW_CONTRACTUALWRITEOFF]
	@GLJobRunID int
	,@print_sql char(1) = 'n'
AS
BEGIN

/********************************************************************************************
Procedure: [ecwStage].[HostGL_eCW_CONTRACTUALWRITEOFF]

Parameters: @GLJobRunID  INT    -- Record ID in table eCWStage.[AUDIT].GLRegionJobRun to reference for needed variables
			@print_sql char     -- argument to print sql statement rather than execute, default to 'n', enter 'y' for print

Original Developer:	 

Original Purpose:	To extract eCW Contractual write off
					
Original Date:		 

Unit Test/Execution Example:
	exec [ecwStage].[HostGL_eCW_CONTRACTUALWRITEOFF] 1
	(to execute sql statement)
	or 
	exec [ecwStage].[HostGL_eCW_CONTRACTUALWRITEOFF] 1, 'y'
	(to print sql statement instead of executing it)

Modification:
Date			Developer		Modification						
---------		---------		--------------------------------------------------
5/10/2010		VAM				Modified for MultiRegion changes
10/07/2010		ESH				Added code to null out bad COID 
10/08/2010		ESH				Added code to make sure a character type FIN class will pass through cleanly
								By putting '' around 99 in the coallesce. 
12/06/2010		ESH				Changed RenProviderID to DOSProviderID, 
								changed output columns to InvServicingProviderID and InsServicingProviderName
9/12/2011		VAM				Bug fix on Company Master Join
								Additional Conditional Logic for Charity and Uninsured Account Transaction Types
4/19/2012		BBA				Added @StartRunDate_R03, @EndRunDate_R03 for region 3 filter in Where Clause, region 3 is on Mountain time (-1hr) and rows entered between 11PM-12AM were not getting posted to the GL 
8/26/2013		JEW				v10 - added 3381 for Withhold
7/2/2014		JEW				v11 - modified to pull Prim Ins from edi_inv_insurance (previously pulled from edi_invoice.PrimaryInsID)
7/15/2015		JEW				v12 - removed hardcoded enddate that accidentally was left in the query
1/16/2019		JMW				Modified for Region Split
*********************************************************************************************/
SET NOCOUNT ON;
DECLARE @ServerName VARCHAR(256);
DECLARE @RegionID VARCHAR(25);
DECLARE @StartRunDate DATETIME;
DECLARE @DatabaseName VARCHAR(50);;
DECLARE @SQL1 VARCHAR(8000);
DECLARE @SQL2 VARCHAR(8000);	
DECLARE @SQL3 VARCHAR(8000);	
DECLARE @SQL4 VARCHAR(8000);
DECLARE @SQL5 VARCHAR(8000);	
DECLARE @SQL6 VARCHAR(8000);
DECLARE @SQL7 VARCHAR(8000);
SET @RegionID = (select RegionID from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @StartRunDate = (select MaxTransactionDate from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @ServerName = (select ServerName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @DatabaseName = (select DatabaseName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);

SET @SQL1 = '
DECLARE @ETLPackageName VARCHAR(50);
DECLARE @EndRunDate DATETIME; 
DECLARE	@LastDay DATETIME;
DECLARE @StartRunDate_R03 DATETIME;
DECLARE @EndRunDate_R03 DATETIME;
SET @ETLPackageName = (select JobName from ' + @ServerName + '.eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = ' + CAST(@GLJobRunID AS VARCHAR(10)) + ');
SET @EndRunDate = dateadd(day, datediff(day, 0, getdate()), 0);
SELECT @LastDay = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEDIFF(dd,1,@EndRunDate))+1,0)));
SELECT @StartRunDate_R03 = DATEADD(hh,-1,''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''');
SELECT @EndRunDate_R03 = DATEADD(hh,-1,@EndRunDate) ';


SET @SQL2 = '
SELECT
	''eCW'' AS SourceSystemCode
	, ''' + @RegionID + ''' AS SourceServer
	, T.id AS SourceTransactionID
	, @EndRunDate AS ETLDate
	, T.modifieddate AS TransactionDate
	, T.trtype AS SourceTrType
	, Case When Adj.Id Is Not Null Then AdjTrType.TrType
		When DelAdj.Id Is Not Null Then DelAdjTrType.TrType
		Else Null
		End AS FamiliarTrType
	, @LastDay AS PostingPeriod
	, T.amount AS TransactionAmount
	, NULL AS ExceptionRecordFlag
	, Case
		When AdjExc.COID Is Not Null AND AdjExc.[Enabled] = 1 Then 1
		When DelAdjExc.COID Is Not Null AND DelAdjExc.[Enabled] = 1 Then 1
		Else 0
		END AS ExcludedCOID
	, NEWID() AS AuditItemId --uniqueidentifier
	, @ETLPackageName As ETLPackageName
----------------------------------------
	, SUBSTRING(Case 
		When AdjEnt.COID Is Not Null Then AdjEnt.COID 
		When DelAdjEnt.COID Is Not Null Then DelAdjEnt.COID
		Else NULL
		END, 1, 8) AS SourceCOID
	, SUBSTRING(Case 
		When AdjEnt.COID Is Not Null Then AdjCoMast.COID 
		When DelAdjEnt.COID Is Not Null Then DelAdjCoMast.COID
		Else NULL
		END, 1, 8) AS CoMastCOID
	, SUBSTRING(Case 
		When AdjEnt.COID Is Not Null Then AdjEnt.DeptCode 
		When DelAdjEnt.COID Is Not Null Then DelAdjEnt.DeptCode
		Else NULL
		END, 1, 8) AS DepartmentCode
	, CAST(CASE 
		WHEN AdjInv.Id is not null 
				THEN 
					CASE WHEN LEN(AdjAcctX.Account) = 4 
						THEN LTRIM(RTRIM(AdjAcctX.Account)) + RIGHT(Cast(AdjEnt.DeptCode AS VarChar), 2)
						ELSE AdjAcctX.Account
					END
		WHEN DelAdjInv.Id is not null 
				THEN CASE WHEN LEN(DelAdjAcctX.Account) = 4
						THEN LTRIM(RTRIM(DelAdjAcctX.Account)) + RIGHT(Cast(DelAdjEnt.DeptCode AS VarChar), 2)
						ELSE DelAdjAcctX.Account
					END
		ELSE NULL
		End AS VarChar(6)) AS Account
	, Case when AdjInv.Id is not null then LTRIM(RTRIM(AdjAcctX.Account))
		When DelAdjInv.Id is not null then LTRIM(RTRIM(DelAdjAcctX.Account))
		Else NULL
		End As SourceAccount
	, Case when AdjInv.Id is not null then AdjInv.Id
		When DelAdjInv.Id is not null then DelAdjInv.Id
		Else NULL
		End As InvoiceId
	, Case when AdjInv.Id is not null then AdjInv.EncounterId
		When DelAdjInv.Id is not null then DelAdjInv.EncounterId
		Else NULL
		End As EncounterId
	, Case when Adj.Id is not null then Fac.Id
		When DelAdj.Id is not null then DelFac.Id
		Else NULL
		End As FacilityId
	, Case when Adj.Id is not null then Fac.Name
		When DelAdj.Id is not null then DelFac.Name
		Else NULL
		End As FacilityName
	, Case when AdjInv.Id is not null then AdjInv.PracticeId
		When DelAdjInv.Id is not null then DelAdjInv.PracticeId
		Else NULL
		End As PracticeId
	, Case when AdjInv.Id is not null then Adj_U_EncProvider.uid
		When DelAdjInv.Id is not null then DelAdj_U_EncProvider.uid
		Else NULL
		End As ApptEncProviderId --Int
	, SUBSTRING(Case when AdjInv.Id is not null 
		then Adj_U_EncProvider.ulname + '', '' + Adj_U_EncProvider.ufname
		When DelAdjInv.Id is not null 
		then DelAdj_U_EncProvider.ulname + '', '' + DelAdj_U_EncProvider.ufname
		Else NULL
		End, 1, 50) As ApptEncProviderName --varchar (50)
	, Case when AdjInv.Id is not null then Adj_U_Provider.uid
		When DelAdjInv.Id is not null then DelAdj_U_Provider.uid
		Else NULL
		End As InvServicingProviderId --Int
	, SUBSTRING(Case when AdjInv.Id is not null 
		then Adj_U_Provider.ulname + '', '' + Adj_U_Provider.ufname
		When DelAdjInv.Id is not null 
		then DelAdj_U_Provider.ulname + '', '' + DelAdj_U_Provider.ufname
		Else NULL
		End, 1, 50) As InvServicingProviderName --varchar (50)
	, Case when AdjInv.Id is not null then Adj_U_Patient.uid
		When DelAdjInv.Id is not null then DelAdj_U_Patient.uid
		Else NULL
		End As PatientId --Int
	, SUBSTRING(Case when AdjInv.Id is not null 
		then Adj_U_Patient.ulname + '', '' + Adj_U_Patient.ufname
		When DelAdjInv.Id is not null 
		then DelAdj_U_Patient.ulname + '', '' + DelAdj_U_Patient.ufname
		Else NULL
		End, 1, 50) As PatientName --varchar (50)
	, CAST(Case when AdjInv.Id is not null then AdjIns.InsuranceName + '' / '' +AdjIns.insuranceclass
		When DelAdjInv.Id is not null then DelAdjIns.InsuranceName  + '' / ''  + DelAdjIns.insuranceclass
		Else NULL
		End AS VarChar(40)) As PatientPrimaryInsurance	--varchar(40)
	----------------------------------------
	, NULL As PaymentID --[int]
	, NULL As PaymentIDDeleted -- [bit]
	, NULL As PaymentCode --char(5)
	, NULL As PaymentCodeDeleted --bit
	, NULL As PayerName --varchar (40)
	, NULL As PayerFinClassCode --char(2)
	, SUBSTRING(case when Adj.Id is not null then Adj.code
		When DelAdj.Id is not null then DelAdj.code
		Else NULL
		End, 1, 5) As AdjustmentCode --char (5)
	, case when AdjInv.Id is not null then 0
		When DelAdjInv.Id is not null then 1
		Else NULL
		End As AdjustmentCodeDeleted --bit
	, Case when AdjInv.Id is not null then ''ContractualAdjPath'' --Ins.InsuranceName 
		When DelAdjInv.Id is not null then ''DeletedContractualAdjPath'' --Ins.InsuranceName
		Else NULL
		End As SourceCOIDLookupPath --varchar(25)
	, NULL As SourceCPTHCPCS -- [char] (5)
	, NULL As SourceCPTModifier -- [char] (2)
	, NULL As PaymentRateCode -- [char] (2)
	, NULL As AncillaryRate --[decimal] (10, 7)
	, NULL As ProfessionalRate -- [decimal] (10, 7)
	, CASE WHEN AdjInv.Id is not null THEN AdjInv.VoidFlag
		WHEN DelAdjInv.Id is not null THEN DelAdjInv.VoidFlag
		ELSE NULL
		END AS InvoiceVoidFlag --tinyint
	, CAST(Case when AdjInv.Id is not null then AdjInvIns.InsuranceClass
		When DelAdjInv.Id is not null then DelAdjInvIns.InsuranceClass
		Else NULL
		End AS CHAR(2)) As InvoiceFinClassCode --char(2)
	, Case when AdjInv.Id is not null then AdjInv.InvPOS
		When DelAdjInv.Id is not null then DelAdjInv.InvPOS
		Else NULL
		End As InvoicePOSCode --[smallint]
	, NULL As Unapplied_ParentOrgID -- [int]
	, NULL As Unapplied_ParentOrgName-- [varchar] (50)
	, NULL As Unapplied_InsPaymentId --[int]
';


SET @SQL3 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions as t
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_adjustments AS Adj
		ON t.trrefid = Adj.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS AdjInv
		ON Adj.InvId = AdjInv.Id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS AdjEnt
		ON AdjInv.invfacilityid = AdjEnt.facilityid
		AND AdjInv.dosproviderid = AdjEnt.providerid 		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS AdjCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(AdjEnt.COID))) = 1   ) AND (LEN(AdjEnt.COID) <= 5)    
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(AdjEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = AdjCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS AdjExc
		ON AdjEnt.COID = AdjExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as Fac
		ON AdjInv.invfacilityid = Fac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As AdjEnc
		ON AdjInv.encounterid = AdjEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Adj_U_Patient
		ON Adj_U_Patient.uid = AdjInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Adj_U_Provider 
		ON Adj_U_Provider.uid = AdjInv.DOSProviderID 		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Adj_U_EncProvider
		ON Adj_U_EncProvider.uid = AdjEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAdjCodeXwalk As AdjAdjX
		ON Adj.code = AdjAdjX.adjcode
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As AdjTrType
		ON AdjAdjX.TrTypeId = AdjTrType.TrTypeId
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS AdjInsDet  -- this JOIN gets "patient" insurance 
		ON AdjInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = Adj_U_Patient.[uid]  -- this is where it joins using patientid                               		
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS AdjIns
		ON AdjInsDet.[insid] = AdjIns.[insId]		
	left join ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance AdjInvEii	
				on AdjInvEii.Id = (select top 1 Id 
									from ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance eii
									where eii.InvoiceId = AdjInv.Id 
									and eii.SeqNo = 1 --eii.SeqNo = 0 
									and eii.deleteFlag = 0									
									ORDER BY [SeqNo] ASC, Id DESC) 				
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS AdjInvIns  -- gets the primary ins on the invoice		
		ON AdjInvEii.InsId = AdjInvIns.InsId		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS AdjAcctX
		ON AdjAdjX.TrtypeID = AdjAcctX.TrtypeID 		
		AND CASE WHEN AdjAdjX.AdjCode in(3391 , 3401, 3361, 3381) --8/26/2013 JEW added 3381 for Withhold
			THEN ''99''
			WHEN AdjAdjX.AdjCode in(3081) --9/12/11 VAM - Added AdjCode 3081 & FinClass 15 Charity
			THEN ''15''
			ELSE ISNULL(AdjInvIns.InsuranceClass, ''99'') END
			= AdjAcctX.FinancialClassCode
-----------------------------------------------------------------
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_deleted_adj AS DelAdj
		ON t.trrefid = deladj.refid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS DelAdjInv
		ON DelAdj.InvId = DelAdjInv.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS DelAdjEnt
		ON DelAdjInv.invfacilityid = DelAdjEnt.facilityid
		AND DelAdjInv.dosproviderid = DelAdjEnt.providerid 		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS DelAdjCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(DelAdjEnt.COID))) = 1   ) AND (LEN(DelAdjEnt.COID) <= 5)    
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(DelAdjEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = DelAdjCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS DelAdjExc
		ON DelAdjEnt.COID = DelAdjExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as DelFac
		ON DelAdjInv.invfacilityid = DelFac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As DelAdjEnc
		ON DelAdjInv.encounterid = DelAdjEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS DelAdj_U_Patient
		ON DelAdj_U_Patient.uid = DelAdjInv.patientid 		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS DelAdj_U_Provider
		ON DelAdj_U_Provider.uid = DelAdjInv.DOSProviderID		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS DelAdj_U_EncProvider
		ON DelAdj_U_EncProvider.uid = DelAdjEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAdjCodeXwalk As DelAdjAdjX
		ON DelAdj.code = DelAdjAdjX.adjcode
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As DelAdjTrType
		ON DelAdjAdjX.TrTypeId = DelAdjTrType.TrTypeId
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS DelAdjInsDet
		ON DelAdjInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = DelAdj_U_Patient.[uid]										
										AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelAdjIns
		ON DelAdjInsDet.[insid] = DelAdjIns.[insId]		
	left join ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance DelAdjInvEii		
				on DelAdjInvEii.Id = (select top 1 Id 
									from ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance eii
									where eii.InvoiceId = DelAdjInv.Id 
									and eii.SeqNo = 1 
									and eii.deleteFlag = 0									
									ORDER BY [SeqNo] ASC, Id DESC) 
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelAdjInvIns	
		ON DelAdjInvEii.InsId = DelAdjInvIns.InsId		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS DelAdjAcctX
		ON DelAdjAdjX.TrtypeID = DelAdjAcctX.TrtypeID 		
		AND CASE WHEN DelAdjAdjX.AdjCode in(3391 , 3401, 3361, 3381) ---- 8/26/2013 JEW added 3381 for Withhold
			THEN ''99''
			WHEN DelAdjAdjX.AdjCode in(3081) --9/12/11 VAM - Added AdjCode 3081 & FinClass 15 Charity
			THEN ''15''
			ELSE ISNULL(DelAdjInvIns.InsuranceClass, ''99'') END
			= DelAdjAcctX.FinancialClassCode
----------------------------------------------------------
WHERE (
	(' + @RegionID + ' <> 3 AND t.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t.modifieddate < @EndRunDate)
	OR
	(' + @RegionID + ' = 3 AND t.modifiedDate > @StartRunDate_R03 AND t.modifiedDate < @EndRunDate_R03)
	)	
	AND (AdjTrType.TrTypeId IN(8, 24, 25, 27) OR DelAdjTrType.TrTypeId IN(8, 24, 25, 27))
	AND t.TrType =''adjustments''
	
UNION ALL

';


SET @SQL4 = '
SELECT
	''eCW'' AS SourceSystemCode
	, ''' + @RegionID + ''' AS SourceServer
	, T.id AS SourceTransactionID
	, @EndRunDate AS ETLDate
	, T.modifieddate AS TransactionDate
	, T.trtype AS SourceTrType
	, Case When epd.PmtDetailId Is Not Null Then epdTrType.TrType
		When Delepd.PmtDetailId Is Not Null Then DelepdTrType.TrType
		Else Null
		End AS FamiliarTrType
	, @LastDay AS PostingPeriod
	, T.amount AS TransactionAmount
	, NULL AS ExceptionRecordFlag
	, Case
		When epdExc.COID Is Not Null AND epdExc.[Enabled] = 1 Then 1
		When DelepdExc.COID Is Not Null AND DelepdExc.[Enabled] = 1 Then 1
		Else 0
		END AS ExcludedCOID
	, NEWID() AS AuditItemId --uniqueidentifier
	, @ETLPackageName As ETLPackageName
----------------------------------------
	, SUBSTRING(Case 
		When epdEnt.COID Is Not Null Then epdEnt.COID 
		When DelepdEnt.COID Is Not Null Then DelepdEnt.COID
		Else NULL
		END, 1, 8) AS SourceCOID
	, SUBSTRING(Case 
		When epdEnt.COID Is Not Null Then epdCoMast.COID 
		When DelepdEnt.COID Is Not Null Then DelepdCoMast.COID
		Else NULL
		END, 1, 8) AS CoMastCOID
	, SUBSTRING(Case 
		When epdEnt.COID Is Not Null Then epdEnt.DeptCode 
		When DelepdEnt.COID Is Not Null Then DelepdEnt.DeptCode
		Else NULL
		END, 1, 8) AS DepartmentCode
	, CAST(CASE 
		WHEN epdInv.Id is not null 
				THEN 
					CASE WHEN LEN(epdAcctX.Account) = 4 
						THEN LTRIM(RTRIM(epdAcctX.Account)) + RIGHT(Cast(epdEnt.DeptCode AS VarChar), 2)
						ELSE epdAcctX.Account
					END
		WHEN DelepdInv.Id is not null 
				THEN CASE WHEN LEN(DelepdAcctX.Account) = 4
						THEN LTRIM(RTRIM(DelepdAcctX.Account)) + RIGHT(Cast(DelepdEnt.DeptCode AS VarChar), 2)
						ELSE DelepdAcctX.Account
					END
		ELSE NULL
		End AS VarChar(6)) AS Account
	, Case when epdInv.Id is not null then LTRIM(RTRIM(epdAcctX.Account))
		When DelepdInv.Id is not null then LTRIM(RTRIM(DelepdAcctX.Account))
		Else NULL
		End As SourceAccount
	, Case when epdInv.Id is not null then epdInv.Id
		When DelepdInv.Id is not null then DelepdInv.Id
		Else NULL
		End As InvoiceId
	, Case when epdInv.Id is not null then epdInv.EncounterId
		When DelepdInv.Id is not null then DelepdInv.EncounterId
		Else NULL
		End As EncounterId
	, Case when epd.PmtDetailId is not null then Fac.Id
		When Delepd.PmtDetailId is not null then DelFac.Id
		Else NULL
		End As FacilityId
	, Case when epd.PmtDetailId is not null then Fac.Name
		When Delepd.PmtDetailId is not null then DelFac.Name
		Else NULL
		End As FacilityName
	, Case when epdInv.Id is not null then epdInv.PracticeId
		When DelepdInv.Id is not null then DelepdInv.PracticeId
		Else NULL
		End As PracticeId
	, Case when epdInv.Id is not null then epd_U_EncProvider.uid
		When DelepdInv.Id is not null then Delepd_U_EncProvider.uid
		Else NULL
		End As ApptEncProviderId --Int
	, SUBSTRING(Case when epdInv.Id is not null 
		then epd_U_EncProvider.ulname + '', '' + epd_U_EncProvider.ufname
		When DelepdInv.Id is not null 
		then Delepd_U_EncProvider.ulname + '', '' + Delepd_U_EncProvider.ufname
		Else NULL
		End, 1, 50) As ApptEncProviderName --varchar (50)
	, Case when epdInv.Id is not null then epd_U_Provider.uid
		When DelepdInv.Id is not null then Delepd_U_Provider.uid
		Else NULL
		End As InvServicingProviderId --Int
	, SUBSTRING(Case when epdInv.Id is not null 
		then epd_U_Provider.ulname + '', '' + epd_U_Provider.ufname
		When DelepdInv.Id is not null 
		then Delepd_U_Provider.ulname + '', '' + Delepd_U_Provider.ufname
		Else NULL
		End, 1, 50) As InvServicingProviderName --varchar (50)
	, Case when epdInv.Id is not null then epd_U_Patient.uid
		When DelepdInv.Id is not null then Delepd_U_Patient.uid
		Else NULL
		End As PatientId --Int
	, SUBSTRING(Case when epdInv.Id is not null 
		then epd_U_Patient.ulname + '', '' + epd_U_Patient.ufname
		When DelepdInv.Id is not null 
		then Delepd_U_Patient.ulname + '', '' + Delepd_U_Patient.ufname
		Else NULL
		End, 1, 50) As PatientName --varchar (50)
	, CAST(Case when epdInv.Id is not null then epdIns.InsuranceName + '' / '' +epdIns.insuranceclass
		When DelepdInv.Id is not null then DelepdIns.InsuranceName  + '' / ''  + DelepdIns.insuranceclass
		Else NULL
		End AS VarChar (40)) As PatientPrimaryInsurance	--varchar(40)
	----------------------------------------
	, NULL As PaymentID --[int]
	, NULL As PaymentIDDeleted -- [bit]
	, NULL As PaymentCode --char(5)
	, NULL As PaymentCodeDeleted --bit
	, NULL As PayerName --varchar (40)
	, NULL As PayerFinClassCode --char(2)	
	, ''4001'' As AdjustmentCode --char (5)
	, case when epdInv.Id is not null then 0
		When DelepdInv.Id is not null then 1
		Else NULL
		End As AdjustmentCodeDeleted --bit
	, Case when epdInv.Id is not null then ''ContractualPayPath''
		When DelepdInv.Id is not null then ''DeletedContractualPayPath''
		Else NULL
		End As SourceCOIDLookupPath --varchar(25)
	, NULL As SourceCPTHCPCS -- [char] (5)
	, NULL As SourceCPTModifier -- [char] (2)
	, NULL As PaymentRateCode -- [char] (2)
	, NULL As AncillaryRate --[decimal] (10, 7)
	, NULL As ProfessionalRate -- [decimal] (10, 7)
	, CASE WHEN epdInv.Id is not null THEN epdInv.VoidFlag
		WHEN DelepdInv.Id is not null THEN DelepdInv.VoidFlag
		ELSE NULL
		END AS InvoiceVoidFlag --tinyint
	, CAST(Case when epdInv.Id is not null then epdInvIns.InsuranceClass
		When DelepdInv.Id is not null then DelepdInvIns.InsuranceClass
		Else NULL
		End AS Char(2)) As InvoiceFinClassCode --char(2)
	, Case when epdInv.Id is not null then epdInv.InvPOS
		When DelepdInv.Id is not null then DelepdInv.InvPOS
		Else NULL
		End As InvoicePOSCode --[smallint]
	, NULL As Unapplied_ParentOrgID -- [int]
	, NULL As Unapplied_ParentOrgName-- [varchar] (50)
	, NULL As Unapplied_InsPaymentId --[int]
';



SET @SQL5 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions as t
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[edi_paymentdetail] AS epd
		ON t.[TrRefId] = epd.[PmtDetailId]		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS epdInv
		ON epd.InvoiceId = epdInv.Id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS epdEnt
		ON epdInv.invfacilityid = epdEnt.facilityid
		AND epdInv.dosproviderid = epdEnt.providerid 		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS epdCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(epdEnt.COID))) = 1) AND (LEN(epdEnt.COID) <= 5)   
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(epdEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = epdCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS epdExc
		ON epdEnt.COID = epdExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as Fac
		ON epdInv.invfacilityid = Fac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As epdEnc
		ON epd.encounterid = epdEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS epd_U_Patient
		ON epd_U_Patient.uid = epdInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS epd_U_Provider
		ON epd_U_Provider.uid = epdInv.DOSProviderID 		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS epd_U_EncProvider
		ON epd_U_EncProvider.uid = epdEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As epdTrType
		ON ''CONTRACTUAL WRITEOFF'' = epdTrType.TrType
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS epdInsDet
		ON epdInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = epd_U_Patient.[uid]										
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS epdIns
		ON epdInsDet.[insid] = epdIns.[insId]		
	left join ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance epdInvEii	
				on epdInvEii.Id = (select top 1 Id 
									from ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance eii
									where eii.InvoiceId = epdInv.Id 
									and eii.SeqNo = 1 
									and eii.deleteFlag = 0									
									ORDER BY [SeqNo] ASC, Id DESC) 
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS epdInvIns	
		ON epdInvEii.InsId = epdInvIns.InsId
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS epdAcctX
		ON epdTrType.TrtypeID = epdAcctX.TrtypeID
		AND ISNULL(epdInvIns.InsuranceClass, ''99'') = epdAcctX.FinancialClassCode
-----------------------------------------------------------------
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[edi_paymentdetail_del]  AS Delepd
		ON t.trrefid = delepd.[PmtDetailId]		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS DelepdInv
		ON Delepd.InvoiceId = DelepdInv.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS DelepdEnt
		ON DelepdInv.invfacilityid = DelepdEnt.facilityid
		AND DelepdInv.dosproviderid = DelepdEnt.providerid 		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS DelepdCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(DelepdEnt.COID))) = 1) AND (LEN(DelepdEnt.COID) <= 5)   
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(DelepdEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = DelepdCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS DelepdExc
		ON DelepdEnt.COID = DelepdExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as DelFac
		ON DelepdInv.invfacilityid = DelFac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As DelepdEnc
		ON DelepdInv.encounterid = DelepdEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Delepd_U_Patient
		ON Delepd_U_Patient.uid = DelepdInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Delepd_U_Provider
		ON Delepd_U_Provider.uid = DelepdInv.DOSProviderID 		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Delepd_U_EncProvider
		ON Delepd_U_EncProvider.uid = DelepdEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As delepdTrType
		ON ''CONTRACTUAL WRITEOFF'' = delepdTrType.TrType
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS DelepdInsDet
		ON DelepdInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = Delepd_U_Patient.[uid]                                		
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelepdIns
		ON DelepdInsDet.[insid] = DelepdIns.[insId]		
	left join ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance DelepdInvEii	
				on DelepdInvEii.Id = (select top 1 Id 
									from ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance eii
									where eii.InvoiceId = DelepdInv.Id 
									and eii.SeqNo = 1 
									and eii.deleteFlag = 0									
									ORDER BY [SeqNo] ASC, Id DESC) 				
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelepdInvIns	
		ON DelepdInvEii.InsId = DelepdInvIns.InsId	
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS DelepdAcctX
		ON DelepdTrType.TrtypeID = DelepdAcctX.TrtypeID
		AND ISNULL(DelepdInvIns.InsuranceClass, ''99'') = DelepdAcctX.FinancialClassCode
----------------------------------------------------------
WHERE (
	(' + @RegionID + ' <> 3 AND t.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t.modifieddate < @EndRunDate)
	OR
	(' + @RegionID + ' = 3 AND t.modifiedDate > @StartRunDate_R03 AND t.modifiedDate < @EndRunDate_R03)
	)
	AND t.TrType = ''encpostedadjust''

UNION ALL

';



SET @SQL6 = '
SELECT
	''eCW'' AS SourceSystemCode
	, ''' + @RegionID + ''' AS SourceServer 
	, T.id AS SourceTransactionID
	, @EndRunDate AS ETLDate
	, T.modifieddate AS TransactionDate
	, T.trtype AS SourceTrType
	, Case When epd.PmtDetailId Is Not Null Then epdTrType.TrType
		When Delepd.PmtDetailId Is Not Null Then DelepdTrType.TrType
		Else Null
		End AS FamiliarTrType
	, @LastDay AS PostingPeriod
	, T.amount AS TransactionAmount
	, NULL AS ExceptionRecordFlag
	, Case
		When epdExc.COID Is Not Null AND epdExc.[Enabled] = 1 Then 1
		When DelepdExc.COID Is Not Null AND DelepdExc.[Enabled] = 1 Then 1
		Else 0
		END AS ExcludedCOID
	, NEWID() AS AuditItemId --uniqueidentifier
	, @ETLPackageName As ETLPackageName
----------------------------------------
	, SUBSTRING(Case 
		When epdEnt.COID Is Not Null Then epdEnt.COID 
		When DelepdEnt.COID Is Not Null Then DelepdEnt.COID
		Else NULL
		END, 1, 8) AS SourceCOID
	, SUBSTRING(Case 
		When epdEnt.COID Is Not Null Then epdCoMast.COID 
		When DelepdEnt.COID Is Not Null Then DelepdCoMast.COID
		Else NULL
		END, 1, 8) AS CoMastCOID
	, SUBSTRING(Case 
		When epdEnt.COID Is Not Null Then epdEnt.DeptCode 
		When DelepdEnt.COID Is Not Null Then DelepdEnt.DeptCode
		Else NULL
		END, 1, 8) AS DepartmentCode
	, CAST(CASE 
		WHEN epdInv.Id is not null 
				THEN 
					CASE WHEN LEN(epdAcctX.Account) = 4 
						THEN LTRIM(RTRIM(epdAcctX.Account)) + RIGHT(Cast(epdEnt.DeptCode AS VarChar), 2)
						ELSE epdAcctX.Account
					END
		WHEN DelepdInv.Id is not null 
				THEN CASE WHEN LEN(DelepdAcctX.Account) = 4
						THEN LTRIM(RTRIM(DelepdAcctX.Account)) + RIGHT(Cast(DelepdEnt.DeptCode AS VarChar), 2)
						ELSE DelepdAcctX.Account
					END
		ELSE NULL
		End AS VarChar(6)) AS Account
	, Case when epdInv.Id is not null then LTRIM(RTRIM(epdAcctX.Account))
		When DelepdInv.Id is not null then LTRIM(RTRIM(DelepdAcctX.Account))
		Else NULL
		End As SourceAccount
	, Case when epdInv.Id is not null then epdInv.Id
		When DelepdInv.Id is not null then DelepdInv.Id
		Else NULL
		End As InvoiceId
	, Case when epdInv.Id is not null then epdInv.EncounterId
		When DelepdInv.Id is not null then DelepdInv.EncounterId
		Else NULL
		End As EncounterId
	, Case when epd.PmtDetailId is not null then Fac.Id
		When Delepd.PmtDetailId is not null then DelFac.Id
		Else NULL
		End As FacilityId
	, Case when epd.PmtDetailId is not null then Fac.Name
		When Delepd.PmtDetailId is not null then DelFac.Name
		Else NULL
		End As FacilityName
	, Case when epdInv.Id is not null then epdInv.PracticeId
		When DelepdInv.Id is not null then DelepdInv.PracticeId
		Else NULL
		End As PracticeId
	, Case when epdInv.Id is not null then epd_U_EncProvider.uid
		When DelepdInv.Id is not null then Delepd_U_EncProvider.uid
		Else NULL
		End As ApptEncProviderId --Int
	, SUBSTRING(Case when epdInv.Id is not null 
		then epd_U_EncProvider.ulname + '', '' + epd_U_EncProvider.ufname
		When DelepdInv.Id is not null 
		then Delepd_U_EncProvider.ulname + '', '' + Delepd_U_EncProvider.ufname
		Else NULL
		End, 1, 50) As ApptEncProviderName --varchar (50)
	, Case when epdInv.Id is not null then epd_U_Provider.uid
		When DelepdInv.Id is not null then Delepd_U_Provider.uid
		Else NULL
		End As InvServicingProviderId --Int
	, SUBSTRING(Case when epdInv.Id is not null 
		then epd_U_Provider.ulname + '', '' + epd_U_Provider.ufname
		When DelepdInv.Id is not null 
		then Delepd_U_Provider.ulname + '', '' + Delepd_U_Provider.ufname
		Else NULL
		End, 1, 50) As InvServicingProviderName --varchar (50)
	, Case when epdInv.Id is not null then epd_U_Patient.uid
		When DelepdInv.Id is not null then Delepd_U_Patient.uid
		Else NULL
		End As PatientId --Int
	, SUBSTRING(Case when epdInv.Id is not null 
		then epd_U_Patient.ulname + '', '' + epd_U_Patient.ufname
		When DelepdInv.Id is not null 
		then Delepd_U_Patient.ulname + '', '' + Delepd_U_Patient.ufname
		Else NULL
		End, 1, 50) As PatientName --varchar (50)
	, CAST(Case when epdInv.Id is not null then epdIns.InsuranceName + '' / '' + epdIns.insuranceclass
		When DelepdInv.Id is not null then DelepdIns.InsuranceName  + '' / ''  + DelepdIns.insuranceclass
		Else NULL
		End AS VarChar (40)) As PatientPrimaryInsurance	--varchar(40)
----------------------------------------
	, NULL As PaymentID --[int]
	, NULL As PaymentIDDeleted -- [bit]
	, NULL As PaymentCode --char(5)
	, NULL As PaymentCodeDeleted --bit
	, NULL As PayerName --varchar (40)
	, NULL As PayerFinClassCode --char(2)	
	, ''4001'' As AdjustmentCode --char (5)
	, case when epdInv.Id is not null then 0
		When DelepdInv.Id is not null then 1
		Else NULL
		End As AdjustmentCodeDeleted --bit
	, Case when epdInv.Id is not null then ''ContractualPayPath''
		When DelepdInv.Id is not null then ''DeletedContractualPayPath''
		Else NULL
		End As SourceCOIDLookupPath --varchar(25)
	, NULL As SourceCPTHCPCS -- [char] (5)
	, NULL As SourceCPTModifier -- [char] (2)
	, NULL As PaymentRateCode -- [char] (2)
	, NULL As TechnicalRate --[decimal] (10, 7)
	, NULL As ProfessionalRate -- [decimal] (10, 7)
	, CASE WHEN epdInv.Id is not null THEN epdInv.VoidFlag
		WHEN DelepdInv.Id is not null THEN DelepdInv.VoidFlag
		ELSE NULL
		END AS InvoiceVoidFlag --tinyint
	, CAST(Case when epdInv.Id is not null then epdInvIns.InsuranceClass
		When DelepdInv.Id is not null then DelepdInvIns.InsuranceClass
		Else NULL
		End AS Char(2))As InvoiceFinClassCode --char(2)
	, Case when epdInv.Id is not null then epdInv.InvPOS
		When DelepdInv.Id is not null then DelepdInv.InvPOS
		Else NULL
		End As InvoicePOSCode --[smallint]
	, NULL As Unapplied_ParentOrgID -- [int]
	, NULL As Unapplied_ParentOrgName -- [varchar] (50)
	, NULL As Unapplied_InsPaymentId --[int]
';



SET @SQL7 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions as t
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[edi_paymentdetail] AS epd
		ON t.[TrRefId] = epd.[PmtDetailId]		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS epdInv
		ON epd.InvoiceId = epdInv.Id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS epdEnt
		ON epdInv.invfacilityid = epdEnt.facilityid
		AND epdInv.dosproviderid = epdEnt.providerid  		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS epdCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(epdEnt.COID))) = 1  ) AND (LEN(epdEnt.COID) <= 5)   
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(epdEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = epdCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS epdExc
		ON epdEnt.COID = epdExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as Fac
		ON epdInv.invfacilityid = Fac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As epdEnc
		ON epd.encounterid = epdEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS epd_U_Patient
		ON epd_U_Patient.uid = epdInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS epd_U_Provider
		ON epd_U_Provider.uid = epdInv.DOSProviderID  		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS epd_U_EncProvider
		ON epd_U_EncProvider.uid = epdEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As epdTrType
		ON epdTrType.TrType = ''CONTRACTUAL WRITEOFF''
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS epdInsDet
		ON epdInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = epd_U_Patient.[uid]                                		
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS epdIns
		ON epdInsDet.[insid] = epdIns.[insId]		
	left join ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance epdInvEii	
				on epdInvEii.Id = (select top 1 Id 
									from ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance eii
									where eii.InvoiceId = epdInv.Id 
									and eii.SeqNo = 1 
									and eii.deleteFlag = 0									
									ORDER BY SeqNo ASC, Id DESC) 
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS epdInvIns
		ON epdInvEii.InsId = epdInvIns.InsId		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS epdAcctX
		ON epdTrType.TrtypeID = epdAcctX.TrtypeID
		AND ISNULL(epdInvIns.InsuranceClass, ''99'') = epdAcctX.FinancialClassCode
-----------------------------------------------------------------
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[edi_paymentdetail_del]  AS Delepd
		ON t.trrefid = delepd.[PmtDetailId]		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS DelepdInv
		ON Delepd.InvoiceId = DelepdInv.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS DelepdEnt
		ON DelepdInv.invfacilityid = DelepdEnt.facilityid
		AND DelepdInv.dosproviderid = DelepdEnt.providerid  		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS DelepdCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(DelepdEnt.COID))) = 1   ) AND (LEN(DelepdEnt.COID) <= 5)  
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(DelepdEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = DelepdCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS DelepdExc
		ON DelepdEnt.COID = DelepdExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as DelFac
		ON DelepdInv.invfacilityid = DelFac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As DelepdEnc
		ON DelepdInv.encounterid = DelepdEnc.encounterid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Delepd_U_Patient
		ON Delepd_U_Patient.uid = DelepdInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Delepd_U_Provider
		ON Delepd_U_Provider.uid = DelepdInv.DOSProviderID  		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Delepd_U_EncProvider
		ON Delepd_U_EncProvider.uid = DelepdEnc.doctorid		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As DelepdTrType
		ON DelepdTrType.TrType = ''CONTRACTUAL WRITEOFF''
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS DelepdInsDet
		ON DelepdInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = Delepd_U_Patient.[uid]                                		
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelepdIns
		ON DelepdInsDet.[insid] = DelepdIns.[insId]		
	left join ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance DelepdInvEii	
				on DelepdInvEii.Id = (select top 1 Id 
									from ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_insurance eii
									where eii.InvoiceId = DelepdInv.Id 
									and eii.SeqNo = 1 
									and eii.deleteFlag = 0									
									ORDER BY [SeqNo] ASC, Id DESC)
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS DelepdInvIns
		ON DelepdInvEii.InsId = DelepdInvIns.InsId		
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS DelepdAcctX
		ON DelepdTrType.TrtypeID = DelepdAcctX.TrtypeID
		AND ISNULL(DelepdInvIns.InsuranceClass, ''99'') = DelepdAcctX.FinancialClassCode
----------------------------------------------------------
WHERE (
	(' + @RegionID + ' <> 3 AND t.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t.modifieddate < @EndRunDate)
	OR
	(' + @RegionID + ' = 3 AND t.modifiedDate > @StartRunDate_R03 AND t.modifiedDate < @EndRunDate_R03)
	)
	AND t.TrType = ''encpostedwithheld''
';

IF @print_sql = 'y'
	BEGIN
		PRINT @SQL1 
		PRINT @SQL2
		PRINT @SQL3
		PRINT @SQL4 
		PRINT @SQL5
		PRINT @SQL6
		PRINT @SQL7
	END
ELSE
	BEGIN
		EXEC(@SQL1 + @SQL2 + @SQL3 + @SQL4 + @SQL5 + @SQL6 + @SQL7);
	END

END
GO



IF OBJECT_ID('[ecwStage].[HostGL_eCW_PAYMENTS]', 'P') IS NOT NULL
	DROP PROC [ecwStage].[HostGL_eCW_PAYMENTS]
GO

CREATE PROC [ecwStage].[HostGL_eCW_PAYMENTS]
	@GLJobRunID int
	,@print_sql char(1) = 'n'
AS
BEGIN
/********************************************************************************************
Procedure: [ecwStage].[HostGL_eCW_PAYMENTS]

Parameters: @GLJobRunID  INT    -- Record ID in table eCWStage.[AUDIT].GLRegionJobRun to reference for needed variables
			@print_sql char     -- argument to print sql statement rather than execute, default to 'n', enter 'y' for print

Original Developer:	 

Original Purpose:	To extract eCW payments
					
Original Date:		 

Unit Test/Execution Example:
	exec [ecwStage].[HostGL_eCW_PAYMENTS] 1
	(to execute sql statement)
	or 
	exec [ecwStage].[HostGL_eCW_PAYMENTS] 1, 'y'
	(to print sql statement instead of executing it)

Modification:
Date			Developer		Modification						
---------		---------		--------------------------------------------------
5/10/2010		VAM				Modified for MultiRegion changes
10/07/2010		ESH				Added code to null out bad COID
10/08/2010		ESH				Added code to make sure a character type FIN class will pass through cleanly
								By putting '' around 99 in the coallesce.
10/12/2010		ESH				Added force 110091 account for pmtType = 'Payment - NSF'
11/13/2010		VAM				Added Cast to VarChar(2) on the PayerFinClass output column
11/15/2010		ESH				Made sure force 110091 account for pmtType = 'Payment - NSF' in place for 
								Delete logic as well. 
12/06/2010		ESH				Changed RenProviderID to DOSProviderID, 
								changed output columns to InvServicingProviderID and InsServicingProviderName								
2/15/2011		ESH				Added code for Payment Ins - Stop Payment	
9/7/2011		VAM				Added Deleteflag check on mobiledoc..paymenttype join							
4/19/2012		BBA				Added @StartRunDate_R03, @EndRunDate_R03 for region 3 filter in Where Clause, region 3 is on Mountain time (-1hr) and rows entered between 11PM-12AM were not getting posted to the GL 
11/8/2012		JRP				Changed where clause to avoid using upper (non sargeable filter)
1/17/2019		JMW				Modified for Region Split
*********************************************************************************************/
 
SET NOCOUNT ON;
DECLARE @ServerName VARCHAR(256);
DECLARE @RegionID VARCHAR(25);
DECLARE @StartRunDate DATETIME;
DECLARE @DatabaseName VARCHAR(50);;
DECLARE @SQL1 VARCHAR(8000);
DECLARE @SQL2 VARCHAR(8000);	
DECLARE @SQL3 VARCHAR(8000);	
DECLARE @SQL4 VARCHAR(8000);	
SET @RegionID = (select RegionID from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @StartRunDate = (select MaxTransactionDate from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @ServerName = (select ServerName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @DatabaseName = (select DatabaseName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);

SET @SQL1 = '
DECLARE @ETLPackageName VARCHAR(50);
DECLARE @EndRunDate DATETIME; 
DECLARE	@LastDay DATETIME;
DECLARE @StartRunDate_R03 DATETIME;
DECLARE @EndRunDate_R03 DATETIME;
SET @ETLPackageName = (select JobName from ' + @ServerName + '.eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = ' + CAST(@GLJobRunID AS VARCHAR(10)) + ');
SET @EndRunDate = dateadd(day, datediff(day, 0, getdate()), 0);
SELECT @LastDay = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEDIFF(dd,1,@EndRunDate))+1,0)));
SELECT @StartRunDate_R03 = DATEADD(hh,-1,''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''');
SELECT @EndRunDate_R03 = DATEADD(hh,-1,@EndRunDate) ';


SET @SQL2 = '
SELECT  ''eCW'' AS SourceSystemCode ,
            ''' + @RegionID + ''' AS SourceServer ,
            T.id AS SourceTransactionID , 
            @EndRunDate AS ETLDate ,
            T.modifieddate AS TransactionDate ,
            T.trtype AS SourceTrType ,
            COALESCE(InsPmtType.pmtType, DelInsPmtType.pmtType, ''PAYMENT'') AS FamiliarTrType ,
            @LastDay AS PostingPeriod ,
            T.amount AS TransactionAmount ,
            NULL AS ExceptionRecordFlag ,
			Case When Exc.COID Is Not Null AND Exc.[Enabled] = 1 Then 1
				 WHEN ProvExc.COID Is Not Null AND ProvExc.[Enabled] = 1 Then 1
				 When DelExc.COID Is Not Null AND DelExc.[Enabled] = 1 Then 1
				 WHEN DelProvExc.COID Is Not Null AND DelProvExc.[Enabled] = 1 Then 1
				 Else 0
			END AS ExcludedCOID ,
            NEWID() AS AuditItemId ,
            @ETLPackageName AS ETLPackageName ,
            SUBSTRING(COALESCE(PmtEnt.COID, PmtProvEnt.COID, DelPmtEnt.COID, DelPmtProvEnt.COID), 1, 8) AS SourceCOID,
            SUBSTRING(COALESCE(PmtCoMast.COID, PmtProvCoMast.COID, DelPmtCoMast.COID, DelPmtProvCoMast.COID), 1, 8) AS CoMastCOID,
            SUBSTRING(COALESCE(PmtEnt.DeptCode, PmtProvEnt.DeptCode, DelPmtEnt.DeptCode, DelPmtProvEnt.DeptCode), 1, 8) AS DepartmentCode ,
            CASE WHEN (InsPmtType.pmtType in ( ''Payment - NSF'',''PAYMENTS – INS STOP PMT'')) THEN 
							''110091''
				 WHEN (DelInsPmtType.pmtType in ( ''Payment - NSF'',''PAYMENTS – INS STOP PMT'')) THEN 
							''110091''							
						ELSE 
							COALESCE(PmtAcctX.Account, DelPmtAcctX.Account) 
						END AS Account , 
            COALESCE(PmtAcctX.Account, DelPmtAcctX.Account) AS SourceAccount ,
            COALESCE(PmtEncInv.Id, DelPmtEncInv.Id) AS InvoiceId ,
            COALESCE(PmtEnc.EncounterId, DelPmtEnc.EncounterId) AS EncounterId ,
            COALESCE(PmtFac.Id, PmtProvFac.id, DelPmtFac.Id, DelPmtProvFac.id) AS FacilityId ,
            COALESCE(PmtFac.NAME, PmtProvFac.NAME, DelPmtFac.NAME, DelPmtProvFac.NAME) AS FacilityName ,
            COALESCE(PmtEncInv.PracticeId, DelPmtEncInv.PracticeId) AS PracticeId ,
            COALESCE(Pmt_U_EncProvider.uid, Del_Pmt_U_EncProvider.uid) AS ApptEncProviderId ,
            SUBSTRING(CASE WHEN PmtEncInv.Id IS NOT NULL
                           THEN Pmt_U_EncProvider.ulname + '', '' + Pmt_U_EncProvider.ufname
                           WHEN DelPmtEncInv.Id IS NOT NULL
                           THEN Del_Pmt_U_EncProvider.ulname + '', '' + Del_Pmt_U_EncProvider.ufname
                           ELSE NULL
                      END, 1, 50) AS ApptEncProviderName ,
            COALESCE(Pmt_U_Provider.uid, Del_Pmt_U_Provider.uid) AS InvServicingProviderId ,
            SUBSTRING(CASE WHEN PmtEncInv.Id IS NOT NULL
                           THEN Pmt_U_Provider.ulname + '', ''
                                + Pmt_U_Provider.ufname
                           WHEN DelPmtEncInv.Id IS NOT NULL
                           THEN Del_Pmt_U_Provider.ulname + '', ''
                                + Del_Pmt_U_Provider.ufname
                           ELSE NULL
                      END, 1, 50) AS InvServicingProviderName ,
            COALESCE(Pmt_U_Patient.uid, Del_Pmt_U_Patient.uid) AS PatientId ,
            SUBSTRING(CASE WHEN PmtEncInv.Id IS NOT NULL
                           THEN Pmt_U_Patient.ulname + '', ''
                                + Pmt_U_Patient.ufname
                           WHEN DelPmtEncInv.Id IS NOT NULL
                           THEN Del_Pmt_U_Patient.ulname + '', ''
                                + Del_Pmt_U_Patient.ufname
                           ELSE NULL
                      END, 1, 50) AS PatientName ,
            COALESCE(PmtIns.InsuranceName, DelPmtIns.InsuranceName) AS PatientPrimaryInsurance ,
            COALESCE(PmtDet.PaymentId, DelPmtDet.PaymentId) AS PaymentID ,
            CASE WHEN PmtDet.PaymentId IS NOT NULL THEN 0
                 WHEN DelPmtDet.PaymentId IS NOT NULL THEN 1
                 ELSE NULL
            END AS PaymentIDDeleted ,
            CAST(COALESCE(InsPmtType.PmtCode, DelInsPmtType.PmtCode) AS CHAR(5)) AS PaymentCode ,
            CASE WHEN InsPmtType.PmtCode IS NOT NULL THEN 0
                 WHEN DelInsPmtType.PmtCode IS NOT NULL THEN 1
                 ELSE NULL
            END AS PaymentCodeDeleted ,
            SUBSTRING(COALESCE(PmtIns.InsuranceName, DelPmtIns.InsuranceName), 1, 40) AS PayerName ,
            CAST(COALESCE(PmtInsDet.InsuranceClass, DelPmtInsDet.InsuranceClass, ''99'') AS VARCHAR(2)) AS PayerFinClassCode ,
            NULL AS AdjustmentCode ,
            NULL AS AdjustmentCodeDeleted ,
            CAST(CASE WHEN PmtEncInv.Id IS NOT NULL THEN ''PaymentPath''
                      WHEN DelPmtEncInv.Id IS NOT NULL THEN ''DeletedPaymentPath''
                      ELSE NULL
                 END AS VARCHAR(25)) AS SourceCOIDLookupPath ,
            NULL AS SourceCPTHCPCS ,
            NULL AS SourceCPTModifier ,
            NULL AS PaymentRateCode ,
            NULL AS AncillaryRate ,
            NULL AS ProfessionalRate ,
            CASE WHEN PmtDet.PmtDetailId is not null THEN PmtEncInv.VoidFlag
				WHEN DelPmtDet.PmtDetailId is not null THEN DelPmtEncInv.VoidFlag
				ELSE NULL
				END AS InvoiceVoidFlag, --tinyint
            CAST(COALESCE(PmtInvIns.InsuranceClass, DelPmtInvIns.InsuranceClass, ''99'') AS VARCHAR(2)) AS InvoiceFinClassCode ,
            COALESCE(PmtEncInv.InvPOS, DelPmtEncInv.InvPOS) AS InvoicePOSCode ,
            NULL AS Unapplied_ParentOrgID ,
            NULL AS Unapplied_ParentOrgName ,
            NULL AS Unapplied_InsPaymentId
';



SET @SQL3 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions AS t
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_paymentdetail AS PmtDet
		ON t.TrRefId = PmtDet.PmtDetailId		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc AS PmtEnc
		ON PmtDet.encounterid = PmtEnc.encounterid		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS PmtEncInv
		ON PmtEnc.invoiceId = PmtEncInv.Id		
-- ******** Get CoID via the Encounter Invoice **********
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS PmtEnt
		ON PmtEncInv.invfacilityid = PmtEnt.facilityid
		AND PmtEncInv.dosproviderid = PmtEnt.providerid 		
--           AND PmtEncInv.PracticeId = PmtEnt.practiceid
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCompanyMaster AS PmtCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(PmtEnt.COID))) = 1   ) AND (LEN(PmtEnt.COID) <= 5) 
					THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(PmtEnt.COID)) AS VARCHAR(5)), 5) 
					ELSE NULL END = PmtCoMast.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities AS PmtFac
		ON PmtEncInv.invfacilityid = PmtFac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Pmt_U_Patient
		ON Pmt_U_Patient.uid = PmtEncInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Pmt_U_Provider
		ON Pmt_U_Provider.uid = PmtEncInv.DOSProviderID 		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Pmt_U_EncProvider
		ON Pmt_U_EncProvider.uid = PmtEnc.doctorid		
-- ******** Get CoID via the Encounter Provider if no invoice on encounter **********
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS PmtProvEnt
		ON PmtEnc.facilityid = PmtProvEnt.facilityid
		AND PmtEnc.doctorid = PmtProvEnt.providerid					
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCompanyMaster AS PmtProvCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(PmtProvEnt.COID))) = 1   ) AND (LEN(PmtProvEnt.COID) <= 5) 
					THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(PmtProvEnt.COID)) AS VARCHAR(5)) , 5) 
					ELSE NULL END = PmtProvCoMast.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities AS PmtProvFac
		ON PmtEnc.facilityid = PmtProvFac.id		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.insurancedetail AS PmtInsDet
		ON PmtInsDet.Id = (SELECT TOP (1)
                                        Id
                               FROM     ' + @ServerName + '.' + @DatabaseName + '.dbo.InsuranceDetail AS B
                               WHERE    B.PID = Pmt_U_Patient.uid                               			
                                        AND B.DeleteFlag = 0
                               ORDER BY seqNo ASC, Id DESC)
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.insurance AS PmtIns
		ON PmtInsDet.insid = PmtIns.insId		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.insurance PmtInvIns
		ON PmtEncInv.PrimaryInsId = PmtInvIns.insid		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inspayments PmtInsPayments
		ON PmtDet.paymentId = PmtInsPayments.paymentId		
    LEFT JOIN (SELECT   pmtTypeId ,						
                        CASE WHEN pmtDescription LIKE ''%NSF%''
                             THEN ''PAYMENT - NSF''
                             WHEN pmtDescription LIKE ''%stop%''
								THEN ''PAYMENTS – INS STOP PMT''  
                             ELSE ''PAYMENT''
                        END AS pmtType ,
                        pmtDescription ,
                        pmtCode
               FROM     ' + @ServerName + '.' + @DatabaseName + '.dbo.paymenttype
               WHERE	deleteflag = 0  
              ) AS InsPmtType
		ON PmtInsPayments.[type] = InsPmtType.pmtDescription		
    LEFT JOIN (SELECT   TrTypeId ,
                        TrType ,
                        Category ,
                        CASE WHEN TrType = ''Payment - nsf''
                             THEN ''PAYMENT - NSF''
                             WHEN TrType = ''PAYMENTS – INS STOP PMT''
                             THEN  ''PAYMENTS – INS STOP PMT''
                             ELSE ''PAYMENT''
                        END AS TrTypeDesc
               FROM     ' + @ServerName + '.ecwstage.eCWStage.StgHostGLTrTypeList
               WHERE    Category = ''Payments''
              ) AS PmtTrType
		ON PmtTrType.TrTypeDesc = ISNULL(InsPmtType.pmtType, ''PAYMENT'')
    LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLAcctXwalk AS PmtAcctX
		ON PmtAcctX.TrTypeId = PmtTrType.TrTypeId
    LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCOIDExclusion AS Exc
		ON PmtEnt.COID = Exc.COID
		AND Exc.[Enabled] = 1
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCOIDExclusion AS ProvExc
		ON PmtProvEnt.COID = ProvExc.COID
		AND ProvExc.[Enabled] = 1'



SET @SQL4 = '
--************** DELETED PAYMENT LOGIC  **********************
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_paymentdetail_del AS DelPmtDet
		ON t.TrRefId = DelPmtDet.PmtDetailId		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS DelPmtInv
		ON DelPmtDet.invoiceId = DelPmtInv.Id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc AS DelPmtEnc
		ON DelPmtDet.encounterid = DelPmtEnc.encounterid		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS DelPmtEncInv
		ON DelPmtEnc.invoiceId = DelPmtEncInv.Id		
-- ******** Get CoID via the Encounter Invoice **********
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS DelPmtEnt
		ON DelPmtEncInv.invfacilityid = DelPmtEnt.facilityid
		AND DelPmtEncInv.dosproviderid = DelPmtEnt.providerid 
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCompanyMaster AS DelPmtCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(DelPmtEnt.COID))) = 1    ) AND (LEN(DelPmtEnt.COID) <= 5) 
					THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(DelPmtEnt.COID)) AS VARCHAR(5)), 5) 
					ELSE NULL END = DelPmtCoMast.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities AS DelPmtFac
		ON DelPmtEncInv.invfacilityid = DelPmtFac.id		
-- ******** Get CoID via the Encounter Provider if no invoice on encounter **********
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS DelPmtProvEnt
		ON DelPmtEnc.facilityid = DelPmtProvEnt.facilityid
		AND DelPmtEnc.doctorid = DelPmtProvEnt.providerid					
	LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCompanyMaster AS DelPmtProvCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(DelPmtProvEnt.COID))) = 1     ) AND (LEN(DelPmtProvEnt.COID) <= 5) 
					THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(DelPmtProvEnt.COID)) AS VARCHAR(5)), 5) 
					ELSE NULL END = DelPmtProvCoMast.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities AS DelPmtProvFac
		ON DelPmtEnc.facilityid = DelPmtProvFac.id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Del_Pmt_U_Patient
		ON Del_Pmt_U_Patient.uid = DelPmtEncInv.patientid		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Del_Pmt_U_Provider
		ON Del_Pmt_U_Provider.uid = DelPmtEncInv.DOSProviderID 		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Del_Pmt_U_EncProvider
		ON Del_Pmt_U_EncProvider.uid = DelPmtEnc.doctorid		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.insurancedetail AS DelPmtInsDet
		ON DelPmtInsDet.Id = (SELECT TOP (1)
                                            Id
                                  FROM      ' + @ServerName + '.' + @DatabaseName + '.dbo.InsuranceDetail AS B
                                  WHERE     B.PID = Del_Pmt_U_Patient.uid                                  			
                                            AND B.DeleteFlag = 0
                                  ORDER BY  seqNo ASC, Id DESC)
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.insurance AS DelPmtIns
		ON DelPmtInsDet.insid = DelPmtIns.insId		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.insurance DelPmtInvIns
		ON DelPmtEncInv.PrimaryInsId = DelPmtInvIns.insid		
    LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inspayments DelPmtInsPayments
		ON DelPmtDet.paymentId = DelPmtInsPayments.paymentId		
    LEFT JOIN (SELECT   pmtTypeId,						
                        CASE WHEN pmtDescription LIKE ''%NSF%''
                             THEN ''PAYMENT - NSF''
                             WHEN pmtDescription LIKE ''%stop%''
								THEN ''PAYMENTS – INS STOP PMT''  
                             ELSE ''PAYMENT''
                        END AS pmtType ,
                        pmtDescription ,
                        pmtCode
               FROM     ' + @ServerName + '.' + @DatabaseName + '.dbo.paymenttype
               WHERE	deleteflag = 0  
              ) AS DelInsPmtType
		ON DelPmtInsPayments.[type] = DelInsPmtType.pmtDescription		
    LEFT JOIN (SELECT   TrTypeId ,
                        TrType ,
                        Category ,
                        CASE WHEN TrType = ''Payment - nsf''
                             THEN ''PAYMENT - NSF''
                             WHEN TrType = ''payments – ins stop pmt''
                             THEN  ''PAYMENTS – INS STOP PMT''
                             ELSE ''PAYMENT''
                        END AS TrTypeDesc
               FROM     ' + @ServerName + '.ecwstage.eCWStage.StgHostGLTrTypeList
               WHERE    Category = ''Payments''
              ) AS DelPmtTrType
		ON DelPmtTrType.TrTypeDesc = ISNULL(DelInsPmtType.pmtType, ''PAYMENT'')
    LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLAcctXwalk AS DelPmtAcctX
		ON DelPmtAcctX.TrTypeId = DelPmtTrType.TrTypeId
    LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCOIDExclusion AS DelExc
		ON DelPmtEnt.COID = DelExc.COID
		AND DelExc.[Enabled] = 1
    LEFT JOIN ' + @ServerName + '.ecwstage.eCWStage.StgHostGLCOIDExclusion AS DelProvExc
		ON DelPmtProvEnt.COID = DelProvExc.COID
		AND DelProvExc.[Enabled] = 1
WHERE t.TrType = ''EncPostedPaid''
            AND (
			(' + @RegionID + ' <> 3 AND t.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t.modifieddate < @EndRunDate)
			OR
			(' + @RegionID + ' = 3 AND t.modifiedDate > @StartRunDate_R03 AND t.modifiedDate < @EndRunDate_R03)
			)
ORDER BY T.id
';



IF @print_sql = 'y'
	BEGIN
		PRINT @SQL1 
		PRINT @SQL2
		PRINT @SQL3
		PRINT @SQL4
	END
ELSE
	BEGIN
		EXEC(@SQL1 + @SQL2 + @SQL3 + @SQL4);
	END

END
GO





IF OBJECT_ID('[ecwStage].[HostGL_eCW_REVENUE]', 'P') IS NOT NULL
	DROP PROC [ecwStage].[HostGL_eCW_REVENUE]
GO

CREATE PROC [ecwStage].[HostGL_eCW_REVENUE]
	@GLJobRunID int
	,@print_sql char(1) = 'n'
AS
BEGIN

/********************************************************************************************
Procedure: [ecwStage].[HostGL_eCW_REVENUE]

Parameters: @GLJobRunID  INT    -- Record ID in table eCWStage.[AUDIT].GLRegionJobRun to reference for needed variables
			@print_sql char     -- argument to print sql statement rather than execute, default to 'n', enter 'y' for print

Original Developer:	 

Original Purpose:	To extract eCW Revenue
					
Original Date:		 

Unit Test/Execution Example:
	exec [ecwStage].[HostGL_eCW_REVENUE] 1
	(to execute sql statement)
	or 
	exec [ecwStage].[HostGL_eCW_REVENUE] 1, 'y'
	(to print sql statement instead of executing it)

Modification:
Date			Developer		Modification						
---------		---------		--------------------------------------------------
5/10/2010		VAM				Modified for MultiRegion changes
10/07/2010		ESH				Added code to null out bad COID
10/08/2010		ESH				Added code to make sure a character type FIN class will pass through cleanly
								By putting '' around 99 in the coallesce. 
12/06/2010		ESH				Changed RenProviderID to DOSProviderID, 
								changed output columns to InvServicingProviderID and InsServicingProviderName
2/2/2011		ESH				Added code to allow for sales tax and taxable items mapping and revenue								
4/19/2012		BBA				Added @StartRunDate_R03, @EndRunDate_R03 for region 3 filter in Where Clause, region 3 is on Mountain time (-1hr) and rows entered between 11PM-12AM were not getting posted to the GL 
11/8/2012		JRP				Changed where clause to avoid using upper (non sargeable filter)
1/18/2019		JMW				Modified for Region Split
*********************************************************************************************/
SET NOCOUNT ON;
DECLARE @ServerName VARCHAR(256);
DECLARE @RegionID VARCHAR(25);
DECLARE @StartRunDate DATETIME;
DECLARE @DatabaseName VARCHAR(50);;
DECLARE @SQL1 VARCHAR(8000);
DECLARE @SQL2 VARCHAR(8000);	
DECLARE @SQL3 VARCHAR(8000);	
SET @RegionID = (select RegionID from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @StartRunDate = (select MaxTransactionDate from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @ServerName = (select ServerName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @DatabaseName = (select DatabaseName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);

SET @SQL1 = '
DECLARE @ETLPackageName VARCHAR(50);
DECLARE @EndRunDate DATETIME; 
DECLARE	@LastDay DATETIME;
DECLARE @StartRunDate_R03 DATETIME;
DECLARE @EndRunDate_R03 DATETIME;
SET @ETLPackageName = (select JobName from ' + @ServerName + '.eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = ' + CAST(@GLJobRunID AS VARCHAR(10)) + ');
SET @EndRunDate = dateadd(day, datediff(day, 0, getdate()), 0);
SELECT @LastDay = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEDIFF(dd,1,@EndRunDate))+1,0)));
SELECT @StartRunDate_R03 = DATEADD(hh,-1,''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''');
SELECT @EndRunDate_R03 = DATEADD(hh,-1,@EndRunDate) ';


SET @SQL2 = '
SELECT
	''eCW'' AS SourceSystemCode
	, ''' + @RegionID + ''' AS SourceServer --5/10/2010 VAM - Modified for MultiRegion changes
	, T.id AS SourceTransactionID
	, @EndRunDate AS ETLDate
	, T.modifieddate AS TransactionDate
	, T.trtype AS SourceTrType
	, CptTrType.TrType AS FamiliarTrType
	, @LastDay AS PostingPeriod
	, Cast((T.amount * CptStg.Rate) As money) AS TransactionAmount
	, NULL AS ExceptionRecordFlag
	, Case
		When CptExc.COID Is Not Null AND CptExc.[Enabled] = 1 Then 1
		Else 0
		END AS ExcludedCOID
	, NEWID() AS AuditItemId --uniqueidentifier
	, @ETLPackageName As ETLPackageName
----------------------------------------
	, SUBSTRING(CptEnt.COID, 1, 8) AS SourceCOID
	, SUBSTRING(CptCoMast.COID, 1, 8) AS CoMastCOID
	, SUBSTRING(CptEnt.DeptCode, 1, 8) AS DepartmentCode
	, CAST(CASE 
			WHEN (LEFT(LOWER(CptStg.HCPCSCode),1) = ''x'') THEN						--ESH 2/2/2011
				LTRIM(RTRIM(CptAcctX.Account)) + RIGHT(RTRIM(CptEnt.DeptCode), 2)
			WHEN LEN(CptAcctX.Account) = 4 
			THEN LEFT(LTRIM(RTRIM(CptAcctX.Account)),1) 
				+ RIGHT(RTRIM(Cast(CptEnt.DeptCode AS VarChar)), 2) 
				+ RIGHT(LTRIM(RTRIM(CptAcctX.Account)),3)
			ELSE CptAcctX.Account
		END AS VarChar (6)) AS Account
	, LTRIM(RTRIM(CptAcctX.Account)) As SourceAccount	
	, CptInv.Id As InvoiceId
	, CptInv.EncounterId As EncounterId
	, CptFac.Id As FacilityId
	, CptFac.Name As FacilityName
	, CptInv.PracticeId As PracticeId
	, Cpt_U_EncProvider.[uid] As ApptEncProviderId --Int
	, SUBSTRING(Cpt_U_EncProvider.ulname + '', '' + Cpt_U_EncProvider.ufname, 1, 50) As ApptEncProviderName --varchar (50)
	, Cpt_U_Provider.[uid] As InvServicingProviderId --Int
	, SUBSTRING(Cpt_U_Provider.ulname + '', '' + Cpt_U_Provider.ufname, 1, 50) As InvServicingProviderName --varchar (50)
	, Cpt_U_Patient.[uid] As PatientId --Int
	, SUBSTRING(Cpt_U_Patient.ulname + '', '' + Cpt_U_Patient.ufname, 1, 50) As PatientName --varchar (50)
	, CAST(CptIns.InsuranceName AS VarChar(40)) As PatientPrimaryInsurance	--varchar(40)
----------------------------------------
	, NULL As PaymentID --[int]
	, NULL As PaymentIDDeleted -- [bit]
	, NULL As PaymentCode --char(5)
	, NULL As PaymentCodeDeleted --bit
	, NULL As PayerName --varchar (40)
	, NULL As PayerFinClassCode --char(2)
	, NULL As AdjustmentCode --char (5)
	, NULL As AdjustmentCodeDeleted --bit
	, ''NA'' As SourceCOIDLookupPath --varchar(25)*/
--**************************************************
	, NULLIF(CAST(CptStg.HCPCSCode AS VARCHAR(5)),'''')  As SourceCPTHCPCS -- [char] (5)
	, NULLIF(CAST(cpt.Mod1 AS VARCHAR(2)), '''') As SourceCPTModifier -- [char] (2)
	, CptStg.PaymentRateCode As PaymentRateCode -- [char] (2)
	, Case When CptStg.RevenueType = ''Revenue Ancillary'' Then CptStg.Rate
			Else NULL End AS AncillaryRate --[decimal] (10, 7)
	, Case When CptStg.RevenueType = ''Revenue Professional'' Then CptStg.Rate
			Else NULL End As ProfessionalRate -- [decimal] (10, 7)
--**************************************************
	, CptInv.VoidFlag AS InvoiceVoidFlag --tinyint
	--, CAST(CptInvIns.InsuranceClass AS Char(2)) As ''InvoiceFinClassCode'' --char(2)
	, CAST(CASE 
			WHEN  CptStg.HCPCSCode = ''S9999'' THEN								--ESH 2/2/2011
				''99'' 
			WHEN (LEFT(LOWER(CptStg.HCPCSCode),1) = ''x'') THEN			--ESH 2/2/2011
				''99''			
		    ELSE 
				ISNULL(NULLIF(CptInvIns.InsuranceClass, ''''), ''99'')
		   END AS Char(2)) As InvoiceFinClassCode
	, CptPOS.POSCode As InvoicePOSCode --[smallint]
	, NULL As Unapplied_ParentOrgID -- [int]
	, NULL As Unapplied_ParentOrgName-- [varchar] (50)
	, NULL As Unapplied_InsPaymentId --[int]
';


SET @SQL3 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions as t
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_cpt AS cpt
		ON t.TrRefId = cpt.Id		
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS CptInv
		ON Cpt.InvoiceId = CptInv.Id
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisecoidmgt AS CptEnt
		ON CptInv.invfacilityid = CptEnt.facilityid
		AND CptInv.dosproviderid = CptEnt.providerid --ESH Changed 12/6 for Rendering to Servicing
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS CptCoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(CptEnt.COID))) = 1  ) AND (LEN(CptEnt.COID) <= 5) 
				THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(CptEnt.COID)) AS VARCHAR(5)), 5) 
				ELSE NULL END = CptCoMast.COID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS CptExc
		ON CptEnt.COID = CptExc.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as CptFac
		ON CptInv.invfacilityid = CptFac.id
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enc As CptEnc
		ON CptInv.encounterid = CptEnc.encounterid
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Cpt_U_Patient
		ON Cpt_U_Patient.uid = CptInv.patientid
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Cpt_U_Provider
		ON Cpt_U_Provider.uid = CptInv.DOSProviderID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.users AS Cpt_U_EncProvider
		ON Cpt_U_EncProvider.uid = CptEnc.doctorid
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS CptInsDet
		ON CptInsDet.[ID] = (SELECT TOP (1) [ID]
                                FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurancedetail] AS B
                                WHERE b.[pid] = Cpt_U_Patient.[uid]
									AND B.DeleteFlag = 0
                                ORDER BY [SeqNo] ASC, Id DESC)
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS CptIns
		ON CptInsDet.[insid] = CptIns.[insId]
		AND CptIns.deleteFlag = 0
	--left join ' + @ServerName + '.' + @DatabaseName + '.dbo.ins_payer_mix AS CptInsCl
	--	on ISNULL(CptIns.InsuranceClass, ''99'') = CptInsCl.code
	--	AND CptInsCl.deleteFlag = 0	
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.[insurance] AS CptInvIns
		ON CptInv.PrimaryInsId = CptInvIns.[insId]
		AND CptInvIns.deleteFlag = 0
    LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLPOSCodes as CptPOS
		ON CptInv.InvPOS = CptPOS.POSCode
    LEFT JOIN (	SELECT * FROM 
			   (SELECT 
					  SourceTransactionID
					, HCPCSCode
					, PaymentRateCode
					, [Revenue Ancillary]
					, [Revenue Professional]
			   FROM 
					(
					   SELECT T2.id AS SourceTransactionID
						, CASE 
							WHEN  NULLIF(cptStg.HCPCSCode,'''') IS NULL THEN 
							   NULL
							ELSE
								NULLIF(cpt.code ,'''')
							END   As HCPCSCode -- [char] (5)
						, ISNULL(CptPOS.PaymentRateCode, ''NF'') As ''PaymentRateCode'' -- [char] (2)
						, Case
							When NULLIF(CptStg.HCPCSCode, '''') IS NULL
								Then 1
								Else Case When ISNULL(CptPOS.PaymentRateCode, ''NF'') = ''NF''
									Then Case When CptStg.NonFacAncillary <> 0 
											Then CptStg.NonFacAncillary
											Else Null
											END
								Else Case When CptStg.FacAncillary <> 0 
											Then CptStg.FacAncillary 
											Else NULL
											End
								End
								End AS ''REVENUE ANCILLARY'' --[decimal] (10, 7)
						, Case 
							When ISNULL(CptPOS.PaymentRateCode, ''NF'') = ''NF''
								Then Case When CptStg.NonFacProfessional <> 0 
										Then CptStg.NonFacProfessional
										Else Null
										End
								Else Case When CptStg.FacProfessional <> 0 
										Then CptStg.FacProfessional
										Else NULL
										End
								End As ''REVENUE PROFESSIONAL'' -- [decimal] (10, 7)
					FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.transactions as t2
						LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_cpt AS cpt ON t2.TrRefId = cpt.Id
						LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_invoice AS CptInv ON Cpt.InvoiceId = CptInv.Id
						LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLPOSCodes as CptPOS ON CptInv.InvPOS = CptPOS.POSCode
						LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCPTCodes AS CptStg
							ON CptStg.HCPCSCode	= 
							  CASE       
								  WHEN ((left(LOWER(cpt.code),1) = ''x''  ) AND (CptStg.HCPCSCode = ''xNNNN''))  THEN 
										 ''xNNNN''
								  ELSE 
										 cpt.code 
								  END 
							AND (select case When cptB.Mod1 = ''26'' Then ''26''
												When cptB.Mod1 = ''TC'' Then ''TC''
												Else ''NULL'' End AS Modifier
									FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inv_cpt AS cptB
									Where cptB.Id = cpt.id
										) = ISNULL(CptStg.[Mod], ''NULL'')
					WHERE   
					( (' + @RegionID + ' <> 3 AND t2.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t2.modifieddate < @EndRunDate)
						OR
						(' + @RegionID + ' = 3 AND t2.modifiedDate > @StartRunDate_R03 AND t2.modifiedDate < @EndRunDate_R03)
					  ) AND t2.trtype = ''charges''
				   ) x
			   ) DeNorm
			UNPIVOT (Rate FOR RevenueType IN ([Revenue Ancillary], [Revenue Professional])
			) as temp ) CptStg ON t.id = CptStg.SourceTransactionId

	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList As CptTrType
		ON CptStg.RevenueType = CptTrType.TrType
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS CptAcctX
		ON  ISNULL(CptAcctX.FinancialClassCode, ''99'') = 
		  CASE 
			WHEN  CptStg.HCPCSCode = ''S9999'' THEN	
				''77'' 
			WHEN (LEFT(LOWER(CptStg.HCPCSCode),1) = ''x'') THEN	
				''78''			
		    ELSE 
				ISNULL(NULLIF(CptInvIns.InsuranceClass, ''''), ''99'')
		   END 
		AND CptTrType.TrTypeId = CptAcctX.TrTypeID 
----------------------------------------------------------
WHERE (
	(' + @RegionID + ' <> 3 AND t.modifieddate > ''' + CONVERT(VARCHAR(23), @StartRunDate, 121) + ''' AND t.modifieddate < @EndRunDate)
	OR
	(' + @RegionID + ' = 3 AND t.modifiedDate > @StartRunDate_R03 AND t.modifiedDate < @EndRunDate_R03)
	)
	AND t.trtype = ''charges''
order by t.id
';

IF @print_sql = 'y'
	BEGIN
		PRINT @SQL1; 
		PRINT @SQL2;
		PRINT @SQL3;
	END
ELSE
	BEGIN
		EXEC(@SQL1 + @SQL2 + @SQL3);
	END

END
GO



IF OBJECT_ID('[ecwStage].[HostGL_eCW_UNAPPLIEDPAYMENTS]', 'P') IS NOT NULL
	DROP PROC [ecwStage].[HostGL_eCW_UNAPPLIEDPAYMENTS]
GO

CREATE PROCEDURE [ecwStage].[HostGL_eCW_UNAPPLIEDPAYMENTS]
	@GLJobRunID int
	,@print_sql char(1) = 'n'
AS 
begin
/********************************************************************************************
Procedure: [ecwStage].[HostGL_eCW_UNAPPLIEDPAYMENTS]

Parameters: @GLJobRunID  INT    -- Record ID in table eCWStage.[AUDIT].GLRegionJobRun to reference for needed variables
			@print_sql char     -- argument to print sql statement rather than execute, default to 'n', enter 'y' for print

Original Developer:	 

Original Purpose:	To extract eCW Unapplied Payments 
					
Original Date:		 

Unit Test/Execution Example:
	exec [ecwStage].[HostGL_eCW_UNAPPLIEDPAYMENTS] 1
	(to execute sql statement)
	or 
	exec [ecwStage].[HostGL_eCW_UNAPPLIEDPAYMENTS] 1, 'y'
	(to print sql statement instead of executing it)

Modification:
Date			Developer		Modification						
---------		---------		--------------------------------------------------
5/10/2010		VAM				Modified for MultiRegion changes
10/07/2010		ESH				Added code to null out bad COID 
12/06/2010		ESH				changed output columns to InvServicingProviderID and InsServicingProviderName
1/21/2019		JMW				Modified for Region Split
*********************************************************************************************/
SET NOCOUNT ON;
DECLARE @ServerName VARCHAR(256);
DECLARE @RegionID VARCHAR(25);
DECLARE @DatabaseName VARCHAR(50);;
DECLARE @SQL1 VARCHAR(8000);
DECLARE @SQL2 VARCHAR(8000);	
DECLARE @SQL3 VARCHAR(8000);	
SET @RegionID = (select RegionID from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @ServerName = (select ServerName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);
SET @DatabaseName = (select DatabaseName from eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = @GLJobRunID);


SET @SQL1 = '
DECLARE @ETLPackageName VARCHAR(50);
DECLARE @EndRunDate DATETIME; 
DECLARE	@LastDay DATETIME;
SET @ETLPackageName = (select JobName from ' + @ServerName + '.eCWStage.[AUDIT].GLRegionJobRun where GLJobRunID = ' + CAST(@GLJobRunID AS VARCHAR(10)) + ');
SET @EndRunDate = dateadd(day, datediff(day, 0, getdate()), 0);
SELECT @LastDay = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEDIFF(dd,1,@EndRunDate))+1,0)));
';


SET @SQL2 = '
SELECT ''eCW'' AS SourceSystemCode ,
            ''' + @RegionID + ''' AS SourceServer , 
            PmtInsPayments.paymentId AS SourceTransactionID , 
            @EndRunDate AS ETLDate ,
            PmtInsPayments.modifieddate AS TransactionDate ,
            ''Unapplied Payment'' AS SourceTrType ,
            PmtTrType.TrType AS FamiliarTrType ,
            @LastDay AS PostingPeriod ,
            SUM(PmtInsPayments.UnpostedAmount) AS TransactionAmount ,
            NULL AS ExceptionRecordFlag ,
            CASE WHEN Exc.COID IS NULL THEN 0
                 ELSE 1
            END AS ExcludedCOID ,
            NEWID() AS AuditItemId ,
            @ETLPackageName AS ETLPackageName ,
            SUBSTRING(CASE WHEN ed1.OrgId IS NULL THEN ''25537''
                           ELSE p.COID
                      END, 1, 8) AS SourceCOID ,
            SUBSTRING(CoMast.COID, 1, 8) AS CoMastCOID ,
            NULL AS DepartmentCode ,
            PmtAcctX.Account AS Account ,
            PmtAcctX.Account AS SourceAccount ,
            NULL AS InvoiceId ,
            NULL AS EncounterId ,
            PmtInsPayments.facilityid AS FacilityId ,
			Fac.Name AS FacilityName ,
            p.Id AS PracticeId ,
            NULL AS ApptEncProviderId ,
            NULL AS ApptEncProviderName ,
            NULL AS InvServicingProviderId ,
            NULL AS InvServicingProviderName ,
            NULL AS PatientId ,
            NULL AS PatientName ,
            NULL AS PatientPrimaryInsurance ,
            NULL AS PaymentID ,
            NULL AS PaymentIDDeleted ,
            NULL AS PaymentCode ,
            NULL AS PaymentCodeDeleted ,
            NULL AS PayerName ,
            NULL AS PayerFinClassCode ,
            NULL AS AdjustmentCode ,
            NULL AS AdjustmentCodeDeleted ,
            NULL AS SourceCOIDLookupPath ,
            NULL AS SourceCPTHCPCS ,
            NULL AS SourceCPTModifier ,
            NULL AS PaymentRateCode ,
            NULL AS AncillaryRate ,
            NULL AS ProfessionalRate ,
            NULL AS InvoiceFinClassCode ,
            NULL AS InvoicePOSCode ,
            ed2.OrgId AS Unapplied_ParentOrgID , 
            CAST(p.name AS VarChar(50)) AS Unapplied_ParentOrgName , 
            PmtInsPayments.PaymentId AS Unapplied_InsPaymentId ,
            NULL AS InvoiceVoidFlag --tinyint
';



SET @SQL3 = '
FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_inspayments AS PmtInsPayments
	LEFT JOIN (SELECT ed1.OrgId,					
					ed1.parentId,
					ed1.orgtype
                FROM   ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisedirectory ed1
                WHERE  ed1.OrgId <> 0
						AND ed1.orgtype = ''Facility''
						AND OrgId NOT IN (
										SELECT ed1.OrgId
										FROM ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisedirectory ed1
											LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisedirectory ed2
											ON ed2.id = ed1.parentId											
										WHERE ed2.orgtype = ''Practice''
											OR ed1.orgtype = ''Facility''
										GROUP BY ed1.orgid												
										HAVING COUNT(ed1.orgid) > 1)
				) ed1
		ON PmtInsPayments.facilityid = ed1.OrgId
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.enterprisedirectory ed2
		ON ed2.id = ed1.parentId
		-- this join is to get the coid
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.practice p
		ON p.id = ed2.OrgId
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCompanyMaster AS CoMast
		ON CASE WHEN (ISNUMERIC(LTRIM(RTRIM(P.COID))) = 1  ) AND (LEN(P.COID) <= 5) 
					THEN RIGHT(''00'' + CAST(LTRIM(RTRIM(P.COID)) AS VARCHAR(5)), 5) 
					ELSE NULL END = CoMast.COID
	LEFT JOIN ' + @ServerName + '.' + @DatabaseName + '.dbo.edi_facilities as Fac
		ON PmtInsPayments.facilityid = Fac.id
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLTrTypeList PmtTrType
		ON PmtTrType.TrTypeId = 20
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLAcctXwalk AS PmtAcctX
		ON PmtTrType.TrTypeId = PmtAcctX.TrTypeID
	LEFT JOIN ' + @ServerName + '.ecwstage.ecwstage.StgHostGLCOIDExclusion AS Exc
		ON p.COID = CAST(Exc.COID AS VARCHAR(10))
WHERE PmtInsPayments.deleteflag = 0
            AND PmtInsPayments.unpostedamount <> 0
GROUP BY	PmtInsPayments.paymentId ,
            PmtInsPayments.modifieddate ,
            PmtTrType.TrType,
            CASE WHEN Exc.COID IS NULL THEN 0
                 ELSE 1
            END ,
            SUBSTRING(CASE WHEN ed1.OrgId IS NULL THEN ''25537''
                           ELSE p.COID
                      END, 1, 8) ,
            CoMast.COID,
            PmtAcctX.Account ,
            p.Id ,
            Fac.Name,
            ed2.OrgId,
            p.Name ,
            PmtAcctX.DebitCreditFlag ,
            PmtInsPayments.facilityid 
ORDER BY sourcecoid
';


IF @print_sql = 'y'
	BEGIN
		PRINT @SQL1; 
		PRINT @SQL2;
		PRINT @SQL3;
	END
ELSE
	BEGIN
		EXEC(@SQL1 + @SQL2 + @SQL3);
	END

end
go
