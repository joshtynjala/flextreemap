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

package com.flextoolbox.controls.treeMapClasses
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