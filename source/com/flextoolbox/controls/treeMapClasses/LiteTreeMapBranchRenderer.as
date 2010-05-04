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
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.events.TreeMapBranchEvent;
	import com.flextoolbox.events.TreeMapEvent;
	import com.flextoolbox.utils.FlexFontUtil;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import mx.styles.CSSStyleDeclaration;
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
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala
	 */
	public class LiteTreeMapBranchRenderer extends BaseTreeMapBranchRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
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
	
		/**
		 * @private
		 * The textField that displays the text for the header.
		 */
		protected var headerText:TextField;
		
		/**
		 * @private
		 */
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the mouseIsOver property.
		 */
		private var _mouseIsOver:Boolean = false;
		
		/**
		 * @private
		 * Flag that indicates that the mouse is over the branch.
		 */
		protected function get mouseIsOver():Boolean
		{
			return this._mouseIsOver;
		}
		
		/**
		 * @private
		 */
		protected function set mouseIsOver(value:Boolean):void
		{
			this._mouseIsOver = value;
			this.invalidateDisplayList();
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
			
			if(!this.headerText)
			{
				this.headerText = new TextField();
				this.headerText.mouseEnabled = false;
				this.headerText.selectable = false;
				this.addChild(this.headerText);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.treeMapBranchData && this.headerText.text != this.treeMapBranchData.label)
			{
				this.headerText.text = this.treeMapBranchData.label;
			}
			FlexFontUtil.applyTextStyles(this.headerText, this);
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
			var headerWidth:Number = Math.max(0, this.unscaledWidth - paddingLeft - paddingRight);
			var headerHeight:Number = 0;
			if(this.treeMapBranchData && this.treeMapBranchData.closed)
			{
				headerHeight = Math.max(0, this.unscaledHeight - paddingTop - paddingBottom);
			}
			else
			{
				headerHeight = Math.min(unscaledHeight, !this.treeMapBranchData.displaySimple ? (this.headerText.textHeight + 4) : 0);
			}
			this.headerText.x = paddingLeft;
			this.headerText.y = paddingTop;
			this.headerText.width = headerWidth;
			this.headerText.height = headerHeight;
			
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
		
		/**
		 * @private
		 * Either zooms or selects the branch when clicked, depending on if the
		 * ctrl key is pressed.
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			if(event.ctrlKey)
			{
				var zoom:TreeMapBranchEvent = new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_ZOOM);
				this.dispatchEvent(zoom);
			}
			else
			{
				var select:TreeMapBranchEvent = new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_SELECT);
				this.dispatchEvent(select);
			}
		}
		
		/**
		 * @private
		 * Zooms the branch when double clicked.
		 */
		protected function doubleClickHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			var zoom:TreeMapBranchEvent = new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_ZOOM);
			this.dispatchEvent(zoom);
		}
		
		/**
		 * @private
		 * Sets the flag to change appearance when the mouse is over.
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			this.mouseIsOver = true;
		}
		
		/**
		 * @private
		 * Clears the flag to change appearance when the mouse is over.
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			this.mouseIsOver = false;
		}
	}
}