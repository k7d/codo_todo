package codo.view.common
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.controls.TextArea;

	public class BlockTextArea extends TextArea
	{
		
		private var blockArray:Array;
		
		public function BlockTextArea()
		{
			super();
			blockArray = [];
		}
		
		
		
		public function showBlock(beginIndex:int, endIndex:int):void
		{
			var movieTip:HighlightBlock= new HighlightBlock(this.textField);
			movieTip.offsetPoint = new Point(6, 5);
			movieTip.highLightDraw(beginIndex, endIndex);
			//movieTip.toolTip = "beginIndex: "+beginIndex+"\nendIndex: "+endIndex+"\nlength: "+(endIndex-beginIndex+1).toString()+"\ntext:\t"+this.textField.text.substring(beginIndex, endIndex+1);
			clearBlock();
			this.addChild(movieTip);
			//this.addChildAt(movieTip, 0);
			blockArray.push(movieTip);			
		}
		
		
		
		public function clearBlock():void
		{
			var len:uint = blockArray.length;
			for(var k:uint=0;k<len;k++)
			{
				var obj:DisplayObject = blockArray[k]
				this.removeChild(obj);
				obj = null;
			}
			blockArray = [];
		}
		
		
		
		public function getCharIndexAtPoint(x: Number, y: Number): int 
		{
			return	textField.getCharIndexAtPoint(x, y);
		}
	}
}