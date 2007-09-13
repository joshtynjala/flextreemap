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
	import mx.core.ClassFactory;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	
	public interface ITreeMapBranchRenderer extends ITreeMapNodeRenderer
	{
		function itemToLabel(item:Object):String;
		function itemToToolTip(item:Object):String;
		function itemToColor(item:Object):uint;
		function itemToWeight(item:Object):Number;
		function itemToRenderer(item:Object):ITreeMapNodeRenderer;
		
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
		function get selectedItem():Object;
		function set selectedItem(value:Object):void;
		
		function get zoomOutType():String;
		function set zoomOutType(value:String):void;
		
		function get nodeRenderer():ClassFactory;
		function set nodeRenderer(value:ClassFactory):void;
		function get branchRenderer():ClassFactory;
		function set branchRenderer(value:ClassFactory):void;
		
		function get dataDescriptor():ITreeDataDescriptor;
		function set dataDescriptor(value:ITreeDataDescriptor):void;
		
		function get layoutStrategy():ITreeMapLayoutStrategy;
		function set layoutStrategy(value:ITreeMapLayoutStrategy):void;
		
		function get maximumDepth():int;
		function set maximumDepth(value:int):void;
	}
}