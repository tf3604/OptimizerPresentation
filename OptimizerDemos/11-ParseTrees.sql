-----------------------------------------------------------------------------------------------------------------------
-- 11-ParseTrees.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.1
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------

-- Turn on TF3604 for the session.  This will cause output to be written back the client (SSMS - on the messages tab).
dbcc traceon (3604);
set fmtonly on;

-- TF8605 will output the "converted" parse tree.

-- Start with a simple parse tree.
select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
option (recompile, querytraceon 8605);

-- Query with a WHERE clause.
select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
where c.State = 'SD'
option (recompile, querytraceon 8605);

-- Query with a WHERE clause (LIKE).
select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
where c.LastName like 'Smi%'
option (recompile, querytraceon 8605);

-- Query with a JOIN.
select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State, oh.OrderId, oh.OrderDate
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
option (recompile, querytraceon 8605);

-- Query with an ORDER BY.
select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State, oh.OrderId, oh.OrderDate
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
order by c.City, c.State, c.LastName, c.FirstName
option (recompile, querytraceon 8605);

-- Query with a GROUP BY.
select c.CustomerID, count(oh.OrderId) NbrOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
group by c.CustomerID
option (recompile, querytraceon 8605);

-- Query with a DISTINCT.
select distinct c.FirstName, c.LastName
from CorpDB.dbo.Customer c
where c.State = 'SD'
option (recompile, querytraceon 8605);

-- Query with a UNION.
select p.ProductId
from CorpDB.dbo.Product p
union all
select od.ProductId
from CorpDB.dbo.OrderDetail od
option (recompile, querytraceon 8605);

select p.ProductId
from CorpDB.dbo.Product p
union
select od.ProductId
from CorpDB.dbo.OrderDetail od
option (recompile, querytraceon 8605);

-- Query with an EXCEPT.
select od.ProductId
from CorpDB.dbo.OrderDetail od
except
select p.ProductId
from CorpDB.dbo.Product p
option (recompile, querytraceon 8605);

-- TF8606 will output the parse tree at various stages of optimization.
-- Trees outputted are: Input, Simplified, Join-Collapsed, Before Project Normalization, After Project Normalization

-- Query with a GROUP BY.
select c.CustomerID, count(oh.OrderId) NbrOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
group by c.CustomerID
option (recompile, querytraceon 8606);

-- Can combine TF8605 and TF8606 for a more complete picture.
select c.CustomerID, count(oh.OrderId) NbrOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
group by c.CustomerID
option (recompile, querytraceon 8605, querytraceon 8606);

-- Further combine with TF8621.
select c.CustomerID, count(oh.OrderId) NbrOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
group by c.CustomerID
option (recompile, querytraceon 8605, querytraceon 8606, querytraceon 8621);

-- TF8607 shows the "output tree".  This will include PHYSICAL operators.
select c.CustomerID, count(oh.OrderId) NbrOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
group by c.CustomerID
option (recompile, querytraceon 8607);

-- TF7352 shows another version of the final tree.
select c.CustomerID, count(oh.OrderId) NbrOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
group by c.CustomerID
option (recompile, querytraceon 7352);

-- Let's look at some of the queries from the simplification demos.

-- Subquery to inner join
-- Note the semi-join operator
select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
where oh.CustomerId in
(
	select c.CustomerId
	from CorpDB.dbo.Customer c
	where c.State = 'SD'
)
option (recompile, querytraceon 8605, querytraceon 8606);

-- Another subquery to inner join
-- Note how the "simplified" tree treats the query as if it had been written without the subquery.
select CustomerOrderView.OrderId, CustomerOrderView.CustomerId, od.ProductId
from CorpDB.dbo.OrderDetail od
inner join
(
	select oh.OrderId, oh.CustomerId, c.State
	from CorpDB.dbo.OrderHeader oh
	inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerId
) CustomerOrderView on od.OrderId = CustomerOrderView.OrderId
where CustomerOrderView.State = 'SD'
option (maxdop 1, recompile, querytraceon 8605, querytraceon 8606);

-- Predicate pushdown
-- Note that the select operator is pushed below the join
select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
where c.State = 'SD'
option (recompile, querytraceon 8605, querytraceon 8606);

-- Foreign key table removal
-- Note that in the join-collapsed tree, Customer has been removed entirely.
select oh.OrderId, oh.OrderDate, oh.CustomerId
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
option (recompile, querytraceon 8605, querytraceon 8606);

-- Contradiction detection
select p.ProductId, p.ProductName, p.UnitPrice
from CorpDB.dbo.Product p
inner join CorpDB.dbo.OrderDetail od on od.ProductId = p.ProductId
where p.UnitPrice > 50.00
and p.UnitPrice < 25.00
option (recompile, querytraceon 8605, querytraceon 8606);

-- Sometimes seemingly simple queries can actually be rather involved.
select * from CorpDB.sys.objects
option (recompile, querytraceon 8605);

-- Additional features in SSPTV: Optimizer Info and Transformation Stats
set fmtonly off;

select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile);
