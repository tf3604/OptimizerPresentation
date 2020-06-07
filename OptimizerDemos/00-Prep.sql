-- restore filelistonly from disk = 'C:\data\sql2014\backup\CorpDB.bak';

restore database CorpDB
from disk = 'CorpDB.bak' --'C:\data\sql2016\backup\CorpDB.bak'
with replace,
move 'CorpDB' to 'c:\sql\sql2019\data\CorpDB.mdf',
move 'CorpDB_log' to 'c:\sql\sql2019\log\CorpDB_log.ldf';

alter database CorpDB set compatibility_level = 150;

dbcc freeproccache;
