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
//  Copyright (c) 2007-2010 Josh Tynjala. All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.skins.halo
{

	import flash.display.GradientType;
	
	import mx.core.IButton;
	import mx.core.UIComponent;
	import mx.skins.Border;
	import mx.skins.halo.HaloColors;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 * The skin for all the states of a Button.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala; Based on code by Adobe Systems Incorporated
	 */
	public class TreeMapLeafRendererSkin extends Border
	{
		
	//----------------------------------
	//  Static Properties
	//----------------------------------
	
		/**
		 * @private
		 */
		private static var cache:Object = {}; 
		
	//----------------------------------
	//  Static Methods
	//----------------------------------
	
		/**
		 * @private
		 * Several colors used for drawing are calculated from the base colors
		 * of the component (themeColor, borderColor and fillColors).
		 * Since these calculations can be a bit expensive,
		 * we calculate once per color set and cache the results.
		 */
		private static function calcDerivedStyles(
			themeColor:uint, fillColor0:uint, fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor,
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
		 * Constructor.
		 */
		public function TreeMapLeafRendererSkin()
		{
			super();
		}
		
	//----------------------------------
	//  Properties
	//----------------------------------
	
		/**
		 * @private
		 */
		override public function get measuredWidth():Number
		{
			return UIComponent.DEFAULT_MEASURED_MIN_WIDTH;
		}
		
		/**
		 * @private
		 */
		override public function get measuredHeight():Number
		{
			return UIComponent.DEFAULT_MEASURED_MIN_HEIGHT;
		}
	
	//----------------------------------
	//  Protected Methods
	//----------------------------------
	
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
	
			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var cornerRadius:Number = getStyle("cornerRadius");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");				
			var themeColor:uint = getStyle("themeColor");
	
			// Derivative styles.
			var derStyles:Object = calcDerivedStyles(themeColor, fillColors[0],
													 fillColors[1]);
	
			var borderColorDrk1:Number =
				ColorUtil.adjustBrightness2(borderColor, -50);
			
			var themeColorDrk1:Number =
				ColorUtil.adjustBrightness2(themeColor, -25);
			
			var emph:Boolean = false;
			
			if (parent is IButton)
				emph = IButton(parent).emphasized;
				
			var cr:Number = Math.max(0, cornerRadius);
			var cr1:Number = Math.max(0, cornerRadius - 1);
			var cr2:Number = Math.max(0, cornerRadius - 2);
			
			var tmp:Number;
			
			graphics.clear();
													
			switch (name)
			{			
				case "selectedUpSkin":
				case "selectedOverSkin":
				{
					//selected up/over state different than the normal button skin
					//needs more emphasis for a TreeMap.
					
					var selectedUpFillColors:Array = [ fillColors[0], fillColors[1] ];
					var selectedUpFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
					
					// button border/edge
					drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight ),
						GradientType.LINEAR, null, 
						{ x: 2, y: 2, w: unscaledWidth - 4, h: unscaledHeight - 4, r: cornerRadius - 1 }); 
													
					// button fill
					drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						selectedUpFillColors, selectedUpFillAlphas,
						verticalGradientMatrix(0, 0, unscaledWidth - 2, unscaledHeight - 2)); 
				  	
				  	//the highlight is flipped and placed over the bottom		
					// top highlight
					drawRoundRect(
						1, 1 + (unscaledHeight - 2) / 2, unscaledWidth - 2, (unscaledHeight - 2) / 2,
						{ tl: 0, tr: 0, bl: cr1, br: cr1 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas.concat().reverse(),
						verticalGradientMatrix(1, 1 + (unscaledHeight - 2) / 2, unscaledWidth - 2, (unscaledHeight - 2) / 2));
						 
					break;
				}
	
				case "upSkin":
				{
	   				var upFillColors:Array = [ fillColors[0], fillColors[1] ];
					var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
	
					if (emph)
					{
						// button border/edge
						drawRoundRect(
							0, 0, unscaledWidth, unscaledHeight, cr,
							[ themeColor, themeColorDrk1 ], 1,
							verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight ),
							GradientType.LINEAR, null, 
							{ x: 2, y: 2, w: unscaledWidth - 4, h: unscaledHeight - 4, r: cornerRadius - 2 });
	                            
						// button fill
						drawRoundRect(
							2, 2, unscaledWidth - 4, unscaledHeight - 4, cr2,
							upFillColors, upFillAlphas,
							verticalGradientMatrix(2, 2, unscaledWidth - 2, unscaledHeight - 2));
											  
						// top highlight
						drawRoundRect(
							2, 2, unscaledWidth - 4, (unscaledHeight - 4) / 2,
							{ tl: cr2, tr: cr2, bl: 0, br: 0 },
							[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
							verticalGradientMatrix(1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2)); 
					}
					else
					{
						// button border/edge
						drawRoundRect(
							0, 0, unscaledWidth, unscaledHeight, cr,
							[ borderColor, borderColorDrk1 ], 1,
							verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight ),
							GradientType.LINEAR, null, 
							{ x: 1, y: 1, w: unscaledWidth - 2, h: unscaledHeight - 2, r: cornerRadius - 1 }); 
	
						// button fill
						drawRoundRect(
							1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
							upFillColors, upFillAlphas,
							verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2)); 
	
						// top highlight
						drawRoundRect(
							1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2,
							{ tl: cr1, tr: cr1, bl: 0, br: 0 },
							[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
							verticalGradientMatrix(1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2)); 
					}
					break;
				}
							
				case "overSkin":
				{
					var overFillColors:Array;
					if (fillColors.length > 2)
						overFillColors = [ fillColors[2], fillColors[3] ];
					else
						overFillColors = [ fillColors[0], fillColors[1] ];
	
					var overFillAlphas:Array;
					if (fillAlphas.length > 2)
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
	  				else
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// button border/edge
					drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: unscaledWidth - 2, h: unscaledHeight - 2, r: cornerRadius - 1 }); 
													
					// button fill
					drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						overFillColors, overFillAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2)); 
											  
					// top highlight
					drawRoundRect(
						1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2,
						{ tl: cr1, tr: cr1, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2)); 
					
					break;
				}
										
				case "downSkin":
				case "selectedDownSkin":
				{
					// button border/edge
					drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight )); 
													
					// button fill
					drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2], 1,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2)); 
											  
					// top highlight
					drawRoundRect(
						2, 2, unscaledWidth - 4, (unscaledHeight - 4) / 2,
						{ tl: cr2, tr: cr2, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2)); 
					
					break;
				}
							
				case "disabledSkin":
				case "selectedDisabledSkin":
				{
	   				var disFillColors:Array = [ fillColors[0], fillColors[1] ];
	   				
					var disFillAlphas:Array =
						[ Math.max( 0, fillAlphas[0] - 0.15),
						  Math.max( 0, fillAlphas[1] - 0.15) ];
	
					// button border/edge
					drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ borderColor, borderColorDrk1 ], 0.5,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight ),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: unscaledWidth - 2, h: unscaledHeight - 2, r: cornerRadius - 1 });
	
					// button fill
					drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						disFillColors, disFillAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2)); 
					
					break;
				}
			}
		}
	}

}
