-----------------------------------------------------------------------------------------------------------------------
-- 06-Bushy Trees.sql
-- Version 1.0.15
-- Look for the most recent version of this script at www.tf3604.com/optimizer
-- MIT License.  See the bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- Normally SQL server will not produce a bushy tree.
-- Get an estimated execution plan on this query.  Note that the plan joins a pair of tables, pulls in another
-- table, then the final table.
select *
from CorpDB.dbo.OrderHeader oh
join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
join CorpDB.dbo.Product p on od.ProductId = p.ProductId;
go

-- We can get the same plan using the "force order" hint.
-- Get an estimated execution plan on this query.
-- Also get an estmiated plan on the previous query and this one together to compare.
select *
from CorpDB.dbo.Customer c
join (CorpDB.dbo.OrderHeader oh
join (CorpDB.dbo.Product p
join CorpDB.dbo.OrderDetail od on od.ProductId = p.ProductId)
on oh.OrderId = od.OrderId)
on oh.CustomerId = c.CustomerID
option (force order);
go

-- We can also force a bushy plan to happen.
-- Get an estimated execution plan on this query.
-- However, note that it is about twice as expensive as the optimized query.
select *
from CorpDB.dbo.Customer c
join CorpDB.dbo.OrderHeader oh on oh.CustomerId = c.CustomerID
join (CorpDB.dbo.Product p
join CorpDB.dbo.OrderDetail od on od.ProductId = p.ProductId)
on oh.OrderId = od.OrderId
option (force order);
go

-- How much does considering bushy trees expand the search space?
use CorpDB;
if exists (select * from sys.objects where name = 'Factorial')
	drop function dbo.Factorial;
go
create function dbo.Factorial (@n int)
returns float
as
begin
	if @n < 1
		return 1;

	if @n < 2
		return @n;

	return @n * dbo.Factorial(@n - 1);
end
go
select	n.n NumberOfTables,
		dbo.Factorial(n.n) LeftDeepTreesJoinCount,
		dbo.Factorial(2 * n.n - 2) / dbo.Factorial(n.n - 1) BushyTreeJoinCount,
		dbo.Factorial(2 * n.n - 2) / dbo.Factorial(n.n - 1) / dbo.Factorial(n.n) [Bushy/LeftDeep]
from	Admin.dbo.Nums n
where	n.n <= 12;
-- The value for "bushy trees" with 12 tables is 28,158,588,057,600 (28 trillion)!
go
drop function dbo.Factorial;
go

-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2019, Brian Hansen (brian at tf3604.com).
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
