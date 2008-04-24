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
	/**
	 * Used by instances of ITreeMapLayoutStrategy to position nodes within a
	 * TreeMap control
	 * 
	 * @author Josh Tynjala
	 * @see ITreeMapLayoutStrategy
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class TreeMapItemLayoutData
	{
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function TreeMapItemLayoutData(renderer:ITreeMapItemRenderer)
		{
			this.renderer = renderer;			
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		private var _renderer:ITreeMapItemRenderer;
		
		public function get renderer():ITreeMapItemRenderer
		{
			return this._renderer;
		}
		
		public function set renderer(value:ITreeMapItemRenderer):void
		{
			this._renderer = value;
		}
	
		private var _x:Number = 0;
		
		public function get x():Number
		{
			return this._x;
		}
		
		public function set x(value:Number):void
		{
			this._x = value;
		}
		
		private var _y:Number = 0;
		
		public function get y():Number
		{
			return this._y;
		}
		
		public function set y(value:Number):void
		{
			this._y = value;
		}
		
		private var _width:Number = 0;
		
		public function get width():Number
		{
			return this._width;
		}
		
		public function set width(value:Number):void
		{
			this._width = value;
		}
		
		private var _height:Number = 0;
		
		public function get height():Number
		{
			return this._height;
		}
		
		public function set height(value:Number):void
		{
			this._height = value;
		}
		
		private var _weight:Number = 0;
		
		public function get weight():Number
		{
			return this._weight;
		}
		
		public function set weight(value:Number):void
		{
			this._weight = value;
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