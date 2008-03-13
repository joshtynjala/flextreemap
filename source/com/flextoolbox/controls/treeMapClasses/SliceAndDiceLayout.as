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
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	
	/**
	 * Slice-and-dice layout algorithm for the TreeMap component. The slice-and-
	 * dice algorithm creates nodes that are ordered, with very high aspect
	 * ratios, but stable node positioning.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * 
	 * @author Josh Tynjala
	 */
	public class SliceAndDiceLayout implements ITreeMapLayoutStrategy
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function SliceAndDiceLayout()
		{
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @copy ITreeMapLayoutStrategy#updateLayout()
		 */
		public function updateLayout(branchData:TreeMapBranchData, bounds:Rectangle):void
		{	
			var dataProvider:ICollectionView = new ArrayCollection(branchData.itemsToArray());
			var totalWeight:Number = this.calculateTotalWeightSum(dataProvider);
			var dataIterator:IViewCursor = dataProvider.createCursor();
			
			var lengthOfLongSide:Number = Math.max(bounds.width, bounds.height);
			var lengthOfShortSide:Number = Math.min(bounds.width, bounds.height);
			
			var position:Number = 0;
			while(!dataIterator.afterLast)
			{
				var currentData:TreeMapItemLayoutData = TreeMapItemLayoutData(dataIterator.current);
				var currentWeight:Number = currentData.weight;
				var oppositeLength:Number = lengthOfLongSide * (currentWeight / totalWeight);
				
				var nodeBounds:Rectangle;
				if(lengthOfLongSide == bounds.width)
				{
					nodeBounds = new Rectangle(bounds.left + position, bounds.top,
						oppositeLength, lengthOfShortSide);
				}
				else
				{
					nodeBounds = new Rectangle(bounds.left, bounds.top + position,
						lengthOfShortSide, oppositeLength);
				}
				
				currentData.x = nodeBounds.x;
				currentData.y = nodeBounds.y;
				currentData.width = nodeBounds.width;
				currentData.height = nodeBounds.height;
				
				position += oppositeLength;
				dataIterator.moveNext()
			}
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
	
	}
}