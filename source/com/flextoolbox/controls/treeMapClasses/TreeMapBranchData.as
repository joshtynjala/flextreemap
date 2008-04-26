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
	import com.flextoolbox.controls.TreeMap;

	/**
	 * The data passed to drop-in TreeMap branch renderers.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class TreeMapBranchData extends BaseTreeMapData
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function TreeMapBranchData(owner:TreeMap)
		{
			super(owner);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var _layoutStrategy:ITreeMapLayoutStrategy;
		
		public function get layoutStrategy():ITreeMapLayoutStrategy
		{
			return this._layoutStrategy;
		}
		
		public function set layoutStrategy(value:ITreeMapLayoutStrategy):void
		{
			this._layoutStrategy = value;
		}
		
		private var _displaySimple:Boolean = true;
		
		/**
		 * Does not display addition information to the user, such as a label.
		 */
		public function get displaySimple():Boolean
		{
			return this._displaySimple;
		}
		
		public function set displaySimple(value:Boolean):void
		{
			this._displaySimple = value;
		}
		
		private var _closed:Boolean = false;
		
		public function get closed():Boolean
		{
			return this._closed;
		}
		
		public function set closed(value:Boolean):void
		{
			this._closed = value;
		}
		
		private var _zoomed:Boolean = false;
		
		public function get zoomed():Boolean
		{
			return this._zoomed;
		}
		
		public function set zoomed(value:Boolean):void
		{
			this._zoomed = value;
		}
		
	}
}