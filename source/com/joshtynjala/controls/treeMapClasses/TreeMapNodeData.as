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
	import mx.core.IUIComponent;
	
	/**
	 * The TreeMapNodeData class defines the data type of the <code>treeMapData</code>
	 * property implemented by drop-in item renderers for the TreeMap control.
	 * 
	 * <p>While the properties of this class are writable, you should consider
	 * them to be read only. They are initialized by the TreeMap class, and read
	 * by an item renderer. Changing these values can lead to unexpected results.</p>
	 */
	public class TreeMapNodeData
	{
		/**
		 * Constructor.
		 * 
		 * @param label		The textual representation of the item data.
		 * @param weight	The weight value of the item data
		 * @param color		The color value of the item data
		 * @param toolTip	The alternative textual representation of the item data
		 * @param uid		A unique identifier.
		 * @param owner		A reference to the treemap control.
		 */
		public function TreeMapNodeData(label:String, weight:Number, color:uint, toolTip:String, uid:String, owner:IUIComponent)
		{
			this.label = label;
			this.weight = weight;
			this.color = color;
			this.toolTip = toolTip;
			this.uid = uid;
			this.owner = owner;
		}
		

		[Bindable("dataChange")]
		/**
		 * The textual representation of the item data, based on the treemap class'
		 * <code>itemToLabel()</code> method.
		 */
		public var label:String;
		
		/**
		 * The weight representation of the item data, based on the treemap class'
		 * <code>itemToWeight()</code> method.
		 */
		public var weight:Number;
		
		/**
		 * The color representation of the item data, based on the treemap class'
		 * <code>itemToColor()</code> method.
		 */
		public var color:uint;
		
		/**
		 * The alternative textual representation of the item data, based on the treemap class'
		 * <code>itemToToolTip()</code> method.
		 */
		public var toolTip:String;
		
		/**
		 * A reference to the treemap object that owns this item.
		 * This should be an implementation of ITreeMapBranchRenderer.
		 * 
		 * This property is typed as IUIComponent so that drop-ins
		 * like Label and TextInput don't have to have dependencies
		 * on TreeMap and all of its dependencies.
		 */
		public var owner:IUIComponent;
		
		/**
		 * The unique identifier for this item.
		 */
		public var uid:String;
	}
}