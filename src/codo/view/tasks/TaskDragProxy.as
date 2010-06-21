package codo.view.tasks
{
	import flash.display.DisplayObject;
	
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBase;
	import mx.controls.listClasses.ListBaseContentHolder;
	import mx.controls.listClasses.ListItemDragProxy;
	import mx.core.UIComponent;
	import mx.core.mx_internal;

	use namespace mx_internal;
		
	public class TaskDragProxy extends ListItemDragProxy
	{
	    public function TaskDragProxy()
	    {
	        super();
	    }
	    
	    override protected function createChildren():void
	    {	   
	    	
	        var items:Array /* of unit */ = ListBase(owner).selectedItems;
	
	        var n:int = items.length;
	        for (var i:int = 0; i < n; i++)
	        {
	            var src:IListItemRenderer = ListBase(owner).itemToItemRenderer(items[i]);
	            if (!src)
	                continue;
	
	            var o:IListItemRenderer = ListBase(owner).createItemRenderer(items[i]);
	            
	            UIComponent(o).setStyle("paddingRight", 0);
	            if (i == 0) {
		            o.styleName = "TaskDragProxyEntryLast";	            
	            } else {
		            o.styleName = "TaskDragProxyEntry";	            	
	            }
	            
	            o.alpha = 0.5;
	            
	            if (o is IDropInListItemRenderer)
	            {
	                var listData:BaseListData =
	                    IDropInListItemRenderer(src).listData;
	                
	                IDropInListItemRenderer(o).listData = items[i] ?
	                                                      listData :
	                                                      null;
	            }
	
	           	o.data = items[i];
	            
	            addChild(DisplayObject(o));
	
	            var contentHolder:ListBaseContentHolder = src.parent as ListBaseContentHolder;
	            
	            o.setActualSize(src.width, src.height);
	            o.x = src.x + contentHolder.leftOffset;
	            o.y = src.y + contentHolder.topOffset;
	
	            measuredHeight = Math.max(measuredHeight, o.y + o.height);
	            measuredWidth = Math.max(measuredWidth, o.x + o.width);
	            o.visible = true;
	        }
			
	        invalidateDisplayList();
	    }
	}
}