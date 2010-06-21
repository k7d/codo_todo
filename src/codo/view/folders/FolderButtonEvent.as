package codo.view.folders
{
	import codo.model.Folder;
	
	import flash.events.Event;

	public class FolderButtonEvent extends Event
	{
		public static var SELECT: String = "select";
		
		public var folder: Folder;
		
		public function FolderButtonEvent(type:String, _folder:Folder, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			folder = _folder;
		}
		
	}
}