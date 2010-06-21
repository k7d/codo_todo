package codo.view
{
	import flash.events.Event;

	public class FilterEntryEvent extends Event
	{
		public static var SELECT: String = "SELECT";
		public static var DRAG_DROP: String = "DRAG_DROP";
		public static var COLLAPSE: String = "COLLAPSE";
		public static var UNCOLLAPSE: String = "UNCOLLAPSE";
		
		public var items:Array;
		
		public function FilterEntryEvent(type:String, _items:Array = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.items = _items;
		}
		
	}
}