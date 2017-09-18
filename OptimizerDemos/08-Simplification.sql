-----------------------------------------------------------------------------------------------------------------------
-- 08-Simplification.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian@tf3604.com).
-- Version 1.0.10
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
-- documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions 
-- of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
-- TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
-- CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- Subqueries rewritten as joins.
-----------------------------------------------------------------------------------------------------------------------

use CorpDB;

-- Get estimated execution plan on these two queries.
-- Note that SQL produces the same plan for them because the subquery in the first is re-written
-- as an inner join (as in query 2).

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
where oh.CustomerId in
(
	select c.CustomerId
	from CorpDB.dbo.Customer c
	where c.State = 'WI'
);

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
where c.State = 'WI';

-- Another example of the same.
-- MAXDOP 1 specified to simplify the graphical query plan, but works without MAXDOP as well.

select CustomerOrderView.OrderId, CustomerOrderView.CustomerId, od.ProductId
from CorpDB.dbo.OrderDetail od
inner join
(
	select oh.OrderId, oh.CustomerId, c.State
	from CorpDB.dbo.OrderHeader oh
	inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerId
) CustomerOrderView on od.OrderId = CustomerOrderView.OrderId
where CustomerOrderView.State = 'WI'
option (maxdop 1);

select oh.OrderId, oh.CustomerId, od.ProductId
from CorpDB.dbo.OrderDetail od
inner join CorpDB.dbo.OrderHeader oh on od.OrderId = oh.OrderId
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
where c.State = 'WI'
option (maxdop 1);

-- How about EXISTS?  Get an estimated query plan on these two queries.

select c.CustomerID, c.FirstName, c.LastName
from CorpDB.dbo.Customer c
where exists
(
	select *
	from CorpDB.dbo.OrderHeader oh
	where oh.CustomerId = c.CustomerId
);

select c.CustomerID, c.FirstName, c.LastName
from CorpDB.dbo.Customer c
inner join
(
	select distinct CustomerId
	from CorpDB.dbo.OrderHeader oh
) oh on oh.CustomerId = c.CustomerID;

-----------------------------------------------------------------------------------------------------------------------
-- Predicate pushdown.
-----------------------------------------------------------------------------------------------------------------------

-- Get actual execution plan on this query.
-- Note that the Clustered Index Scan on Customer contains the predicate (State = 'WI').
-- Also note that the estimated/actual number of rows is the number after the predicate is applied.
-- In SQL 2012 SP3 and in SQL 2016, SQL will provide a "Number of Rows" metric to indicate the
-- number of physical rows read before the predicate.  Not available in SQL 2014 (as of SP1+CU6).

-- Clustered Index Scan (Customer) shows Actual Number of Rows = 824.

-- We can also see a trivial example of "project early" heuristics as work here.  Note that the
-- clustered index scan on Customer only outputs CustomerId and not all columns from the table.

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
where c.State = 'WI';

-- We can get SQL to separate the predicate.
-- Now the Clustered Index Scan (Customer) shows Actual Number of Rows = 70,132.
-- The Filter operator has Actual Number of Rows = 824.

dbcc traceon (9130);
go
select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
where c.State = 'WI';

go
dbcc traceoff (9130);
go

-----------------------------------------------------------------------------------------------------------------------
-- Foreign key table removal
-----------------------------------------------------------------------------------------------------------------------

-- Get an estimated query plan on this query.
-- Note that SQL removes the Customer table entirely from the plan because the FK guarantees that the row exists
-- in Customer, and no columns are otherwise required from Customer.

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID;

-- We temporarily disable the FK.

alter table CorpDB.dbo.OrderHeader nocheck constraint fk_OrderHeader__Customer;

-- Get the estimated plan again.
-- Now SQL must actually access the Customer table.

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID;

-- Enable the FK.

alter table CorpDB.dbo.OrderHeader check constraint fk_OrderHeader__Customer;

