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

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * TODO: Document this!
	 */
	[Event(name="branchSelect", type="com.flextoolbox.events.TreeMapEvent")]

	/**
	 * TODO: Document this!
	 */
	[Event(name="branchZoom", type="com.flextoolbox.events.TreeMapEvent")]

	/**
	 * TODO: Document this!
	 */
	[Event(name="branchLayoutChange", type="com.flextoolbox.events.TreeMapLayoutEvent")]
	
	/**
	 * The interface that defines functionality required for a TreeMap control's
	 * branch renderers.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public interface ITreeMapBranchRenderer extends ITreeMapItemRenderer
	{
		/**
		 * The number of items displayed in this branch.
		 */
		function get itemCount():int;
	
		/**
		 * Returns the item at the specified index.
		 */
		function getItemAt(index:int):TreeMapItemLayoutData;
	
		/**
		 * Adds an item to be displayed in this branch.
		 */
		function addItem(item:TreeMapItemLayoutData):void;
	
		/**
		 * Adds an item to a specific position in this branch.
		 */
		function addItemAt(item:TreeMapItemLayoutData, index:int):void;
	
		/**
		 * Removes an item that is currently being displayed in this branch.
		 */
		function removeItem(item:TreeMapItemLayoutData):void;
	
		/**
		 * Removes an item from a specific position in this branch.
		 */
		function removeItemAt(index:int):void;
		
		/**
		 * Removes all items currently displayed in this branch.
		 */
		function removeAllItems():void;
		
		/**
		 * Returns an Array containing all TreeMapItemLayoutData instances displayed by this branch.
		 */
		function itemsToArray():Array;
	}
}