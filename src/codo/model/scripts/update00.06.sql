CREATE TABLE Tag (
	tag TEXT PRIMARY KEY
);

CREATE TABLE TaskTag (
	tag TEXT,
	taskId INTEGER,
	PRIMARY KEY (tag, taskId)
);

create index TaskTag_taskId on TaskTag (taskId);