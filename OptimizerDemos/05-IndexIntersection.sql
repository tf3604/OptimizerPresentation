-----------------------------------------------------------------------------------------------------------------------
-- 05-IndexIntersection.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian@tf3604.com).
-- Version 1.0.10
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
