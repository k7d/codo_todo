drop table if exists _Action;

alter table Action rename to _Action;

CREATE TABLE Action (
	id INTEGER PRIMARY KEY,
	status INTEGER,
	statusTimestamp DATE,
	ordering INTEGER,
	editText TEXT,
	viewText TEXT,
	isToday integer(1)
);

INSERT INTO Action SELECT id, status, statusTimestamp, ordering, name, name, isToday from _Action;

drop table _Action;

create index Action_status_ordering on Action (status asc, ordering desc);