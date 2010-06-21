package codo.model
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.StringUtil;
	
	public class TaskService
	{
		private static var _instance:TaskService = null;
		
		public static var URL_PATTERN:RegExp = /https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.\+\-]*(\?\S+)?)?)?/ig;
		public static var TAG_PATTERN:RegExp = /#[^(\s,#)]*/ig;
		
		protected var con:SQLConnection;
		
		protected var folderCache: Object = new Object();
		
		public static function get instance(): TaskService
		{
			if (!_instance) {
				_instance = new TaskService();
			}
			
			return _instance;
		}
				

		
		public function TaskService()
		{
			this.con = DB.instance.connection;
		}
		
		
		
		public function addNewTask(folder:Folder, tag: Tag, text: String = null):int
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = con;
			
			if (!folder) {
				folder = getDefaultFolder();
			}
			
			st.text = 
				"insert into Task (ordering, editText, viewText, status, statusTimestamp, folderId, folderOrdering) values " +
				"(ifnull((select max(ordering) from Task),0) + 1, " + 
				":text,:text,:status,:statusTimestamp,:folderId,:folderOrdering);";
			
			if (!text) {
				text = 'New Task';
			}
			
			if (tag) {				
				st.parameters[':text'] = text + ' ' + tag.tagLabel;
			} else {
				st.parameters[':text'] = text;
			}
			
			st.parameters[':status'] = Task.STATUS_PENDING;
			st.parameters[':statusTimestamp'] = new Date();				
			
			st.parameters[':folderId'] = folder.id;
			st.parameters[':folderOrdering'] = folder.ordering;
			
			st.execute();
			
			var taskId: int = st.getResult().lastInsertRowID;
			
			if (tag) {
				var st2:SQLStatement = new SQLStatement();
				st2.sqlConnection = con;
				st2.text = "insert into TaskTag (tag, taskId) values (:tag, :taskId)";
				st2.parameters[":taskId"] = taskId;
				
				var tags:Array = splitTag(tag.tag);
				for (var i:int = 0; i < tags.length; i++) 
				{
					st2.parameters[":tag"] = tags[i];
					st2.execute();
				}				
			}
			
			return taskId;
		}
		
		
		
		public function splitTag(tag: String): Array
		{
			var prefix: String = '';
			var parts: Array = tag.split('/');
			for (var i:int = 0; i < parts.length; i++)
			{
				var t: String = parts[i];
				parts[i] = prefix + t;
				prefix = parts[i] + '/';
			}
			return parts;
		} 
		
		
		
		protected function parseTaskTags(task:Task, createTag: Boolean):void
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = con;			
			st.parameters[":id"] = task.id;
			
			var tags:Array = task.editText.match(TAG_PATTERN);
			if (tags) {
				var allTags:Array = [];
				var allTagLabels:Array = [];				
				for (var i:int = 0; i < tags.length; i++) 
				{
					var parts:Array = splitTag(tags[i]);
					for (var ii:int = 0; ii < parts.length; ii++) 
					{
						var l: String = parts[ii];
						var t: String = l.toLowerCase();
						if (allTags.indexOf(t) < 0) {
							allTags.push(t);
							allTagLabels.push(l);
						}						
					}				
				}		
				if (createTag) {
					var st2:SQLStatement = new SQLStatement();
					st2.sqlConnection = con;
					st2.text = "select tag from Tag where tag = :tag";
					
					var st3:SQLStatement = new SQLStatement();
					st3.sqlConnection = con;
					st3.text = "insert into Tag (tag, tagLabel, isFavourite) values (:tag, :tagLabel, 1)";
				}
				
				st.text = "insert into TaskTag (tag, taskId) values (:tag, :id)";
				for (i = 0; i < allTagLabels.length; i++) {
					var tagLabel:String = allTagLabels[i];
					var tag:String = tagLabel.toLowerCase();
					
					if (createTag) {
						st2.parameters[":tag"] = tag;
						st2.execute();
						if (st2.getResult().data == null)
						{
							st3.parameters[":tag"] = tag;
							st3.parameters[":tagLabel"] = tagLabel;
							st3.execute();
						}
					}
											
					st.parameters[":tag"] = tag;
					st.execute(); 
				}
				task.viewText = task.viewText.replace(TAG_PATTERN, '<font color="#888888">$&</font>');
			}			
		}
		
		
		
		public function updateTask(task: Task): void
		{
			try 
			{
				con.begin();
				
				task.viewText = task.editText.replace(URL_PATTERN, '<a href="$&"><u>$&</u></a>');
	
				// delete current tags
				var st:SQLStatement = new SQLStatement();
				st.sqlConnection = con;			
				st.text = "delete from TaskTag where taskId = :id";
				st.parameters[":id"] = task.id;		
				st.execute();
				
				parseTaskTags(task, true);
	
				// updater task
				st = new SQLStatement();
				st.sqlConnection = con;			
				st.text = "update Task set editText = :editText, viewText = :viewText where id = :id";
				st.parameters[':editText'] = task.editText;
				st.parameters[':viewText'] = task.viewText;
				st.parameters[':id'] = task.id;
				
				st.execute();	
										
				con.commit();
				
			} catch (e:Error) {
				con.rollback();
				Alert.show("We have a tiny problem: " + e.message);
			}
		}



		public function updateTaskStatuses(tasks: Array, newStatus: int): void
		{
			for (var i:int = 0; i < tasks.length; i++) {
				var task:Task = tasks[i];
				if (task.status != newStatus) {
					var st:SQLStatement = new SQLStatement();
					st.sqlConnection = con;
					
					st.text = "update Task set status = :status,statusTimestamp=:statusTimestamp where id = :id";
					
					st.parameters[':status'] = newStatus;
					st.parameters[':statusTimestamp'] = new Date();					
					
					st.parameters[':id'] = task.id;
					
					st.execute();
					
					task.status = newStatus; 
					
					if (newStatus == Task.STATUS_COMPLETED) {
						updateTaskFolders([task], getFolder(Folder.FOLDER_ID_DONE));
					} else {
						updateTaskFolders([task], getFolder(Folder.FOLDER_ID_TODAY));
					}
				}				
			}						
		}
		
		
		
		public function updateTaskFolders(tasks: Array, newFolder: Folder): void
		{
			for (var i:int = 0; i < tasks.length; i++) {
				var task:Task = tasks[i];
				if (task.folderId != newFolder.id) {
					var st:SQLStatement = new SQLStatement();
					st.sqlConnection = con;
					
					st.text = "update Task set folderId = :folderId,folderOrdering = :folderOrdering where id = :id";
					
					st.parameters[':folderId'] = newFolder.id;
					st.parameters[':folderOrdering'] = newFolder.ordering;					
					
					st.parameters[':id'] = task.id;
					
					st.execute();
					
					task.folderId = newFolder.id;
					task.folderOrdering = newFolder.ordering;

					if (newFolder.id == Folder.FOLDER_ID_TODAY) {
						reorderTasks([task], getLastFolderTask(newFolder));						
					} else {
						reorderTasks([task], null);
					}
				}
			}						
		}
		
		
		
		
		
		public function deleteTasks(tasks: Array): void
		{
			for (var i:int = 0; i < tasks.length; i++) {
				var task:Task = tasks[i];
				
				con.begin();

				var st:SQLStatement = new SQLStatement();
				st.sqlConnection = con;
				st.text = "delete from TaskTag where taskId = :id";
				st.parameters[":id"] = task.id;
				st.execute();			

				st.text = "update Task set folderOrdering = null, folderId = null where id = :id";
				st.execute();			
				
				con.commit();
			}						
		}
				
		
		
		public function reorderTasks(items:Array, after: Task/*, before: Task, updateStatuses: Boolean = true*/): void 
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = con;

			var ordering: int;
			if (after) {		
				ordering = after.ordering;						
			} else {
				st.text = "select ifnull(max(ordering),0) + 1 as o from Task";				
				st.execute();
				ordering = st.getResult().data[0]["o"];
			}

			var cnt:int = items.length;			

			st.text = "update Task set ordering = ordering + :cnt where ordering >= :ordering";		
			st.parameters[":cnt"] = cnt;
			st.parameters[":ordering"] = ordering;
			st.execute();
										
			st = new SQLStatement();					
			st.sqlConnection = con;
			
			items.sort(function(a:Task,b:Task):int {
				if (a.ordering > b.ordering)
					return -1;
				else
					return 1;
			});
				
			for (var i:int = 0; i < cnt; i++) {
				var a:Task = items[i];
				st.text = "update Task set ordering = :ordering where id = :id";
				st.parameters[":ordering"] = ordering + cnt - i - 1;	
				st.parameters[":id"] = a.id;					
				st.execute();														
			}
			
		}
		
		
				
		public function getTasksByFolder(folder: Folder):ArrayCollection
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Task;
			
			st.text = "select t.* from Task t where t.folderOrdering = :folderOrdering order by ordering desc";
			st.parameters[":folderOrdering"] = folder.ordering;
						
			st.execute();
			
			var res:ArrayCollection = new ArrayCollection(st.getResult().data);
			
			if (folder.id == Folder.FOLDER_ID_TODAY) {
				var arch: Folder = getFolder(Folder.FOLDER_ID_DONE);
				
				st.text = "select t.* from Task t where date(statusTimestamp) >= date('now', 'start of day') and t.folderOrdering = :folderOrdering order by ordering desc";
				st.parameters[":folderOrdering"] = arch.ordering;

				st.execute();
				
				res.addAll(new ArrayCollection(st.getResult().data));
			}			
						
			return res;
		}
		


		public function getTasksById(id: int):Task
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Task;
			
			st.text = "select t.* from Task t where t.id = :id";
			st.parameters[":id"] = id;
			
			st.execute();
			
			var d: Array = st.getResult().data;
			if (d && d.length > 0) {
				return Task(d[0]); 
			} else {
				return null;
			}
		}



		public function getLastFolderTask(folder: Folder):Task
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Task;
			st.text = "select t.* from Task t where t.folderOrdering = :folderOrdering order by ordering asc limit 1";
			st.parameters[":folderOrdering"] = folder.ordering;			
			st.execute();
			var data: Array = st.getResult().data;
			if (data && data.length > 0) {
				return data[0];
			} else {
				return null; 
			}
		}

		
			
		public function getTasksByTag(tag: Tag):Array
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Task;
			st.text = "select t.* from TaskTag tt inner join Task t on t.id = tt.taskId where tt.tag = :tag order by folderOrdering desc, ordering desc";
			st.parameters[":tag"] = tag.tag;
			st.execute();
			return st.getResult().data;
		}



		public function getAllTags():Array
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Tag;
			st.text = "select * from Tag order by tag";
			st.execute();
			return st.getResult().data;
		}


		
		public function getTags(isFavourite: Boolean):Array
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Tag;
			//st.text = "select * from Tag order by tag";
			st.text = "select * from Tag where isFavourite = :isFavourite order by tag";
			st.parameters[":isFavourite"] = isFavourite;
			st.execute();
			return st.getResult().data;
		}
		
		
		
		public function getTagsLike(tag: String, limit: int = 0):Array
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Tag;
			st.text = "select * from Tag where tag like :tag escape ' ' order by isFavourite desc, tag asc";
			var t: String = tag.toLowerCase().replace(/\%/g, " %").replace(/\_/g, " _") + "%";
			st.parameters[":tag"] = t;
			if (limit > 0) {
				 st.text += " limit :limit";
				st.parameters[":limit"] = limit;
			}
			st.execute();
			return st.getResult().data;
		}		
		
		
		
		public function getTag(tag:String):Tag
		{			
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Tag;
			st.text = "select * from Tag where tag = :tag";
			st.parameters[":tag"] = tag;
			st.execute();
			var data:Array = st.getResult().data;
			if (data && data.length > 0) {
				return data[0]
			} else {
				return null;
			}
		}
		
		
		
		public function escapeRegexChars(s:String):String
        {
            var newString:String = s.replace(new RegExp("([{}\(\)\^$&.\*\?\/\+\|\[\\\\]|\]|\-)","g"), "\\$1");
            return newString;
        }
        
        
		
		public function assignTasksToTag(items: Array, tag: Tag):void 
		{
			var rootTag:String = splitTag(tag.tag)[0];
			
			for (var i: int = 0; i < items.length; i++) 
			{
				var task: Task = Task(items[i]);
				
				// remove existing tags with given root tag
				task.editText = task.editText.replace(new RegExp(escapeRegexChars(rootTag) + "[^(\s,#)]*", "gi"), "");
								
				// add new tag
				task.editText = StringUtil.trim(task.editText) + " " + tag.tagLabel;
				updateTask(task);
			}			
		}
		
		
		
		public function deleteTag(tag:Tag): void
		{
			try {
				var tasks:Array = getTasksByTag(tag);
				if (tasks) {
					for (var i: int = 0; i < tasks.length; i++) 
					{
						var task: Task = Task(tasks[i]);
						task.editText = StringUtil.trim(task.editText.replace(new RegExp(escapeRegexChars(tag.tag), "gi"), ""));				
						updateTask(task);
					}
				}
							
				var st:SQLStatement = new SQLStatement();
				st.sqlConnection = DB.instance.connection;
				st.text = "delete from Tag where tag = :tag";
				st.parameters[":tag"] = tag.tag;
				st.execute();
			} catch (e:Error) {
				Alert.show("We have a tiny problem: " + e.message);
			}				
		}
		
		
		/*
		public function archiveTasks():void 
		{
			// archive tasks
			var archiveFolder:Folder = getFolder(Folder.FOLDER_ID_DONE);
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.text = "update Task set folderId = :folderId, folderOrdering = :folderOrdering where status = :status and date(statusTimestamp) < date('now', 'start of day')";
			st.parameters[":folderId"] = archiveFolder.id;
			st.parameters[":folderOrdering"] = archiveFolder.ordering;
			st.parameters[":status"] = Task.STATUS_COMPLETED;
			st.execute();
		}
		*/
		
		
		public function getFolder(folderId:int): Folder
		{
			var f:Folder = folderCache[folderId];
			if (!f) {
				var st:SQLStatement = new SQLStatement();
				st.sqlConnection = DB.instance.connection;
				st.itemClass = Folder;			
				st.text = "select * from Folder where id = :folderId";				
				st.parameters[":folderId"] = folderId;
				st.execute();
				var r:Object = st.getResult().data;
				if (r) {
					f = r[0];
				}
				
				folderCache[folderId] = f;			
			}
			return f;
		}


		
		public function getDefaultFolder():Folder 
		{
			return getFolder(Folder.FOLDER_ID_TODAY);
		}
		
		
		
		public function getFolders():Array
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Folder;
			st.text = "select * from Folder order by ordering desc";
			st.execute();
			return st.getResult().data;			
		}
		
		
		
		public function getFolderButtons():Array
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = DB.instance.connection;
			st.itemClass = Folder;
			st.text = "select * from Folder where buttonName is not null order by ordering desc";
			st.execute();
			return st.getResult().data;			
		}
		
		
		
		public function updateTag(tag: Tag): void
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = con;
			
			st.text = "update Tag set isFavourite = :isFavourite where tag = :tag";
			
			st.parameters[':tag'] = tag.tag;
			st.parameters[':isFavourite'] = tag.isFavourite;
			
			st.execute();
		}
		
		
		
		public function addNewTag(isFavourite: Boolean = true, parentTag: Tag = null):Tag 
		{
			if (parentTag) {
				return _addNewTag(isFavourite, parentTag.tagLabel + "/NewTag", 0);
			} else {
				return _addNewTag(isFavourite, "#NewTag", 0);
			}
		}
		
		
		
		protected function _addNewTag(isFavourite: Boolean = true, prefix: String = "#NewTag", index:int = 0):Tag
		{
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = con;
			
			var tagLabel: String = prefix;
			if (index > 0) {
				tagLabel += index;
			}
			
			var tag:String = tagLabel.toLowerCase(); 
			
			st.text = "select tag from Tag where tag = :tag";
			st.parameters[":tag"] = tag;
			st.execute();
			
			if (st.getResult().data != null) {
				return _addNewTag(isFavourite, prefix, index + 1);
			}
			
			
			st.text = "insert into Tag (tag, tagLabel, isFavourite) values (:tag, :tagLabel, :isFavourite)";
			st.parameters[":tagLabel"] = tagLabel;
			st.parameters[":isFavourite"] = isFavourite;
			st.execute();
						
			var t: Tag = new Tag();
			t.tag = tag;
			t.tagLabel = tagLabel;
			t.isFavourite = isFavourite;
			
			return t;
		}
		
		
		
		public function renameTag(tag: Tag, newTagLabel: String): void
		{
			var childTags: Array = getTagsLike(tag.tag + "/");
			var oldTagLabel:String = tag.tagLabel;  
			
			_renameTag(tag, newTagLabel);			

			if (childTags) {
				for (var i:int = 0; i < childTags.length; i++)
				{
					var t:Tag = childTags[i];
					_renameTag(t, newTagLabel + t.tagLabel.substring(oldTagLabel.length));	
				}
			}						
		}
		
		
		public function _renameTag(tag: Tag, newTagLabel: String): void
		{
			//trace('_renameTag ' + tag.tagLabel + '->' + newTagLabel);
			 
			var newTag: String = newTagLabel.toLowerCase();
			
			if (tag.tag == newTag) {
				return;
			}
			
			if (getTag(newTag) != null) {
				return;
			}

			var tasks: Array = getTasksByTag(tag);

			// update current tag
			var st:SQLStatement = new SQLStatement();
			st.sqlConnection = con;
			st.text = "update Tag set tag = :newTag, tagLabel = :tagLabel where tag = :oldTag";
			st.parameters[":newTag"] = newTag;
			st.parameters[":tagLabel"] = newTagLabel;
			st.parameters[":oldTag"] = tag.tag;
			st.execute();
			
			if (tasks) {
				for (var i: int = 0; i < tasks.length; i++) 
				{
					var task:Task = tasks[i];
					task.editText = task.editText.replace(TAG_PATTERN, function(t:String, p2:Object, p3:Object):String {
						if (t.toLowerCase() == tag.tag) {
							return "";
						} else {
							return t;
						}
					});
					task.editText = StringUtil.trim(task.editText) + " " + newTagLabel;					
					updateTask(task);
				}
			}
			
			tag.tag = newTag;
			tag.tagLabel = newTagLabel;
		}		
		
		
		
		public function emptyTrash(): void
		{
			try 
			{
				con.begin();

				var st:SQLStatement = new SQLStatement();
				st.sqlConnection = con;
				st.text = "delete from TaskTag where taskId in (select id from Task where folderOrdering = :trashFolderOrdering)";
				st.parameters[":trashFolderOrdering"] = getFolder(Folder.FOLDER_ID_TRASH).ordering;
				st.execute();			

				st.text = "update Task set folderOrdering = null, folderId = null where folderOrdering = :trashFolderOrdering";
				st.execute();			
				
				con.commit();
				
			} catch (e:SQLError) {
				con.rollback();
				Alert.show("We have a tiny problem: " + e.message + " (" + e.details + ")");
			}			
		}
		
		
		
		public function tasksToText(tasks:Array): String
		{
			tasks.sort(function(a: Object, b: Object): int {
				if (Task(a).folderOrdering > Task(b).folderOrdering) return -1; 
				if (Task(a).folderOrdering < Task(b).folderOrdering) return 1;
				if (Task(a).ordering > Task(b).ordering) return -1; 
				return 1;
			});
			
			var text: String = "";
			
			for (var i: int = 0; i < tasks.length; i++) 
			{
				var task:Task = tasks[i];
				text += task.editText + "\n";
			}
			
			return text;
		}



		public function textToTasks(text: String, folder:Folder, tag: Tag): Array
		{
			var lines: Array = text.split("\n");
			var taskIds: Array = [];
			for (var i: int = lines.length - 1; i >= 0; i--) 
			{
				var line:String = lines[i];
				line = StringUtil.trim(line);
				if (line != "") {
					var id: int = addNewTask(folder, tag, line);
					updateTask(getTasksById(id));
					taskIds.push(id);
				}
			}
			return taskIds;
		}

	}
}