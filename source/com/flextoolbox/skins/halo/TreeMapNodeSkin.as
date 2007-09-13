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

package com.flextoolbox.skins.halo
{

	import flash.display.GradientType;
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.skins.Border;
	import mx.skins.halo.*;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 *  The skin for all the states of a TreeMapNodeRenderer.
	 */
	public class TreeMapNodeSkin extends Border
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
												  fillColor0:uint,
												  fillColor1:uint):Object
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
		 *  Constructor.
		 */
		public function TreeMapNodeSkin()
		{
			super();
		}
		
	//----------------------------------
	//  Variables and Properties
	//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get measuredWidth():Number
		{
			return UIComponent.DEFAULT_MEASURED_MIN_WIDTH;
		}
	
		/**
		 *  @private
		 */
		override public function get measuredHeight():Number
		{
			return UIComponent.DEFAULT_MEASURED_MIN_HEIGHT;
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
			var cornerRadius:Number = getStyle("cornerRadius");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");	
			var selectedFillColors:Array = getStyle("selectedFillColors");			
			var themeColor:uint = getStyle("themeColor");
	
			// Derivative styles.
			var derStyles:Object = calcDerivedStyles(themeColor, fillColors[0],
													 fillColors[1]);
	
			var borderColorDrk1:Number =
				ColorUtil.adjustBrightness2(borderColor, -50);
			
			var themeColorDrk1:Number =
				ColorUtil.adjustBrightness2(themeColor, -40);
			
			var themeColorDrk2:Number =
				ColorUtil.adjustBrightness2(themeColor, -70);
			
			var themeColorLgt1:Number =
				ColorUtil.adjustBrightness2(themeColor, 60);
			
			if (!selectedFillColors)
			{
				selectedFillColors = []; // So we don't clobber the original...
				selectedFillColors[0] =
					ColorUtil.adjustBrightness2(themeColor, 60);
				selectedFillColors[1] =
					ColorUtil.adjustBrightness2(themeColor, -15);
			}
			
			var emph:Boolean = false;
			
			if (parent is Button)
				emph = Button(parent).emphasized;
				
			var cr:Number = Math.max(0, cornerRadius);
			var cr1:Number = Math.max(0, cornerRadius - 1);
			var cr2:Number = Math.max(0, cornerRadius - 2);
			
			var tmp:Number;
			
			graphics.clear();
													
			switch (name)
			{			
				case "selectedUpSkin":
				{
					// button border/edge
					drawRoundRect(
						0, 0, w, h, cr,
						[ borderColor, borderColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, w , h )); 
													
					// button fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr1,
						selectedFillColors, 1,
						verticalGradientMatrix(0, 0, w - 2, h - 2));
															
					break;
				}
				case "selectedOverSkin":
				{
					// button border/edge
					drawRoundRect(
						0, 0, w, h, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, w , h )); 
													
					// button fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr1,
						selectedFillColors, 1,
						verticalGradientMatrix(0, 0, w - 2, h - 2));
															
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
							0, 0, w, h, cr,
							[ themeColor, derStyles.themeColorDrk2 ], 1,
							verticalGradientMatrix(0, 0, w , h ),
							GradientType.LINEAR, null, 
							{ x: 2, y: 2, w: w - 4, h: h - 4, r: cornerRadius - 2 });
								
						// button fill
						drawRoundRect(
							2, 2, w - 4, h - 4, cr2,
							upFillColors, upFillAlphas,
							verticalGradientMatrix(2, 2, w - 2, h - 2));
											  
						// top highlight
						drawRoundRect(
							2, 2, w - 4, (h - 4) / 2,
							{ tl: cr2, tr: cr2, bl: 0, br: 0 },
							[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
							verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
					}
					else
					{
						// button border/edge
						drawRoundRect(
							0, 0, w, h, cr,
							[ borderColor, borderColorDrk1 ], 1,
							verticalGradientMatrix(0, 0, w, h ),
							GradientType.LINEAR, null, 
							{ x: 1, y: 1, w: w - 2, h: h - 2, r: cornerRadius - 1 }); 
	
						// button fill
						drawRoundRect(
							1, 1, w - 2, h - 2, cr1,
							upFillColors, upFillAlphas,
							verticalGradientMatrix(1, 1, w - 2, h - 2)); 
	
						// top highlight
						drawRoundRect(
							1, 1, w - 2, (h - 2) / 2,
							{ tl: cr1, tr: cr1, bl: 0, br: 0 },
							[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
							verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
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
						0, 0, w, h, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, w , h),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: w - 2, h: h - 2, r: cornerRadius - 1 }); 
													
					// button fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr1,
						
						overFillColors, overFillAlphas,
						verticalGradientMatrix(1, 1, w - 2, h - 2)); 
											  
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2,
						{ tl: cr1, tr: cr1, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
					
					break;
				}
										
				case "downSkin":
				case "selectedDownSkin":
				{
					// button border/edge
					drawRoundRect(
						0, 0, w, h, cr,
						[ themeColor, derStyles.themeColorDrk2 ], 1,
						verticalGradientMatrix(0, 0, w , h )); 
													
					// button fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr1,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2], 1,
						verticalGradientMatrix(1, 1, w - 2, h - 2)); 
											  
					// top highlight
					drawRoundRect(
						2, 2, w - 4, (h - 4) / 2,
						{ tl: cr2, tr: cr2, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2)); 
					
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
						0, 0, w, h, cr,
						[ borderColor, borderColorDrk1 ], 0.5,
						verticalGradientMatrix(0, 0, w, h ),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: w - 2, h: h - 2, r: cornerRadius - 1 });
	
					// button fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr1,
						disFillColors, disFillAlphas,
						verticalGradientMatrix(1, 1, w - 2, h - 2)); 
					
					break;
				}
			}
		}
	}

}
