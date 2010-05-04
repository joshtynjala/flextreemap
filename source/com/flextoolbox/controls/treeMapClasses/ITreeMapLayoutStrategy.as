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
	 * Designed to allow easy switching between treemap layout algorithms. 
	 * Several algorithms have been developed for treemaps and this interface
	 * may be extended to allow new layout methods.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public interface ITreeMapLayoutStrategy
	{
		
	//--------------------------------------
	//  Methods
	//--------------------------------------
	
		/**
		 * Updates the size and positions of a TreeMap branch renderer's child items.
		 */
		function updateLayout(branchRenderer:ITreeMapBranchRenderer, bounds:Rectangle):void
	}
}