////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 Josh Tynjala
//
// 	This source code is subject to the terms of the Mozilla Public License (MPL)
//  http://www.mozilla.org/MPL/MPL-1.1.html
//
//  Contains modified code derived from the Open Source Flex 3 SDK originally
//  developed by Adobe Systems Incorporated. Changes to the code are minor and
//  include mostly aesthetic alterations. Original source code copyright (c)
//  2005-2007 Adobe Systems Incorporated.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.utils
{
	import flash.display.Graphics;
	
	public class FlexGraphicsUtil
	{
		/**
		 * Draws a border using a series of rectangular fills.
		 */	
		public static function drawBorder(graphics:Graphics, x:Number, y:Number, w:Number, h:Number,
									color1:Number, color2:Number, thickness:Number, alpha:Number):void
		{
			// border line on the left side
			drawFill(graphics, x, y, thickness, h, color1, alpha);
		
			// border line on the top side
			drawFill(graphics, x, y, w, thickness, color1, alpha);
		
			// border line on the right side
			drawFill(graphics, x + (w - thickness), y, thickness, h, color2, alpha);
		
			// border line on the bottom side
			drawFill(graphics, x, y + (h - thickness), w, thickness, color2, alpha);
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