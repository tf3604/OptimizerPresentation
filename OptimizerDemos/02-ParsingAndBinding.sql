-----------------------------------------------------------------------------------------------------------------------
-- 02-ParsingAndBinding.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Version 1.0.1
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

-- Turn on PARSEONLY.  This directs the query processor to only execute the "parse" phase.
set parseonly on;

-- The following is a valid, executable query.  However, we get no results back because all SQL is doing
-- is validating the syntax.

-- Also note that we cannot get an execution plan.

select * from CorpDB.dbo.Customer;

-- The following is a valid query but cannot be executed because the table doesn't exist.  However, it
-- will still run without error because it is syntactically correct.

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

select * from CorpDB.dbo.Customer;

-- Cleanup

set fmtonly off;
