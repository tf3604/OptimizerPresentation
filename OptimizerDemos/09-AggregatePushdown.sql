-----------------------------------------------------------------------------------------------------------------------
-- 09-AggregatePushdown.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.0
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------

-- Get an estimated query plan for the following query.
-- This is a traditional aggregation where SQL Server first joins our two tables, then aggregates the result.

with CustomerCount as
(
	select oh.CustomerId, count(*) NbrOrders
	from CorpDB.dbo.OrderHeader oh
	group by oh.CustomerId
)
select c.CustomerID, c.FirstName, c.LastName, cc.NbrOrders
from CorpDB.dbo.Customer c
inner join CustomerCount cc on c.CustomerID = cc.CustomerId
where c.State = 'SD';

-- Get an estimated query plan for the following query.
-- With a large input from Customer (no predicate), SQL Server decides to first aggregate out of OrderHeader,
-- then to join the aggregate results to Customer.

with CustomerCount as
(
	select oh.CustomerId, count(*) NbrOrders
	from CorpDB.dbo.OrderHeader oh
	group by oh.CustomerId
)
select c.CustomerID, c.FirstName, c.LastName, cc.NbrOrders
from CorpDB.dbo.Customer c
inner join CustomerCount cc on c.CustomerID = cc.CustomerId;

-- Get an estimated query plan for the following query.
-- Similar, but with the table order reversed.

with CustomerCount as
(
	select oh.CustomerId, count(*) NbrOrders
	from CorpDB.dbo.OrderHeader oh
	group by oh.CustomerId
)
select c.CustomerID, c.FirstName, c.LastName, cc.NbrOrders
from CorpDB.dbo.Customer c
inner join CustomerCount cc on c.CustomerID = cc.CustomerId
where c.State = 'CA';
