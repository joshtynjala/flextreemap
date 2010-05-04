/*
Copyright (c) 2008 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Utility functions for use with DisplayObjects.
	 * 
	 * @author Josh Tynjala
	 */
	public class DisplayObjectUtil
	{
		/**
		 * Converts a point from the local coordinate system of one DisplayObject to
		 * the local coordinate system of another DisplayObject.
		 *
		 * @param point					the point to convert
		 * @param firstDisplayObject	the original coordinate system
		 * @param secondDisplayObject	the new coordinate system
		 */
		public static function localToLocal(point:Point, firstDisplayObject:DisplayObject, secondDisplayObject:DisplayObject):Point
		{
			point = firstDisplayObject.localToGlobal(point);
			return secondDisplayObject.globalToLocal(point);
		}
	}
}