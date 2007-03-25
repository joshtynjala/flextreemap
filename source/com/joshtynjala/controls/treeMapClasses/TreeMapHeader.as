/*

	Copyright (C) 2006 Josh Tynjala
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
	import com.joshtynjala.controls.TreeMap;
	import com.joshtynjala.skins.halo.TreeMapHeaderSkin;
	
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
	
	use namespace mx_internal;
	
	[AccessibilityClass(implementation="mx.accessibility.AccordionHeaderAccImpl")]
	
	/**
	 * The TreeMapHeader class defines the appearance of the header buttons
	 * of an TreeMap.
	 * You use the <code>getHeaderAt()</code> method of the TreeMap class to get a reference
	 * to an individual TreeMapHeader object.
	 * 
	 * <p>Note: The majority of this comes from the class <code>mx.containers.accordionClasses.AccordionHeader</code>,
	 * from the source code provided with the Flex 2 SDK.</p>
	 *
	 * @see com.joshtynjala.controls.TreeMap
	 */
	public class TreeMapHeader extends Button implements IDataRenderer
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
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeMapHeader");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				//this.fillAlphas = [1.0, 1.0];
				this.paddingLeft = 5;
				this.paddingRight = 5;
				this.upSkin = TreeMapHeaderSkin;
				this.downSkin = TreeMapHeaderSkin;
				this.overSkin = TreeMapHeaderSkin;
				this.disabledSkin = TreeMapHeaderSkin;
				this.selectedUpSkin = TreeMapHeaderSkin;
				this.selectedDownSkin = TreeMapHeaderSkin;
				this.selectedOverSkin = TreeMapHeaderSkin;
				this.selectedDisabledSkin = TreeMapHeaderSkin;
			}
			
			StyleManager.setStyleDeclaration("TreeMapHeader", selector, false);
		}
		
		//initialize the default styles
		initializeStyles();
	
    //----------------------------------
	//  Constructor
    //----------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapHeader()
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
			if (TreeMapHeader.createAccessibilityImplementation != null)
				TreeMapHeader.createAccessibilityImplementation(this);
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
			
			if (styleDecl)
			{
				var value:Number = styleDecl.getStyle("paddingLeft");
				if (!isNaN(value))
					setStyle("paddingLeft", value);
				value = styleDecl.getStyle("paddingRight");
				if (!isNaN(value))
					setStyle("paddingRight", value);
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
			var treemap:TreeMap = TreeMap(parent);
			if (treemap.enabled)
			{
				treemap.setChildIndex(this, treemap.numChildren - 1);
			}
		}
		
	}
}
