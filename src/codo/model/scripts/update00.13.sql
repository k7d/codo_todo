alter table Tag add column isArchived INTEGER;
alter table Tag add column completeTimestamp DATE;

update Tag set isArchived = 0;

create index Tag_isArchived on Tag (isArchived asc, tag asc);

delete from Folder where id = 1 or id = 2;

update Folder set ordering = 6 where id = 5;
UPDATE Task set folderOrdering = 6 where folderId = 5;

update Folder set ordering = 5 where id = 6;
UPDATE Task set folderOrdering = 5 where status = 6;



