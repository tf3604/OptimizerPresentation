restore filelistonly from disk = 'C:\data\sql2014\backup\CorpDB.bak';

restore database CorpDB from disk = 'C:\data\sql2016\backup\CorpDB.bak' with replace,
move 'CorpDB' to 'c:\data\sql2016\data\CorpDB.mdf',
move 'CorpDB_log' to 'c:\data\sql2016\log\CorpDB_log.ldf';

alter database CorpDB set compatibility_level = 130;

dbcc freeproccache;
