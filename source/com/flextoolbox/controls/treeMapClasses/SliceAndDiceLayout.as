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
	 * Slice-and-dice layout algorithm for the TreeMap component. The slice-and-
	 * dice algorithm creates nodes that are ordered, with very high aspect
	 * ratios, but stable node positions.
	 *  
	 * @see com.flextoolbox.controls.TreeMap
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
		 * @inheritDoc
		 */
		public function updateLayout(branchRenderer:ITreeMapBranchRenderer, bounds:Rectangle):void
		{	
			if(branchRenderer.itemCount == 0)
			{
				return;
			}
			
			var items:Array = branchRenderer.itemsToArray();
			var totalWeight:Number = this.sumWeights(items);
			
			var lengthOfLongSide:Number = Math.max(bounds.width, bounds.height);
			var lengthOfShortSide:Number = Math.min(bounds.width, bounds.height);
			
			var position:Number = 0;
			var itemCount:int = items.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var currentData:TreeMapItemLayoutData = TreeMapItemLayoutData(items[i]);
				var currentWeight:Number = currentData.weight;
				var oppositeLength:Number = lengthOfLongSide * (currentWeight / totalWeight);
				if(isNaN(oppositeLength))
				{
					if(totalWeight == 0 || isNaN(totalWeight))
					{
						oppositeLength = lengthOfLongSide * 1 / itemCount; 
					}
					else
					{
						oppositeLength = 0;
					}
				}
				
				if(lengthOfLongSide == bounds.width)
				{
					currentData.x = bounds.left + position;
					currentData.y = bounds.top;
					currentData.width = oppositeLength;
					currentData.height = lengthOfShortSide;
				}
				else
				{
					currentData.x = bounds.left;
					currentData.y = bounds.top + position;
					currentData.width = lengthOfShortSide;
					currentData.height = oppositeLength;
				}
				
				position += oppositeLength;
			}
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Calculates the sum of item weights.
		 */
		private function sumWeights(source:Array):Number
		{
			var sum:Number = 0;
			for each (var item:TreeMapItemLayoutData in source)
			{
				sum += item.weight;
			}
			return sum;
		}
	
	}
}