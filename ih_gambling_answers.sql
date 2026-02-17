USE ih_gambling;
/*Question1*/
SELECT Title, FirstName, LastName, DateOfBirth
FROM customer;

/*Question2*/
SELECT CustomerGroup, COUNT(*) AS NumberofCustomers
FROM customer
GROUP BY CustomerGroup;

/*Question3*/
SELECT customer.*, account.CurrencyCode
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId;

/*Question4*/
SELECT BetDate, product.product, SUM(Bet_Amt) AS TotalBet
FROM betting
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
GROUP BY product.product, BetDate
ORDER BY BetDate, product.product;

/*Question5*/
SELECT BetDate, product.product, SUM(Bet_Amt) AS TotalBet
FROM betting
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
WHERE STR_TO_DATE(BetDate, "%d/%m/%Y") >= "2012/11/01" AND product.product = "Sportsbook" /*Agregamos condicion*/
GROUP BY product.product, BetDate
ORDER BY BetDate;

/*Question6*/
SELECT product.product, account.CurrencyCode, customer.CustomerGroup, SUM(Bet_Amt) AS TotalBet
FROM betting
INNER JOIN  account
ON betting.AccountNo = account.AccountNo
INNER JOIN customer
ON account.CustId = customer.CustId
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
WHERE STR_TO_DATE(BetDate, "%d/%m/%Y") > "2012/12/01"
GROUP BY product.product, account.CurrencyCode, customer.CustomerGroup
ORDER BY product.product, account.CurrencyCode, customer.CustomerGroup;

/*Question7*/
SELECT customer.CustId, Title, FirstName, LastName, COALESCE(SUM(Bet_Amt),0) AS TotalBet
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
AND STR_TO_DATE(BetDate, "%d/%m/%Y")  >= "2012/11/01" AND STR_TO_DATE(BetDate, "%d/%m/%Y") < "2012/12/01"
GROUP BY customer.CustId, customer.Title, customer.FirstName, customer.LastName;

/*Question8*/
SELECT customer.CustId, Title, FirstName, LastName, COUNT(DISTINCT product.product) AS TotalProducts
FROM customer
INNER JOIN account
ON customer.CustId = account.CustId
INNER JOIN betting
ON account.AccountNo = betting.AccountNo
INNER JOIN product
ON betting.classId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
GROUP BY customer.CustId, Title, FirstName, LastName;

SELECT customer.CustId, Title, FirstName, LastName
FROM customer
INNER JOIN account
ON customer.CustId = account.CustId
INNER JOIN betting
ON account.AccountNo = betting.AccountNo
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
WHERE product.product IN ("Sportsbook", "Vegas")
GROUP BY customer.CustId, Title, FirstName, LastName
HAVING COUNT(DISTINCT product.product) = 2;

/*Question9*/
SELECT customer.CustId, Title, FirstName, LastName, SUM(Bet_Amt) AS TotalBet
FROM customer
INNER JOIN account
ON customer.CustId = account.CustId
INNER JOIN betting
ON account.AccountNo = betting.AccountNo
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
WHERE betting.Bet_Amt > 0
GROUP BY customer.CustId, Title, FirstName, LastName
HAVING COUNT(DISTINCT product.product) = 1
AND MAX(product.product) = "Sportsbook";

/*Question10*/
SELECT
    CustID,
    FirstName,
    LastName,
    Product,
    TotalBet
FROM 
(	SELECT
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

/*EXTERNAL ANALYISIS*/
/*1- What product its more productive?(EXCERCISE4)*/
/*2- Worst months less profitable and why?(EJERCISE7)*/
/*3- Number of clients inactive in the worst month*/
/*4- Confirm if groups are really true to there bets(gold, bronxe,silver)*/

/*1*/
SELECT product.product, SUM(Bet_Amt) AS TotalBet
FROM betting
JOIN product
ON betting.classid = product.CLASSID
AND betting.categoryid = product.CATEGORYID
GROUP BY product.product
ORDER BY TotalBet DESC;

/*2*/
SELECT MONTH(STR_TO_DATE(BetDate, "%d/%m/%Y")) AS month, YEAR(STR_TO_DATE(BetDate, "%d/%m/%Y")) AS year, SUM(Bet_Amt) AS TotalBet
FROM betting
GROUP BY MONTH(STR_TO_DATE(BetDate, "%d/%m/%Y")), YEAR(STR_TO_DATE(BetDate, "%d/%m/%Y"))
ORDER BY month, year;

/*3*/
SELECT customer.CustId, Title, FirstName, LastName, COALESCE(SUM(Bet_Amt),0) AS TotalBet
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
AND STR_TO_DATE(BetDate, "%d/%m/%Y")  >= "2012/09/01" AND STR_TO_DATE(BetDate, "%d/%m/%Y") < "2012/10/01"
GROUP BY customer.CustId, customer.Title, customer.FirstName, customer.LastName;

/*4*/
SELECT CustomerGroup, SUM(Bet_Amt) AS TotalBet
FROM customer
JOIN account
ON customer.CustId = account.CustId
JOIN betting
ON account.AccountNo = betting.AccountNo
GROUP BY customer.CustomerGroup
ORDER BY TotalBet DESC;

