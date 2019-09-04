-----------------------------------------------------------------------------------------------------------------------
-- 07-OptimizerInfo.sql
-- Version 1.0.16
-- Look for the most recent version of this script at www.tf3604.com/optimizer
-- MIT License.  See the bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

select *
from sys.dm_exec_query_optimizer_info;

-- The following statements will take a snapshot of sys.dm_exec_query_optimizer_info before and after a
-- query of interest gets executed.  We have to execute the exact two select ... into statements and the drop
-- statements ahead of time to make sure they are in the plan cache and don't go through the optimizer when
-- we run them again.  Also, other queries running concurrently will skew the results, so this needs to happen
-- on a quiet system.  If we run these statements (with no "query of interest") we should get no results.

-- sys.dm_exec_query_transformation_stats shows one record for each transformation rule that the optimizer has.
-- It includes some "promise" information that is a guess about how effective the rule will be under the
-- current circumstances (which allows the optimizer to prioritize rules).  It also contains columns
-- indicating how successful the transformation was.

-- The stats are accumulated since the instance start.

-----------------------------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------------------------
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select a.counter, a.occurrence - b.occurrence occurrence, a.occurrence * a.value - b.occurrence * b.value value
from #before_optimizer_info b
join #after_optimizer_info a on a.counter = b.counter
where a.occurrence != b.occurrence order by counter;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
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
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
select top (10) od.ProductId, sum(od.Quantity) - 20 ExcessOrders
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.OrderDetail od on oh.OrderId = od.OrderId
inner join CorpDB.dbo.Customer cust on oh.CustomerId = cust.CustomerID
where cust.State = 'AZ'
group by od.ProductId
having sum(od.Quantity) >= 20
order by od.ProductId
option (recompile);
go
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select a.counter, a.occurrence - b.occurrence occurrence, a.occurrence * a.value - b.occurrence * b.value value
from #before_optimizer_info b
join #after_optimizer_info a on a.counter = b.counter
where a.occurrence != b.occurrence order by counter;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------


-- Interesting to observe how CTEs are handled by the optimizer.
-- First, without a CTE.  Note no change in view references.

-----------------------------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------------------------
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
select oh.OrderId, oh.OrderDate, c.FirstName, c.LastName
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on oh.CustomerId = c.CustomerID
where c.State = 'AZ'
option (recompile);
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select a.counter, a.occurrence - b.occurrence occurrence, a.occurrence * a.value - b.occurrence * b.value value
from #before_optimizer_info b
join #after_optimizer_info a on a.counter = b.counter
where a.occurrence != b.occurrence order by counter;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------

-- Now with a CTE. Note that "view reference" is bumped by 1.

-----------------------------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------------------------
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
select * into #before_optimizer_info from sys.dm_exec_query_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- Insert query of interest here
-----------------------------------------------------------------------------------------------------------------------
with CustomersOfInterest as
(
	select c.CustomerID, c.FirstName, c.LastName
	from CorpDB.dbo.Customer c
	where c.State = 'AZ'
)
select oh.OrderId, oh.OrderDate, c.FirstName, c.LastName
from CorpDB.dbo.OrderHeader oh
inner join CustomersOfInterest c on oh.CustomerId = c.CustomerID
option (recompile);
go
select * into #after_optimizer_info from sys.dm_exec_query_optimizer_info;
go
select a.counter, a.occurrence - b.occurrence occurrence, a.occurrence * a.value - b.occurrence * b.value value
from #before_optimizer_info b
join #after_optimizer_info a on a.counter = b.counter
where a.occurrence != b.occurrence order by counter;
go
if object_id('tempdb..#before_optimizer_info') is not null drop table #before_optimizer_info;
if object_id('tempdb..#after_optimizer_info') is not null drop table #after_optimizer_info;
go
-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------

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
