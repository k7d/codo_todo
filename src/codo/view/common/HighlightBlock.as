package codo.view.common
{
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextLineMetrics;
	
	import mx.core.IUITextField;
	import mx.flash.UIMovieClip;
	
	public class HighlightBlock extends UIMovieClip
	{
		private var _textField:IUITextField;
		private var _offsetPoint:Point;
		
		
		
		public function HighlightBlock(textField:IUITextField)
		{
			super();
			_offsetPoint = new Point(0, 0);
			_textField = textField;
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		
		
		public function highLightDraw(beginIndex:Number, endIndex:Number):void
		{
			var beginValidIndex:Number = getValidBeginCharIndex(beginIndex);
			var endValidIndex:Number = getValidEndCharIndex(endIndex);
			if(beginValidIndex == -1 || endValidIndex == -2)
			{
				return;
			}
			if(beginValidIndex<=endValidIndex)
			{
				normalDraw(beginValidIndex, endValidIndex);
			}
		}
		
		
		private function normalDraw(beginIndex:Number, endIndex:Number):void
		{
			var beginLineIndex:Number = _textField.getLineIndexOfChar(beginIndex);
			var endLineIndex:Number = _textField.getLineIndexOfChar(endIndex);
			var disLineNum:Number = endLineIndex-beginLineIndex;
			if(disLineNum<1)
			{
				drawSingleLine(beginIndex, endIndex);
				return;
			}
			drawSingleLine(beginIndex, _textField.getLineOffset(beginLineIndex)+_textField.getLineLength(beginLineIndex)-1);
			for(var i:Number=beginLineIndex+1;i<endLineIndex;i++)
			{
				drawSingleLine(_textField.getLineOffset(i), _textField.getLineOffset(i)+_textField.getLineLength(i)-1);
			}
			drawSingleLine(_textField.getLineOffset(endLineIndex), endIndex);
		}
		
		

		private function drawSingleLine(beginIndex:Number, endIndex:Number):void
		{
			var beginLineIndex:Number = _textField.getLineIndexOfChar(beginIndex);
			var endLineIndex:Number = _textField.getLineIndexOfChar(endIndex);
			var disLineNum:Number = endLineIndex-beginLineIndex;
			
			if(disLineNum<1)
			{
				var frame:Rectangle = _textField.getCharBoundaries(beginIndex);
				frame.y = getDisLineHeightByLine(beginLineIndex);
				frame.width = _textField.getCharBoundaries(endIndex).x - _textField.getCharBoundaries(beginIndex).x+_textField.getCharBoundaries(endIndex).width;
				showBlock(frame, _textField.text.substring(beginIndex, endIndex));
			}
			else
			{
				throw new Error("drawSingleLine:disLineNum >= 1.");
			}
		}



		public function getDisLineHeightByLine(lineIndex:Number):Number
		{
			
			var addHeight:Number = 2;
			for(var i:Number=_textField.scrollV-1;i<lineIndex;i++)
			{
				var showLine:TextLineMetrics = _textField.getLineMetrics(i);
				addHeight += showLine.height;
			}
			return addHeight;
		}



		public function getDisLineHeightByChar(charIndex:Number):Number
		{
			var line:Number = _textField.getLineIndexOfChar(charIndex);
			return getDisLineHeightByLine(line);
		}
		

	
		public function getValidBeginCharIndex(beginIndex:Number):Number
		{
			var len:Number = _textField.text.length;
			if(beginIndex<0 || beginIndex>len-1) 
			{
				return -1;
			}
			var line:Number = _textField.getLineIndexOfChar(beginIndex);
			
			if(line<_textField.scrollV-1)
			{
				line = _textField.scrollV-1;
				return _textField.getLineOffset(line);
			}
			return beginIndex;
		}



		public function getValidEndCharIndex(endIndex:Number):Number
		{
			var len:Number = _textField.text.length;
			if(endIndex<0 || endIndex>len-1) 
			{
				return -2;
			}
			var line:Number = _textField.getLineIndexOfChar(endIndex);
			if(line>_textField.bottomScrollV-1)
			{
				line = _textField.bottomScrollV-1;
				return _textField.getLineOffset(line)+_textField.getLineLength(line)-1;
			}
			return endIndex;
		}
		
		
			
		private function showBlock(pos:Rectangle, text: String):void
		{
			var rect:Rectangle = new Rectangle(_offsetPoint.x+pos.x, _offsetPoint.y+pos.y, pos.width, pos.height);
			
			this.addChild(drawBlock(rect));
			
			var t:TextField = new TextField();			
			t.defaultTextFormat = TextField(_textField).defaultTextFormat;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.text = text;
			t.textColor = 0xffffff;
			t.x = _offsetPoint.x+pos.x - 1;
			t.y = _offsetPoint.y+pos.y - 1;
			this.addChild(t);
		}
		

	
		protected function drawBlock(rect:Rectangle):Shape
		{
			var block:Shape = new Shape();
			block.graphics.clear();
			block.graphics.beginFill(0x98a9c8, 1.0); 
			//block.graphics.lineStyle(1, 0x0099CC, .65, true);
			block.graphics.drawRoundRectComplex(rect.x - 3, rect.y - 2, rect.width + 6, rect.height + 6, 0, 0, 0, 0);
			block.graphics.endFill();
			
			return block;
		}
		
		/**
		 * 
		 * 目标文本组件
		 * @param tf 目标文本
		 * 
		 */		
		public function set textField(tf:IUITextField):void
		{
			_textField = tf;
		}
		
		/**
		 * 
		 * @private
		 * @return 目标文本
		 * 
		 */		
		public function get textField():IUITextField
		{
			return _textField;
		}
		
		/**
		 * 
		 * 偏移点
		 * @param op 偏移点
		 * 
		 */		
		public function set offsetPoint(op:Point):void
		{
			_offsetPoint = op;
		}
		
		/**
		 * 
		 * @private
		 * @return 偏移点
		 * 
		 */		
		public function get offsetPoint():Point
		{
			return _offsetPoint;
		}
	}
}