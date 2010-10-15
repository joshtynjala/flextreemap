////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2007-2010 Josh Tynjala
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
	import com.flextoolbox.skins.halo.TreeMapLeafRendererSkin;
	import com.flextoolbox.utils.FlexFontUtil;
	import com.flextoolbox.utils.TheInstantiator;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.IInvalidating;
	import mx.core.IStateClient;
	import mx.core.UIComponent;
	import mx.events.SandboxMouseEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
include "../../styles/metadata/FocusStyles.inc"
include "../../styles/metadata/LeadingStyle.inc"
include "../../styles/metadata/PaddingStyles.inc"
include "../../styles/metadata/SkinStyles.inc"
include "../../styles/metadata/TextStyles.inc"

/**
 *  Text color of the label as the user moves the mouse pointer over the button.
 *  
 *  @default 0xffffff
 */
[Style(name="textRollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  Text color of the label as the user presses it.
 *  
 *  @default 0x2b333c
 */
[Style(name="textSelectedColor", type="uint", format="Color", inherit="yes")]

/**
 *  Name of the class to use as the default skin for the background and border. 
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="skin", type="Class", inherit="no", states="up, over, down, disabled, selectedUp, selectedOver, selectedDown, selectedDisabled")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the button is not selected and the mouse is not over the control.
 *  
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="upSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the button is not selected and the mouse is over the control.
 *  
 *  @default "mx.skins.halo.ButtonSkin" 
 */
[Style(name="overSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the button is not selected and the mouse button is down.
 *  
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="downSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the button is not selected and is disabled.
 * 
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="disabledSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when a toggle button is selected and the mouse is not over the control.
 * 
 *  @default "mx.skins.halo.ButtonSkin" 
 */
[Style(name="selectedUpSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when a toggle button is selected and the mouse is over the control.
 *  
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="selectedOverSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when a toggle button is selected and the mouse button is down.
 *  
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="selectedDownSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when a toggle button is selected and disabled.
 * 
 *  @default "mx.skins.halo.ButtonSkin"
 */
[Style(name="selectedDisabledSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when a toggle button is selected and disabled.
 * 
 *  @default "noChange"
 */
[Style(name="fontSizeMode", type="String", enumeration="noChange,fitToBounds,fitToBoundsWithoutBreaks", inherit="no")]


	/**
	 * The default leaf renderer for the TreeMap control.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala
	 */
	public class TreeMapLeafRenderer extends UIComponent implements ITreeMapLeafRenderer, IDropInTreeMapItemRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapLeafRenderer()
		{
			super();
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The background skin of the renderer.
		 */
		protected var backgroundSkin:DisplayObject;
	
		/**
		 * @private
		 * The textfield used to display the label.
		 */
		protected var textField:TextField;
		
		/**
		 * @private
		 */
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			this.skinInvalid = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the treeMapData property.
		 */
		private var _treeMapLeafData:TreeMapLeafData;
		
		/**
		 * @inheritDoc
		 */
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
		
		/**
		 * @private
		 * Storage for the data property.
		 */
		private var _data:Object;
		
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 * Storage for the selected property.
		 */
		private var _selected:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		public function get selected():Boolean
		{
			return this._selected;
		}
		
		/**
		 * @private
		 */
		public function set selected(value:Boolean):void
		{
			if(this._selected != value)
			{
				this._selected = value;
				this.skinInvalid = true;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Flag indicating that the skin needs to be changed.
		 */
		protected var skinInvalid:Boolean = false;
		
		/**
		 * @private
		 * Storage for the mouseIsOver property.
		 */
		private var _mouseIsOver:Boolean = false;
		
		/**
		 * @private
		 * Flag indicating that the mouse is currently over the renderer.
		 * Used for the skin states.
		 */
		protected function get mouseIsOver():Boolean
		{
			return this._mouseIsOver;
		}
		
		/**
		 * @private
		 */
		protected function set mouseIsOver(value:Boolean):void
		{
			this._mouseIsOver = value;
			this.skinInvalid = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the mouseIsDown property.
		 */
		private var _mouseIsDown:Boolean = false;
		
		/**
		 * @private
		 * Flag indicating that the mouse button is down. Generally, this is
		 * only true when mouseIsOver is true. Used for the skin states.
		 */
		protected function get mouseIsDown():Boolean
		{
			return this._mouseIsDown;
		}
		
		/**
		 * @private
		 */
		protected function set mouseIsDown(value:Boolean):void
		{
			this._mouseIsDown = value;
			this.skinInvalid = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Special flag to reset mouseIsDown.
		 */
		protected var mouseWasDown:Boolean = false; 
		
		/**
		 * @private
		 * The skins are saved and reused, whenever possible. A skin is
		 * removed from the cache when the appropriate style changes.
		 */
		protected var cachedSkins:Object = {};
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp.toLowerCase().indexOf("skin") >= 0)
			{
				if(this.cachedSkins.hasOwnProperty(styleProp))
				{
					var oldSkin:DisplayObject = DisplayObject(this.cachedSkins[styleProp]);
					this.removeChild(oldSkin);
					
					delete this.cachedSkins[styleProp];
				}
				this.skinInvalid = true;
				this.invalidateProperties();
			}
			
			if(allStyles || styleProp == "fontSizeMode")
			{
				this.invalidateProperties();
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
			
			if(!this.backgroundSkin)
			{
				this.updateBackgroundSkin();
			}
			
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
			
			if(this.skinInvalid)
			{
				this.updateBackgroundSkin();
				this.skinInvalid = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var cornerRadius:Number = this.getStyle("cornerRadius");
			this.graphics.clear();
			if(this._treeMapLeafData)
			{
				var color:uint = this._treeMapLeafData.color;
				this.graphics.beginFill(color);
				this.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius);
				this.graphics.endFill();
			}
			
			if(this.backgroundSkin is IFlexDisplayObject)
			{
				IFlexDisplayObject(this.backgroundSkin).setActualSize(unscaledWidth, unscaledHeight);
			}
			else
			{
				this.backgroundSkin.width = unscaledWidth;
				this.backgroundSkin.height = unscaledHeight;
			}
			
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
			var textFormat:TextFormat = this.textField.getTextFormat();
			textFormat.color = this.getLabelColor();
			this.textField.setTextFormat(textFormat);
			
			//we want to center vertically, so resize if needed
			this.textField.height = Math.min(viewHeight, this.textField.textHeight + FlexFontUtil.TEXTFIELD_VERTICAL_MARGIN);
			
			//center the text field
			this.textField.x = (unscaledWidth - this.textField.width) / 2;
			this.textField.y = (unscaledHeight - this.textField.height) / 2;
		}
		
		/**
		 * @private
		 * Sets the appropriate backgrouns skin. Similar to
		 * Button.viewSkinForPhase().
		 */
		private function updateBackgroundSkin():void
		{
			var oldBackgroundSkin:DisplayObject = this.backgroundSkin;
				
			//skin state behavior adapted from mx.controls.Button
			var skinState:String = this.selected ? "selectedUp" : "up";
			if(!this.enabled)
			{
				skinState = this.selected ? "selectedDisabled" : "disabled"
			}
			else if(this.mouseIsDown)
			{
				skinState = this.selected ? "selectedDown" : "down";
			}
			else if(this.mouseIsOver)
			{
				skinState = this.selected ? "selectedOver" : "over";
			}
			var skinStyle:String = skinState + "Skin";
			
			var skin:Object = this.getStyle("skin");
			if(skin)
			{
				if(this.cachedSkins.hasOwnProperty("skin"))
				{
					this.backgroundSkin = this.cachedSkins["skin"];
				}
				else
				{
					this.backgroundSkin = DisplayObject(TheInstantiator.newInstance(skin));
					this.cachedSkins["skin"] = this.backgroundSkin;
				}
				
				if(this.backgroundSkin is IStateClient)
				{
					IStateClient(this.backgroundSkin).currentState = skinState;
				}
			}
			else
			{
				if(this.cachedSkins.hasOwnProperty(skinStyle))
				{
					this.backgroundSkin = DisplayObject(this.cachedSkins[skinStyle]);
				}
				else
				{
					var stateSkin:Object = this.getStyle(skinStyle);
					if(stateSkin)
					{
						this.backgroundSkin = DisplayObject(TheInstantiator.newInstance(stateSkin));
					}
					this.cachedSkins[skinStyle] = this.backgroundSkin;
				}
			}
			
			this.backgroundSkin.name = skinStyle;
			if(this.backgroundSkin is ISimpleStyleClient)
			{
				ISimpleStyleClient(this.backgroundSkin).styleName = this;
			}
			
			if(!this.backgroundSkin.parent)
			{
				this.addChildAt(this.backgroundSkin, 0);
			}
			
			if(this.backgroundSkin is IInvalidating)
			{
				//force it to redraw. why buttonskin doesn't do this itself
				//is beyond me.
				IInvalidating(this.backgroundSkin).invalidateProperties();
				IInvalidating(this.backgroundSkin).invalidateDisplayList();
			}
			
			if(oldBackgroundSkin && this.backgroundSkin != oldBackgroundSkin)
			{
				oldBackgroundSkin.visible = false;
				this.backgroundSkin.visible = true;
			}
		}
		
		/**
		 * @private
		 * Determines the proper label color for the state.
		 */
		private function getLabelColor():uint
		{
			//behavior copied from mx.controls.Button
			//there's so much more that could be customized.
			//can't wait for Gumbo.
			var labelColor:uint = this.getStyle("color");
			if(!this.enabled)
			{
				labelColor = this.getStyle("disabledColor");
			}
			else if(this.mouseIsDown)
			{
				labelColor = this.getStyle("textSelectedColor");
			}
			else if(this.mouseIsOver)
			{
				labelColor = this.getStyle("textRollOverColor");
			}
			return labelColor;
		}
		
		/**
		 * @private
		 * Updates the mouse state.
		 */
		private function rollOverHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			
			this.mouseIsOver = true;
			this.mouseIsDown = this.mouseWasDown && event.buttonDown;
		}
		
		/**
		 * @private
		 * Updates the mouse state.
		 */
		private function rollOutHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			
			this.mouseIsOver = false;
			this.mouseIsDown = false;
		}
		
		/**
		 * @private
		 * Updates the mouse state.
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			this.mouseIsDown = true;
			this.mouseWasDown = true;
			
			this.systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			this.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler);
		}
		
		/**
		 * @private
		 * Updates the mouse state.
		 */
		private function mouseUpHandler(event:MouseEvent):void
		{
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			event.currentTarget.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler);
			if(!this.enabled)
			{
				return;
			}
			this.mouseIsDown = false;
			this.mouseWasDown = false;
		}
		
	}
}