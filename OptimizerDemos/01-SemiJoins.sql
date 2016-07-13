-----------------------------------------------------------------------------------------------------------------------
-- 01-SemiJoins.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.0
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------

-- Semi join.  Output is only from one of the tables (Customer); second table (OrderHeader) is used only
-- to do a logical correlation.
-- T-SQL does not have explicit syntax to write a semi-join, but we can accomplish it using an EXISTS statement.
-- Find customers that have orders.
select *
from CorpDB.dbo.Customer c
where exists
(
	select *
	from CorpDB.dbo.OrderHeader oh
	where oh.CustomerId = c.CustomerId
);

-- Anti-semi join.  Output is only from one of the tables (Customer); second table (OrderHeader) is used only
-- to do a logical correlation.
-- T-SQL does not have explicit syntax to write a semi-join, but we can accomplish it using a NOT EXISTS statement.
-- Find customers without orders.
select *
from CorpDB.dbo.Customer c
where not exists
(
	select *
	from CorpDB.dbo.OrderHeader oh
	where oh.CustomerId = c.CustomerId
);
