/*

	Copyright (C) 2006 Josh Tynjala
	Flex 2 TreeMap Component
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License (version 2) as
	published by the Free Software Foundation. 

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License (version 2) for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

package com.joshtynjala.controls.treeMapClasses
{
	import com.joshtynjala.controls.TreeMap;
	import com.joshtynjala.controls.treeMapClasses.treemap_internal;
	import mx.collections.IViewCursor;
	import mx.collections.ICollectionView;
	import mx.collections.CursorBookmark;
	import flash.geom.Rectangle;
	
	use namespace treemap_internal;
	
	/**
	 *  Lays out <code>TreeMap</code> nodes using the Slice-and-dice subdivision alogrithm.
	 *  Preserves the original ordering of the data set, but generates high aspect ratios.
	 *  Node positions are very stable.
	 * 
	 *  @see zeuslabs.visualization.treemaps.TreeMap
	 */
	public class SliceAndDice implements ITreeMapLayoutStrategy
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 *  Constructor.
		 */
		public function SliceAndDice()
		{
		}
		
	//--------------------------------------
	//  Variables and Properties
	//--------------------------------------
	
		/**
		 *  Storage for the treemap whose nodes are being laid out.
		 */
		private var _target:TreeMap;
		
		/**
		 *  @private
		 *  Iterator for the target's data provider.
		 */
		private var _dataIterator:IViewCursor;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 *  @copy com.joshtynjala.controls.treeMapClasses.ITreeMapLayoutStrategy#updateLayout
		 */
		public function updateLayout(treeMap:TreeMap):void
		{
			this._target = treeMap;
			if(!this._target) return;
			
			var dataProvider:ICollectionView = this._target.dataProvider as ICollectionView;
			
			this._dataIterator = dataProvider.createCursor();
			var totalWeight:Number = this.calculateTotalWeightSum();
			
			//the starting bounds are based on the map's calculated content area
			var mapBounds:Rectangle = this._target.contentBounds.clone();
			
			var lengthOfLongSide:Number = Math.max(mapBounds.width, mapBounds.height);
			var lengthOfShortSide:Number = Math.min(mapBounds.width, mapBounds.height);
			
			var nodeID:int = 0;
			var position:Number = 0;
			if(this._dataIterator.afterLast) return;
			do
			{
				var currentData:Object = this._dataIterator.current;
				var currentWeight:Number = this._target.itemToWeight(currentData);
				var oppositeLength:Number = lengthOfLongSide * (currentWeight / totalWeight);
				
				var nodeBounds:Rectangle;
				if(lengthOfLongSide == mapBounds.width)
				{
					nodeBounds = new Rectangle(mapBounds.left + position, mapBounds.top,
						oppositeLength, lengthOfShortSide);
				}
				else
				{
					nodeBounds = new Rectangle(mapBounds.left, mapBounds.top + position,
						lengthOfShortSide, oppositeLength);
				}
				
				this.drawNode(nodeID, nodeBounds);
				nodeID++
				position += oppositeLength;
			}
			while(this._dataIterator.moveNext());
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
	
		/**
		 *  @private
		 *  Places a node and sets its dimensions.
		 */
		private function drawNode(nodeID:int, bounds:Rectangle):void
		{
			var currentNode:ITreeMapNodeRenderer = this._target.nodes[nodeID] as ITreeMapNodeRenderer;
			currentNode.move(bounds.x, bounds.y);
			currentNode.setActualSize(bounds.width, bounds.height);
		}
		
		/**
		 *  @private
		 *  Uses the data provider's iterator to access each data item to
		 *  determine the total sum of the items' weight properties.
		 */
		private function calculateTotalWeightSum():Number
		{
			var start:CursorBookmark = this._dataIterator.bookmark;
			
			var totalSum:Number = 0;
			do
			{
				var currentWeight:Number = this._target.itemToWeight(this._dataIterator.current);
				totalSum += currentWeight;
			}
			while(this._dataIterator.moveNext());
				
			this._dataIterator.seek(start);
			
			return totalSum;
		}
	}
}