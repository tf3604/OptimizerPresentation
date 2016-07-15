-----------------------------------------------------------------------------------------------------------------------
-- 10-TransformationStats.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.0
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------

-- sys.dm_exec_query_transformation_stats shows one record for each transformation rule that the optimizer has.
-- It includes some "promise" information that is a guess about how effective the rule will be under the
-- current circumstances (which allows the optimizer to prioritize rules).  It also contains columns
-- indicating how successful the transformation was.

-- The rule names can be difficult, especially at first, to figure out.  Suggestion: do a web search on a rule
-- name.

-- The stats are accumulated since the instance start, so just selecting from the table is not terribly useful.

select *
from sys.dm_exec_query_transformation_stats;

-- The following statements will take a snapshot of sys.dm_exec_query_transformation_stats before and after a
-- query of interest gets executed.  We have to execute the exact two select ... into statements and the drop
-- statements ahead of time to make sure they are in the plan cache and don't go through the optimizer when
-- we run them again.  Also, other queries running concurrently will skew the results, so this needs to happen
-- on a quiet system.  If we run these statements (with no "query of interest") we should get no results.

-----------------------------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------------------------
go
select * into #before_transf_stats from sys.dm_exec_query_transformation_stats;
go
select * into #after_transf_stats from sys.dm_exec_query_transformation_stats;
go
if object_id('tempdb..#before_transf_stats') is not null drop table #before_transf_stats;
if object_id('tempdb..#after_transf_stats') is not null drop table #after_transf_stats;
go
select * into #before_transf_stats from sys.dm_exec_query_transformation_stats;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
go
select * into #after_transf_stats from sys.dm_exec_query_transformation_stats;
go
select a.name, a.promised - b.promised promised, a.succeeded - b.succeeded succeeded
from #before_transf_stats b
join #after_transf_stats a on a.name = b.name
where a.succeeded != b.succeeded
order by name;
go
if object_id('tempdb..#before_transf_stats') is not null drop table #before_transf_stats;
if object_id('tempdb..#after_transf_stats') is not null drop table #after_transf_stats;
go
-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------

-- Now let's try this on one of our queries.
-- Turn on actual execution plan first.
-- Cost of the query is 5.294

-----------------------------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------------------------
go
select * into #before_transf_stats from sys.dm_exec_query_transformation_stats;
go
select * into #after_transf_stats from sys.dm_exec_query_transformation_stats;
go
if object_id('tempdb..#before_transf_stats') is not null drop table #before_transf_stats;
if object_id('tempdb..#after_transf_stats') is not null drop table #after_transf_stats;
go
select * into #before_transf_stats from sys.dm_exec_query_transformation_stats;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from dbo.OrderHeader oh
inner join dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile);
go
select * into #after_transf_stats from sys.dm_exec_query_transformation_stats;
go
select a.name, a.promised - b.promised promised, a.succeeded - b.succeeded succeeded
from #before_transf_stats b
join #after_transf_stats a on a.name = b.name
where a.succeeded != b.succeeded
order by name;
go
if object_id('tempdb..#before_transf_stats') is not null drop table #before_transf_stats;
if object_id('tempdb..#after_transf_stats') is not null drop table #after_transf_stats;
go
-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------

-- Notice that in the execution plan we had a couple of hash joins and one hash aggregation.  Suppose we want
-- to try the query again and see what happens if we don't allow SQL to consider hash joins and aggregates.
-- We eliminate the hash join and aggregate, and instead use merge join and stream aggregate.  However, a
-- couple of sorts have to be introduced to support this operator.
-- Now the query cost has jumped to 17.94.

dbcc ruleoff ('JNtoHS');
dbcc ruleoff ('GbAggToHS');
dbcc ruleoff ('HJwBMtoHS');
go
-----------------------------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------------------------
go
select * into #before_transf_stats from sys.dm_exec_query_transformation_stats;
go
select * into #after_transf_stats from sys.dm_exec_query_transformation_stats;
go
if object_id('tempdb..#before_transf_stats') is not null drop table #before_transf_stats;
if object_id('tempdb..#after_transf_stats') is not null drop table #after_transf_stats;
go
select * into #before_transf_stats from sys.dm_exec_query_transformation_stats;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
select top 10 od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from dbo.OrderHeader oh
inner join dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'SD'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile);
go
select * into #after_transf_stats from sys.dm_exec_query_transformation_stats;
go
select a.name, a.promised - b.promised promised, a.succeeded - b.succeeded succeeded
from #before_transf_stats b
join #after_transf_stats a on a.name = b.name
where a.succeeded != b.succeeded
order by name;
go
if object_id('tempdb..#before_transf_stats') is not null drop table #before_transf_stats;
if object_id('tempdb..#after_transf_stats') is not null drop table #after_transf_stats;
go
-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------

-- We can also at any time identify the rules are currently enabled.

dbcc traceon (3604);
dbcc showonrules;

-- Or which rules are currently disabled.

dbcc traceon (3604);
dbcc showoffrules;

-- Cleanup

dbcc ruleon ('JNtoHS');
dbcc ruleon ('GbAggToHS');
dbcc ruleon ('HJwBMtoHS');
