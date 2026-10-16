--How many coutries on the list?
SELECT DISTINCT
    COUNT(Area) AS Total_Countries
FROM health_expenditure_table_1;

--How many times the highest-spending country spends compared with the lowest-spending country in each year
WITH YearlySpending AS (
    SELECT Area, 2020 AS Year, Year_2020 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2021 AS Year, Year_2021 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2022 AS Year, Year_2022 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2023 AS Year, Year_2023 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2024 AS Year, Year_2024 AS Spending
    FROM health_expenditure_table_1
),
RankedSpending AS (
    SELECT
        area,
        Year,
        Spending,
        ROW_NUMBER() OVER (
            PARTITION BY Year
            ORDER BY Spending DESC
        ) AS HighestRank,
        ROW_NUMBER() OVER (
            PARTITION BY Year
            ORDER BY Spending ASC
        ) AS LowestRank
    FROM YearlySpending
    WHERE Spending IS NOT NULL
),
YearlySummary AS (
    SELECT
        Year,
        MAX(Spending) AS Highest_Spending,
        MIN(Spending) AS Lowest_Spending,
        ROUND(
            MAX(Spending) * 1.0 /
            NULLIF(MIN(Spending), 0),
            0
        ) AS Spending_Ratio
    FROM YearlySpending
    WHERE Spending IS NOT NULL
    GROUP BY Year
)
SELECT
    s.Year,
    h.Area AS Highest_Spending_Country,
    s.Highest_Spending,
    l.Area AS Lowest_Spending_Country,
    s.Lowest_Spending,
    s.Spending_Ratio
FROM YearlySummary s
JOIN RankedSpending h
    ON s.Year = h.Year
    AND h.HighestRank = 1
JOIN RankedSpending l
    ON s.Year = l.Year
    AND l.LowestRank = 1
ORDER BY s.Year;

--Which five countries have the highest health expenditure in 2020?
SELECT TOP 5
    Area,
    Year_2020 AS Health_Expenditure_2020
FROM health_expenditure_table_1
WHERE Year_2020 IS NOT NULL
ORDER BY Year_2020 DESC;

--Which five countries have the highest health expenditure in 2021?
SELECT TOP 5
    Area,
    Year_2021 AS Health_Expenditure_2021
FROM health_expenditure_table_1
WHERE Year_2021 IS NOT NULL
ORDER BY Year_2021 DESC;

--Which five countries have the highest health expenditure in 2022?
SELECT TOP 5
    Area,
    Year_2022 AS Health_Expenditure_2022
FROM health_expenditure_table_1
WHERE Year_2022 IS NOT NULL
ORDER BY Year_2022 DESC;

--Which five countries have the highest health expenditure in 2023?
SELECT TOP 5
    Area,
    Year_2023 AS Health_Expenditure_2023
FROM health_expenditure_table_1
WHERE Year_2023 IS NOT NULL
ORDER BY Year_2023 DESC;

--Which five countries have the highest health expenditure in 2024?
SELECT TOP 5
    Area,
    Year_2024 AS Health_Expenditure_2024
FROM health_expenditure_table_1
WHERE Year_2024 IS NOT NULL
ORDER BY Year_2024 DESC;

----The highest to lowest money spending per capita in the timeline from 2020 to 2024?
WITH YearlySpending AS (
    SELECT Area, 2020 AS Year, Year_2020 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2021 AS Year, Year_2021 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2022 AS Year, Year_2022 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2023 AS Year, Year_2023 AS Spending
    FROM health_expenditure_table_1

    UNION ALL

    SELECT Area, 2024 AS Year, Year_2024 AS Spending
    FROM health_expenditure_table_1
)
SELECT Area, Year, Spending
FROM YearlySpending
ORDER BY Spending DESC;

-- Which countries have the fastest healthcare spending growth?
SELECT
    Area,
    Year_2020,
    Year_2024,
    (Year_2024 - Year_2020) * 100.0
        / NULLIF(Year_2020, 0) AS Growth_Rate_Percentage
FROM health_expenditure_table_1
WHERE Year_2020 IS NOT NULL
  AND Year_2024 IS NOT NULL
  AND Year_2020 > 0
ORDER BY Growth_Rate_Percentage DESC;

--Which countries contribute most to total healthcare spending?
WITH CountrySpending AS (
    SELECT
        Area,
        (
            COALESCE(Year_2020, 0) +
            COALESCE(Year_2021, 0) +
            COALESCE(Year_2022, 0) +
            COALESCE(Year_2023, 0) +
            COALESCE(Year_2024, 0)
        ) * 1.0 /
        NULLIF(
            (CASE WHEN Year_2020 IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN Year_2021 IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN Year_2022 IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN Year_2023 IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN Year_2024 IS NOT NULL THEN 1 ELSE 0 END),
            0
        ) AS Avg_Spending_Per_Capita
    FROM health_expenditure_table_1
)
SELECT TOP 10
    Area,
    Avg_Spending_Per_Capita,
    ROUND(Avg_Spending_Per_Capita * 100.0 /
        NULLIF(SUM(Avg_Spending_Per_Capita) OVER (), 0),2,0)
        AS Percentage_Of_Combined_Values
FROM CountrySpending
WHERE Avg_Spending_Per_Capita IS NOT NULL
ORDER BY Percentage_Of_Combined_Values DESC;
