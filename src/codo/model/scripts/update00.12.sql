CREATE TABLE Folder (
	id INTEGER PRIMARY KEY,
	name TEXT,
	ordering INTEGER,
	color INTEGER,
	buttonName TEXT
);

create index Folder_ordering on Folder (ordering desc);

insert into Folder values (1, "Trash", 1, 1, "Delete");

insert into Folder values (2, "Archive", 2, 2, null);

insert into Folder values (3, "Someday", 3, 3, "Someday");

insert into Folder values (4, "Next", 4, 4, "Next");

insert into Folder values (5, "Today", 5, 5, "Today");

insert into Folder values (6, "Inbox", 6, 6, null);


drop index Task_isArchived_ordering;

drop table if exists _Task;

alter table Task rename to _Task;

CREATE TABLE Task (
	id INTEGER PRIMARY KEY,
	status INTEGER,
	statusTimestamp DATE,
	ordering INTEGER,
	editText TEXT,
	viewText TEXT,
	folderId INTEGER,
	folderOrdering INTEGER
);

INSERT INTO Task SELECT id, status, statusTimestamp, ordering, editText, viewText, 4, 4 from _Task;

UPDATE Task set folderId = 5, folderOrdering = 5, status = 40 where status = 10;

UPDATE Task set folderId = 1, folderOrdering = 1, status = 40 where status = 60;

create index Task_folderOrdering_ordering on Task (folderOrdering desc, ordering desc);
