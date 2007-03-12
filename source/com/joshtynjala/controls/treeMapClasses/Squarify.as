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
	import mx.collections.ICollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.IViewCursor;
	import mx.collections.CursorBookmark;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.geom.Point;

	use namespace treemap_internal;

	/**
	 * Lays out <code>TreeMap</code> nodes using the Squarified subdivision alogrithm.
	 * Generates excellent aspect ratios, but doesn't preserve the original
	 * ordering of the data set. Node positions have medium stability.
	 * 
	 * @see zeuslabs.visualization.treemaps.TreeMap
	 */
	public class Squarify implements ITreeMapLayoutStrategy
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param target		The <code>TreeMap</code> that this layout strategy will manipulate.
		 */
		public function Squarify()
		{
		}
		
	//--------------------------------------
	//  Variables and Properties
	//--------------------------------------
	
		/**
		 * @private
		 * Storage for the treemap whose nodes are being laid out.
		 */
		private var _target:TreeMap;
		
		/**
		 * @private
		 * Storage for the length of the shorter side of the remaining unfilled space.
		 */
		private var _shorterSide:Number;
		
		/**
		 * @private
		 * Storage for the length of the longer side of the remaining unfilled space.
		 */
		private var _longerSide:Number;
		
		/**
		 * @private
		 * The number of nodes that have been drawn during a layout update.
		 */
		private var _numDrawnNodes:int;
		
		/**
		 * @private
		 * Storage for the target's data provider.
		 */
		private var _dataProvider:ICollectionView;
		
		/**
		 * @private
		 * Iterator for the target's data provider.
		 */
		private var _dataIterator:IViewCursor;
		
		/**
		 * @private
		 * At the beginning of a layout update, store the weights as calculated by the
		 * target TreeMap. This provides a huge performance boost because we won't need
		 * to calculate these values many times.
		 */
		private var _savedWeights:Dictionary;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @copy com.joshtynjala.controls.treeMapClasses.ITreeMapLayoutStrategy#updateLayout
		 */
		public function updateLayout(treeMap:TreeMap):void
		{
			this._target = treeMap;
			if(!this._target) return;
			
			this._dataProvider = this._target.dataProvider as ICollectionView;
			if(this._dataProvider.length == 0) return;
			
			this.saveWeightsAndGetTotalSum(this._dataProvider);
			
			var sortWeights:Sort = new Sort();
			var weightField:SortField = new SortField(null, true, true, true);
			weightField.compareFunction = this.compareWeights;
			sortWeights.fields = [weightField];

			this._dataProvider.sort = sortWeights;
			this._dataProvider.refresh();
			
			var weightSum:Number = this.saveWeightsAndGetTotalSum(this._dataProvider);
			
			//the starting bounds are based on the map's calculated content area
			var mapBounds:Rectangle = this._target.contentBounds.clone();
			this._longerSide = Math.max(mapBounds.width, mapBounds.height);
			this._shorterSide = Math.min(mapBounds.width, mapBounds.height);
			
			this._numDrawnNodes = 0;
			this._dataIterator = this._dataProvider.createCursor();
			if(!this._dataIterator.afterLast)
			{
				this.squarify([this._dataIterator.current], weightSum, mapBounds);
			}
			
			this._dataProvider.sort = null;
			this._dataProvider.refresh();
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Determines the weight of items from the target TreeMap and saves the values
		 * so that they don't need to be calculated every time a weight is required.
		 */
		private function saveWeightsAndGetTotalSum(data:ICollectionView):Number
		{
			var sum:Number = 0;
			this._savedWeights = new Dictionary();
			var iterator:IViewCursor = data.createCursor();
			do
			{
				var currentData:Object = iterator.current;
				var weight:Number = this._target.itemToWeight(currentData);
				this._savedWeights[currentData] = weight;
				sum += weight;
			}
			while(iterator.moveNext());
			return sum;
		}
		
		/**
		 * @private
		 * Called recursively to calculate the <code>TreeMap</code>'s layout.
		 */
		private function squarify(dataInCurrentRow:Array, sumOfRemaining:Number, mapBounds:Rectangle):void
		{
			var sumOfCurrentRow:Number = this.sumWeights(dataInCurrentRow);
			
			//make a copy of the data in the current row, then add the next piece of unused data
			if(this._dataIterator.moveNext())
			{
				var dataWithExtraNode:Array = dataInCurrentRow.concat();
				var temp:Object = this._dataIterator.current;
				dataWithExtraNode.push(temp);
				
				var extraWeight:Number = this._savedWeights[this._dataIterator.current];
				
				if(this.aspectRatio(dataInCurrentRow, sumOfCurrentRow, sumOfRemaining) 
					>= this.aspectRatio(dataWithExtraNode, sumOfCurrentRow + extraWeight, sumOfRemaining))
				{
					this.squarify(dataWithExtraNode, sumOfRemaining, mapBounds);
					return;
				}
				this._dataIterator.movePrevious();
			}
					
			//draw the row and make new bounds for the next row
			mapBounds = this.drawRow(dataInCurrentRow, sumOfCurrentRow, sumOfRemaining, mapBounds);
			
			//start a new row if we still have data
			if(this._dataIterator.moveNext())
			{
				sumOfRemaining -= sumOfCurrentRow;
			
				//generate the distances needed for calculation of the bounds for each child
				this._shorterSide = Math.min(mapBounds.width, mapBounds.height);
				this._longerSide = Math.max(mapBounds.width, mapBounds.height);
				
				this.squarify([this._dataIterator.current], sumOfRemaining, mapBounds);
			}

		}
		
		/**
		 * @private
		 * Determines the worst (maximum) aspect ratio of a row if it contained a specific set of data.
		 * 
		 * @param dataInRow		the data for which to calculate the worst aspect ratio for a row
		 * @param sumOfRow			a precalculated sum of the data in the row
		 * @param sumOfRemaining	a precalculated sum of the remaining data to be drawn
		 * @return					the worst aspect ratio for the data in the row
		 */
		private function aspectRatio(dataInRow:Array, sumOfRow:Number, sumOfRemaining:Number):Number
		{
			var lengthOfLongerSide:Number = this.calculateLengthOfLongerSide(dataInRow, sumOfRow, sumOfRemaining);
			
			//special case
			if(sumOfRemaining == 0)
			{
				var value:Number = Math.max(this._shorterSide / dataInRow.length, dataInRow.length / this._shorterSide);
				return Math.max(value / lengthOfLongerSide, lengthOfLongerSide / value);
			}
			
			var weight:Number = this._savedWeights[dataInRow[0]];
			var minValue:Number = weight;
			var maxValue:Number = weight;
			var rowCount:int = dataInRow.length;
			for(var i:int = 1; i < rowCount; i++)
			{
				weight = this._savedWeights[dataInRow[i]];
				minValue = Math.min(minValue, weight);
				maxValue = Math.max(maxValue, weight);
			}
			
			value = Math.max((this._shorterSide * maxValue) / sumOfRow, sumOfRow / (this._shorterSide * minValue));
			return Math.max(value / lengthOfLongerSide, lengthOfLongerSide / value);
		}
		
		/**
		 * @private
		 * Draws a single row of nodes.
		 */
		private function drawRow(dataInRow:Array, sumOfRow:Number, sumOfRemaining:Number, mapBounds:Rectangle):Rectangle
		{
			var lengthOfLongerSide:Number = this.calculateLengthOfLongerSide(dataInRow, sumOfRow, sumOfRemaining);
			
			var currentDistance:Number = 0;
			var rowCount:int = dataInRow.length;
			for(var i:int = 0; i < rowCount; i++)
			{	
				var currentData:Object = dataInRow[i];
				var currentNode:ITreeMapNodeRenderer = this._target.nodeDataToRenderer(currentData);
				if(!currentNode) continue;
				var currentWeight:Number = this._savedWeights[currentData];
				
				var ratio:Number = currentWeight / sumOfRow;
				//if all nodes in a row have a weight of zero, give them the same area
				if(isNaN(ratio))
				{
					if(sumOfRow == 0) ratio = 1 / dataInRow.length;
					else ratio = 0;
				}
				
				var lengthOfShorterSide:Number = this._shorterSide * ratio;
				
				var position:Point;
				if(mapBounds.width > mapBounds.height)
				{
					currentNode.setActualSize(Math.max(0, lengthOfLongerSide), Math.max(0, lengthOfShorterSide));
					currentNode.x = mapBounds.x;
					currentNode.y = mapBounds.y + currentDistance;
				}
				else
				{
					currentNode.setActualSize(Math.max(0, lengthOfShorterSide), Math.max(0, lengthOfLongerSide));
					currentNode.x = mapBounds.x + currentDistance;
					currentNode.y = mapBounds.y;
				}
					
				currentDistance += lengthOfShorterSide;
				this._numDrawnNodes++;
			}
			
			return this.updateBoundsForNextRow(mapBounds, lengthOfLongerSide);
		}
		
		/**
		 * @private
		 * After a row is drawn, the bounds are modified to fit the smaller region.
		 */
		private function updateBoundsForNextRow(mapBounds:Rectangle, modifier:Number):Rectangle
		{
			if(mapBounds.width > mapBounds.height)
			{
				mapBounds.x += modifier;
				mapBounds.width -= modifier;
			}
			else
			{
				mapBounds.y += modifier;
				mapBounds.height -= modifier;
			}
			
			return mapBounds;
		}
		
		/**
		 * @private
		 * Determines the portion of the longer remaining side that will be used for a set of data.
		 */
		private function calculateLengthOfLongerSide(dataInRow:Array, sumOfRow:Number, sumOfRemaining:Number):Number
		{
			var lengthOfLongerSide:Number = this._longerSide * (sumOfRow / sumOfRemaining);
			if(isNaN(lengthOfLongerSide))
			{
				//if all remaining weights are zero, give each row an equal size
				if(sumOfRemaining == 0)
				{
					lengthOfLongerSide = this._longerSide * (dataInRow.length / (this._dataProvider.length - this._numDrawnNodes));
				}
				else lengthOfLongerSide = 0;
			}
			return lengthOfLongerSide
		}
	
		/**
		 * @private
		 * Adds the weight value from each item in the TreeMap's data provider.
		 */
		private function sumWeights(q:Array):Number
		{
			var sum:Number = 0;
			var qCount:int = q.length;
			for(var i:int = 0; i < qCount; i++)
			{
				var currentItem:Object = q[i] as Object;
				var weight:Number = this._savedWeights[currentItem];
				sum += weight;
			}
			return sum;
		}
		
		/**
		 * @private
		 * Compares the weights from two items in the TreeMap's data provider.
		 */
		private function compareWeights(a:Object, b:Object, fields:Array = null):int
		{
			if(a == null && b == null)
				return 0;
			if(a == null)
				return 1;
			if(b == null)
				return -1;
                 
			var weightA:Number = this._savedWeights[a];
			var weightB:Number = this._savedWeights[b];

			if(weightA < weightB) return -1;
			if(weightA > weightB) return 1;
			return 0;
		}
	}
}