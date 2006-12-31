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

package com.joshtynjala.controls.treeMapClasses
{
	import mx.core.ClassFactory;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	
	public interface ITreeMapBranchRenderer extends ITreeMapNodeRenderer
	{
		function itemToLabel(item:Object):String;
		function itemToToolTip(item:Object):String;
		function itemToColor(item:Object):uint;
		function itemToWeight(item:Object):Number;
		function nodeDataToRenderer(data:Object):ITreeMapNodeRenderer;
		
		function get labelField():String;
		function set labelField(value:String):void;
		function get labelFunction():Function;
		function set labelFunction(value:Function):void;
		
		function get toolTipField():String;
		function set toolTipField(value:String):void;
		function get toolTipFunction():Function;
		function set toolTipFunction(value:Function):void;
		
		function get weightField():String;
		function set weightField(value:String):void;
		function get weightFunction():Function;
		function set weightFunction(value:Function):void;
		
		function get colorField():String;
		function set colorField(value:String):void;
		function get colorFunction():Function;
		function set colorFunction(value:Function):void;
		
		function get selectable():Boolean;
		function set selectable(value:Boolean):void;
		
		function get nodeRenderer():ClassFactory;
		function set nodeRenderer(value:ClassFactory):void;
		function get branchRenderer():ClassFactory;
		function set branchRenderer(value:ClassFactory):void;
		
		function get dataDescriptor():ITreeDataDescriptor;
		function set dataDescriptor(value:ITreeDataDescriptor):void;
		
		function get layoutStrategy():ITreeMapLayoutStrategy;
		function set layoutStrategy(value:ITreeMapLayoutStrategy):void;
	}
}