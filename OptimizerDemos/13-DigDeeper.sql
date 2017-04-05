-----------------------------------------------------------------------------------------------------------------------
-- 13-DigDeeper.sql
-----------------------------------------------------------------------------------------------------------------------

-- These queries courtesy of Kevin Kline (blogs.sentryone.com/KevinKline | @KEKline).

-----------------------------------------------------------------------------------------------------------------------
-- Give the Optimizer More Time ###
-----------------------------------------------------------------------------------------------------------------------

-- Give the optimizer more "time" with -TF8780. Also, note -T8671.
-- Related: TF8675 will show optimization phases and search times
-- Note that the query runs Search 1 twice (once for serial, once for parallel)

USE AdventureWorks2014;
GO

PRINT '
    ****
	Base query, showing optimization phases via -T8675
	****';
GO 

SET STATISTICS TIME ON;
GO

SELECT *
FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Sales.CreditCard cc ON cc.CreditCardID = soh.CreditCardID
    JOIN Sales.CurrencyRate cr ON cr.CurrencyRateID = soh.CurrencyRateID
    LEFT JOIN Sales.Currency crn ON crn.CurrencyCode = cr.FromCurrencyCode AND crn.ModifiedDate = cr.ModifiedDate
    JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
    LEFT JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    JOIN Person.BusinessEntity be ON sp.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Person p ON p.BusinessEntityID = be.BusinessEntityID
    JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Address a ON bea.AddressID = a.AddressID
    LEFT JOIN Person.StateProvince spr ON a.StateProvinceID = spr.StateProvinceID
    JOIN (
        SELECT MAX(tha.TransactionDate) AS m, tha.ProductID 
		FROM Production.TransactionHistoryArchive AS tha 
		GROUP BY tha.ProductID
    ) tha ON tha.ProductID = sod.ProductID
WHERE
    cc.CardType IN ('SuperiorCard','Vista') AND
    p.PersonType = 'SP' AND
    (soh.SalesOrderNumber >= 'SO' OR spr.CountryRegionCode IN ('FR', 'DE', 'GB'))
OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8675);
GO

SET STATISTICS TIME OFF;
GO

PRINT '
    ****
	With -T8780 added
	****';
GO 

SET STATISTICS TIME ON;
GO

SELECT *
FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Sales.CreditCard cc ON cc.CreditCardID = soh.CreditCardID
    JOIN Sales.CurrencyRate cr ON cr.CurrencyRateID = soh.CurrencyRateID
    LEFT JOIN Sales.Currency crn ON crn.CurrencyCode = cr.FromCurrencyCode AND crn.ModifiedDate = cr.ModifiedDate
    JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
    LEFT JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    JOIN Person.BusinessEntity be ON sp.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Person p ON p.BusinessEntityID = be.BusinessEntityID
    JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Address a ON bea.AddressID = a.AddressID
    LEFT JOIN Person.StateProvince spr ON a.StateProvinceID = spr.StateProvinceID
    JOIN (
        SELECT MAX(tha.TransactionDate) AS m, tha.ProductID 
		FROM Production.TransactionHistoryArchive AS tha 
		GROUP BY tha.ProductID
    ) tha ON tha.ProductID = sod.ProductID
WHERE
    cc.CardType IN ('SuperiorCard','Vista') AND
    p.PersonType = 'SP' AND
    (soh.SalesOrderNumber >= 'SO' OR spr.CountryRegionCode IN ('FR', 'DE', 'GB'))
OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8675, QUERYTRACEON 8780);
go

SET STATISTICS TIME OFF;
GO

PRINT '
    ****
	With -T8780 and -T8681 added
	****';
GO 

SET STATISTICS TIME ON;
GO

SELECT *
FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Sales.CreditCard cc ON cc.CreditCardID = soh.CreditCardID
    JOIN Sales.CurrencyRate cr ON cr.CurrencyRateID = soh.CurrencyRateID
    LEFT JOIN Sales.Currency crn ON crn.CurrencyCode = cr.FromCurrencyCode AND crn.ModifiedDate = cr.ModifiedDate
    JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
    LEFT JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    JOIN Person.BusinessEntity be ON sp.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Person p ON p.BusinessEntityID = be.BusinessEntityID
    JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Address a ON bea.AddressID = a.AddressID
    LEFT JOIN Person.StateProvince spr ON a.StateProvinceID = spr.StateProvinceID
    JOIN (
        SELECT MAX(tha.TransactionDate) AS m, tha.ProductID 
		FROM Production.TransactionHistoryArchive AS tha 
		GROUP BY tha.ProductID
    ) tha ON tha.ProductID = sod.ProductID
WHERE
    cc.CardType IN ('SuperiorCard','Vista') AND
    p.PersonType = 'SP' AND
    (soh.SalesOrderNumber >= 'SO' OR spr.CountryRegionCode IN ('FR', 'DE', 'GB'))
OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8675, QUERYTRACEON 8780, QUERYTRACEON 8671);
GO

SET STATISTICS TIME OFF;
GO
