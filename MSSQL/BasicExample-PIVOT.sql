-- Create sample sales data
CREATE TABLE #Sales (
    SalesPerson VARCHAR(50),
    Region VARCHAR(50),
    SalesAmount DECIMAL(10,2)
);

INSERT INTO #Sales VALUES
('John', 'North', 1000),
('John', 'South', 1500),
('John', 'East', 800),
('Mary', 'North', 1200),
('Mary', 'South', 900),
('Mary', 'East', 1100),
('Bob', 'North', 800),
('Bob', 'South', 1300),
('Bob', 'East', 950);


SELECT SalesPerson, 
       [North], 
       [South], 
       [East]
FROM (
    SELECT SalesPerson, Region, SalesAmount
    FROM #Sales
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR Region IN ([North], [South], [East])
) AS PivotTable;