use [ecwStage]
go

set ansi_nulls on
go

set quoted_identifier on
go


if object_id('ecwStage.HostGL_GetTransaction', 'P') is not null
	drop proc ecwStage.HostGL_GetTransaction
go

if OBJECT_ID('ecwStage.HostGL_eCW_ADJUSTMENTS_SP', 'P') IS NOT NULL
	drop proc ecwStage.HostGL_eCW_ADJUSTMENTS_SP
go

if OBJECT_ID('ecwStage.HostGL_eCW_CONTRACTUALWRITEOFF_SP', 'P') IS NOT NULL
	drop proc ecwStage.HostGL_eCW_CONTRACTUALWRITEOFF_SP
go


if OBJECT_ID('ecwStage.HostGL_eCW_PAYMENTS_SP', 'P') IS NOT NULL
	drop proc ecwStage.HostGL_eCW_PAYMENTS_SP
go


if OBJECT_ID('ecwStage.HostGL_eCW_REVENUE_SP', 'P') IS NOT NULL
	drop proc ecwStage.HostGL_eCW_REVENUE_SP
go


if OBJECT_ID('ecwStage.HostGL_eCW_UNAPPLIEDPAYMENTS_SP', 'P') IS NOT NULL
	drop proc ecwStage.HostGL_eCW_UNAPPLIEDPAYMENTS_SP
go