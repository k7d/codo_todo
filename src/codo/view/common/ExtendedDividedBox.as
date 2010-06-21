package codo.view.common
{
    //import flash.geom.*;
    import flash.display.GradientType;
    import flash.display.SpreadMethod;
    import flash.events.MouseEvent;
    import flash.geom.*;
    
    import mx.containers.DividedBox;
    import mx.containers.dividedBoxClasses.*;
    import mx.controls.Button;
    import mx.core.mx_internal;
    import mx.events.ResizeEvent;
    
    use namespace mx_internal;
    
    [Style(name="barFillColors",type="Array",format="Color",inherit="no")]
        
    [Event(name="buttonClick", type="codo.view.common.ButtonClickEvent")]
    public class ExtendedDividedBox extends DividedBox
    {
                        
        //create the gradient and apply tothe box controle
        private var fillType:String = GradientType.LINEAR;
        private var alphas:Array = [1,1];
        private var ratios:Array = [0,255];
        private var spreadMethod:String = SpreadMethod.PAD;
        
        private var mBoxDivider:Array = new Array();
        
        private var _barFillColors:Array;    
        
        [Embed(source="/codo/assets/divider/arrow_down.png")]
        private var Arrow_Down:Class;
        
        [Embed(source="/codo/assets/divider/arrow_up.png")]
        private var Arrow_Up:Class;
                
        [Embed(source="/codo/assets/divider/arrow_close.png")]
        private var Arrow_Close:Class;
        
        [Embed(source="/codo/assets/divider/arrow_open.png")]
        private var Arrow_Open:Class;

        [Embed(source="/codo/assets/empty.png")]
        private var Empty:Class;
                        
        private var _buttonOnIndexs:Array;
        private var _showButton:Boolean=false;
        private var _isOverButton:Boolean;
        
        public function ExtendedDividedBox():void{
            super();
        }
        
        public function set buttonOnIndexs(value:Array):void{
            _buttonOnIndexs=value
        }
        
        public function get buttonOnIndexs():Array{
            return _buttonOnIndexs;    
        }
        
        public function set showButton(value:Boolean):void{
            _showButton=value
        }
        
        public function get showButton():Boolean{
            return _showButton;    
        }
        
        public function set buttonSelected(value:Boolean):void{
            if (_button){
                _button.selected=value;
            }
        }
        
        public function get buttonSelected():Boolean{
            if (_button){
                return _button.selected;    
            }
            else{
                return false;
            }
        }


        /**
         * don't allow dragging if over a button
         * */        
        
        override mx_internal function startDividerDrag(divider:BoxDivider,trigger:MouseEvent):void{
            
            //ignore if we are over a button
            if(_showButton && _isOverButton){
                return;            
            }
    
            super.mx_internal::startDividerDrag(divider,trigger);
            
        }
        
        /**
         * don't show splitter cursor when over a button
         * */    
        override mx_internal function changeCursor(divider:BoxDivider):void{
            
            //ignore if we are over a button
            if(_showButton && _isOverButton){
                return;            
            }
            
            super.mx_internal::changeCursor(divider);
            
        }
        
        private function verifyButtonIndex(value:int):Boolean{
            
            for(var i:int=0;i < _buttonOnIndexs.length;i++) {
                if (value == _buttonOnIndexs[i]){
                    return true;
                }
            }
            
            return false;
            
        }        
        
        private var _button:Button;      
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth, unscaledHeight);

			var oldDividers:Array = mBoxDivider;
			mBoxDivider = new Array();
			
            for(var i:int=0;i < numDividers;i++) {
                var divbar:BoxDivider = getDividerAt(i);
                mBoxDivider.push(divbar);
                if (oldDividers.indexOf(divbar) < 0) {
	                divbar.addEventListener("resize",handleResize);                    

                    var _hasbutton:Boolean=true;
                    if (_buttonOnIndexs){
                        if (_buttonOnIndexs.length !=0){
                            _hasbutton= verifyButtonIndex(i)
                        }
                    }
                                                
                    if(i == 0 && _showButton && _hasbutton){
                        _button = new Button();
                        _button.name = "SplitterButton" + i;
                        
                        _button.toggle = true;

                        _button.setStyle("cornerRadius",0);                        
                        _button.setStyle("downSkin",Empty);
                        _button.setStyle("overSkin",Empty);
                        _button.setStyle("upSkin", Empty);

                        _button.setStyle("selectedDownSkin",Empty);
                        _button.setStyle("selectedOverSkin",Empty);
                        _button.setStyle("selectedUpSkin",Empty);
                                                
                        if (direction == "vertical"){
                            _button.width = getStyle("buttonWidth");
                            _button.height= getStyle("dividerThickness")+1;
                            
                            _button.setStyle("icon",Arrow_Down);
                            _button.setStyle("selectedOverIcon",Arrow_Up);
                            _button.setStyle("selectedUpIcon",Arrow_Up);
                            _button.setStyle("selectedDownIcon",Arrow_Up);
                            
                            
                        }
                        else{
                            _button.height = getStyle("buttonWidth");
                            _button.width= getStyle("dividerThickness");
                            _button.setStyle("paddingLeft", 0);
                            _button.setStyle("paddingRight", 0);
                            _button.setStyle("icon",Arrow_Close);
                            _button.setStyle("selectedOverIcon",Arrow_Open);
                            _button.setStyle("selectedUpIcon",Arrow_Open);
                            _button.setStyle("selectedDownIcon",Arrow_Open);
                        }
                        
                        _button.addEventListener(MouseEvent.CLICK, handleClick);
                        _button.addEventListener(MouseEvent.MOUSE_OVER, handleOver);
                        _button.addEventListener(MouseEvent.MOUSE_OUT, handleOut);
                        
                        divbar.addChild(_button);
                 	}
                } 
			}         
            
			drawGradientFill();            
        }
        
        
        
        private function handleResize(event:ResizeEvent):void{
            
            if(!_showButton){return;}
            
            if (event.currentTarget.width != event.oldWidth || event.currentTarget.height != event.oldHeight){
            
                for(var i:int=0;i < numDividers;i++) {
                    var divbar:BoxDivider = getDividerAt(i);

                }
            }
        }



        private function handleClick(event:MouseEvent):void
        {
            dispatchEvent(new ButtonClickEvent("buttonClick",event.currentTarget,Boolean(event.currentTarget.selected)));
        }
        


        private function handleOut(event:MouseEvent):void
        {
            _isOverButton=false;
        }
        
        
        
        private function handleOver(event:MouseEvent):void
        {
            _isOverButton=true;
        }
        
        
        
        override public function styleChanged(styleProp:String):void 
        {
            super.styleChanged(styleProp);

            if (styleProp=="barFillColors") 
            {
                _barFillColors=null;
                invalidateDisplayList();
                return;
            }
        }


                
        private function drawGradientFill():void
        {            
            graphics.clear();
                
            for(var i:int=0;i < mBoxDivider.length;i++) {
                    
                if (!_barFillColors){
                    _barFillColors = getStyle("barFillColors");
                    if (!_barFillColors){
                        _barFillColors =[0xFCFCFC,0xEAEAEA];
                    }
                }
                
                var divwidth:Number = mBoxDivider[i].getStyle("dividerThickness");
                
                if (divwidth==0){divwidth=10;}
                
                var matr:Matrix = new Matrix();
                
                if (direction == "vertical"){
                    matr.createGradientBox(mBoxDivider[i].width,divwidth,Math.PI/2, mBoxDivider[i].x, mBoxDivider[i].y);
                    
                    graphics.beginGradientFill(fillType, _barFillColors, alphas, ratios, matr,spreadMethod);
                    graphics.drawRect(mBoxDivider[i].x,mBoxDivider[i].y,mBoxDivider[i].width,divwidth);
                }
                else{
                    matr.createGradientBox(divwidth,mBoxDivider[i].height ,0, mBoxDivider[i].x, mBoxDivider[i].x+10);
                    graphics.beginGradientFill(fillType, _barFillColors, alphas, ratios, matr,spreadMethod);
                    graphics.drawRect(mBoxDivider[i].x,mBoxDivider[i].y,divwidth, mBoxDivider[i].height);
                }
            }            
        }
                
    }
}