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
	 * Defines constants for a TreeMap's <code>zoomOutType</code> property.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class TreeMapZoomOutType
	{
		/**
		 * If a treemap's <code>zoomOutType</code> property is set to "full",
		 * zoom out actions will force the treemap to zoom out completely.
		 */
		public static const FULL:String = "full";
		
		/**
		 * If a treemap's <code>zoomOutType</code> property is set to "previous",
		 * zoom out actions will stop at the previously zoomed in branch if it exists.
		 */
		public static const PREVIOUS:String = "previous";
		
		/**
		 * If a treemap's <code>zoomOutType</code> property is set to "parent",
		 * zoom out actions will stop at the parent branch if it exists.
		 */
		public static const PARENT:String = "parent";
	}
}