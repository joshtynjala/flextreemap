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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.core.UIComponent;
	import com.yahoo.astra.utils.DisplayObjectUtil;
	import com.flextoolbox.controls.TreeMap;
	
	public class BaseTreeMapBranchRenderer extends UIComponent implements ITreeMapBranchRenderer, IDropInTreeMapItemRenderer
	{
		public function BaseTreeMapBranchRenderer()
		{
			super();
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
		
		private var _data:Object;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			this._data = value;
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
				this.invalidateDisplayList();
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var contentBounds:Rectangle = new Rectangle(0, 0, unscaledWidth, unscaledHeight);
			this.layoutContents(contentBounds);
		}
		
		protected function layoutContents(contentBounds:Rectangle):void
		{
			var treeMap:TreeMap = this.treeMapBranchData.owner;
			
			this.treeMapBranchData.layoutStrategy.updateLayout(this.treeMapBranchData, contentBounds);
			
			var itemCount:int = this.treeMapBranchData.itemCount;
			for(var i:int = 0; i < itemCount; i++)
			{
				var itemLayoutData:TreeMapItemLayoutData = this.treeMapBranchData.getItemAt(i);
				var itemPosition:Point = new Point(itemLayoutData.x, itemLayoutData.y);
				var topLevelPosition:Point = DisplayObjectUtil.localToLocal(itemPosition, this, this.owner);
				
				var renderer:ITreeMapItemRenderer = treeMap.itemToItemRenderer(itemLayoutData.item);
				if(renderer.data == treeMap.zoomedBranch)
				{
					renderer.move(0, 0);
					//this is strange and kind hacky, but it works!
					renderer.setActualSize(treeMap.width, treeMap.height);
				}
				else
				{
					renderer.move(topLevelPosition.x, topLevelPosition.y);
					renderer.setActualSize(itemLayoutData.width, itemLayoutData.height);
				}
			}
			
		}
	}
}