-- Get the estimated plan again.
-- SQL realizes that there is a possibility that there may have been changes to OrderHeader that don't comply
-- with the FK, so Customer will still be accessed.

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID;

-- Enable the FK and have SQL Server validate the data.

alter table CorpDB.dbo.OrderHeader with check check constraint fk_OrderHeader__Customer;

-- Get the estimated plan again.
-- Once again, SQL Server is satisfied of the data integrity and can once again skip physical access to Customer.

select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID;

-----------------------------------------------------------------------------------------------------------------------
-- Contradiction detection
-----------------------------------------------------------------------------------------------------------------------

-- Get an estimated plan on this query.
-- Note that we need to include a join in the query to avoid getting a trivial plan.
-- SQL Server recognizes that the where conditions are contradictory and removes all data access.

select p.ProductId, p.ProductName, p.UnitPrice
from CorpDB.dbo.Product p
inner join CorpDB.dbo.OrderDetail od on od.ProductId = p.ProductId
where p.UnitPrice > 50.00
and p.UnitPrice < 25.00;

-- Of course, this is really just a poorly-written query.  But what about the following?
-- Create the following view.

go
if exists (select * from CorpDB.sys.views where name = 'ImportantCustomers')
	drop view dbo.ImportantCustomers;
go
create view ImportantCustomers
as
select c.CustomerId, c.FirstName, c.LastName, c.State
from CorpDB.dbo.Customer c
where c.State = 'WI';
go

-- Now get an estimated plan on this query.
-- The contradiction may not be so obvious.

select c.*
from CorpDB.dbo.ImportantCustomers c
inner join CorpDB.dbo.OrderHeader oh on oh.CustomerId = c.CustomerId
where c.State = 'MO';

-- Cleanup
if exists (select * from CorpDB.sys.views where name = 'ImportantCustomers')
	drop view dbo.ImportantCustomers;
go

-- Create a products table that contains only items one dollar or less.

if exists (select * from CorpDB.sys.tables where name = 'CheapProducts')
	drop table CheapProducts;
go

select p.*
into CorpDB.dbo.CheapProducts
from CorpDB.dbo.Product p
where p.UnitPrice <= 1.00;

-- Add a check contraint to prevent more expensive products from being added to the table.

alter table CorpDB.dbo.CheapProducts with check add constraint ck_OnlyDollarProducts check (UnitPrice <= 1.00 and UnitPrice >= 0.00);

-- Now find more expensive products in the table.

select *
from CorpDB.dbo.CheapProducts p
inner join CorpDB.dbo.OrderDetail od on p.ProductId = od.ProductId
where p.UnitPrice > 50.00;

-- Cleanup

if exists (select * from CorpDB.sys.tables where name = 'CheapProducts')
	drop table CheapProducts;

-----------------------------------------------------------------------------------------------------------------------
-- Aggregates on unique keys
-----------------------------------------------------------------------------------------------------------------------

-- Get an estimated plan on the following query.
-- CustomerID is the PK for the table, thus is a unique key.  The aggregation cannot take more than one row
-- per customer ID as input.

select c.CustomerID, min(c.FirstName) FirstName, min(c.LastName) LastName
from CorpDB.dbo.Customer c
where c.State = 'WI'
group by c.CustomerID;

-- This is simplified to the following.
-- Note subtle differences in the query plan due to expression evaluation.

select c.CustomerID, FirstName, LastName
from CorpDB.dbo.Customer c
where c.State = 'WI';

-----------------------------------------------------------------------------------------------------------------------
-- Convert inner join to outer join
-----------------------------------------------------------------------------------------------------------------------

-- Get an estimated plan on the following query.
-- Note that even though we specify an outer join, the plan converts it to an inner join.
-- The WHERE clause precludes the possibility of non-existent rows in Customer.

select *
from CorpDB.dbo.OrderHeader oh
left join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
where c.State = 'WI';
