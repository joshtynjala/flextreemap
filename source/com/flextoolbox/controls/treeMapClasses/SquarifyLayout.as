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
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import flash.geom.Point;
	
	/**
	 * Squarify layout algorithm for the TreeMap component. The squarify
	 * algorithm creates nodes that are unordered, with the lowest aspect
	 * ratios, and medium stability of node positioning.
	 *  
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class SquarifyLayout implements ITreeMapLayoutStrategy
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function SquarifyLayout()
		{
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
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
				
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @copy ITreeMapLayoutStrategy#updateLayout()
		 */
		public function updateLayout(branchData:TreeMapBranchData, bounds:Rectangle):void
		{
			if(branchData.itemCount == 0) return;
			this._dataProvider = new ArrayCollection(branchData.itemsToArray());
			
			var weightSum:Number = this.calculateTotalWeightSum(this._dataProvider);
			
			var sortWeights:Sort = new Sort();
			var weightField:SortField = new SortField(null, true, true, true);
			weightField.compareFunction = this.compareWeights;
			sortWeights.fields = [weightField];

			this._dataProvider.sort = sortWeights;
			this._dataProvider.refresh();
			
			//the starting bounds are based on the map's calculated content area
			this._longerSide = Math.max(bounds.width, bounds.height);
			this._shorterSide = Math.min(bounds.width, bounds.height);
			
			this._numDrawnNodes = 0;
			this._dataIterator = this._dataProvider.createCursor();
			if(!this._dataIterator.afterLast)
			{
				this.squarify([this._dataIterator.current], weightSum, bounds.clone());
			}
			
			this._dataProvider.sort = null;
			this._dataProvider.refresh();
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Calculates the sum of item weights.
		 */
		private function calculateTotalWeightSum(data:ICollectionView):Number
		{
			var sum:Number = 0;
			var iterator:IViewCursor = data.createCursor();
			do
			{
				var currentData:TreeMapItemLayoutData = iterator.current;
				var weight:Number = currentData.weight;
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
				var temp:TreeMapItemLayoutData = TreeMapItemLayoutData(this._dataIterator.current);
				dataWithExtraNode.push(temp);
				
				var extraWeight:Number = temp.weight;
				
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
			
			var layoutData:TreeMapItemLayoutData = TreeMapItemLayoutData(dataInRow[0]);
			var weight:Number = layoutData.weight;
			var minValue:Number = weight;
			var maxValue:Number = weight;
			var rowCount:int = dataInRow.length;
			for(var i:int = 1; i < rowCount; i++)
			{
				layoutData = TreeMapItemLayoutData(dataInRow[i]);
				weight = layoutData.weight;
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
				var currentData:TreeMapItemLayoutData = TreeMapItemLayoutData(dataInRow[i]);
				var currentWeight:Number = currentData.weight;
				
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
					currentData.x = mapBounds.x;
					currentData.y = mapBounds.y + currentDistance;
					currentData.width = Math.max(0, lengthOfLongerSide);
					currentData.height = Math.max(0, lengthOfShorterSide);
				}
				else
				{
					currentData.x = mapBounds.x + currentDistance;
					currentData.y = mapBounds.y;
					currentData.width = Math.max(0, lengthOfShorterSide);
					currentData.height = Math.max(0, lengthOfLongerSide);
				}
				currentData.x;
				currentData.y;
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
				var currentItem:TreeMapItemLayoutData = TreeMapItemLayoutData(q[i]);
				sum += currentItem.weight;
			}
			return sum;
		}
		
		/**
		 * @private
		 * Compares the weights from two items in the TreeMap's data provider.
		 */
		private function compareWeights(a:TreeMapItemLayoutData, b:TreeMapItemLayoutData, fields:Array = null):int
		{
			if(a == null && b == null)
				return 0;
			if(a == null)
				return 1;
			if(b == null)
				return -1;
                 
			var weightA:Number = a.weight;
			var weightB:Number = b.weight;

			if(weightA < weightB) return -1;
			if(weightA > weightB) return 1;
			return 0;
		}
		
	}
}