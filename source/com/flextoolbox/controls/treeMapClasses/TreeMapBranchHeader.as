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
	import mx.containers.Accordion;
	import mx.controls.Button;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.IDataRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderSkin;
	import mx.core.UIComponent;
	
	use namespace mx_internal;
	
	[AccessibilityClass(implementation="mx.accessibility.AccordionHeaderAccImpl")]
	
	/**
	 * The TreeMapBranchHeader class defines the appearance of the header buttons
	 * of the branches in a TreeMap.
	 * You use the <code>getHeaderAt()</code> method of the TreeMap class to get a reference
	 * to an individual TreeMapBranchHeader object.
	 * 
	 * <p>Note: The majority of this comes from the class <code>mx.containers.accordionClasses.AccordionHeader</code>,
	 * from the source code provided with the Flex 2 SDK.</p>
	 */
	public class TreeMapBranchHeader extends Button implements IDataRenderer
	{
	
    //----------------------------------
	//  Class Mixins
    //----------------------------------
	
		/**
		 * @private
		 * Placeholder for mixin by AccordionHeaderAccImpl.
		 */
		mx_internal static var createAccessibilityImplementation:Function;
		
    //----------------------------------
	//  Class Methods
    //----------------------------------
    
		/**
		 * @private
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeMapBranchHeader");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.fillAlphas = [1.0, 1.0];
				this.paddingLeft = 5;
				this.paddingRight = 5;
				this.upSkin = TreeMapBranchHeaderSkin;
				this.downSkin = TreeMapBranchHeaderSkin;
				this.overSkin = TreeMapBranchHeaderSkin;
				this.disabledSkin = TreeMapBranchHeaderSkin;
				this.selectedUpSkin = TreeMapBranchHeaderSkin;
				this.selectedDownSkin = TreeMapBranchHeaderSkin;
				this.selectedOverSkin = TreeMapBranchHeaderSkin;
				this.selectedDisabledSkin = TreeMapBranchHeaderSkin;
			}
			
			StyleManager.setStyleDeclaration("TreeMapBranchHeader", selector, false);
		}
		initializeStyles();
	
    //----------------------------------
	//  Constructor
    //----------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapBranchHeader()
		{
			super();
	
			// Since we play games with allowing selected to be set without
			// toggle being set, we need to clear the default toggleChanged
			// flag here otherwise the initially selected header isn't
			// drawn in a selected state.
			toggleChanged = false;
			mouseFocusEnabled = false;
			tabEnabled = false;
		}
	
    //----------------------------------
	//  Variables and Properties
    //----------------------------------
	
		/**
		 * @private
		 */
		private var focusObj:DisplayObject;
	
		/**
		 * @private
		 */
		private var focusSkin:IFlexDisplayObject;
	
		/**
		 * @private
		 * Storage for the _data property.
		 */
		private var _data:Object;
	
		/**
		 * Stores a reference to the content associated with the header.
		 */
		override public function get data():Object
		{
			return _data;
		}
		
		/**
		 * @private
		 */
		override public function set data(value:Object):void
		{
			_data = value;
		}
	
		/**
		 * @private
		 */
		override public function set selected(value:Boolean):void
		{
			_selected = value;
	
			invalidateDisplayList();
		}
	
    //----------------------------------
	//  Protected Methods
    //----------------------------------
	
		/**
		 * @private
		 */
		override protected function initializeAccessibility():void
		{
			if (TreeMapBranchHeader.createAccessibilityImplementation != null)
				TreeMapBranchHeader.createAccessibilityImplementation(this);
		}
	
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			// AccordionHeader has a bit of a conflict here. Our styleName points to
			// our parent Accordion, which has padding values defined. We also have
			// padding values defined on our type selector, but since class selectors
			// take precedence over type selectors, the type selector padding values
			// are ignored. Force them in here.
			var styleDecl:CSSStyleDeclaration = StyleManager.getStyleDeclaration(className);
			
			if(styleDecl)
			{
				var value:Number = styleDecl.getStyle("paddingLeft");
				if(!isNaN(value))
				{
					this.setStyle("paddingLeft", value);
				}
				value = styleDecl.getStyle("paddingRight");
				if(!isNaN(value))
				{
					this.setStyle("paddingRight", value);
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function drawFocus(isFocused:Boolean):void
		{
			// Accordion header focus is drawn inside the control.
			if (isFocused && !isEffectStarted)
			{
				if (!focusObj)
				{
					var focusClass:Class = getStyle("focusSkin");
	
					focusObj = new focusClass();
	
					var focusStyleable:ISimpleStyleClient = focusObj as ISimpleStyleClient;
					if (focusStyleable)
						focusStyleable.styleName = this;
	
					addChild(focusObj);
	
					// Call the draw method if it has one
					focusSkin = focusObj as IFlexDisplayObject;
				}
	
				if (focusSkin)
				{
					focusSkin.move(0, 0);
					focusSkin.setActualSize(unscaledWidth, unscaledHeight);
				}
				focusObj.visible = true;
	
				dispatchEvent(new Event("focusDraw"));
			}
			else if (focusObj)
			{
				focusObj.visible = false;
			}
		}
	
		/**
		 * @private
		 */
		override mx_internal function layoutContents(unscaledWidth:Number,
												     unscaledHeight:Number,
												     offset:Boolean):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight, offset);
	
			// Move the focus object to front.
			// AccordionHeader needs special treatment because it doesn't
			// show focus by having the standard focus ring display outside.
			if (focusObj)
				setChildIndex(focusObj, numChildren - 1);
		}
	
		/**
		 * @private
		 */
		override protected function rollOverHandler(event:MouseEvent):void
		{
			super.rollOverHandler(event);
	
			// The halo design specifies that accordion headers overlap
			// by a pixel when layed out. In order for the border to be
			// completely drawn on rollover, we need to set our index
			// here to bring this header to the front.
			var branch:UIComponent = UIComponent(this.parent);
			if (branch.enabled)
			{
				branch.setChildIndex(this, branch.numChildren - 1);
			}
		}
		
	}
}
