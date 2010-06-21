alter table Folder add column keyboardShortcut INTEGER;

update Folder set keyboardShortcut = 84 where id = 5;

update Folder set keyboardShortcut = 88 where id = 4;

update Folder set keyboardShortcut = 83 where id = 3;

update Folder set keyboardShortcut = 8 where id = 1;