////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 Josh Tynjala
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
	import com.flextoolbox.events.TreeMapEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.IFlexDisplayObject;
	import mx.skins.RectangularBorder;
	import mx.skins.halo.HaloBorder;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	
	public class TreeMapBranchRenderer extends BaseTreeMapBranchRenderer
	{
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets the default style values for instances of this type.
		 */
		public static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeMapBranchRenderer");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.backgroundColor = 0xcccccc;
				
				this.paddingLeft = 2;
				this.paddingRight = 2;
				this.paddingTop = 2;
				this.paddingBottom = 2;
				
				this.borderSkin = HaloBorder;
				this.borderStyle = "solid";
				this.borderColor = 0xaaaaaa;
				this.borderThickness = 1;
				
				this.fontSize = 10;
				this.fontWeight = "bold";
				this.textAlign = "left";
			}
			
			StyleManager.setStyleDeclaration("TreeMapBranchRenderer", selector, false);
		}
		initializeStyles();
		
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
		
		protected var headerHighlighted:Boolean = false;
		
		protected var header:TreeMapBranchHeader;
		protected var border:IFlexDisplayObject;
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			super.styleChanged(styleProp);
			
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
			
			if(allStyles || styleProp == "branchHeaderStyleName" && this.header)
			{
				var headerStyleName:String = this.getStyle("branchHeaderStyleName");
				if(headerStyleName)
				{
					var headerStyleDecl:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + headerStyleName);
					if(headerStyleDecl)
					{
						this.header.styleDeclaration = headerStyleDecl;
						this.header.regenerateStyleCache(true);
						this.header.styleChanged(null);
					}
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
			
			if(!this.header)
			{
				this.header = new TreeMapBranchHeader();
				this.addChild(this.header);
				
				this.header.styleName = this;
				var headerStyleName:String = this.getStyle("headerStyleName");
				if(headerStyleName)
				{
					var headerStyleDecl:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + headerStyleName);
					if(headerStyleDecl)
					{
						this.header.styleDeclaration = headerStyleDecl;
						this.header.regenerateStyleCache(true);
						this.header.styleChanged(null);
					}
				}
				this.header.addEventListener(TreeMapEvent.BRANCH_SELECT, headerSelectHandler);
				this.header.addEventListener(TreeMapEvent.BRANCH_ZOOM, headerZoomHandler);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.treeMapBranchData)
			{
				this.header.label = this.treeMapBranchData.label;
				this.header.selected = this.selected;
				this.header.enabled = this.enabled && this.treeMapBranchData.showLabel;
				this.header.zoomEnabled = this.enabled && this.treeMapBranchData.owner.zoomEnabled;
				this.header.zoomed = this.treeMapBranchData.zoomed;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{	
			//update the header
			var headerWidth:Number = this.unscaledWidth;
			var headerHeight:Number = 0;
			this.header.visible = true;
			if(this.treeMapBranchData)
			{
				if(this.treeMapBranchData.closed)
				{
					headerHeight = this.unscaledHeight;
				}
				else if(this.treeMapBranchData.showLabel)
				{	
					headerHeight = this.header.getExplicitOrMeasuredHeight();
				}
				else
				{
					this.header.visible = false;
				}
			}
			this.header.setActualSize(headerWidth, headerHeight);
			
			//update the border
			if(this.border)
			{
				this.border.setActualSize(unscaledWidth, unscaledHeight);
			}
			
			//if not closed, layout the contents
			if(this.treeMapBranchData && this.treeMapBranchData.closed) return;
			
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
			
			var x:Number = paddingLeft;
			var y:Number = headerHeight + paddingTop;
			var w:Number = unscaledWidth - x - paddingRight;
			var h:Number = unscaledHeight - y - paddingBottom;
			var contentBounds:Rectangle = new Rectangle(x, y, w, h);
			this.layoutContents(contentBounds);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
	
		protected function headerSelectHandler(event:Event):void
		{
			var select:TreeMapEvent = new TreeMapEvent(TreeMapEvent.BRANCH_SELECT, this);
			this.dispatchEvent(select);
		}
	
		protected function headerZoomHandler(event:Event):void
		{
			var zoom:TreeMapEvent = new TreeMapEvent(TreeMapEvent.BRANCH_ZOOM, this);
			this.dispatchEvent(zoom);
		}
	}
}