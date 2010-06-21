package codo.model
{
	[Bindable]
	public class Folder
	{
		public static var FOLDER_ID_TRASH:int = 1;
		public static var FOLDER_ID_DONE:int = 2;
		public static var FOLDER_ID_NEXT:int = 4;
		public static var FOLDER_ID_TODAY:int = 5;

		
		public var id: int;
		public var name:String;
		public var ordering:int;
		public var color:int;
		public var buttonName:String;
		public var keyboardShortcut: int;
		
		public function toString():String
		{
			return "Folder(" + name + ")";
     	}     	
     		
	}
}