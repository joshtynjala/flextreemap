////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 Josh Tynjala
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

package com.flextoolbox.utils
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.EmbeddedFont;
	import mx.core.EmbeddedFontRegistry;
	import mx.core.IEmbeddedFontRegistry;
	import mx.core.IFlexModuleFactory;
	import mx.core.Singleton;
	import mx.core.UIComponent;
	
	import mx.managers.ISystemManager;
	
	/**
	 * Utility methods for use with fonts in Flex.
	 * 
	 * @author Josh Tynjala
	 * @see flash.text.TextField
	 */
	public class FlexFontUtil
	{
		/**
		 * The extra vertical margin around text in a TextField (the difference
		 * between height and textHeight, if the TextField is set to auto size).
		 */
		public static const TEXTFIELD_VERTICAL_MARGIN:Number = 4;
		
		/**
		 * Mode setting for the <code>autoAdjustFontSize()</code> function to
		 * specify that the font size should not be changed.
		 */
		public static const SIZE_MODE_NO_CHANGE:String = "noChange";
		
		/**
		 * Mode setting for the <code>autoAdjustFontSize()</code> function to
		 * specify that the font size should be increased to fill the maximum
		 * amount of space in the TextField.
		 */
		public static const SIZE_MODE_FIT_TO_BOUNDS:String = "fitToBounds";
		
		/**
		 * Mode setting for the <code>autoAdjustFontSize()</code> function to
		 * specify that the font size should be increased to fill the maximum
		 * amount of space in the TextField. Additionally, if possible, words
		 * should not be broken apart onto multiple lines.
		 */
		public static const SIZE_MODE_FIT_TO_BOUNDS_WITHOUT_BREAKS:String = "fitToBoundsWithoutBreaks";
		
		/**
		 * @private
		 * Increases or decreases the font size until the text fills the bounds.
		 * 
		 * @param textField		The TextField of which to change the font size
		 * @param mode			The mode used to change the font size.
		 * 
		 * @see #SIZE_MODE_NO_CHANGE
		 * @see #SIZE_MODE_FIT_TO_BOUNDS
		 * @see #SIZE_MODE_FIT_TO_BOUNDS_WITHOUT_BREAKS
		 */
		public static function autoAdjustFontSize(textField:TextField, mode:String = "noChange"):void
		{
			if(mode == SIZE_MODE_NO_CHANGE || textField.length == 0 ||
				textField.width == 0 || textField.height == 0)
			{
				return;
			}
			
			var format:TextFormat = textField.getTextFormat();
			var originalSize:Number = format.size as Number;
			
			//increase font size to fit in bounds. stop if the text grows larger than the bounds
			var currentSize:Number = originalSize;
			var sameHeightMeasurement:Boolean = false;
			var lastHeight:Number = 0;
			while(textField.textHeight < (textField.height - TEXTFIELD_VERTICAL_MARGIN))
			{
				if(textField.textHeight == lastHeight)
				{
					//sometimes if the font size is increased by one, the textHeight won't change
					//but then it will change when it is increased again.
					//to combat this problem, we need to check twice
					if(sameHeightMeasurement)
					{
						break;
					}
					sameHeightMeasurement = true;
				}
				else
				{
					sameHeightMeasurement = false;
				}
				lastHeight = textField.textHeight;
				
				currentSize++;
				format.size = currentSize;
				textField.setTextFormat(format);
				
				//special case when we don't want words to break in the middle
				if(mode == SIZE_MODE_FIT_TO_BOUNDS_WITHOUT_BREAKS && textField.numLines > 1)
				{
					//minimize words being broken into multiple lines
					//note: it can still happen if the min font size is too big!
					for(var i:int = 1; i < textField.numLines; i++)
					{
						var lineOffset:int = textField.getLineOffset(i);
						
						//check for a space or dash at the end of the previous line
						var beginningOfLine:String = textField.text.charAt(lineOffset);
						var endOfPreviousLine:String = textField.text.charAt(lineOffset - 1);
						
						var loopRun:Boolean = false;
						while(endOfPreviousLine != " " && endOfPreviousLine != "-" && textField.numLines > i && currentSize > originalSize)
						{
							loopRun = true;
							
							currentSize--;
							format.size = currentSize;
							textField.setTextFormat(format);
							
							//similar to above, if the height doesn't change between point sizes
							//we need to run it again. this sucks.
							if(textField.numLines > i)
							{
								lineOffset = textField.getLineOffset(i);
								beginningOfLine = textField.text.charAt(lineOffset);
								endOfPreviousLine = textField.text.charAt(lineOffset - 1);
							}
							
						}
						if(loopRun)
						{
							return;
						}
					}
				}
			}
			
			//decrease font size to fit in bounds. stop if the font size reaches original size
			while(currentSize > originalSize && textField.textHeight > (textField.height - TEXTFIELD_VERTICAL_MARGIN))
			{
				currentSize--;
				format.size = currentSize;
				textField.setTextFormat(format);
			}
		}

		/**
	     * Returns the TextFormat object that represents character formatting
	     * information for the label.
	     *
	     * @param target		The TextField to which we'll apply the text styles.
	     * @param source		The source of the styles.
	     * @return				A TextFormat object. 
	     *
	     * @see		flash.text.TextFormat
	     */
		public static function applyTextStyles(target:TextField, source:UIComponent):void
		{
	    	var textFormat:TextFormat = new TextFormat();

			textFormat.font = source.getStyle("fontFamily");
			textFormat.size = source.getStyle("fontSize");
			if(source.enabled)
			{
				textFormat.color = source.getStyle("color");
			}
			else
			{
				textFormat.color = source.getStyle("disabledColor");
			}
			textFormat.bold = source.getStyle("fontWeight") == "bold";
			textFormat.italic = source.getStyle("fontStyle") == "italic";
			textFormat.underline = source.getStyle("textDecoration") == "underline";
			textFormat.align = source.getStyle("textAlign");
			
			textFormat.leading = source.getStyle("leading");
			textFormat.kerning = source.getStyle("kerning");
			textFormat.letterSpacing = source.getStyle("letterSpacing");
			textFormat.indent = source.getStyle("textIndent");
			
			target.setTextFormat(textFormat);
			if(source.getStyle("fontAntiAliasType") != undefined)
			{
				target.antiAliasType = source.getStyle("fontAntiAliasType");
				target.gridFitType = source.getStyle("fontGridFitType");
				target.sharpness = source.getStyle("fontSharpness");
				target.thickness = source.getStyle("fontThickness");
			}
			
			var embedFonts:Boolean = false;
			if(textFormat.font)
			{
				var embeddedFont:EmbeddedFont = new EmbeddedFont(textFormat.font, textFormat.bold, textFormat.italic);
				
				var embeddedFontRegistry:IEmbeddedFontRegistry =
					IEmbeddedFontRegistry(Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
				var fontModuleFactory:IFlexModuleFactory = 
					embeddedFontRegistry.getAssociatedModuleFactory(
				    embeddedFont, source.systemManager);
				
				// if we found the font, then it is embedded. 
				// Some fonts are not listed in info(), so are not in the above registry.
				// Call isFontFaceEmbedded() which get the list of embedded fonts from the player.
				if(fontModuleFactory != null) 
				{
					embedFonts = true;
				}
				else
				{
					var sm:ISystemManager = source.systemManager;
					embedFonts = sm != null && sm.isFontFaceEmbedded(textFormat);
				}
			}
			else
			{
				embedFonts = source.getStyle("embedFonts");
			}
			target.embedFonts = embedFonts;
		}
	}
}