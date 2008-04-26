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
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.events.TreeMapEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.core.UITextField;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @copy ITreeMapBranchRenderer#branchSelect
	 */
	[Event(name="branchSelect", type="com.flextoolbox.events.TreeMapEvent")]

	/**
	 * @copy ITreeMapBranchRenderer#branchZoom
	 */
	[Event(name="branchZoom", type="com.flextoolbox.events.TreeMapEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	//TODO: Add rollOverColor and others
	
include "../../styles/metadata/BorderStyles.inc"
include "../../styles/metadata/PaddingStyles.inc"
include "../../styles/metadata/TextStyles.inc"

	/**
	 * A very simple branch renderer for the TreeMap control. If the TreeMap has
	 * branch selection enabled, clicking the branch renderer will select the
	 * branch. If the TreeMap has zoom enabled, double clicking or ctrl-clicking
	 * the branch renderer will zoom the branch.
	 *  
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class LiteTreeMapBranchRenderer extends BaseTreeMapBranchRenderer
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
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("LiteTreeMapBranchRenderer");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				
				this.paddingLeft = 2;
				this.paddingRight = 2;
				this.paddingTop = 2;
				this.paddingBottom = 2;
				
				this.backgroundColor = 0xcccccc;
				this.rollOverColor = 0xeefee6;
				this.selectionColor = 0x7fceff;
				this.selectionDisabledColor = 0xdddddd;
				
				this.textSelectedColor = 0x2b333c;
				this.textRollOverColor = 0x2b333c;
				
				this.fontSize = 10;
			}
			
			StyleManager.setStyleDeclaration("LiteTreeMapBranchRenderer", selector, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function LiteTreeMapBranchRenderer()
		{
			super();
		
			this.doubleClickEnabled = true;
			
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		protected var headerText:UITextField;
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			this.invalidateDisplayList();
		}
		
		protected var mouseIsOver:Boolean = false;
		
		protected var zoomCursorID:int = 0;
	
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.headerText)
			{
				this.headerText = new UITextField();
				this.headerText.mouseEnabled = false;
				this.headerText.styleName = this;
				this.addChild(this.headerText);
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
				this.headerText.text = this.treeMapBranchData.label;
				this.headerText.enabled = this.enabled && this.treeMapBranchData.displaySimple;
				this.headerText.toolTip = this.treeMapBranchData.dataTip;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var treeMap:TreeMap = this.treeMapBranchData.owner;
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
			//update the header
			var headerWidth:Number = this.unscaledWidth - paddingLeft - paddingRight;
			var headerHeight:Number = 0;
			if(this.treeMapBranchData && this.treeMapBranchData.closed)
			{
				headerHeight = this.unscaledHeight - paddingTop - paddingBottom;
			}
			else
			{
				headerHeight = this.treeMapBranchData.displaySimple ? this.headerText.getExplicitOrMeasuredHeight() : 0;
			}
			this.headerText.x = paddingLeft;
			this.headerText.y = paddingTop;
			this.headerText.setActualSize(headerWidth, headerHeight);
			
			//draw the background
			var backgroundColor:uint = this.getStyle("backgroundColor");
			if(treeMap.selectable)
			{
				if(this.mouseIsOver)
				{
					backgroundColor = this.getStyle("rollOverColor");
				}
				else if(this.selected)
				{
					if(this.enabled)
					{
						backgroundColor = this.getStyle("selectionColor");	
					}
					else
					{
						backgroundColor = this.getStyle("selectionDisabledColor");
					}
				}
			}
			this.graphics.clear();
			this.graphics.beginFill(backgroundColor);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
			
			//if not closed, layout the contents
			if(this.treeMapBranchData && this.treeMapBranchData.closed)
			{
				return;
			}
			
			var boundsX:Number = paddingLeft;
			var boundsY:Number = headerHeight + paddingTop;
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
		
		protected function clickHandler(event:MouseEvent):void
		{
			if(event.ctrlKey)
			{
				var zoom:TreeMapEvent = new TreeMapEvent(TreeMapEvent.BRANCH_ZOOM, this);
				this.dispatchEvent(zoom);
			}
			else
			{
				var select:TreeMapEvent = new TreeMapEvent(TreeMapEvent.BRANCH_SELECT, this);
				this.dispatchEvent(select);
			}
		}
		
		protected function doubleClickHandler(event:MouseEvent):void
		{
			var zoom:TreeMapEvent = new TreeMapEvent(TreeMapEvent.BRANCH_ZOOM, this);
			this.dispatchEvent(zoom);
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			this.mouseIsOver = true;
			this.invalidateDisplayList();
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			this.mouseIsOver = false;
			this.invalidateDisplayList();
		}
	}
}