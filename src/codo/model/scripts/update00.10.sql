alter table Task add column isArchived INTEGER;

update Task set isArchived = 0;

drop index Task_ordering;

create index Task_isArchived_ordering on Task (isArchived asc, ordering desc);

insert into Task select *, 1 from ArchivedTask;

insert into TaskTag select att.* from ArchivedTaskTag att left join TaskTag tt on tt.taskId = att.taskId and att.tag = tt.tag where tt.taskId is null;

drop table ArchivedTask;

drop table ArchivedTaskTag;