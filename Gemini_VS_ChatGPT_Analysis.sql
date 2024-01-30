-- 1)What are the average scores for each capability on both the Gemini Ultra and GPT-4 models?
SELECT CapabilityName, 
ROUND(AVG(ScoreGemini),0) AS Avg_Score_Gemini_Ultra , 
ROUND(AVG(ScoreGPT4),0) AS Avg_Score_GPT_4
FROM benchmarks B JOIN capabilities C ON B.CapabilityID = C.CapabilityID 
GROUP BY CapabilityName;

-- 2)Which benchmarks does Gemini Ultra outperform GPT-4 in terms of scores?
SELECT BenchmarkName 
FROM benchmarks 
WHERE ScoreGemini > ScoreGPT4;

-- 3)What are the highest scores achieved by Gemini Ultra and GPT-4 for each benchmark in the Image capability?
SELECT BenchmarkName,
MAX(ScoreGemini), MAX(ScoreGPT4) 
FROM benchmarks 
WHERE CapabilityID = 5 
GROUP BY BenchmarkName;

-- 4)Calculate the percentage improvement of Gemini Ultra over GPT-4 for each benchmark?
SELECT BenchmarkName, ROUND(((ScoreGemini - ScoreGPT4)/ScoreGPT4*100),0) AS Percentage_Improvement 
FROM benchmarks 
WHERE ScoreGPT4 IS NOT NULL;

-- 5)Retrieve the benchmarks where both models scored above the average for their respective models?
SELECT BenchmarkName, ScoreGemini, ScoreGPT4 FROM benchmarks
WHERE 
ScoreGemini > (SELECT AVG(ScoreGPT4) FROM  benchmarks) 
AND 
ScoreGPT4 > (SELECT AVG(ScoreGemini) FROM  benchmarks);

-- 6)Which benchmarks show that Gemini Ultra is expected to outperform GPT-4 based on the next score?
SELECT BenchmarkName, ScoreGemini, ScoreGPT4 
FROM benchmarks 
WHERE 
ScoreGemini > ScoreGPT4 
AND ScoreGPT4 IS NOT NULL;

-- 7)Classify benchmarks into performance categories based on score ranges?
SELECT BenchmarkName, 
CASE
	WHEN ScoreGemini >= 90.0 THEN "Excellent"
	WHEN ScoreGemini >= 80.0 THEN "Good"
	WHEN ScoreGemini >= 70.0 THEN "Average"
	WHEN ScoreGemini >= 60.0 THEN "Below Average"
	ELSE "Poor"
END AS PerformanceGemini,
CASE
	WHEN ScoreGPT4 >= 90.0 THEN "Excellent"
	WHEN ScoreGPT4 >= 80.0 THEN "Good"
	WHEN ScoreGPT4 >= 70.0 THEN "Average"
	WHEN ScoreGPT4 >= 60.0 THEN "Below Average"
	ELSE "Poor"
END AS PerformanceGPT4 
FROM benchmarks
WHERE ScoreGPT4 IS NOT NULL;

-- 8) Retrieve the rankings for each capability based on Gemini Ultra scores?
WITH CTE AS (
SELECT 
C.CapabilityName, B.BenchmarkName, B.ScoreGemini,
RANK() OVER (PARTITION BY C.CapabilityName ORDER BY B.ScoreGemini) AS GeminiUltraRank
FROM capabilities C
JOIN benchmarks B ON C.CapabilityID = B.CapabilityID
WHERE ScoreGPT4 IS NOT NULL
)
SELECT 
CapabilityName, BenchmarkName, ScoreGemini, GeminiUltraRank
FROM CTE
ORDER BY CapabilityName, GeminiUltraRank;

-- 9)Convert the Capability and Benchmark names to uppercase?
SELECT
UPPER(C.CapabilityName) AS Capability_Name,
UPPER(B.BenchmarkName) AS Benchmark_Name
FROM capabilities C
JOIN  benchmarks B ON C.CapabilityID = B.CapabilityID
GROUP BY CapabilityName, BenchmarkName ;

-- 10) Can you provide the benchmarks along with their descriptions in a concatenated format?
SELECT CONCAT( BenchmarkName, " : " , Description)
AS ConcatenationInfo
FROM benchmarks;


