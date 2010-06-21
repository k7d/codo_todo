package codo.model
{
	import mx.controls.DateField;
	import mx.events.IndexChangedEvent;
	
	[Bindable]
	public class Task
	{
		/*
		public static var STATUS_TODAY:int = 10;
		public static var STATUS_THIS_WEEK:int = 20;
		public static var STATUS_INBOX:int = 30;
		*/
		public static var STATUS_PENDING:int = 40;
		public static var STATUS_COMPLETED:int = 50;
		//public static var STATUS_DELETED:int = 60;
		
		public var id:int;
		public var status: int = STATUS_PENDING;
		public var statusTimestamp:Date = new Date();
		public var ordering:int;
		public var editText:String;
		public var viewText:String;
		public var folderId:int;
		public var folderOrdering:int;
		
		public function toString():String
		{
			return "Task(" + folderId + "/" + id + "," + ordering + "," + editText + ")";
     	}     	
     	
     	
     	
     	public function get isCompleted():Boolean
     	{
     		return status == STATUS_COMPLETED;
 		}
 		
     	public function set isCompleted(b:Boolean):void
     	{
 		} 		 		



     	public function get isDeleted():Boolean
     	{
     		return folderId == Folder.FOLDER_ID_TRASH;
 		}
 		
     	public function set isDeleted(b:Boolean):void
     	{
 		} 		 		
	}		
}