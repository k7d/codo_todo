package codo.view.common
{
	import flash.filters.DropShadowFilter;
	
	import mx.controls.Button;

	public class ToolbarButton extends Button
	{
		[Inspectable( defaultValue=1 )]
		public var shadowDistance:Number = 5;
		
		[Inspectable( defaultValue=45 )]
		public var shadowAngle:Number = 45;
		
		[Inspectable( defaultValue=0x003333 )]
		public var shadowColor:Number = 0x003333;
		
		[Inspectable( defaultValue=1 )]
		public var shadowAlpha:Number = 1;
		
		[Inspectable( defaultValue=0 )]
		public var shadowBlur:Number = 0;
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if ( getStyle( "shadowDistance" ))
			{
			shadowDistance = getStyle( "shadowDistance" );
			}
			
			if ( getStyle( "shadowAngle" ))
			{
			shadowAngle = getStyle( "shadowAngle" );
			}
			
			if ( getStyle( "shadowColor" ))
			{
			shadowColor = getStyle( "shadowColor" );
			}
			
			if ( getStyle( "shadowAlpha" ))
			{
			shadowAlpha = getStyle( "shadowAlpha" );
			}
			
			if ( getStyle( "shadowBlur" ))
			{
			shadowBlur = getStyle( "shadowBlur" );
			}
			
			textField.filters = [ new DropShadowFilter( shadowDistance, shadowAngle, shadowColor, shadowAlpha, shadowBlur, shadowBlur )];
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			textField.filters = [ new DropShadowFilter( shadowDistance, shadowAngle, shadowColor, shadowAlpha, shadowBlur, shadowBlur )];
		}
	}
}