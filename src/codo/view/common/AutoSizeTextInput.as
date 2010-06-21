package codo.view.common
{
	import flash.events.Event;
	
	import mx.controls.TextInput;

	public class AutoSizeTextInput extends TextInput {

		private var txtSpan:uint = 10;
	
		public var max:uint = 0;
		
		public function AutoSizeTextInput() {
			super();
			this.addEventListener(Event.CHANGE, onTextChange);
			var t:ToolbarButton = new ToolbarButton();
		}

		private function onTextChange(evnt:Event):void {
			resize();
		}

		override protected function commitProperties():void {
			super.commitProperties();
			resize();
		}
		
		protected function resize(): void {
			var w: int = this.autoSizeWidth;
			if (max > 0 && w > max) {
				this.width = max;				
			} else {
				this.textField.scrollH = 0;
				this.width = w;				
			}			
		}

		private function get autoSizeWidth():uint {
			return (this.textWidth+txtSpan);
		}
	}
}