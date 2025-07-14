-- Sample data setup
CREATE TABLE #SampleData (
    ID INT,
    OrderDate DATETIME,
    CustomerName VARCHAR(50),
    Amount DECIMAL(10,2)
);

INSERT INTO #SampleData VALUES
(1, '2024-01-15', 'Alice', 100.00),
(2, '2024-01-20', 'Bob', 150.00),
(3, '2024-01-25', 'Charlie', 200.00),
(4, '2024-02-01', 'David', 120.00),
(5, '2024-02-10', 'Eve', 180.00),
(6, '2024-02-15', 'Frank', 90.00),
(7, '2024-02-20', 'Grace', 250.00);

-- 1. INTEGER COLUMNS - Range between based on row positions
SELECT 
    ID,
    Amount,
	count(1) over(order by ID),
	count(1) over(order by ID desc),
	count(1) over(order by ID),
	count(1) over(order by ID),

    -- Running total of previous 2 rows plus current row
    SUM(Amount) OVER (
        ORDER BY ID 
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal_IntRange,
    
    -- Average of current row and next 1 row
    AVG(Amount) OVER (
        ORDER BY ID 
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS AvgNext_IntRange
FROM #SampleData;