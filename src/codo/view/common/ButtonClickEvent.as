package codo.view.common
{
    import flash.events.Event;


    public class ButtonClickEvent extends Event
    {

            public function ButtonClickEvent(type:String,buttonObject:Object,selected:Boolean){
                super(type);
                
                this.buttonObject=buttonObject;
                this.selected=selected;
                
            }

            public var buttonObject:Object;
            public var selected:Boolean;

            override public function clone():Event {
                return new ButtonClickEvent(type, buttonObject,selected);
            }

        
    }

}