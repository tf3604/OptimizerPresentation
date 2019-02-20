-----------------------------------------------------------------------------------------------------------------------
-- 09-AggregatePushdown.sql
-- Version 1.0.14
-- Look for the most recent version of this script at www.tf3604.com/optimizer
-- MIT License.  See the bottom of this file for details.
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
where c.State = 'ND';

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

-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2018, Brian Hansen (brian at tf3604.com).
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
