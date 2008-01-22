/*
Copyright (c) 2007, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.com/flash/license.html
*/
package com.yahoo.astra.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * Utility functions for use with DisplayObjects.
	 * 
	 * @author Josh Tynjala
	 */
	public class DisplayObjectUtil
	{
		public static function localToLocal(point:Point, firstDisplayObject:DisplayObject, secondDisplayObject:DisplayObject):Point
		{
			point = firstDisplayObject.localToGlobal(point);
			return secondDisplayObject.globalToLocal(point);
		}
	}
}