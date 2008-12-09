////////////////////////////////////////////////////////////////////////////////
//
// 	The contents of this file are subject to the Mozilla Public License
//	Version 1.1 (the "License"); you may not use this file except in
//	compliance with the License. You may obtain a copy of the License at
//	http://www.mozilla.org/MPL/
//
//	Software distributed under the License is distributed on an "AS IS"
//	basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
//	License for the specific language governing rights and limitations
//	under the License.
//
//	The Original Code is from the Open Source Flex 3 SDK.
//
//	The Initial Developer of the Original Code is Adobe Systems, Inc.
//
//	Portions created by Josh Tynjala (joshtynjala.com) are
//  Copyright (C) 2008 Josh Tynjala. All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.utils
{
	import flash.display.Graphics;
	
	public class FlexGraphicsUtil
	{
		/**
		 * Draws a border using a series of rectangular fills. Should be used
		 * instead of a stroke since strokes "bleed" into and out of fills.
		 */	
		public static function drawBorder(graphics:Graphics, x:Number, y:Number, w:Number, h:Number,
									color1:Number, color2:Number, thickness:Number, alpha:Number):void
		{
			//ensure that the thickness doesn't extend outside the width and height
			var wThickness:Number = Math.min(thickness, w / 2);
			var hThickness:Number = Math.min(thickness, h / 2);
			
			// border line on the left side
			drawFill(graphics, x, y, wThickness, h, color1, alpha);
		
			// border line on the top side
			drawFill(graphics, x, y, w, hThickness, color1, alpha);
		
			// border line on the right side
			drawFill(graphics, x + (w - wThickness), y, wThickness, h, color2, alpha);
		
			// border line on the bottom side
			drawFill(graphics, x, y + (h - hThickness), w, hThickness, color2, alpha);
		}
			
		/**
		 * Draws a rectangular fill.
		 */	
		public static function drawFill(graphics:Graphics, x:Number, y:Number, w:Number, h:Number,
								  color:Number, alpha:Number):void
		{
			graphics.moveTo(x, y);
			graphics.beginFill(color, alpha);
			graphics.drawRect(x, y, w, h);
			graphics.endFill();
		}
		
		/**
		 * Draws an arrow pointing down.
		 */	
		public static function drawDownArrow(graphics:Graphics, x:Number, y:Number, w:Number, h:Number,
								   color:Number, alpha:Number):void
		{	
			graphics.moveTo(x, y);
			graphics.beginFill(color, alpha);
			graphics.lineTo(x + w, y);
			graphics.lineTo(x + w / 2, h + y);
			graphics.lineTo(x, y);
			graphics.endFill();
		}
		
		/**
		 * Draws an arrow pointing up.
		 */	
		public static function drawUpArrow(graphics:Graphics, x:Number, y:Number, w:Number, h:Number,
								   color:Number, alpha:Number):void
		{	
			graphics.moveTo(x, y + h);
			graphics.beginFill(color, alpha);
			graphics.lineTo(x + w / 2, y);
			graphics.lineTo(x + w, y + h);
			graphics.lineTo(x, y + h);
			graphics.endFill();
		}

	}
}