CREATE TABLE ArchivedTask (
	id INTEGER PRIMARY KEY,
	status INTEGER,
	statusTimestamp DATE,
	ordering INTEGER,
	editText TEXT,
	viewText TEXT,
	isToday integer(1)
);

create index ArchivedTask_ordering on ArchivedTask (ordering desc);

CREATE TABLE ArchivedTaskTag (
	tag TEXT,
	taskId INTEGER,
	PRIMARY KEY (tag, taskId)
);

create index ArchivedTaskTag_taskId on ArchivedTaskTag (taskId);