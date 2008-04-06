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
	import com.flextoolbox.utils.FontSizeMode;
	import com.flextoolbox.utils.UITextFieldUtil;
	
	import flash.text.TextFormat;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;


	//--------------------------------------
	//  Events
	//--------------------------------------
	
	
	//--------------------------------------
	//  Styles
	//--------------------------------------


	/**
	 * The default leaf renderer for the TreeMap control.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
	 */
	public class TreeMapLeafRenderer extends UIComponent implements ITreeMapLeafRenderer, IDropInTreeMapItemRenderer
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
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeMapLeafRenderer");
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.fontSizeMode = FontSizeMode.NO_CHANGE;
				this.color = 0xffffff;
				this.fillAlphas = [1.0, 1.0];
				this.fontSize = 10;
				this.highlightAlphas = [0.3, 0];
				this.cornerRadius = 0;
				this.borderColor = 0x676a6c;
				this.textAlign = "center";
				this.paddingLeft = 0;
				this.paddingRight = 0;
				this.paddingTop = 0;
				this.paddingBottom = 0;
				this.rollOverColor = 0x7FCEFF;
			}
			
			StyleManager.setStyleDeclaration("TreeMapLeafRenderer", selector, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function TreeMapLeafRenderer()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		protected var background:Button;
		protected var textField:UITextField;
		
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
	
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.background)
			{
				this.background = new Button();
				this.background.styleName = this;
				this.addChild(this.background);
			}
			
			if(!this.textField)
			{
				this.textField = new UITextField();
				this.textField.styleName = this;
				this.textField.multiline = true;
				this.textField.wordWrap = true;
				this.textField.selectable = false;
				this.textField.mouseEnabled = false;
				this.addChild(this.textField);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			var label:String = "";
			if(this._treeMapLeafData)
			{
				label = this._treeMapLeafData.label;
				this.toolTip = this._treeMapLeafData.dataTip;
				var color:uint = this._treeMapLeafData.color;
				this.setStyle("fillColors", [color, color]);
			}
			
			var labelChanged:Boolean = this.textField.text != label;
			if(labelChanged)
			{
				this.textField.text = label;
			}
			
			this.background.selected = this.selected;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.background.setActualSize(unscaledWidth, unscaledHeight);
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
	        var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
    	    var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			
			//width must always be maximum to handle alignment
			this.textField.width = Math.max(0, viewWidth);
			this.textField.height = Math.max(0, viewHeight);
				
			var fontSizeMode:String = this.getStyle("fontSizeMode");
			UITextFieldUtil.autoAdjustFontSize(this.textField, this.getStyle("fontSize"), fontSizeMode);
			
			//we want to center vertically, so resize if needed
			this.textField.height = Math.min(this.textField.height, this.textField.textHeight + 4);
			
			//center the text field
			this.textField.x = (unscaledWidth - this.textField.width) / 2;
			this.textField.y = (unscaledHeight - this.textField.height) / 2;
		}
		
	}
}