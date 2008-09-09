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
	import com.flextoolbox.utils.FlexFontUtil;
	import com.flextoolbox.utils.FlexGraphicsUtil;
	import com.flextoolbox.utils.FontSizeMode;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	
	
	/**
	 * A very simple leaf renderer for the TreeMap component.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
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
				this.fontSizeMode = FontSizeMode.NO_CHANGE;
				this.color = 0xffffff;
				this.cornerRadius = 0;
				this.borderColor = 0x676a6c;
				this.borderThickness = 1;
				this.textAlign = "center";
				this.paddingLeft = 0;
				this.paddingRight = 0;
				this.paddingTop = 0;
				this.paddingBottom = 0;
				this.rollOverColor = 0x009DFF;
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
		 * @private
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
	//  Public Methods
	//--------------------------------------
	
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "fontSizeMode")
			{
				this.invalidateDisplayList();
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.textField)
			{
				this.textField = new TextField();
				this.textField.multiline = true;
				this.textField.wordWrap = true;
				this.textField.selectable = false;
				this.textField.mouseEnabled = false;
				this.addChild(this.textField);
			}
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
			
			this.graphics.clear();
			this.graphics.beginFill(backgroundColor, 1);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
			
			var borderColor:uint = this.getStyle("borderColor") as uint;
			var indicatorColor:uint = borderColor;
			if(this.selected)
			{
				indicatorColor = this.getStyle("themeColor");
			}
			if(this.highlighted)
			{
				indicatorColor = this.getStyle("rollOverColor");
			}
			var borderThickness:uint = this.getStyle("borderThickness");
			FlexGraphicsUtil.drawBorder(this.graphics, 0, 0, unscaledWidth, unscaledHeight,
				indicatorColor, indicatorColor, Math.min(unscaledWidth / 2, unscaledHeight / 2, borderThickness), 1);
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
	        var viewWidth:Number = Math.max(0, unscaledWidth - paddingLeft - paddingRight);
    	    var viewHeight:Number = Math.max(0, unscaledHeight - paddingTop - paddingBottom);
			
			//width must always be maximum to handle alignment
			this.textField.width = viewWidth;
			this.textField.height = viewHeight;
			
			FlexFontUtil.applyTextStyles(this.textField, this);
			FlexFontUtil.autoAdjustFontSize(this.textField, this.getStyle("fontSizeMode"));
			
			//we want to center vertically, so resize if needed
			this.textField.height = Math.min(viewHeight, this.textField.textHeight + FlexFontUtil.TEXTFIELD_VERTICAL_MARGIN);
			
			
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
		
	}
}