-----------------------------------------------------------------------------------------------------------------------
-- 14-FromTheTrenches.sql
-- Version 1.0.16
-- Look for the most recent version of this script at www.tf3604.com/optimizer
-- MIT License.  See the bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- These queries are based on real-world examples and will not run on the sample database.

-- Original query.

declare @StartDate datetime = '2016-08-01';
declare @EndDate datetime = '2016-09-01';

select o.OrderId, max(rt.RelatedDate)
FROM OrderHeader o
inner join RelatedTable rt on o.OrderId = rt.OrderId
where cast(o.FulfilledDate as date) = cast(rt.RelatedDate as date)
and o.FulfilledDate >= @StartDate
and o.FulfilledDate < @EndDate
and o.Status = 2
and o.Batch is null
group by o.OrderId;

-- This query takes 28+ minutes to run and consumes a lot of resources and contending with other processing
-- on the system.

-- What are some possible problems?

-- Initially, "cast(o.FulfilledDate as date) = cast(rt.RelatedDate as date)" seems problematic, because
-- it is not SARGable.  However, that turns out to be not much of an issue.

-- Here are some stats on the tables:
--    OrderHeader contains 52,605,504 records.
--    RelatedTable contains 34,948,348 records.
-- However, the join predicate columns are well-indexed and there is mostly a 1:1 relationship
-- between the two tables, so nothing crazy there.

-- Of the 52,605,504 records in OrderHeader:
--   Status = 2 ==> 34,093,108 rows, or 0.648090131 of the rows in the table.
--   Batch is null ==> 18,516,799 rows, or 0.351993567 of the rows in the table.

-- So how many rows have Status = 2 and Batch is null?
-- The Cardinality Estimator (CE) doesn't do a great job in cases like this (correlated predicates), even
-- though there is an index on those two columns.

-- Legacy CE (SQL 7.0 to SQL 2012) bases its estimate on the product of these two selectivity values:
--    0.351993567 * 0.648090131 = 0.22812355 (or 12,000,554 rows)

-- New CE (SQL 2014+) uses an "exponential backoff" methodology:
--    0.351993567 * sqrt(0.648090131) = 0.28336906 (or 14,906,772 rows)

-- Actual number of rows where Status = 2 and Batch is null:  4481
-- The CE is way off.

-- There is a business reason.  BatchId is null means the Order is unbatched, and Status = 2 means that the
-- order is complete.  Completed orders are generally batched daily, so this particular pair of predicates
-- means we are basically looking for recently completed orders.  This is going to be a small number.

-- But the CE doesn't know that, and the heuristics that it applies happen to be quite incorrect in this case.

-- Why does this matter?

-- As mentioned, there *IS* an index on these columns, and using that index would be really quite
-- efficient.  Notice that the OrderHeader table references another column in the query (FulfillmentDate).
-- That means if SQL uses the index, it will have to back to the main table for every row to get
-- the FulfillmentDate.  For 4400 rows (in a 52M row table), doing that lookup is small potatoes.
-- For 12M to 15M rows, it would be huge deal.  SQL know this, and so opts to instead do a full table
-- scan.

if object_id('tempdb.dbo.#Order') is not null drop table #Order;
create table #Order (OrderId int);

insert #Order (OrderId)
select o.OrderId
from dbo.OrderHeader o
where o.Status = 2
and o.Batch is null;

select o.OrderId, max(rt.RelatedDate)
from #Order tmp
inner join OrderHeader o on tmp.OrderId = o.OrderId
inner join RelatedTable rt on o.OrderId = rt.OrderId
WHERE cast(o.FulfulledDate as date) = cast(rt.RelatedDate as date)
	and o.FulfilledDate >= '2018-03-01'
	and o.FulfilledDate < '2018-04-01'
GROUP BY o.OrderId;

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
