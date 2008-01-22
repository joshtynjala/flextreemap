package com.flextoolbox.controls.treeMapClasses
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	import mx.managers.ISystemManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	[Mixin]
	public class LiteTreeMapLeafRenderer extends UIComponent implements ITreeMapLeafRenderer, IDropInTreeMapItemRenderer
	{
		
	//--------------------------------------
	//  Class Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Initializes the default styles.
		 */
		public static function init(systemManager:ISystemManager):void
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
			
			this.toolTip = this._treeMapLeafData.dataTip;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var backgroundColor:uint = this._treeMapLeafData.color;
			var themeColor:uint = this.getStyle("themeColor");
			var rollOverColor:uint = this.getStyle("rollOverColor");
			var borderColor:uint = this.getStyle("borderColor") as uint;
			
			this.graphics.clear();
			this.graphics.lineStyle(2, borderColor);
			this.graphics.beginFill(backgroundColor, 1);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
			
			if(this.treeMapData.owner.selectable && (this.selected || this.highlighted))
			{
				var indicatorColor:uint = rollOverColor;
				if(this.selected) indicatorColor = themeColor;
				this.graphics.lineStyle(2, indicatorColor);
				this.graphics.drawRect(2, 2, unscaledWidth - 4, unscaledHeight - 4);
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