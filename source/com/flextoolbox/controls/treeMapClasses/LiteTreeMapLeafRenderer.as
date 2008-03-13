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

package com.flextoolbox.controls.treeMapClasses
{
	import com.flextoolbox.utils.GraphicsUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	/**
	 * A very simple leaf renderer for the TreeMap component.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * 
	 * @author Josh Tynjala
	 */
	public class LiteTreeMapLeafRenderer extends UIComponent implements ITreeMapLeafRenderer, IDropInTreeMapItemRenderer
	{
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets the default style values for instances of this type.
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("LiteTreeMapLeafRenderer");
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.autoFitText = "none";
				this.color = 0xffffff;
				this.cornerRadius = 0;
				this.borderColor = 0xcccccc;//0x676a6c;
				this.textAlign = "center";
				this.paddingLeft = 0;
				this.paddingRight = 0;
				this.paddingTop = 0;
				this.paddingBottom = 0;
				this.rollOverColor = 0x7FCEFF;
			}
			
			StyleManager.setStyleDeclaration("LiteTreeMapLeafRenderer", selector, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function LiteTreeMapLeafRenderer()
		{
			super();
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private (protected)
		 * The TextField used to display the leaf's label.
		 */
		protected var textField:TextField;
		
		private var _treeMapLeafData:TreeMapLeafData;
		
		public function get treeMapData():BaseTreeMapData
		{
			return this._treeMapLeafData;
		}
		
		/**
		 * @private
		 */
		public function set treeMapData(value:BaseTreeMapData):void
		{
			this._treeMapLeafData = TreeMapLeafData(value);
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		private var _data:Object;
		
		public function get data():Object
		{
			return this._data;
		}
		
		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			this._data = value;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		private var _selected:Boolean = false;
		
		public function get selected():Boolean
		{
			return this._selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if(this._selected != value)
			{
				this._selected = value;
				this.invalidateDisplayList();
			}
		}
		
		protected var highlighted:Boolean = false;
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			this.textField = new TextField();
			this.textField.multiline = true;
			this.textField.wordWrap = true;
			this.textField.selectable = false;
			this.addChild(this.textField);
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			var label:String = "";
			if(this._treeMapLeafData)
			{
				label = this._treeMapLeafData.label;
				this.toolTip = this._treeMapLeafData.dataTip;
			}
			
			var labelChanged:Boolean = this.textField.text != label;
			if(labelChanged)
			{
				this.textField.text = label;
					
				//set the initial text format
				var format:TextFormat = this.getTextStyles();
				this.textField.setTextFormat(format);
				
				var autoFitText:String = this.getStyle("autoFitText");
				this.increaseOrDecreaseFontSizeToFit(autoFitText);
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(!this._treeMapLeafData)
			{
				return;
			}
			
			var backgroundColor:uint = this._treeMapLeafData.color;
			var borderColor:uint = this.getStyle("borderColor") as uint;
			
			this.graphics.clear();
			this.graphics.beginFill(backgroundColor, 1);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
			
			if(this.treeMapData.owner.selectable && (this.selected || this.highlighted))
			{
				var themeColor:uint = this.getStyle("themeColor");
				var indicatorColor:uint = themeColor;
				if(this.highlighted)
				{
					var rollOverColor:uint = this.getStyle("rollOverColor");
					indicatorColor = rollOverColor;
				}
				GraphicsUtil.drawBorder(this.graphics, 0, 0, unscaledWidth, unscaledHeight, indicatorColor, indicatorColor, 2, 1);
			}
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
	        var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
    	    var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			
			//width must always be maximum to handle alignment
			this.textField.width = Math.max(0, viewWidth);
			//height may be edited later to center the label vertically
			this.textField.height = Math.min(Math.max(0, viewHeight), this.textField.textHeight + 4);
			
			//center the text field
			this.textField.x = (unscaledWidth - this.textField.width) / 2;
			this.textField.y = (unscaledHeight - this.textField.height) / 2;
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			this.highlighted = true;
			this.invalidateDisplayList();
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			this.highlighted = false;
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Increases the font size until the text fills the bounds.
		 */
		private function increaseOrDecreaseFontSizeToFit(mode:String = "none"):void
		{
			if(mode == "none" || this.textField.length == 0 ||
				this.textField.width == 0 || this.textField.height == 0) return;
			
			var format:TextFormat = this.textField.getTextFormat();
			var originalSize:Number = Number(format.size);
			if(isNaN(originalSize)) originalSize = 1;
			var currentSize:Number = originalSize;
			
			var sameHeightTwice:Boolean = false;
			var lastHeight:Number = 0;
			while(this.textField.textHeight < this.textField.height - 4)
			{
				if(this.textField.textHeight == lastHeight)
				{
					//sometimes if the font size is increased by one, the textHeight won't change
					//but then it will change when it is increased again.
					//to combat this problem, we need to check if the height has matched twice!
					if(sameHeightTwice) break;
					sameHeightTwice = true;
				}
				else sameHeightTwice = false;
				lastHeight = this.textField.textHeight;
				
				format.size = currentSize += 1;
				this.textField.setTextFormat(format);
				
				//special case for partial mode
				if(mode == "partial" && this.textField.numLines > 1)
				{
					//minimize words being broken into multiple lines!
					for(var i:int = 1; i < this.textField.numLines; i++)
					{
						var lineOffset:int = this.textField.getLineOffset(i);
						
						//check for a space or dash at the end of the previous line
						var beginningOfLine:String = this.textField.text.charAt(lineOffset);
						var endOfPreviousLine:String = this.textField.text.charAt(lineOffset - 1);
						
						if(endOfPreviousLine != " " && endOfPreviousLine != "-" && this.textField.numLines > 1 && currentSize > 1)
						{
							format.size = currentSize -= 1;
							this.textField.setTextFormat(format);
							return;
						}
					}
				}
			}
			
			//decrease to fit. stop at size == 1
			while(currentSize > 1 &&
				this.textField.textHeight > this.textField.height - 4)
			{
				format.size = currentSize -= 1;
				this.textField.setTextFormat(format);
			}
		}
		
		/**
		 * @private
	     * Returns the TextFormat object that represents character formatting
	     * information for the label.
	     *
	     * @return		A TextFormat object. 
	     * @see			flash.text.TextFormat
	     */
	    private function getTextStyles():TextFormat
	    {
	        var textFormat:TextFormat = new TextFormat();
	
	        textFormat.align = this.getStyle("textAlign");
	        textFormat.bold = this.getStyle("fontWeight") == "bold";
			if(enabled)
	        {
	            textFormat.color = this.getStyle("color");
	        }
	        else
	        {
	            textFormat.color = this.getStyle("disabledColor");
	        }
	        textFormat.font = this.getStyle("fontFamily");
	        textFormat.indent = this.getStyle("textIndent");
	        textFormat.italic = this.getStyle("fontStyle") == "italic";
	        textFormat.leading = this.getStyle("leading");
	        textFormat.size = this.getStyle("fontSize");
	        textFormat.underline = this.getStyle("textDecoration") == "underline";
	
	        return textFormat;
	    }
		
	}
}