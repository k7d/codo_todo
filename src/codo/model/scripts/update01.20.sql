update Folder set name = "Review" where id = 6;

update Folder set buttonName = "Do Someday" where id = 3; 

update Folder set buttonName = "Do Next" where id = 4;

update Folder set buttonName = "Do Today" where id = 5;

update Folder set name = "Done" where id = 2;

create index Task_statusTimestamp on Task (statusTimestamp asc);

update Task set folderId = 2, folderOrdering = 2 where status = 50;