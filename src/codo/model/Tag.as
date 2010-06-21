package codo.model
{
	[Bindable]
	public class Tag
	{
		public var tag:String;
		public var tagLabel:String;
		public var isFavourite:Boolean;
		
		public function toString():String
		{
			return "Tag(" + tag + "/" + isFavourite + ")";
     	}     	
	}
}