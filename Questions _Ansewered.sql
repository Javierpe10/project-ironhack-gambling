USE ih_gambling;
SELECT * 
FROM customer;

##Question 1

SELECT
	FirstName,
    LastName,
    Title,
    DateOfBirth
FROM customer;

##Question 2
SELECT 
	CustomerGroup,
    COUNT(*) AS Number_Of_Customers
FROM customer
GROUP BY CustomerGroup;
SELECT *
FROM account;


##Question 3

SELECT 
	c.*,
    a.CurrencyCode
FROM Customer c
 LEFT JOIN account a
	ON c.CustID = a.CustID;
    
##Question 4
    
    SELECT * 
    FROM betting;
    
    SELECT * 
    FROM product;
    
    SELECT 
		b.BetDate,
        p.Product,
        SUM(b.Bet_Amt) AS total_bet_amount
	FROM betting b
    JOIN product p
		ON b.ClassId = p.ClassId
        AND b.CategoryId = p.CategoryId
	GROUP BY 
		b.BetDate,
        p.product;
	
##Question 5
SELECT 
	b.BetDate,
	p.Product,
	SUM(b.Bet_Amt) AS total_Bet_Amount
FROM betting b
JOIN product p
	ON b.ClassId = p.ClassId
	AND b.CategoryId = p.CategoryId
WHERE b.BetDate >= '2019-11-01'
AND p.Product = 'SportsBook'
GROUP BY 
	b.BetDate,
    p.Product;

##Question 6
SELECT
    p.Product,
    a.CurrencyCode,
    c.CustomerGroup,
    SUM(b.Bet_Amt) AS total_bet_amount
FROM betting b
JOIN product p
    ON b.ClassId = p.ClassId
   AND b.CategoryId = p.CategoryId
JOIN account a
    ON b.AccountNo = a.AccountNo
JOIN customer c
    ON a.CustId = c.CustId
WHERE
    b.BetDate >= '2019-12-01'
GROUP BY
    p.Product,
    a.CurrencyCode,
    c.CustomerGroup;
    

##Question 7
	SELECT
		c.Title,
		c.FirstName,
		c.LastName,
		COALESCE(SUM(b.Bet_Amt), 0) AS TotalNovemberBets
FROM Customer c
LEFT JOIN Account a
    ON c.CustID = a.CustId
LEFT JOIN Betting b
    ON a.AccountNo = b.AccountNo
   AND b.BetDate BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY
    c.Title,
    c.FirstName,
    c.LastName;
    
##Question 8
##number of poroducts played per player 
SELECT
	c.FirstName,
	c.LastName,
    p.product,
    COUNT(DISTINCT p.Product) AS NumProductsPlayed
FROM Customer c
LEFT JOIN Account a
    ON c.CustId = a.CustId
LEFT JOIN Betting b
    ON a.AccountNo = b.AccountNo
LEFT JOIN Product p
    ON b.ClassId = p.ClassId
   AND b.CategoryId = p.CategoryId
GROUP BY
    p.product,
	c.FirstName,
    c.LastName;


## Question 8
## Players who play both sports and vegas
SELECT
    c.CustId,
 	c.FirstName,
	c.LastName
FROM Customer c
LEFT JOIN Account a
    ON c.CustId = a.CustId
LEFT JOIN Betting b
    ON a.AccountNo = b.AccountNo
LEFT JOIN Product p
    ON b.ClassId = p.ClassId
   AND b.CategoryId = p.CategoryId
WHERE
    p.Product IN ('Sportsbook', 'Vegas')
GROUP BY
    c.CustId,
    c.FirstName,
    c.LastName
HAVING
    COUNT(DISTINCT p.Product) = 2;

## Question 9
SELECT
    c.CustId,
    c.FirstName,
    c.LastName,
    SUM(b.Bet_Amt) AS SportsbookBets
FROM Customer c
JOIN Account a
    ON c.CustId = a.CustId
JOIN Betting b
    ON a.AccountNo = b.AccountNo
