package com.flextoolbox.utils
{
	import flash.display.Graphics;
	
	public class GraphicsUtil
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
			graphics.lineTo(x + w, y);
			graphics.lineTo(x + w, h + y);
			graphics.lineTo(x, h + y);
			graphics.lineTo(x, y);
			graphics.endFill();
		}
		
		/**
		 * Draws an arrow.
		 */	
		public static function drawArrow(graphics:Graphics, x:Number, y:Number, w:Number, h:Number,
								   color:Number, alpha:Number):void
		{	
			graphics.moveTo(x, y);
			graphics.beginFill(color, alpha);
			graphics.lineTo(x + w, y);
			graphics.lineTo(x + w / 2, h + y);
			graphics.lineTo(x, y);
			graphics.endFill();
		}

	}
}