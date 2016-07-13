-----------------------------------------------------------------------------------------------------------------------
-- 04-PlanCache.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.0
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------

-- We are going to first clear the plan cache.

dbcc freeproccache;

-- Look in the plan cache.  It should be empty (but system processes, etc., may quickly start adding to the cache).

select *
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
cross apply sys.dm_exec_query_plan(cp.plan_handle) qp;

-- Execute a query

set quoted_identifier on;

go
select *
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
where c.State = 'IA'
and c.FirstName = 'Mary';
go

-- Now find in the plan cache.  This should return one row.

select *
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
cross apply sys.dm_exec_query_plan(cp.plan_handle) qp
where st.text like '%Mary%'
and st.text not like '%sys.dm_exec_cached_plans%';

-- Execute the same query, now with quoted_identifier off

set quoted_identifier off;

go
select *
from CorpDB.dbo.OrderHeader oh
inner join CorpDB.dbo.Customer c on c.CustomerID = oh.CustomerId
where c.State = 'IA'
and c.FirstName = 'Mary';
go
set quoted_identifier on;
go

-- Look in the plan cache again.  This should now return two rows.
-- This is because the SET options are factored in when caching a plan.

select *
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
cross apply sys.dm_exec_query_plan(cp.plan_handle) qp
where st.text like '%Mary%'
and st.text not like '%sys.dm_exec_cached_plans%';