JOIN Product p
    ON b.ClassId = p.ClassId
   AND b.CategoryId = p.CategoryId
WHERE
    p.Product ='Sportsbook'
    AND b.Bet_Amt > 0
GROUP BY
    c.CustId,
    c.FirstName,
    c.LastName;
## Question 10
SELECT
    CustID,
    FirstName,
    LastName,
    Product
FROM (
    SELECT
        c.CustID,
        c.FirstName,
        c.LastName,
        p.Product,
        SUM(b.Bet_Amt) AS TotalBet,
        RANK() OVER (
            PARTITION BY c.CustID
            ORDER BY SUM(b.Bet_Amt) DESC
        ) AS rnk
    FROM Customer c
    LEFT JOIN Account a
        ON c.CustID = a.CustId
    LEFT JOIN Betting b
        ON a.AccountNo = b.AccountNo
    LEFT JOIN Product p
        ON b.ClassId = p.ClassId
       AND b.CategoryId = p.CategoryId
    WHERE b.Bet_Amt > 0
    GROUP BY
        c.CustID,
        c.FirstName,
        c.LastName,
        p.Product
) ranked
WHERE rnk = 1;

##Where Are the Large Pools of Money?
SELECT
    p.Product,
    SUM(b.Bet_Amt) AS Total_Revenue
FROM Betting b
JOIN Product p
    ON b.ClassId = p.ClassId
   AND b.CategoryId = p.CategoryId
WHERE b.Bet_Amt > 0
GROUP BY p.Product
ORDER BY Total_Revenue DESC;


###Revenue by Customer Group
SELECT
    c.CustomerGroup,
    SUM(b.Bet_Amt) AS Total_Revenue
FROM Customer c
JOIN Account a ON c.CustID = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
WHERE b.Bet_Amt > 0
GROUP BY c.CustomerGroup
ORDER BY Total_Revenue DESC;

#-----What Are the Most Profitable Periods?

SELECT
    b.BetDate,
    SUM(b.Bet_Amt) AS DailyTurnover
FROM Betting b
WHERE b.Bet_Amt > 0
GROUP BY b.BetDate
ORDER BY b.BetDate;

#-----Revenue by Month
SELECT
    DATE_FORMAT(b.BetDate, '%Y-%m') AS Month,
    SUM(b.Bet_Amt) AS MonthlyTurnover
FROM Betting b
WHERE b.Bet_Amt > 0
GROUP BY Month
ORDER BY Month;

#----High-Value Players
SELECT
    c.CustID,
    c.CustomerGroup,
    SUM(b.Bet_Amt) AS Total_Revenue
FROM Customer c
JOIN Account a ON c.CustID = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
WHERE b.Bet_Amt > 0
GROUP BY c.CustID, c.CustomerGroup
ORDER BY Total_Revenue DESC;

#----Multi-Product Players vs Single Product
SELECT
    c.CustID,
    c.FirstName,
    c.LastName,
    p.product,
    COUNT(DISTINCT p.Product) AS ProductsPlayed
FROM Customer c
JOIN Account a ON c.CustID = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN Product p
    ON b.ClassId = p.ClassId
   AND b.CategoryId = p.CategoryId
WHERE b.Bet_Amt > 0
GROUP BY 
	c.CustID,
    c.FirstName,
    c.LastName,
    p.product;

    
    #--------Currency Exposure Risk
    
    SELECT
    a.CurrencyCode,
    SUM(b.Bet_Amt) AS Total_Revenue
FROM Account a
JOIN Betting b ON a.AccountNo = b.AccountNo
WHERE b.Bet_Amt > 0
GROUP BY a.CurrencyCode;

#-----Risk Behaviour Analysis

SELECT
    c.CustomerGroup,
    AVG(a.StakeScale) AS AvgStakeScale,
    AVG(a.DailyDepositLimit) AS AvgDepositLimit
FROM Customer c
JOIN Account a ON c.CustID = a.CustId
GROUP BY c.CustomerGroup;


