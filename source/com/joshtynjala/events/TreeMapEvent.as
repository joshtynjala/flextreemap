/*

	Copyright (C) 2006 Josh Tynjala
	Flex 2 TreeMap Component
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License (version 2) as
	published by the Free Software Foundation. 

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License (version 2) for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

package com.joshtynjala.events
{
	import flash.events.Event;
	import com.joshtynjala.controls.treeMapClasses.ITreeMapNodeRenderer;

	/**
	 *  The TreeMapEvent class represents events associated with nodes of the
	 *  <code>TreeMap</code> control.
	 */
	public class TreeMapEvent extends Event
	{
		
	//--------------------------------------
	//  Class Constants
	//--------------------------------------
	
		/**
		 *  Dispatched when the user clicks on a node in the TreeMap component.
		 */
		public static const NODE_CLICK:String = "nodeClick";
		
		/**
		 *  Dispatched when the user double clicks on a node in the TreeMap component.
		 */
		public static const NODE_DOUBLE_CLICK:String = "nodeDoubleClick";
		
		/**
		 *  Dispatched when the user rolls over a node in the TreeMap component.
		 */
		public static const NODE_ROLL_OVER:String = "nodeRollOver";
		
		/**
		 *  Dispatched when the user rolls out of a node in the TreeMap component.
		 */
		public static const NODE_ROLL_OUT:String = "nodeRollOut";
	
		/**
		 *  Dispatched when a node should be zoomed in the TreeMap compoennt.
		 */
		public static const NODE_REQUEST_ZOOM:String = "nodeRequestZoom";
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 *  Constructor.
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
		 *  @private
		 *  Storage for the affected node renderer.
		 */
		private var _nodeRenderer:ITreeMapNodeRenderer;
		
		/**
		 *  The node renderer where the event occurred.
		 */
		public function get nodeRenderer():ITreeMapNodeRenderer
		{
			return this._nodeRenderer;
		}
		
		/**
		 *  @private
		 */
		public function set nodeRenderer(renderer:ITreeMapNodeRenderer):void
		{
			this._nodeRenderer = renderer;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 *  @private
		 */
		override public function clone():Event
		{
			return new TreeMapEvent(this.type, this.bubbles, this.cancelable, this.nodeRenderer);
		}
		
	}
}