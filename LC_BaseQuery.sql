WITH Claims AS
	(
	 SELECT 
		DISTINCT 
		[File Num],
		[PL ID],
		[VRU Policy Number], 
		[ProductCode],
		[Loss County],
		[PerilBin],
		[Date of Loss_x],
		[Date Rep to Sedgwick],
		[Date Clm Closed],
		[Assignment of Benefi] AS AOB,
		'N/A' AS [Date of AOB],
		[Plaintiff Original Demand],
		COALESCE(STR([Plaintiff Original Demand],20,2), 'N/A') AS [Assignee's Presuit Settlement Demand],
		'N/A' AS [Insurer's Presuit Settlement Offer],
		[Final Settlement Amt - TOTAL],
		COALESCE(STR([Final Settlement Amt - TOTAL],20,2), 'N/A') AS [Judgment Obtained by Assignee],
		CASE 
			WHEN [Final Settlement Amt - TOTAL] IS NOT NULL THEN 'Y'
			WHEN [Final Settlement Amt - TOTAL] IS NULL THEN 'N'
		END AS [Litigation?],
		[Pd Ind] AS PaidIndemnity,
		[Net Exp Pd] AS ALAE,
		a.[Class of Business],
		CASE 
			WHEN a.[Class of Business] = 'Condominium' THEN 'CRC'
			WHEN a.[Class of Business] IN ('Apartments','Assisted Living') THEN 'CRO'
			ELSE 'CNR'
		END AS 'Type of Policy',
		[SNIC Policy Number (Admitted)],
		[SNIC Participation],
		[USIC Policy Number (Non-Admitted)],
		[USIC Participation],
		[ISIC Policy Number],
		[ISIC Participation]
	 FROM [Analyst_RL].[dbo].[ml_parsed_2020-03-13] AS a
		  RIGHT JOIN [Analyst_RL].[dbo].[AOB_AllClaims_2020-03-19] AS b
		  ON right(replace(a.[VRU Policy Number],'-',''),8)=right(replace(b.[Certificate Reference],'-',''),8)
		  WHERE b.[Coverholder Name] LIKE '%Commer%' 
		 AND (
			[SNIC Policy Number (Admitted)] IS NOT NULL
			  OR [USIC Policy Number (Non-Admitted)] IS NOT NULL
			  OR [ISIC Policy Number] IS NOT NULL
			  )
		--ORDER BY  a.[VRU Policy Number]
	)
,
Cov AS 
	(
	SELECT [ContractID]
      ,[Coverage_A]
      ,[Source]
      ,[ContractSID]
	FROM [Analyst_MT].[dbo].[FL_LC_CovA]
	)
,
Staging AS
	(
	SELECT
	Cl.*,
	CASE 
		WHEN [SNIC Participation] IS NOT NULL THEN 'SNIC'
		WHEN [USIC Participation] IS NOT NULL THEN 'USIC'
		WHEN [ISIC Participation] IS NOT NULL THEN 'ISIC'
		END AS 'FinalPaper',
	CASE 
		WHEN Cl.[SNIC Participation] IS NOT NULL THEN CONVERT(FLOAT, Cl.[SNIC Participation]) * Cl.PaidIndemnity
		WHEN Cl.[USIC Participation] IS NOT NULL THEN CONVERT(FLOAT, Cl.[USIC Participation]) * Cl.PaidIndemnity
		WHEN Cl.[ISIC Participation] IS NOT NULL THEN CONVERT(FLOAT, Cl.[ISIC Participation]) * Cl.PaidIndemnity
		END AS 'Split_PaidIndemnity',
	CASE 
		WHEN Cl.[SNIC Participation] IS NOT NULL THEN CONVERT(FLOAT, Cl.[SNIC Participation]) * Cl.ALAE
		WHEN Cl.[USIC Participation] IS NOT NULL THEN CONVERT(FLOAT, Cl.[USIC Participation]) * Cl.ALAE
		WHEN Cl.[ISIC Participation] IS NOT NULL THEN CONVERT(FLOAT, Cl.[ISIC Participation]) * Cl.ALAE
		END AS 'Split_ALAE',
	CASE 
		WHEN Cl.[SNIC Participation] IS NOT NULL AND Cl.[Plaintiff Original Demand] IS NOT NULL 
			THEN LTRIM(STR(CONVERT(FLOAT, Cl.[SNIC Participation]) * Cl.[Plaintiff Original Demand], 50, 2))
		WHEN Cl.[USIC Participation] IS NOT NULL AND Cl.[Plaintiff Original Demand] IS NOT NULL 
			THEN LTRIM(STR(CONVERT(FLOAT, Cl.[USIC Participation]) * Cl.[Plaintiff Original Demand], 50, 2))
		WHEN Cl.[ISIC Participation] IS NOT NULL AND Cl.[Plaintiff Original Demand] IS NOT NULL 
			THEN LTRIM(STR(CONVERT(FLOAT, Cl.[ISIC Participation]) * Cl.[Plaintiff Original Demand], 50, 2))
		ELSE 'N/A'
		END AS [Split Assignee's Presuit Settlement Demand],
	CASE 
		WHEN Cl.[SNIC Participation] IS NOT NULL AND Cl.[Final Settlement Amt - TOTAL] IS NOT NULL 
			THEN LTRIM(STR(CONVERT(FLOAT, Cl.[SNIC Participation]) * Cl.[Final Settlement Amt - TOTAL], 50, 2))
		WHEN Cl.[USIC Participation] IS NOT NULL AND Cl.[Final Settlement Amt - TOTAL] IS NOT NULL 
			THEN LTRIM(STR(CONVERT(FLOAT, Cl.[USIC Participation]) * Cl.[Final Settlement Amt - TOTAL], 50, 2))
		WHEN Cl.[ISIC Participation] IS NOT NULL AND Cl.[Final Settlement Amt - TOTAL] IS NOT NULL 
			THEN LTRIM(STR(CONVERT(FLOAT, Cl.[ISIC Participation]) * Cl.[Final Settlement Amt - TOTAL], 50, 2))
		ELSE 'N/A'
		END AS [Split Judgment Obtained by Assignee],
	Cov.Coverage_A
	FROM Claims AS Cl
	LEFT JOIN Cov
	ON Cl.[VRU Policy Number] = Cov.ContractID
	)

SELECT * INTO [Analyst_RL].[dbo].[AOB_LC_Complete_2020-03-23] FROM (
	SELECT 
	FinalPaper,
	[VRU Policy Number],
	[File Num] AS [Claim ID],
	[Type of Policy],
	[Loss County] AS [County of Loss],
	Coverage_A AS [Building Replacement Cost],
	PerilBin AS Peril,
	[Date of Loss_x],
	[Date Rep to Sedgwick],
	[Date Clm Closed],
	AOB,
	[Date of AOB],
	[Split Assignee's Presuit Settlement Demand],
	[Insurer's Presuit Settlement Offer],
	[Split Judgment Obtained by Assignee],
	[Litigation?],
	PaidIndemnity,
	ALAE

	FROM Staging
	)a
--Returns number of unique LC policies from relevant claims data
/*
SELECT DISTINCT *
FROM [Analyst_RL].[dbo].[AOB_AllClaims_2020-03-19]
 WHERE [Coverholder Name] LIKE '%Commer%'
 AND [PL ID]  IN (SELECT * FROM [Analyst_RL].[dbo].[LC_SN_True])
*/


