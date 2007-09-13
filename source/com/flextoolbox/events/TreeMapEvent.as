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
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.events
{
	import flash.events.Event;
	import com.flextoolbox.controls.treeMapClasses.ITreeMapNodeRenderer;

	/**
	 * The TreeMapEvent class represents events associated with nodes of the
	 * <code>TreeMap</code> control.
	 */
	public class TreeMapEvent extends Event
	{
		
	//--------------------------------------
	//  Class Constants
	//--------------------------------------
	
		/**
		 * Dispatched when the user clicks on a node in the TreeMap component.
		 */
		public static const NODE_CLICK:String = "nodeClick";
		
		/**
		 * Dispatched when the user double clicks on a node in the TreeMap component.
		 */
		public static const NODE_DOUBLE_CLICK:String = "nodeDoubleClick";
		
		/**
		 * Dispatched when the user rolls over a node in the TreeMap component.
		 */
		public static const NODE_ROLL_OVER:String = "nodeRollOver";
		
		/**
		 * Dispatched when the user rolls out of a node in the TreeMap component.
		 */
		public static const NODE_ROLL_OUT:String = "nodeRollOut";
	
		/**
		 * Dispatched when a node should be zoomed in the TreeMap compoennt.
		 */
		public static const NODE_REQUEST_ZOOM:String = "nodeRequestZoom";
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, nodeRenderer:ITreeMapNodeRenderer = null)
		{
			super(type, bubbles, cancelable);
			this.nodeRenderer = nodeRenderer;
		}
		
	//--------------------------------------
	//  Member Variables and Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the affected node renderer.
		 */
		private var _nodeRenderer:ITreeMapNodeRenderer;
		
		/**
		 * The node renderer where the event occurred.
		 */
		public function get nodeRenderer():ITreeMapNodeRenderer
		{
			return this._nodeRenderer;
		}
		
		/**
		 * @private
		 */
		public function set nodeRenderer(renderer:ITreeMapNodeRenderer):void
		{
			this._nodeRenderer = renderer;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TreeMapEvent(this.type, this.bubbles, this.cancelable, this.nodeRenderer);
		}
		
	}
}