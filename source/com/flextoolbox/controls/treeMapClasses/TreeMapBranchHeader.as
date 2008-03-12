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
	import com.flextoolbox.events.TreeMapEvent;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderSkin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
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
	public class TreeMapBranchHeader extends UIComponent implements IDataRenderer
	{
		
    //----------------------------------
	//  Static Methods
    //----------------------------------
    
		/**
		 * @private
		 * Initializes the default styles for instances of this type.
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
				this.zoomButtonUpSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonDownSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonOverSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonDisabledSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonSelectedUpSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonSelectedDownSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonSelectedOverSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonSelectedDisabledSkin = TreeMapBranchHeaderSkin;
				this.zoomInIcon = ZoomInIcon;
				this.zoomOutIcon = ZoomOutIcon;
			}
			
			StyleManager.setStyleDeclaration("TreeMapBranchHeader", selector, false);
		}
		initializeStyles();
	
		[Embed(source="/assets/mac_max_up.png")]
		private static const ZoomInIcon:Class;
	
		[Embed(source="/assets/mac_min_up.png")]
		private static const ZoomOutIcon:Class;
	
    //----------------------------------
	//  Constructor
    //----------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMapBranchHeader()
		{
			super();
			this.tabEnabled = false;
		}
	
    //----------------------------------
	//  Variables and Properties
    //----------------------------------
	
		protected var selectionButton:Button;
		protected var zoomButton:Button;
	
		/**
		 * @private
		 * Storage for the label property.
		 */
		private var _label:String;
	
		/**
		 * Stores a reference to the label with the header.
		 */
		public function get label():String
		{
			return this._label;
		}
		
		/**
		 * @private
		 */
		public function set label(value:String):void
		{
			this._label = value;
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
		}
	
		/**
		 * @private
		 * Storage for the _data property.
		 */
		private var _data:Object;
	
		/**
		 * Stores a reference to the content associated with the header.
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			_data = value;
		}
	
		private var _selected:Boolean = false;
	
		public function get selected():Boolean
		{
			return this._selected;
		}
	
		/**
		 * @private
		 */
		public function set selected(value:Boolean):void
		{
			this._selected = value;
			this.invalidateProperties();
		}
		
		private var _zoomEnabled:Boolean = false;
		
		public function get zoomEnabled():Boolean
		{
			return this._zoomEnabled;
		}
		
		public function set zoomEnabled(value:Boolean):void
		{
			if(this._zoomEnabled != value)
			{
				this._zoomEnabled = value;
				this.invalidateProperties();
				this.invalidateSize();
				this.invalidateDisplayList();
			}
		}
		
		private var _zoomed:Boolean = false;
		
		public function get zoomed():Boolean
		{
			return this._zoomed;
		}
		
		public function set zoomed(value:Boolean):void
		{
			if(this._zoomed != value)
			{
				this._zoomed = value;
				this.invalidateProperties();
			}
		}
	
		private var _selectionButtonStyleFilter:Object = 
		{
			upSkin: "upSkin",
			downSkin: "downSkin",
			overSkin: "overSkin",
			disabledSkin: "disabledSkin",
			selectedUpSkin: "selectedUpSkin",
			selectedDownSkin: "selectedDownSkin",
			selectedOverSkin: "selectedOverSkin",
			selectedDisabledSkin: "selectedDisabledSkin"
		};
		
		protected function get selectionButtonStyleFilter():Object
		{
			return this._selectionButtonStyleFilter;
		}
	
		private var _zoomButtonStyleFilter:Object = 
		{
			zoomButtonUpSkin: "upSkin",
			zoomButtonDownSkin: "downSkin",
			zoomButtonOverSkin: "overSkin",
			zoomButtonDisabledSkin: "disabledSkin",
			zoomButtonSelectedUpSkin: "selectedUpSkin",
			zoomButtonSelectedDownSkin: "selectedDownSkin",
			zoomButtonSelectedOverSkin: "selectedOverSkin",
			zoomButtonSelectedDisabledSkin: "selectedDisabledSkin",
			zoomInIcon: "icon",
			zoomOutIcon: "selectedUpIcon"
		};
		
		protected function get zoomButtonStyleFilter():Object
		{
			return this._zoomButtonStyleFilter;
		}
	
    //----------------------------------
	//  Protected Methods
    //----------------------------------
	
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.selectionButton)
			{
				this.selectionButton = new Button();
				this.selectionButton.styleName = new StyleProxy(this, this.selectionButtonStyleFilter);
				this.selectionButton.addEventListener(MouseEvent.CLICK, selectionButtonClickHandler);
				this.addChild(this.selectionButton);
			}
			
			if(!this.zoomButton)
			{
				this.zoomButton = new Button();
				this.zoomButton.styleName = new StyleProxy(this, this.zoomButtonStyleFilter);
				this.zoomButton.addEventListener(MouseEvent.CLICK, zoomButtonClickHandler);
				this.addChild(this.zoomButton);
			}

		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			this.selectionButton.selected = this.selected;
			this.selectionButton.label = this.label;
			
			this.zoomButton.selected = this.zoomed;
			this.zoomButton.visible = this.zoomEnabled;
		}
		
		override protected function measure():void
		{
			super.measure();
			
			this.measuredWidth = this.selectionButton.measuredWidth;
			this.measuredHeight = this.selectionButton.measuredHeight;
			
			if(this.zoomEnabled)
			{
				this.measuredWidth += this.zoomButton.measuredWidth;
				this.measuredHeight = Math.max(this.measuredHeight, this.zoomButton.measuredHeight);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var zoomButtonWidth:Number = 0;
			if(this.zoomEnabled)
			{
				zoomButtonWidth = Math.min(this.zoomButton.measuredWidth, unscaledWidth / 2);
				this.zoomButton.setActualSize(zoomButtonWidth, unscaledHeight);
				this.zoomButton.move(unscaledWidth - zoomButtonWidth, 0);
			}
			
			var selectionButtonWidth:Number = unscaledWidth - zoomButtonWidth;
			this.selectionButton.move(0, 0);
			this.selectionButton.setActualSize(selectionButtonWidth, unscaledHeight);
		}
	
    //----------------------------------
	//  Protected Event Handlers
    //----------------------------------
		
		protected function selectionButtonClickHandler(event:Event):void
		{
			this.dispatchEvent(new TreeMapEvent(TreeMapEvent.BRANCH_SELECT));
		}
		
		protected function zoomButtonClickHandler(event:MouseEvent):void
		{
			this.dispatchEvent(new TreeMapEvent(TreeMapEvent.BRANCH_ZOOM));
		}
	}
}
