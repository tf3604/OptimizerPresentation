-----------------------------------------------------------------------------------------------------------------------
-- 04-PlanCache.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Version 1.0.3
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
where c.State = 'MN'
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
where c.State = 'MN'
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

