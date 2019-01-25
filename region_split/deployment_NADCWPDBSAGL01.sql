USE [AccountingAutomation]
GO

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

