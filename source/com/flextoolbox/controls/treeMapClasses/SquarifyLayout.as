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
	import flash.geom.Rectangle;

	/**
	 * The squarify treemap layout algorithm creates nodes that are unordered,
	 * with the lowest possible aspect ratios, and medium stability of node
	 * positions. In short, the algorithm attempts to make all the nodes into
	 * squares.
	 *  
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala
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
		 * The sum of the weight values for the remaining items that have not
		 * yet been positioned and sized.
		 */
		private var _totalRemainingWeightSum:Number = 0;

		/**
		 * @private
		 * The number of items remaining to be drawn.
		 */
		private var _itemsRemaining:int = 0;

	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @inheritDoc
		 */
		public function updateLayout(branchRenderer:ITreeMapBranchRenderer, bounds:Rectangle):void
		{
			var items:Array = branchRenderer.itemsToArray();
			this.squarify(items, bounds.clone());
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * The main squarify algorithm.
		 */
		private function squarify(items:Array, bounds:Rectangle):void
		{
			items = items.sortOn("weight", Array.DESCENDING | Array.NUMERIC);
			this._totalRemainingWeightSum = this.sumWeights(items);
			this._itemsRemaining = items.length;
			var lastAspectRatio:Number = Number.POSITIVE_INFINITY;
			var lengthOfShorterEdge:Number = Math.min(bounds.width, bounds.height);
			var row:Array = [];
			while(items.length > 0)
			{
				var nextItem:TreeMapItemLayoutData = TreeMapItemLayoutData(items.shift());
				row.push(nextItem);
				var drawRow:Boolean = true;
				var aspectRatio:Number = this.calculateWorstAspectRatioInRow(row, lengthOfShorterEdge, bounds);
				if(lastAspectRatio >= aspectRatio || isNaN(aspectRatio))
				{
					lastAspectRatio = aspectRatio;
					
					//if this is the last item, force the row to draw
					drawRow = items.length == 0;
				}
				else
				{
					//put the item back if the aspect ratio is worse than the previous one
					//we want to draw, of course
					items.unshift(row.pop());
				}
				
				if(drawRow)
				{	
					bounds = this.layoutRow(row, lengthOfShorterEdge, bounds);
					
					//reset for the next pass
					lastAspectRatio = Number.POSITIVE_INFINITY;
					lengthOfShorterEdge = Math.min(bounds.width, bounds.height);
					row = [];
					drawRow = false;
				}
			}
		}
		
		/**
		 * @private
		 * Determines the worst (maximum) aspect ratio of the items in a row.
		 * 
		 * @param row						a row of items for which to calculate the worst aspect ratio
		 * @param lengthOfShorterEdge		the length, in pixels, of the edge of the remaining bounds on which to draw the row (the shorter one)
		 * @return							the worst aspect ratio for the items in the row
		 */
		private function calculateWorstAspectRatioInRow(row:Array, lengthOfShorterEdge:Number, bounds:Rectangle):Number
		{
			if(row.length == 0)
			{
				throw new ArgumentError("Row must contain at least one item. If you see this message, please file a bug report.");
			}
			
			if(lengthOfShorterEdge == 0)
			{
				return Number.MAX_VALUE;
			}
			
			var totalArea:Number = bounds.width * bounds.height;
			var lengthSquared:Number = lengthOfShorterEdge * lengthOfShorterEdge;
			
			//special case where there is zero weight (to avoid divide by zero problems)
			if(this._totalRemainingWeightSum == 0)
			{
				var oneItemArea:Number = totalArea * (1 / this._itemsRemaining);
				var rowAreaSquared:Number = Math.pow(oneItemArea * row.length, 2);
				return Math.max(lengthSquared * oneItemArea / rowAreaSquared, rowAreaSquared / (lengthSquared * oneItemArea));
			}
			
			var firstItem:TreeMapItemLayoutData = TreeMapItemLayoutData(row[0]);
			var firstItemArea:Number = totalArea * (firstItem.weight / this._totalRemainingWeightSum);
			var maxArea:Number = firstItemArea;
			var minArea:Number = firstItemArea;
			var sumOfAreas:Number = firstItemArea;
			var rowCount:int = row.length;
			for(var i:int = 1; i < rowCount; i++)
			{
				var item:TreeMapItemLayoutData = TreeMapItemLayoutData(row[i]);
				var area:Number = totalArea * (item.weight / this._totalRemainingWeightSum);
				minArea = Math.min(area, minArea);
				maxArea = Math.max(area, maxArea);
				sumOfAreas += area;
			}
			
			// max(w^2 * r+ / s^2, s^2 / (w^2 / r-))
			var sumSquared:Number = sumOfAreas * sumOfAreas;
			return Math.max(lengthSquared * maxArea / sumSquared, sumSquared / (lengthSquared * minArea));
		}
		
		/**
		 * @private
		 * Draws a row of items
		 * 
		 * @param row						The items in the row
		 * @param lengthOfShorterEdge		the length, in pixels, of the edge of the remaining bounds on which to draw the row (the shorter one)
		 * @param bounds					The remaining bounds into which to draw items
		 */
		private function layoutRow(row:Array, lengthOfShorterEdge:Number, bounds:Rectangle):Rectangle
		{
			var horizontal:Boolean = lengthOfShorterEdge == bounds.width;
			var lengthOfLongerEdge:Number = horizontal ? bounds.height : bounds.width;
			var sumOfRowWeights:Number = this.sumWeights(row);
			
			var lengthOfCommonItemEdge:Number = lengthOfLongerEdge * (sumOfRowWeights / this._totalRemainingWeightSum);
			if(isNaN(lengthOfCommonItemEdge))
			{
				if(this._totalRemainingWeightSum == 0)
				{
					lengthOfCommonItemEdge = lengthOfLongerEdge * row.length / this._itemsRemaining;
				}
				else
				{
					lengthOfCommonItemEdge = 0;
				}
			}
			
			var rowCount:int = row.length;
			var position:Number = 0;
			for(var i:int = 0; i < rowCount; i++)
			{
				var item:TreeMapItemLayoutData = TreeMapItemLayoutData(row[i]);
				var weight:Number = item.weight;
				
				var ratio:Number = weight / sumOfRowWeights;
				//if all nodes in a row have a weight of zero, give them the same area
				if(isNaN(ratio))
				{
					if(sumOfRowWeights == 0 || isNaN(sumOfRowWeights))
					{
						ratio = 1 / row.length;
					}
					else
					{
						ratio = 0;
					}
				}
				
				var lengthOfItemEdge:Number = lengthOfShorterEdge * ratio;
				
				if(horizontal)
				{
					item.x = bounds.x + position;
					item.y = bounds.y;
					item.width = lengthOfItemEdge;
					item.height = lengthOfCommonItemEdge;
				}
				else
				{
					item.x = bounds.x;
					item.y = bounds.y + position;
					item.width = Math.max(0, lengthOfCommonItemEdge);
					item.height = Math.max(0, lengthOfItemEdge);
				}
				position += lengthOfItemEdge;
				this._itemsRemaining--;
			}
			
			this._totalRemainingWeightSum -= sumOfRowWeights;
			return this.updateBoundsForNextRow(bounds, lengthOfCommonItemEdge);
		}
		
		/**
		 * @private
		 * After a row is drawn, the bounds must be made smaller to draw the
		 * next row.
		 */
		private function updateBoundsForNextRow(bounds:Rectangle, modifier:Number):Rectangle
		{
			if(bounds.width > bounds.height)
			{
				var newWidth:Number = Math.max(0, bounds.width - modifier);
				bounds.x -= (newWidth - bounds.width);
				bounds.width = newWidth;
			}
			else
			{
				var newHeight:Number = Math.max(0, bounds.height - modifier);
				bounds.y -= (newHeight - bounds.height);
				bounds.height = newHeight;
			}
			
			return bounds;
		}
	
		/**
		 * @private
		 * Calculates the sum of weight values in an Array of
		 * TreeMapItemLayoutData instances.
		 */
		private function sumWeights(source:Array):Number
		{
			var sum:Number = 0;
			for each(var item:TreeMapItemLayoutData in source)
			{
				sum += item.weight;
			}
			return sum;
		}
		
	}
}