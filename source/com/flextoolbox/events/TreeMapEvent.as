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

package com.flextoolbox.events
{
	import com.flextoolbox.controls.treeMapClasses.ITreeMapItemRenderer;
	
	import flash.events.Event;

	/**
	 * The TreeMapEvent class represents events associated with items of the <code>TreeMap</code> control.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class TreeMapEvent extends Event
	{
		
	//--------------------------------------
	//  Class Constants
	//--------------------------------------
	
		/**
		 * Dispatched when the user clicks on a leaf item in the TreeMap component.
		 */
		public static const LEAF_CLICK:String = "leafClick";
		
		/**
		 * Dispatched when the user double clicks on a leaf item in the TreeMap component.
		 */
		public static const LEAF_DOUBLE_CLICK:String = "leafDoubleClick";
		
		/**
		 * Dispatched when the user rolls over a leaf item in the TreeMap component.
		 */
		public static const LEAF_ROLL_OVER:String = "leafRollOver";
		
		/**
		 * Dispatched when the user rolls out of a leaf item in the TreeMap component.
		 */
		public static const LEAF_ROLL_OUT:String = "leafRollOut";
		
		/**
		 * Dispatched when the user zooms a branch item in the TreeMap component.
		 */
		public static const BRANCH_ZOOM:String = "branchZoom";
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapEvent(type:String, itemRenderer:ITreeMapItemRenderer = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.itemRenderer = itemRenderer;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The item renderer to which the event is associated. This value may
		 * be <code>null</code> if the event wasn't dispatched as a result of
		 * user interaction.
		 */
		public var itemRenderer:ITreeMapItemRenderer;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TreeMapEvent(this.type, this.itemRenderer, this.bubbles, this.cancelable);
		}
		
	}
}