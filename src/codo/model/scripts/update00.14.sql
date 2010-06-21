insert into Folder values (1, "Trash", 1, 1, "Delete");

insert into Folder values (2, "Archive", 2, 2, null);

drop table if exists _Tag;

alter table Tag rename to _Tag;

CREATE TABLE Tag (
	tag TEXT PRIMARY KEY,
	tagLabel TEXT,
	isFavourite INTEGER(1)
);

insert into Tag (tag, tagLabel, isFavourite) select tag, tagLabel, 1 from _Tag;

drop table _Tag;

create index Tag_isFavourite_tag on Tag (isFavourite, tag);