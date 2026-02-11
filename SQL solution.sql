USE ih_gambling;

-- Q1
SELECT
	Title,
    FirstName,
    LastName,
    DateOfBirth
FROM customer;

-- Q2
SELECT
	CustomerGroup,
    COUNT(*) AS members_count
FROM customer
GROUP BY CustomerGroup;

-- Q3

SELECT
	customer.*,
    account.CurrencyCode
FROM customer
LEFT JOIN account
	ON account.CustId = customer.CustId;
    
-- Q4
SELECT * FROM betting;
SELECT * FROM product;

CREATE TEMPORARY TABLE bet_by_product AS
SELECT b.*, p.product AS product_joined
FROM betting b
INNER JOIN product p
	ON b.ClassId = p.CLASSID
    AND b.CategoryId = p.CATEGORYID;
    
SELECT
	STR_TO_DATE(BetDate, '%d/%m/%Y') AS date,
	product_joined AS product,
    SUM(Bet_Amt) AS total_bet_amount
FROM bet_by_product
GROUP BY 
	STR_TO_DATE(BetDate, '%d/%m/%Y'),
	product_joined
ORDER BY STR_TO_DATE(BetDate, '%d/%m/%Y');

-- Q5

SELECT
	BetDate AS date,
	product_joined AS product,
    SUM(Bet_Amt) AS total_bet_amount
FROM bet_by_product
WHERE
	BetDate LIKE '01/11%'
    AND product = 'Sportsbook'
GROUP BY 
	BetDate,
	product_joined
ORDER BY BetDate;

-- Q6
SELECT 
	STR_TO_DATE(b.BetDate, '%d/%m/%Y') AS date,
	c.CustomerGroup,
    a.CurrencyCode,
	b.Product,
    SUM(Bet_Amt) AS bet_amount
FROM customer c
INNER JOIN account a
	ON a.CustId = c.CustId
INNER JOIN betting b
	ON a.AccountNo = b.AccountNo
WHERE STR_TO_DATE(b.BetDate, '%d/%m/%Y') > '2012-12-01'
GROUP BY 
	STR_TO_DATE(b.BetDate, '%d/%m/%Y'),
	c.CustomerGroup,
    a.CurrencyCode,
	b.Product
ORDER BY date;

-- Q7
SELECT * FROM customer;
SELECT * FROM betting;
SELECT * FROM account;

SELECT
	c.Title,
    c.FirstName,
    c.LastName,
	COALESCE(SUM(b.Bet_Amt), 0) as total_bet_amt -- returns zero intead of NULL
FROM customer c
LEFT JOIN account a
	ON a.CustId = c.CustId
LEFT JOIN betting b
	ON b.AccountNo = a.AccountNo
	AND MONTH(STR_TO_DATE(b.BetDate, '%d/%m/%Y')) = 11 -- extracting the month portion, setting to 11/ join on AND condition to keep the nulls (preseve left)
GROUP BY 
	c.Title,
    c.FirstName,
    c.LastName
ORDER BY total_bet_amt DESC;


-- Q8
SELECT * FROM customer;

SELECT
	c.CustId,
	c.FirstName,
    c.LastName,
    COUNT(DISTINCT Product) AS product_count
FROM customer c
LEFT JOIN account a
	ON a.CustId = c.CustId
LEFT JOIN betting b
	ON b.AccountNo = a.AccountNo
GROUP BY
	c.CustId,
	c.FirstName,
    c.LastName
ORDER BY COUNT(DISTINCT Product) DESC;

SELECT
	c.CustId,
	c.FirstName,
    c.LastName
FROM customer c
INNER JOIN account a
	ON a.CustId = c.CustId
INNER JOIN betting b
	ON b.AccountNo = a.AccountNo
WHERE b.Product in ('Sportsbook', 'Vegas')
GROUP BY
	c.CustId,
	c.FirstName,
    c.LastName
HAVING COUNT(DISTINCT b.Product) = 2; -- necessary for BOTH condition 

-- Q9
SELECT DISTINCT
	AccountNo,
    Product
FROM betting
ORDER BY AccountNo; -- only 01284UW account fits 

SELECT 
	customer.CustId,
	FirstName,
    LastName,
    SUM(Bet_Amt) AS total_bet_amount
FROM betting
INNER JOIN account
	ON account.AccountNo = betting.AccountNo
INNER JOIN customer
	ON customer.CustId = account.CustId
GROUP BY 
	customer.CustId,
	FirstName,
    LastName
HAVING 
	COUNT(DISTINCT Product) = 1
    AND MAX(Product) = 'Sportsbook' -- works because it's the only one
;
-- Q10

SELECT * FROM betting;

CREATE TEMPORARY TABLE amt_by_prod_acc AS(
SELECT
	b.AccountNo,
    b.Product,
    SUM(b.Bet_Amt) AS total_amt_bet
FROM betting b
GROUP BY
	b.AccountNo,
    b.Product
ORDER BY b.AccountNo, SUM(b.Bet_Amt) DESC
);

CREATE TEMPORARY TABLE amt_max AS(
SELECT
	a.AccountNo,
    MAX(total_amt_bet) AS max_amt_bet
FROM amt_by_prod_acc a
GROUP BY 
	a.AccountNo
);

SELECT * FROM amt_by_prod_acc;
SELECT * FROM amt_max; 
SELECT * FROM customer;

SELECT 
	c.CustId,
	c.FirstName,
    c.LastName,
	am.max_amt_bet,
    ap.Product
FROM amt_max am
INNER JOIN amt_by_prod_acc ap
	ON ap.AccountNo = am.AccountNo
    AND ap.total_amt_bet = am.max_amt_bet
INNER JOIN account a
	ON a.AccountNo = am.AccountNo
INNER JOIN customer c
	ON c.CustId = a.CustId;










