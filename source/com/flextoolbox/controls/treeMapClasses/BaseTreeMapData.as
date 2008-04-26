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
	 * The data passed to drop-in TreeMap item renderers.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class BaseTreeMapData
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function BaseTreeMapData(owner:TreeMap)
		{
			this._owner = owner;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The unique identifier for this item.
		 */
		public var uid:String;
		
		private var _owner:TreeMap;
		
		public function get owner():TreeMap
		{
			return this._owner;
		}
		
		private var _depth:int = 0;
		
		public function get depth():int
		{
			return this._depth;
		}
		
		public function set depth(value:int):void
		{
			this._depth = value;
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
		
		private var _label:String = "";
		
		public function get label():String
		{
			return this._label;
		}
		
		public function set label(value:String):void
		{
			this._label = value;
		}
		
		private var _dataTip:String = "";
		
		public function get dataTip():String
		{
			return this._dataTip;
		}
		
		public function set dataTip(value:String):void
		{
			this._dataTip = value;
		}
	}
}