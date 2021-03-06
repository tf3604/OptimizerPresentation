select count_big(*) from CorpDB.dbo.OrderHeader;
select count_big(*) from CorpDB.dbo.OrderDetail;
select count_big(*) from CorpDB.dbo.Customer;

select count_big(*)
from CorpDB.dbo.OrderHeader
cross join CorpDB.dbo.OrderDetail;

select count_big(*) * (select count_big(*) from CorpDB.dbo.Customer)
from CorpDB.dbo.OrderHeader
cross join CorpDB.dbo.OrderDetail;

select count_big(*)
from CorpDB.dbo.OrderHeader oh
cross join CorpDB.dbo.OrderDetail od
cross join CorpDb.dbo.Customer c
where oh.OrderId = od.OrderId;

select count_big(*)
from CorpDB.dbo.OrderHeader oh
cross join CorpDB.dbo.OrderDetail od
cross join CorpDb.dbo.Customer c
where oh.OrderId = od.OrderId
and oh.CustomerId = c.CustomerID;

select count_big(*)
from CorpDB.dbo.OrderHeader oh
cross join CorpDB.dbo.OrderDetail od
cross join CorpDb.dbo.Customer c
where oh.OrderId = od.OrderId
and oh.CustomerId = c.CustomerID
and c.State = 'CA';

select count_big(*)
from
(
	select count_big(*) cnt
	from CorpDB.dbo.OrderHeader oh
	cross join CorpDB.dbo.OrderDetail od
	cross join CorpDb.dbo.Customer c
	where oh.OrderId = od.OrderId
	and oh.CustomerId = c.CustomerID
	and c.State = 'CA'
	group by od.ProductId
) gb;

select count_big(*)
from CorpDB.dbo.OrderHeader oh
cross join CorpDB.dbo.OrderDetail od
cross join CorpDb.dbo.Customer c
where oh.OrderId = od.OrderId
and oh.CustomerId = c.CustomerID
and c.State = 'CA'
group by od.ProductId
having sum(Quantity) >= 20;
