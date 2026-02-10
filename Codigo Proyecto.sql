USE ih_gambling;
/*Question1*/
/*Mostrar columnas especificas del archivo customer*/
SELECT Title, FirstName, LastName, DateOfBirth
FROM customer;

/*Question2*/
/*Contabilizar el total de customers de cada grupo establecido*/
SELECT CustomerGroup, COUNT(*) AS NumberofCustomers
FROM customer
GROUP BY CustomerGroup;

/*Question3*/
/*Unir tablas para añadir Currency (account) a tabla customer*/
SELECT customer.*, account.CurrencyCode
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId;

/*Question4*/
/*Resumir total de apuestas segun la fecha y el producto*/
SELECT AccountNo, BetDate, ClassId, CategoryId, Bet_Amt, Product
FROM betting;

SELECT *
FROM product;

SELECT BetDate, product.product, SUM(Bet_Amt) AS TotalBet
FROM betting
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
GROUP BY product.product, BetDate
ORDER BY BetDate, product.product;

/*Question5*/
/*Realizar cambios donde muestre solo transacciones luego del 1 de noviembre
y del producto Sportsbook*/
SELECT BetDate, product.product, SUM(Bet_Amt) AS TotalBet
FROM betting
INNER JOIN product
ON betting.ClassId = product.CLASSID
AND betting.CategoryId = product.CATEGORYID
WHERE STR_TO_DATE(BetDate, "%d/%m/%Y") >= "2012/11/01" AND product.product = "Sportsbook" /*Agregamos condicion*/
GROUP BY product.product, BetDate
ORDER BY BetDate;

/*Question6*/
/*Cambios en la presentacion de productos, ahora relacionados
a currencycode y customergroup y luego del 1 de diciembre*/
/*Un customer ID puede tener varias cuentas, por lo que hay que JOIN segun las cuentas ya que
desde ahi se hacen las apuestas*/
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
/*Mostrar a todos los jugadores sin importar si han hecho alguna apuesta o no
y tienen que ser solo los del mes de noviembre.
Tiene que mostrar Title, Nombre, apellido y el resumen de sus apuestas en ese periodo*/
SELECT customer.CustId, Title, FirstName, LastName, COALESCE(SUM(Bet_Amt),0) AS TotalBet
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
AND STR_TO_DATE(BetDate, "%d/%m/%Y")  >= "2012/11/01" AND STR_TO_DATE(BetDate, "%d/%m/%Y") < "2012/12/01"
GROUP BY customer.CustId, customer.Title, customer.FirstName, customer.LastName;

/*Question8*/
/*1-Number of product per player*/
/*2- Players who play Sportsbook and Vegas*/
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
/*Players who only play Sportsbook, bet_amt > 0 as key*/

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
/*Player favorite product*/

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
SELECT CustId, Title, FirstName, LastName, COALESCE(SUM(Bet_Amt),0) AS TotalBet
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

