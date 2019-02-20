-----------------------------------------------------------------------------------------------------------------------
-- 02-ParsingAndBinding.sql
-- Version 1.0.14
-- Look for the most recent version of this script at www.tf3604.com/optimizer
-- MIT License.  See the bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- Turn on PARSEONLY.  This directs the query processor to only execute the "parse" phase.
set parseonly on;

-- The following is a valid, executable query.  However, we get no results back because all SQL is doing
-- is validating the syntax.

-- Also note that we cannot get an execution plan.

select * from CorpDB.dbo.Customer;

-- The following is a valid query but cannot be executed because the table doesn't exist.  However, it
-- is syntactically correct.

select NonExistantColumn from NonExistantTable;

-- The following is not a valid query because it violates SQL syntax rules, so an error is generated.

select * form CorpDB.dbo.Customer;

-- Cleanup.

set parseonly off;

-- A similar option if FMTONLY.  However, queries submitted will go through the parsing and binding process, but 
-- won't be fully optimized.

set fmtonly on;

-- Now when we execute query it gets optimized, but it does not output any rows.
-- We still don't get an execution plan.

select *
from CorpDB.dbo.Customer c
inner join CorpDB.dbo.OrderHeader oh on oh.CustomerId = c.CustomerID;

-- Cleanup

set fmtonly off;

-- Data type resolution.
-- Even though CustomerID and OrderId have completely different meanings, we can still union
-- the results together because they have the same data type (int).

select c.CustomerID
from CorpDB.dbo.Customer c
union
select oh.OrderId
from CorpDB.dbo.OrderHeader oh;

-- However, FirstName is of type varchar() and OrderDate is datetime2.  These types are
-- incompatible and we will get an error.  This error happens during the binding process
-- and before optimization begins.

select c.CustomerID, c.FirstName
from CorpDB.dbo.Customer c
union
select oh.OrderId, oh.OrderDate
from CorpDB.dbo.OrderHeader oh;

-- Msg 241, Level 16, State 1, Line ##
-- Conversion failed when converting date and/or time from character string.

-- Aggregate binding.
-- This query will generate an error during the binding process because SQL knows that
-- "FirstName" is not a valid column because it is neither in the group by clause nor
-- is it an aggregate.

select c.LastName, c.FirstName, count(*) NbrCustomers
from CorpDB.dbo.Customer c
group by c.LastName

-- Msg 8120, Level 16, State 1, Line ##
-- Column 'CorpDB.dbo.Customer.FirstName' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2018, Brian Hansen (brian at tf3604.com).
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
