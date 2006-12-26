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

package com.joshtynjala.skins.halo
{
	
	import flash.display.GradientType;
	import mx.core.EdgeMetrics;
	import mx.skins.Border;
	import mx.skins.halo.*;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 *  The skin for all the states of an TreeMapHeader in a TreeMap.
	 */
	public class TreeMapHeaderSkin extends Border
	{

	//----------------------------------
	//  Class Variables
	//----------------------------------
	
		/**
		 *  @private
		 */
		private static var cache:Object = {};
	
	//----------------------------------
	//  Class Methods
	//----------------------------------
	
		/**
		 *  @private
		 *  Several colors used for drawing are calculated from the base colors
		 *  of the component (themeColor, borderColor and fillColors).
		 *  Since these calculations can be a bit expensive,
		 *  we calculate once per color set and cache the results.
		 */
		private static function calcDerivedStyles(themeColor:uint,
												  borderColor:uint,
												  falseFillColor0:uint,
												  falseFillColor1:uint,
												  fillColor0:uint,
												  fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor, borderColor,
													falseFillColor0,
													falseFillColor1,
													fillColor0, fillColor1);
			
			if (!cache[key])
			{
				var o:Object = cache[key] = {};
				
				// Cross-component styles.
				HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
				
			}
			
			return cache[key];
		}

	//----------------------------------
	//  Constructor
	//----------------------------------
	
		/**
		 *  Constructor.
		 */
		public function TreeMapHeaderSkin()
		{
			super();
		}
	
	//----------------------------------
	//  Variables and Properties
	//----------------------------------
	
		/**
		 *  @private
		 *  Storage for the borderMetrics property.
		 */
		private var _borderMetrics:EdgeMetrics = new EdgeMetrics(1, 1, 1, 1);
	
		/**
		 *  @private
		 */
		override public function get borderMetrics():EdgeMetrics
		{
			return _borderMetrics;
		}
		
		/**
		 *  @private
		 */
		override public function get measuredWidth():Number
		{
			return 10;
		}
	
		/**
		 *  @private
		 */
		override public function get measuredHeight():Number
		{
			return 22;
		}
	
	//----------------------------------
	//  Protected Methods
	//----------------------------------
	
		/**
		 *  @private
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");		
			var selectedFillColors:Array = getStyle("selectedFillColors");
			var themeColor:uint = getStyle("themeColor");
			
			// Placehold styles stub.
			var falseFillColors:Array /* of Color */ = []; // added style prop
			falseFillColors[0] = ColorUtil.adjustBrightness2(fillColors[0], -8);
			falseFillColors[1] = ColorUtil.adjustBrightness2(fillColors[1], -10);	
			
			var borderColorDrk1:Number =
				ColorUtil.adjustBrightness2(borderColor, -15);
				
			var overFillColor1:Number =
					ColorUtil.adjustBrightness2(fillColors[0], -4);
			var overFillColor2:Number =
					ColorUtil.adjustBrightness2(fillColors[1], -6);
			
			if (!selectedFillColors)
			{
				selectedFillColors = []; // So we don't clobber the original...
				selectedFillColors[0] =
					ColorUtil.adjustBrightness2(themeColor, 55);
				selectedFillColors[1] =
					ColorUtil.adjustBrightness2(themeColor, 10);
			}
			
			// Derivative styles.
			var derStyles:Object = calcDerivedStyles(themeColor, borderColor,
													 falseFillColors[0],
													 falseFillColors[1],
													 fillColors[0], fillColors[1]);
			
			graphics.clear();
	
			switch (name)
			{
				case "upSkin":
				case "disabledSkin":
				case "selectedDisabledSkin":
				{
	   				var upFillColors:Array =
						[ falseFillColors[0], falseFillColors[1] ];
	   				var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
	
					// edge 
					drawRoundRect(
						0, 0, w, h, 0,
						[ borderColor, borderColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null,
	                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 });
	
					// fill 
					drawRoundRect(
						1, 1,w - 2, h - 2, 0,
						upFillColors, upFillAlphas,
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
	
					// bottom edge bevel shadow
					drawRoundRect(
						1, h - 2, w - 2, 1, 0,
						borderColor, 0.1);
					
					break;
				}
							
				case "overSkin":
				{
					var overFillColors:Array;
					if (fillColors.length > 2)
					{
						overFillColors =
						[
							ColorUtil.adjustBrightness2(fillColors[2], -4), 
							ColorUtil.adjustBrightness2(fillColors[3], -6)
						];
					}
					else
					{
						overFillColors = [ overFillColor1, overFillColor2 ];
					}
	
					var overFillAlphas:Array;
					if (fillAlphas.length > 2)
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
	  				else
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// edge
					drawRoundRect(
						0, 0, w, h, 0,
						[ themeColor, derStyles.themeColDrk1 ], 1,
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null,
						{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 });
					
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						overFillColors, overFillAlphas,
						verticalGradientMatrix(1, 1, w - 2, h - 2));
	
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
	
					// bottom edge bevel shadow
					drawRoundRect(
						1, h - 2, w - 2, 1, 0,
						borderColor, 0.1);
					
					break;
				}
							
				case "downSkin":
				case "selectedDownSkin":
				{
					// edge 
					drawRoundRect(
						0, 0, w, h, 0,
						[ themeColor, derStyles.themeColDrk1 ], 1,
						verticalGradientMatrix(0, 0, w, h));
					
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2 ], 1,
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2));
	
					break;
				}
				case "selectedOverSkin":
				{
	   				var selectedFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
	
					// edge 
					drawRoundRect(
						0, 0, w, h, 0, 
						[ themeColor, derStyles.themeColDrk1 ], 1,
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null,
	                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 })
					
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						[ selectedFillColors[0],
						  selectedFillColors[1] ], selectedFillAlphas,
						verticalGradientMatrix(1, 1, w - 2, h - 2));
	
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
	
					// bottom edge highlight
					drawRoundRect(
						1, h - 2, w - 2, 1, 0,
						borderColor, 0.05);
	
					break;
				}
				case "selectedUpSkin":
				{
	   				selectedFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// edge 
					drawRoundRect(
						0, 0, w, h, 0, 
						[ borderColor, borderColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null,
	                    { x: 1, y: 1, w: w - 2, h: h - 2, r: 0 })
					
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						[ selectedFillColors[0],
						  selectedFillColors[1] ], selectedFillAlphas,
						verticalGradientMatrix(1, 1, w - 2, h - 2));
	
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
	
					// bottom edge highlight
					drawRoundRect(
						1, h - 2, w - 2, 1, 0,
						borderColor, 0.05);
	
					break;
				}
			}
		}
	}

}
