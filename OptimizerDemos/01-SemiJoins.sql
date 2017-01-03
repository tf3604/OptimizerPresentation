-----------------------------------------------------------------------------------------------------------------------
-- 01-SemiJoins.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian@tf3604.com).
-- Version 1.0.4
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

-- Semi join.  Output is only from one of the tables (Customer); second table (OrderHeader) is used only
-- to do a logical correlation.
-- T-SQL does not have explicit syntax to write a semi-join, but we can accomplish it using an EXISTS statement or an IN clause.
-- Find customers that have orders.
select *
from CorpDB.dbo.Customer c
where exists
(
	select *
	from CorpDB.dbo.OrderHeader oh
	where oh.CustomerId = c.CustomerId
);

select *
from CorpDB.dbo.Customer c
where c.CustomerID in
(
	select oh.CustomerId
	from CorpDB.dbo.OrderHeader oh
);

-- Anti-semi join.  Output is only from one of the tables (Customer); second table (OrderHeader) is used only
-- to do a logical correlation.
-- T-SQL does not have explicit syntax to write a semi-join, but we can accomplish it using a NOT EXISTS or NOT IN statement.
-- In this example, OrderHeader.CustomerId is NOT NULL, but if not we need to exclude NULLs from the IN clause.
-- Find customers without orders.
select *
from CorpDB.dbo.Customer c
where not exists
(
	select *
	from CorpDB.dbo.OrderHeader oh
	where oh.CustomerId = c.CustomerId
);

select *
from CorpDB.dbo.Customer c
where c.CustomerID not in
(
	select oh.CustomerId
	from CorpDB.dbo.OrderHeader oh
);

-- The EXCEPT table operator is implemented using an anti-semi join.
-- Get an estimated query plan for this query.

select oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
where od.ProductId = 125
except
select oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
where od.ProductId = 59;
