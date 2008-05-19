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
	import com.flextoolbox.events.TreeMapLayoutEvent;
	
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	/**
	 * Some basic functionality for a branch renderer of the TreeMap control.
	 * Please consider this an abstract class that should be subclassed.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class BaseTreeMapBranchRenderer extends UIComponent implements ITreeMapBranchRenderer, IDropInTreeMapItemRenderer
	{
		public function BaseTreeMapBranchRenderer()
		{
			super();
		}
		
		protected var items:Array = [];
		
		private var _data:Object;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			this._data = value;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		private var _selected:Boolean = false;
		
		public function get selected():Boolean
		{
			return this._selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if(this._selected != value)
			{
				this._selected = value;
				this.invalidateProperties();
			}
		}
		
		protected var treeMapBranchData:TreeMapBranchData;
		
		public function get treeMapData():BaseTreeMapData
		{
			return this.treeMapBranchData;
		}
		
		public function set treeMapData(value:BaseTreeMapData):void
		{
			this.treeMapBranchData = TreeMapBranchData(value);
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		public function get itemCount():int
		{
			return this.items.length;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		public function getItemAt(index:int):TreeMapItemLayoutData
		{
			return this.items[index];
		}
	
		public function addItem(item:TreeMapItemLayoutData):void
		{
			this.items.push(item);
		}
	
		public function addItemAt(item:TreeMapItemLayoutData, index:int):void
		{
			this.items.splice(index, 0, item);
		}
	
		public function removeItem(item:TreeMapItemLayoutData):void
		{
			var index:int = this.items.indexOf(item);
			if(index >= 0)
			{
				this.items.splice(index, 1);
			}
		}
	
		public function removeItemAt(index:int):void
		{
			this.items.splice(index, 1);
		}
		
		public function removeAllItems():void
		{
			this.items = [];
		}
		
		public function itemsToArray():Array
		{
			return this.items.concat();
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var contentBounds:Rectangle = new Rectangle(this.x, this.y, unscaledWidth, unscaledHeight);
			this.layoutContents(contentBounds);
		}
		
		protected function layoutContents(contentBounds:Rectangle):void
		{	
			this.treeMapBranchData.layoutStrategy.updateLayout(this, contentBounds);
			this.dispatchEvent(new TreeMapLayoutEvent(TreeMapLayoutEvent.BRANCH_LAYOUT_CHANGE, this.data));
		}
	}
}