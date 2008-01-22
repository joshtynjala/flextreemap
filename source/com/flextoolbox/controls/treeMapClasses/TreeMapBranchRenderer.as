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
	import flash.geom.Rectangle;
	import mx.core.IFlexDisplayObject;
	import flash.display.DisplayObject;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	import mx.skins.RectangularBorder;
	import mx.managers.ISystemManager;
	import mx.skins.halo.HaloBorder;
	import flash.events.MouseEvent;
	import com.flextoolbox.events.TreeMapEvent;
	import flash.text.TextField;
	import mx.core.UITextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderSkin;
	
	public class TreeMapBranchRenderer extends BaseTreeMapBranchRenderer
	{
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
		
		public function TreeMapBranchRenderer()
		{
			super();
		}
		
		protected var headerHighlighted:Boolean = false;
		
		protected var header:TreeMapBranchHeader;
		protected var border:IFlexDisplayObject;
	
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
				this.header.addEventListener(MouseEvent.CLICK, headerClickHandler, false, 0, true);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.header)
			{
				this.header.label = this.treeMapBranchData.label;
				this.header.selected = this.selected;
				this.header.enabled = this.enabled && this.treeMapBranchData.showLabel;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{	
			var headerWidth:Number = 0;
			var headerHeight:Number = 0;
			if(this.header)
			{
				headerWidth = this.unscaledWidth;
				if(this.treeMapBranchData.closed)
				{
					headerHeight = this.unscaledHeight;
				}
				else
				{
					headerHeight = this.treeMapBranchData.showLabel ? this.header.getExplicitOrMeasuredHeight() : 0;
				}
				
				this.header.setActualSize(headerWidth, headerHeight);
			}
			
			if(this.border)
			{
				this.border.setActualSize(unscaledWidth, unscaledHeight);
			}
			if(this.treeMapBranchData.closed) return;
			
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
		
		protected function headerClickHandler(event:MouseEvent):void
		{
			var zoom:TreeMapEvent = new TreeMapEvent(TreeMapEvent.BRANCH_ZOOM, this, true);
			this.dispatchEvent(zoom);
		}
	}
}