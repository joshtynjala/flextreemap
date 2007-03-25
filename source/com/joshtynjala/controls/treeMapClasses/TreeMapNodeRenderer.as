/*

	Copyright (C) 2007 Josh Tynjala
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

package com.joshtynjala.controls.treeMapClasses
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	import mx.core.mx_internal;
	import mx.core.UIComponent;
	import mx.controls.Button;
	import mx.events.FlexEvent;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;
	import com.joshtynjala.skins.halo.TreeMapNodeSkin;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * If "full" or "partial", the node's text may increase or decrease in size to 
	 * fill the node. Choose "partial" for best readability.
	 * 
	 * @default "none"
	 */
	[Style(name="autoFitText", type="String")]
	
	/**
	 * The standard renderer used for <code>TreeMap</code> nodes. It's actually a button
	 * with specialized functionality for the label and coloring.
	 */
	public class TreeMapNodeRenderer extends Button implements ITreeMapNodeRenderer, IDropInTreeMapNodeRenderer, IDataRenderer
	{
		
    //----------------------------------
	//  Class Methods
    //----------------------------------
    
		/**
		 * @private
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeMapNodeRenderer");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.autoFitText = "none";
				this.color = 0xffffff;
				this.fillAlphas = [1.0, 1.0];
				this.highlightAlphas = [0.3, 0];
				this.cornerRadius = 0;
				this.borderColor = 0x676a6c;
				this.paddingLeft = 0;
				this.paddingRight = 0;
				this.paddingTop = 0;
				this.paddingBottom = 0;
				this.upSkin = TreeMapNodeSkin;
				this.downSkin = TreeMapNodeSkin;
				this.overSkin = TreeMapNodeSkin;
				this.disabledSkin = TreeMapNodeSkin;
				this.selectedUpSkin = TreeMapNodeSkin;
				this.selectedDownSkin = TreeMapNodeSkin;
				this.selectedOverSkin = TreeMapNodeSkin;
				this.selectedDisabledSkin = TreeMapNodeSkin;
			}
			
			StyleManager.setStyleDeclaration("TreeMapNodeRenderer", selector, false);
		}
		
		//initialize the default styles
		initializeStyles();

	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapNodeRenderer()
		{
			super();
		}
		
	//--------------------------------------
	//  Variables and Properties
	//--------------------------------------
	
		/**
		 * @private
		 * Holds the data assigned to this node.
		 */
		private var _data:Object;
		
		/**
		 * The data to render.
		 */
		override public function get data():Object
		{
			return this._data;
		}
		
		/**
		 * @private
		 */
		override public function set data(value:Object):void
		{
			if(this._data != value)
			{
				this._data = value;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}

			this.dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		private var _treeMapData:TreeMapNodeData;
		
		/**
		 * @copy com.joshtynjala.controls.treeMapClasses.IDropInTreeMapNodeRenderer#treeMapData
		 */
		public function get treeMapData():TreeMapNodeData
		{
			return this._treeMapData;
		}
		
		/**
		 * @private
		 */
		public function set treeMapData(value:TreeMapNodeData):void
		{
			if(this._treeMapData != value)
			{
				this._treeMapData = value;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the label value.
		 */
		private var _label:String = "";
		
		/**
		 * @private
		 * Flag set when the label changes.
		 */
		private var _labelChanged:Boolean = false;
		
		/**
		 * Always returns an empty string ("") because anything else ruins the component's performance.
		 * It's okay, though, because the component sets its own label text anyway!
		 */
		override public function get label():String
		{
			return "";
		}
		
		/**
		 * @private
		 */
		override public function set label(value:String):void
		{
			if(this._label != value)
			{
				this._label = value;
				this._labelChanged = true;
				this.invalidateDisplayList()
			}
		}
		
		/**
		 * @private
		 * The text field used to display the label text. Replaces the standard button
		 * label used by mx.controls.Button.
		 */
		private var _textField:TextField;
		
		/**
		 * @private
		 * Flag required by the update
		 */
		private var _styleChanged:Boolean = false;
		
		/**
		 * @private
		 * Saved value used to determine if the label needs to be updated.
		 */
		private var _oldUnscaledWidth:Number = 0;
		
		/**
		 * @private
		 * Saved value used to determine if the label needs to be updated.
		 */
		private var _oldUnscaledHeight:Number = 0;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			this._styleChanged = true;
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			super.styleChanged(styleProp);
			
			if(allStyles || styleProp == "autoFitText")
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
			
			//create the replacement TextField.
			if(!this._textField)
			{
				this._textField = new TextField();
				this.addChild(this._textField);
			}
			this._textField.multiline = true;
			this._textField.wordWrap = true;
		}
		
		/**
		 * @private
		 * Updates the label property and fillColors style with the data.
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.treeMapData)
			{
				this.label = this.treeMapData.label;
				var color:Number = this.treeMapData.color;
				this.setStyle("fillColors", [color, color]);
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			//hide the regular text field
			this.textField.text = "";
			this.textField.setActualSize(0, 0);
			
			if(this.treeMapData)
			{
				//normally, I'd set this in commitProperties, but I have to override the standard
				//Button behavior that sets the toolTip in updateDisplayList
				this.toolTip = this.treeMapData.toolTip;
			}
			else this.toolTip = null;
				
			if(this._labelChanged || this._styleChanged ||
				this._oldUnscaledWidth != unscaledWidth ||
				this._oldUnscaledHeight != unscaledHeight)
			{
				//may not be html, but this will account for that case!
				if(this._label)
				{
					this._textField.text = this._label;
				}
				
				//set the initial text format
				var format:TextFormat = this.getTextStyles();
				this._textField.setTextFormat(format);
				
				var autoFitText:String = this.getStyle("autoFitText");
				this.increaseOrDecreaseFontSizeToFit(autoFitText);
				this._labelChanged = false;
			}
			
			//we've already set the max height, so make sure we don't go larger!
			this._textField.height = Math.min(this._textField.height, this._textField.textHeight + 4);
			//center the text field
			this._textField.x = (unscaledWidth - this._textField.width) / 2;
			this._textField.y = (unscaledHeight - this._textField.height) / 2;
			
			this._styleChanged = false;
			this._oldUnscaledWidth = unscaledWidth;
			this._oldUnscaledHeight = unscaledHeight;
		}
		
		/**
		 * @private
		 * Overrides the labels regular sizing because we allow it to grow.
		 */
		override mx_internal function layoutContents(unscaledWidth:Number,
									    unscaledHeight:Number, offset:Boolean):void
		{
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
	        var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
    	    var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			
			//width must always be maximum to handle alignment
			this._textField.width = Math.max(0, viewWidth);
			//height may be edited later to center the label vertically
			this._textField.height = Math.max(0, viewHeight);
			
			//make sure the text field is always on top!
			this.setChildIndex(this._textField, this.numChildren - 1);
		}
		
		/**
		 * @private
		 * Increases the font size until the text fills the bounds.
		 */
		private function increaseOrDecreaseFontSizeToFit(mode:String = "none"):void
		{
			if(mode == "none" || this._textField.length == 0 ||
				this._textField.width == 0 || this._textField.height == 0) return;
			
			var format:TextFormat = this._textField.getTextFormat();
			var originalSize:Number = Number(format.size);
			if(isNaN(originalSize)) originalSize = 1;
			var currentSize:Number = originalSize;
			
			var sameHeightTwice:Boolean = false;
			var lastHeight:Number = 0;
			while(this._textField.textHeight < this._textField.height - 4)
			{
				if(this._textField.textHeight == lastHeight)
				{
					//sometimes if the font size is increased by one, the textHeight won't change
					//but then it will change when it is increased again.
					//to combat this problem, we need to check if the height has matched twice!
					if(sameHeightTwice) break;
					sameHeightTwice = true;
				}
				else sameHeightTwice = false;
				lastHeight = this._textField.textHeight;
				
				format.size = currentSize += 1;
				this._textField.setTextFormat(format);
				
				//special case for partial mode
				if(mode == "partial" && this._textField.numLines > 1)
				{
					//minimize words being broken into multiple lines!
					for(var i:int = 1; i < this._textField.numLines; i++)
					{
						var lineOffset:int = this._textField.getLineOffset(i);
						
						//check for a space or dash at the end of the previous line
						var beginningOfLine:String = this._textField.text.charAt(lineOffset);
						var endOfPreviousLine:String = this._textField.text.charAt(lineOffset - 1);
						
						if(endOfPreviousLine != " " && endOfPreviousLine != "-" && this._textField.numLines > 1 && currentSize > 1)
						{
							format.size = currentSize -= 1;
							this._textField.setTextFormat(format);
							return;
						}
					}
				}
			}
			
			//decrease to fit. stop at size == 1
			while(currentSize > 1 &&
				this._textField.textHeight > this._textField.height - 4)
			{
				format.size = currentSize -= 1;
				this._textField.setTextFormat(format);
			}
		}
		
		/**
	     * Returns the TextFormat object that represents 
	     * character formatting information for the label.
	     *
	     * @return		A TextFormat object. 
	     *
	     * @see		flash.text.TextFormat
	     */
	    public function getTextStyles():TextFormat
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