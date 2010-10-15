////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2007-2010 Josh Tynjala
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.controls.treeMapClasses
{
	import com.flextoolbox.events.TreeMapBranchEvent;
	import com.flextoolbox.events.TreeMapEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.skins.RectangularBorder;
	import mx.skins.halo.HaloBorder;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @copy ITreeMapBranchRenderer#requestSelect
	 */
	[Event(name="requestSelect", type="com.flextoolbox.events.TreeMapBranchEvent")]

	/**
	 * @copy ITreeMapBranchRenderer#requestZoom
	 */
	[Event(name="requestZoom", type="com.flextoolbox.events.TreeMapBranchEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
include "../../styles/metadata/BorderStyles.inc"
include "../../styles/metadata/PaddingStyles.inc"
	
	/**
	 * Name of the CSS style declaration that specifies styles for the treemap
	 * branch headers. You can use this class selector to set the values of all
	 * the style properties of the TreeMapBranchHeader class.
	 * 
	 * @see TreeMapBranchHeader
	 */
	[Style(name="headerStyleName",type="String",inherit="no")]
	
	/**
	 * The default branch renderer for the TreeMap control. Includes a header
	 * with a label and a zoom button.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala
	 */
	public class TreeMapBranchRenderer extends BaseTreeMapBranchRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapBranchRenderer()
		{
			super();
		}
	
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The border skin for the branch.
		 */
		protected var border:IFlexDisplayObject;
	
		/**
		 * @private
		 * The header control on this branch renderer.
		 */
		protected var header:UIComponent;
	
		/**
		 * @private
		 * Flag that indicates if the headerRenderer factory has changed
		 * and if a new header needs to be created to replace the old.
		 */	
		protected var headerRendererChanged:Boolean = true;
	
		/**
		 * @private
		 * Storage for the headerRenderer property.
		 */
		private var _headerRenderer:IFactory = new ClassFactory(TreeMapBranchHeader);
		
		/**
		 * A factory used to create the header controls for the branch. The
		 * default value is a factory which creates a com.flextoolbox.controls.treeMapClasses.TreeMapBranchHeader.
		 * The created object must be a subclass of UIComponent and implement
		 * the mx.core.IDataRenderer interface. The data property is set to the
		 * branch renderer associated with the header.
		 * 
		 * @see TreeMapBranchHeader
		 */
		public function get headerRenderer():IFactory
		{
			return this._headerRenderer;
		}
		
		/**
		 * @private
		 */
		public function set headerRenderer(value:IFactory):void
		{
			this._headerRenderer = value;
			this.headerRendererChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{	
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "borderSkin")
			{
				if(this.border)
				{
					this.removeChild(DisplayObject(this.border));
				}
				
				var borderSkin:Class = this.getStyle("borderSkin");
				if(borderSkin)
				{
					this.border = new borderSkin();
					if(this.border is ISimpleStyleClient)
					{
						(this.border as ISimpleStyleClient).styleName = this;
					}
					this.addChildAt(DisplayObject(this.border), 0);
				}
			}
			
			if(allStyles || styleProp == "headerStyleName")
			{
				if(this.header)
				{
					var headerStyleName:String = this.getStyle("headerStyleName");
					this.header.styleName = headerStyleName;
				}
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.border)
			{
				var borderSkin:Class = this.getStyle("borderSkin");
				if(borderSkin)
				{
					this.border = new borderSkin();
					if(this.border is ISimpleStyleClient)
					{
						(this.border as ISimpleStyleClient).styleName = this;
					}
					this.addChildAt(DisplayObject(this.border), 0);
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.headerRendererChanged)
			{
				if(this.header)
				{
					this.header.removeEventListener(TreeMapBranchEvent.REQUEST_ZOOM, headerZoomHandler);
					this.header.removeEventListener(TreeMapBranchEvent.REQUEST_SELECT, headerSelectHandler);
					this.removeChild(this.header);
					this.header = null;
				}

				var headerStyleName:String = this.getStyle("headerStyleName");				
				this.header = this.headerRenderer.newInstance();
				
				if(this.header)
				{
					this.header.styleName = headerStyleName;
					this.header.addEventListener(TreeMapBranchEvent.REQUEST_SELECT, headerSelectHandler);
					this.header.addEventListener(TreeMapBranchEvent.REQUEST_ZOOM, headerZoomHandler);
					this.addChild(this.header);
				}
				
				this.headerRendererChanged = false;
			}
			
			if(this.header)
			{
				if(this.header is IDataRenderer)
				{
					IDataRenderer(this.header).data = this;
				}
			
				this.header.enabled = this.enabled && (!this.treeMapBranchData || !this.treeMapBranchData.displaySimple);
				this.header.visible = this.treeMapBranchData.closed || !this.treeMapBranchData.displaySimple;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{	
			//update the header
			var headerWidth:Number = unscaledWidth;
			var headerHeight:Number = 0;
			if(this.treeMapBranchData)
			{
				if(this.treeMapBranchData.closed)
				{
					headerHeight = unscaledHeight;
				}
				else if(!this.treeMapBranchData.displaySimple)
				{	
					headerHeight = Math.min(unscaledHeight, this.header.getExplicitOrMeasuredHeight());
				}
			}
			this.header.setActualSize(headerWidth, headerHeight);
			
			//update the border
			if(this.border)
			{
				this.border.setActualSize(unscaledWidth, unscaledHeight);
			}
			
			//if closed, we don't need to layout the contents
			if(this.treeMapBranchData && this.treeMapBranchData.closed)
			{
				return;
			}
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
			//include the border metrics
			if(this.border && this.border is RectangularBorder)
			{
				var rectBorder:RectangularBorder = this.border as RectangularBorder;
				paddingLeft += rectBorder.borderMetrics.left;
				paddingTop += rectBorder.borderMetrics.top;
				paddingRight += rectBorder.borderMetrics.right;
				paddingBottom += rectBorder.borderMetrics.bottom;
			}
			
			var boundsX:Number = Math.min(unscaledWidth, paddingLeft);
			var boundsY:Number = Math.min(unscaledHeight, headerHeight + paddingTop);
			var boundsW:Number = Math.max(0, unscaledWidth - boundsX - paddingRight);
			var boundsH:Number = Math.max(0, unscaledHeight - boundsY - paddingBottom);
			boundsX += this.x;
			boundsY += this.y;
			var contentBounds:Rectangle = new Rectangle(boundsX, boundsY, boundsW, boundsH);
			this.layoutContents(contentBounds);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
	
		/**
		 * @private
		 * Handles select events from the header.
		 */
		protected function headerSelectHandler(event:Event):void
		{
			var select:TreeMapBranchEvent = new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_SELECT);
			this.dispatchEvent(select);
		}
	
		/**
		 * @private
		 * Handles zoom events from the header.
		 */
		protected function headerZoomHandler(event:Event):void
		{
			var zoom:TreeMapBranchEvent = new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_ZOOM);
			this.dispatchEvent(zoom);
		}
	}
}