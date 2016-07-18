-----------------------------------------------------------------------------------------------------------------------
-- 05-IndexIntersection.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016, Brian Hansen (brian@tf3604.com).
-- Feel free to use this code in any way you see fit, but do so at your own risk.
-- Version 1.0.1
-- Look for the most recent version of this script at www.tf3604.com/optimizer.
-----------------------------------------------------------------------------------------------------------------------
use CorpDB;
go

-- Get an estimated query plan on the following statement.
-- Initially, there are no indexes on FirstName or LastName, so there SQL has to scan the clustered index
-- to answer this query.
-- Cost = 0.5115

select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
where c.FirstName = 'William'
and c.LastName = 'Smith';

-- Add an index on LastName

create nonclustered index idx_Customer_LastName on CorpDB.dbo.Customer (LastName);

-- Get an estimated query plan on the same statement.
-- Since the cardinality of 'Smith' is relatively high (713 rows out of 70132 = 1.02%) SQL still scans
-- the clustered index.

select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
where c.FirstName = 'William'
and c.LastName = 'Smith';

-- Add an index on FirstName

create nonclustered index idx_Customer_FirstName on CorpDB.dbo.Customer (FirstName);

-- Get an estimated query plan on the same statement.
-- Now the plan changes.  SQL can more efficiently seek + scan to get the CustomerIds from the LastName
-- index, then seek + scan to get the CustomerIds from the FirstName index, then join them to find
-- the intersection of the two sets.  SQL still need to do a lookup to get Address, City and State.
-- Cost = 0.0497

select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
where c.FirstName = 'William'
and c.LastName = 'Smith';

-- SQL can intersect more than two indexes as well.

create nonclustered index idx_Customer_City on CorpDB.dbo.Customer (City);

-- Now the query plan uses all three indexes to resolve the query.
-- Cost = 0.0358

select c.CustomerID, c.FirstName, c.LastName, c.Address, c.City, c.State
from CorpDB.dbo.Customer c
where c.FirstName = 'William'
and c.LastName = 'Smith'
and c.City = 'Chicago'
and c.State = 'IL';

-- Cleanup

drop index dbo.Customer.idx_Customer_LastName;
drop index dbo.Customer.idx_Customer_FirstName;
drop index dbo.Customer.idx_Customer_City;
