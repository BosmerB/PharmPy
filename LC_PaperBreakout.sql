/****** Script for SelectTopNRows command from SSMS  ******/

SELECT * INTO [Analyst_RL].[dbo].[AOB_LC_Complete_SNIC_2020-03-23]
FROM
(
SELECT [FinalPaper]
      ,[VRU Policy Number]
      ,[Claim ID]
      ,[Type of Policy]
      ,[County of Loss]
      ,[Building Replacement Cost]
      ,[Peril]
      ,[Date of Loss_x]
      ,[Date Rep to Sedgwick]
      ,[Date Clm Closed]
      ,[AOB]
      ,[Date of AOB]
      ,[Split Assignee's Presuit Settlement Demand]
      ,[Insurer's Presuit Settlement Offer]
      ,[Split Judgment Obtained by Assignee]
      ,[Litigation?]
      ,[PaidIndemnity]
      ,[ALAE]
  FROM [Analyst_RL].[dbo].[AOB_LC_Complete_2020-03-23]
)_
WHERE FinalPaper = 'SNIC'

SELECT * INTO [Analyst_RL].[dbo].[AOB_LC_Complete_USIC_2020-03-23]
FROM
(
SELECT [FinalPaper]
      ,[VRU Policy Number]
      ,[Claim ID]
      ,[Type of Policy]
      ,[County of Loss]
      ,[Building Replacement Cost]
      ,[Peril]
      ,[Date of Loss_x]
      ,[Date Rep to Sedgwick]
      ,[Date Clm Closed]
      ,[AOB]
      ,[Date of AOB]
      ,[Split Assignee's Presuit Settlement Demand]
      ,[Insurer's Presuit Settlement Offer]
      ,[Split Judgment Obtained by Assignee]
      ,[Litigation?]
      ,[PaidIndemnity]
      ,[ALAE]
  FROM [Analyst_RL].[dbo].[AOB_LC_Complete_2020-03-23]
)_
WHERE FinalPaper = 'USIC'


SELECT * INTO [Analyst_RL].[dbo].[AOB_LC_Complete_ISIC_2020-03-23]
FROM
(
SELECT [FinalPaper]
      ,[VRU Policy Number]
      ,[Claim ID]
      ,[Type of Policy]
      ,[County of Loss]
      ,[Building Replacement Cost]
      ,[Peril]
      ,[Date of Loss_x]
      ,[Date Rep to Sedgwick]
      ,[Date Clm Closed]
      ,[AOB]
      ,[Date of AOB]
      ,[Split Assignee's Presuit Settlement Demand]
      ,[Insurer's Presuit Settlement Offer]
      ,[Split Judgment Obtained by Assignee]
      ,[Litigation?]
      ,[PaidIndemnity]
      ,[ALAE]
  FROM [Analyst_RL].[dbo].[AOB_LC_Complete_2020-03-23]
)_
WHERE FinalPaper = 'ISIC'