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
	
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	/**
	 * Some basic functionality for a branch renderer of the TreeMap control.
	 * Please consider this an abstract class that should be subclassed.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala
	 */
	public class BaseTreeMapBranchRenderer extends UIComponent implements ITreeMapBranchRenderer, IDropInTreeMapItemRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function BaseTreeMapBranchRenderer()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function set x(value:Number):void
		{
			super.x = value;
			//we need to invalidate the display list because the positions of
			//the "children" depends on our position and bounds. however, the
			//"children" are actually not display list children.
			this.invalidateDisplayList();
			//note: this appears to work correctly without the extra
			//invalidation in flex 3, but not in flex 4
		}
		
		/**
		 * @private
		 */
		override public function set y(value:Number):void
		{
			super.y = value;
			//for explanation, see comment in set x
			this.invalidateDisplayList();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function move(x:Number, y:Number):void
		{
			super.move(x, y);
			//for explanation, see comment in set x
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the items that are contained by this branch.
		 */
		protected var items:Array = [];
		
		/**
		 * @private
		 * Storage for the data property.
		 */
		private var _data:Object;
		
		/**
		 * @inheritDoc
		 */
		public function get data():Object
		{
			return this._data;
		}
		
		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			this._data = value;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the selected property.
		 */
		private var _selected:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		public function get selected():Boolean
		{
			return this._selected;
		}
		
		/**
		 * @private
		 */
		public function set selected(value:Boolean):void
		{
			if(this._selected != value)
			{
				this._selected = value;
				this.invalidateProperties();
			}
		}
		
		/**
		 * @private
		 * Storage for the treeMapData property.
		 */
		protected var treeMapBranchData:TreeMapBranchData;
		
		/**
		 * @inheritDoc
		 */
		public function get treeMapData():BaseTreeMapData
		{
			return this.treeMapBranchData;
		}
		
		/**
		 * @private
		 */
		public function set treeMapData(value:BaseTreeMapData):void
		{
			this.treeMapBranchData = TreeMapBranchData(value);
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get itemCount():int
		{
			return this.items.length;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int):TreeMapItemLayoutData
		{
			return this.items[index];
		}
	
		/**
		 * @inheritDoc
		 */
		public function addItem(item:TreeMapItemLayoutData):void
		{
			this.items.push(item);
		}
	
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:TreeMapItemLayoutData, index:int):void
		{
			this.items.splice(index, 0, item);
		}
	
		/**
		 * @inheritDoc
		 */
		public function removeItem(item:TreeMapItemLayoutData):void
		{
			var index:int = this.items.indexOf(item);
			if(index >= 0)
			{
				this.items.splice(index, 1);
			}
		}
	
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):void
		{
			this.items.splice(index, 1);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAllItems():void
		{
			this.items = [];
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemsToArray():Array
		{
			return this.items.concat();
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var contentBounds:Rectangle = new Rectangle(this.x, this.y, unscaledWidth, unscaledHeight);
			this.layoutContents(contentBounds);
		}
		
		/**
		 * Positions the children.
		 * Subclasses should override this or updateDisplayList() to size and
		 * position chrome.
		 */
		protected function layoutContents(contentBounds:Rectangle):void
		{	
			this.treeMapBranchData.layoutStrategy.updateLayout(this, contentBounds);
			this.dispatchEvent(new TreeMapBranchEvent(TreeMapBranchEvent.LAYOUT_COMPLETE));
		}
	}
}