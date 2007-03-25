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
	/**
	 * The interface for "drop-in" item renderers.
	 */
	public interface IDropInTreeMapNodeRenderer
	{
		/**
		 * Implements the <code>treeMapData</code> property
		 */
		function get treeMapData():TreeMapNodeData;
		
		/**
		 * @private
		 */
		function set treeMapData(value:TreeMapNodeData):void;
	}
}