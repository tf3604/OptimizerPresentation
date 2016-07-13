-----------------------------------------------------------------------------------------------------------------------
-- 02-ParsingAndBinding.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.0
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
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
