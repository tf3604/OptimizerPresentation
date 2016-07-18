-----------------------------------------------------------------------------------------------------------------------
-- 12-Memos.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.1
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------

dbcc traceon (3604);

-- Start with a very simple (in fact, technically trivial) query.
-- TF8757 will bypass trivial plan generation.
-- TF8608 will output the initial memo structure.
select *
from CorpDB.dbo.Customer c
option (recompile, querytraceon 8757, querytraceon 8608);

-- Now with a WHERE clause

select *
from CorpDB.dbo.Customer c
where c.State = 'SD'
option (recompile, querytraceon 8757, querytraceon 8608);

-- Join to another table (TF8757 no longer required because this query is not trivial).

select *
from CorpDB.dbo.Customer c
inner join CorpDB.dbo.OrderHeader oh on oh.CustomerId = c.CustomerID
where c.State = 'SD'
option (recompile, querytraceon 8608);

-- TF8615 will output the final memo structure.
select *
from CorpDB.dbo.Customer c
inner join CorpDB.dbo.OrderHeader oh on oh.CustomerId = c.CustomerID
where c.State = 'SD'
option (recompile, querytraceon 8615);

-- Same query.  Get an estimated query plan.
-- TF9130 will show the pushed predicate in the query plan
select *
from CorpDB.dbo.Customer c
inner join CorpDB.dbo.OrderHeader oh on oh.CustomerId = c.CustomerID
where c.State = 'SD'
option (recompile, querytraceon 8615, querytraceon 9130);

-- More complex query
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8615);

-- Related: TF8675 will show optimization phases and search times
-- Note that the query runs Search 1 twice (once for serial, once for parallel)
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8675);

-- Related: TF8677 will force Search 2 to run
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8675, querytraceon 8677);

-- TF2372 will display information about memory usage during optimization
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 2372);

-- TF2373 will display information about memory usage related to property derivation
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 2373);

-- Combine the two for a more complete picture.
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 2372, querytraceon 2373);

-- TF8619 shows more complex rules that are applied
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8619);

-- Combine with TF8620 to show some memo-related information
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8619, querytraceon 8620);

-- TF8621 shows query tree after applying rules
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8621);

-- Combine TF8619/8620/8621 to get a fuller picture
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8619, querytraceon 8620, querytraceon 8621);

-- TF8609 to show task information
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 8609);

-- Combine TF2372/2373/8619/8620/8621 to get very wide picture
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile, querytraceon 2372, querytraceon 2373, querytraceon 8619, querytraceon 8620, querytraceon 8621);
