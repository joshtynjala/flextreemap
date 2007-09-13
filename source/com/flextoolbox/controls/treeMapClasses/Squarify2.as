////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2007 Josh Tynjala
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
//  Copyright (c) 2001 Christophe Bouthier
//	Based in part on an implementation of the squarify algorithm
//	by Christophe Bouthier released under the MIT license.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.controls.treeMapClasses
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import mx.collections.ICollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.IViewCursor;
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.controls.treeMapClasses.treemap_internal;
	
	use namespace treemap_internal;

	/**
	 * Lays out <code>TreeMap</code> nodes using the Squarified subdivision alogrithm.
	 * Generates excellent aspect ratios, but doesn't preserve the original
	 * ordering of the data set. Node positions have medium stability.
	 * 
	 * @see zeuslabs.visualization.treemaps.TreeMap
	 */
	public class Squarify2 implements ITreeMapLayoutStrategy
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function Squarify2()
		{
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the treemap whose nodes are being laid out.
		 */
		private var _target:TreeMap;
		
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
			
			var dataProvider:ICollectionView = treeMap.dataProvider as ICollectionView;
			if(dataProvider.length == 0) return;
			
			var mapBounds:Rectangle = this._target.contentBounds;
			var x:Number = mapBounds.x;
			var y:Number = mapBounds.y;
			var width:Number = mapBounds.width;
			var height:Number = mapBounds.height;
			
			var totalWeight:Number = this.saveWeightsAndGetTotalSum(dataProvider);
			
			var sortWeights:Sort = new Sort();
			var weightField:SortField = new SortField(null, true, true, true);
			weightField.compareFunction = this.compareWeights;
			sortWeights.fields = [weightField];

			var oldSort:Sort = dataProvider.sort;
			dataProvider.sort = sortWeights;
			dataProvider.refresh();
			
			var iterator:IViewCursor = dataProvider.createCursor();
			while(!iterator.afterLast)
			{
				//start a new row
				var item:Object = iterator.current;
				var row:Array = [item];
				var rowWeight:Number = this._savedWeights[item];
				
				var w:Number = 0;
				var h:Number = 0;
				if(width > height)
				{
					w = width * (rowWeight / totalWeight);
					h = height;
				}
				else
				{
					w = width;
					h = height * (rowWeight / totalWeight);
				}
				
				var ratio:Number = this.ratio(w, h);
				
				//add items to the row until the ratio gets too big
				var rowDone:Boolean = false;
				iterator.moveNext();
				while(!iterator.afterLast && !rowDone)
				{
					var candidate:Object = iterator.current;
					var candidateWeight:Number = this._savedWeights[candidate];
					var newRowWeight:Number = rowWeight + candidateWeight;
					
					var newW:Number = 0;
					var newH:Number = 0;
					if(width > height)
					{
						newW = width * (newRowWeight / totalWeight);
						newH = height * (candidateWeight / newRowWeight);
					}
					else
					{
						newW = width * (candidateWeight / newRowWeight);
						newH = height * (newRowWeight / totalWeight);
					}
					
					var newRatio:Number = this.ratio(newW, newH);
					if(newRatio > ratio)
					{
						rowDone = true;
						iterator.movePrevious();
					}
					else
					{
						row.push(candidate);
						ratio = newRatio;
						rowWeight = newRowWeight;
						iterator.moveNext();
					}
				}
				
				//draw the row
				var childWidth:Number = 0;
				var childHeight:Number = 0;
				var childX:Number = x;
				var childY:Number = y;
				
				if(width > height)
				{
					childWidth = width * (rowWeight / totalWeight);
				}
				else
				{
					childHeight = height * (rowWeight / totalWeight);
				}
				
				var itemCount:int = row.length;
				for(var i:int = 0; i < itemCount; i++)
				{
					item = row[i];
					var node:ITreeMapNodeRenderer = treeMap.itemToRenderer(item);
					if(!node) continue;
					
					node.x = childX;
					node.y = childY;
					
					var proportion:Number = this._savedWeights[item] / rowWeight;
					if(width > height)
					{
						childHeight = proportion * height;
						childY += childHeight;
					}
					else
					{
						childWidth = proportion * width;
						childX += childWidth;
					}
					node.setActualSize(childWidth, childHeight);
				}
				
				totalWeight -= rowWeight;
				if(width > height)
				{
					x += childWidth;
					width -= childWidth;
				}
				else
				{
					y += childHeight;
					height -= childHeight;
				}
				iterator.moveNext();
			}
			
			
			//put the old sort back
			dataProvider.sort = oldSort;
			dataProvider.refresh();
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		private function ratio(width:Number, height:Number):Number
		{
    		return Math.max(width / height, height / width);
	    }
	    
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