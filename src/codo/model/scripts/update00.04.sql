DROP TABLE IF EXISTS ActionFlag;

drop table if exists _Action;

alter table Action rename to _Action;

CREATE TABLE Action (
	id INTEGER PRIMARY KEY,
	ordering INTEGER,
	status INTEGER,
	statusTimestamp DATE,
	name TEXT NOT NULL,
	isToday integer(1)
);

INSERT INTO Action SELECT id, ordering, 40, statusTimestamp, name, 0 from _Action;

drop table _Action;