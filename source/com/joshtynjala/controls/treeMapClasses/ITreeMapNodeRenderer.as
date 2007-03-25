/*

	Copyright (C) 2007 Josh Tynjala
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

package com.joshtynjala.controls.treeMapClasses
{
	import mx.core.IDataRenderer;
	import mx.core.IUIComponent;
	import mx.core.IFlexDisplayObject;
	import flash.events.IEventDispatcher;
	import mx.styles.IStyleClient;

	/**
	 * Dispatched when the <code>data</code> property changes.
	 *
	 * <p>When you use a component as an node renderer,
	 * the <code>data</code> property contains the data to display.
	 * You can listen for this event and update the component
	 * when the <code>data</code> property changes.</p>
	 * 
	 * @eventType mx.events.FlexEvent.DATA_CHANGE
	 */
	[Event(name="dataChange", type="mx.events.FlexEvent")]

	/**
	 * Defines an interface for nodes that appear inside a <code>TreeMap</code> component.
	 * 
	 * @see zeuslabs.visualization.treemaps.TreeMap
	 */
	public interface ITreeMapNodeRenderer
		extends IUIComponent, IEventDispatcher, IDataRenderer, IFlexDisplayObject, IStyleClient
	{
		function get selected():Boolean;
		function set selected(value:Boolean):void;
	}
}