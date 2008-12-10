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

package com.flextoolbox.events
{
	import flash.events.Event;

	/**
	 * Event used by branch renderers to indicate certain changes.
	 * 
	 * @see com.flextoolbox.controls.treeMapClasses.ITreeMapBranchRenderer
	 * @author Josh Tynjala
	 */
	public class TreeMapBranchEvent extends Event
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * Dispatched when the branch finishes laying out its children.
		 */
		public static const LAYOUT_COMPLETE:String = "layoutComplete";
		
		/**
		 * Dispatched when the user interacts with the branch to zoom it.
		 */
		public static const REQUEST_ZOOM:String = "requestZoom";
		
		/**
		 * Dispatched when the user interacts when the branch to select it.
		 */
		public static const REQUEST_SELECT:String = "requestSelect";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapBranchEvent(type:String)
		{
			super(type, false, false);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TreeMapBranchEvent(this.type);
		}
		
	}
}