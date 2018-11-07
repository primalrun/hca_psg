--use NADCWPDBSAGL01
--This query maps the effect of the stored procedure [ECW].[HostGL_eCW_ADJUSTMENTS_EX] on table ECW.StgHostGLDetail
--The mapping result is displayed in the field ExceptionReason
--The result is filtered for records where the ExceptionRecordFlag should = 1 based on the stored procedure, but has a 0

select
	*
from (
select	
	case
		when
			g.SourceCOID IS NULL
			OR g.SourceCOID = 0
			OR g.CoMastCOID IS NULL
			OR g.Account IS NULL
			OR g.Account = '0'
		then 'Missing COID or Account'
		when
			(LEN(g.SourceAccount) = 4 AND g.DepartmentCode IS NULL)
			OR (LEN(g.SourceAccount) = 4 AND LEN(LTRIM(RTRIM(g.DepartmentCode))) < 2)
			OR (LEN(g.SourceAccount) = 4 AND ISNUMERIC(g.DepartmentCode) = 0)
		then 'Department Code used to make Account'
		when
			g.SourceTransactionID in (			
				select
					g.SourceTransactionID
				from ECW.StgHostGLDetail g
				group by
					g.SourceTransactionID,
					g.SourceSystemCode,
					g.SourceServer
				having
					count(*) > 1)
		then 'SourceTransactionID - Multiple Record Count'
		else 'No Exception'
	end as ExceptionReason
	,g.SourceSystemCode
	,g.SourceServer	
	,g.SourceTransactionID
	,g.ExceptionRecordFlag
	,g.SourceTrType
	,g.SourceCOID
	,g.CoMastCOID
	,g.Account
	,g.SourceAccount
	,g.DepartmentCode
	,g.FamiliarTrType
	,g.ETLDate
	,g.TransactionDate
	,g.TransactionAmount
from ECW.StgHostGLDetail g
) g1
where
	g1.ExceptionReason <> 'No Exception'
	and g1.ExceptionRecordFlag = 0
	