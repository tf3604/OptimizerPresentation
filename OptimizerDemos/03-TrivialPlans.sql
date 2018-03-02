-----------------------------------------------------------------------------------------------------------------------
-- 03-TrivialPlans.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian@tf3604.com).
-- Version 1.0.11
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

use CorpDB;

-- Get an estimated execution plan on this query.
-- Get the "F4" properties and select the root node.
-- Note that "Optimization Level" = TRIVIAL

select *
from CorpDB.dbo.Customer c;

-- Same thing with a WHERE clause

select *
from CorpDB.dbo.Customer c
where c.State = 'WI';

-- Now let's add an index on State.

if exists (select * from CorpDB.sys.indexes where name = 'idx_Customer__State')
	drop index dbo.Customer.idx_Customer__State;

create index idx_Customer__State on CorpDB.dbo.Customer (State);

-- Now get the estimated plan.
-- We still wind up with the same plan, but because SQL had alternative to consider this is no
-- longer a trivial plan.  "Optimization Level" = FULL.

select *
from CorpDB.dbo.Customer c
where c.State = 'WI';

-- Cleanup

if exists (select * from CorpDB.sys.indexes where name = 'idx_Customer__State')
	drop index dbo.Customer.idx_Customer__State;

-- Example of a plan with multiple tables but which is still trivial.
-- This is because simplification rules optimize away all but the OrderDetail table,
-- so this query is essentially:
--     select od.OrderId, od.Quantity, od.UnitPrice
--     from CorpDB.dbo.OrderDetail od
--     where od.ProductId = 7304;

with AllData as
(
	select od.ProductId, p.ProductName, od.OrderId, od.Quantity, od.UnitPrice,
		oh.OrderDate, c.CustomerID, c.FirstName, c.LastName
	from CorpDB.dbo.Product p
	full join CorpDB.dbo.OrderDetail od on od.ProductId = p.ProductId
	full join CorpDB.dbo.OrderHeader oh on oh.OrderId = od.OrderId
	full join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
)
select ad.OrderId, ad.Quantity, ad.UnitPrice
from AllData ad
where ad.ProductId = 7304;

-- Note that we can avoid generating a trivial plan using TF8757.

dbcc traceon (8757);
go
select *
from CorpDB.dbo.Customer c;
go
dbcc traceoff (8757);
go
