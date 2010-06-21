alter table Tag add column tagLabel TEXT;

update Tag set tagLabel = tag;

update tag set tag = lower(tag);

drop index Action_status_ordering;

alter table Action rename to Task;

create index Task_ordering on Task (ordering desc);

insert into Tag(tag, tagLabel) values ("#work", "#Work");

insert into Tag(tag, tagLabel) values ("#personal", "#Personal");

insert into Tag(tag, tagLabel) values ("#personal/home", "#Personal/Home");