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

//TODO: Add Adobe Flex license info

package com.flextoolbox.controls.treeMapClasses
{
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.events.TreeMapEvent;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderSkin;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderZoomButtonSkin;
	import com.flextoolbox.skins.halo.TreeMapZoomInIcon;
	import com.flextoolbox.skins.halo.TreeMapZoomOutIcon;
	
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
	
    //----------------------------------
	//  Styles
    //----------------------------------
	
include "../../styles/metadata/BorderStyles.inc"
include "../../styles/metadata/PaddingStyles.inc"
include "../../styles/metadata/TextStyles.inc"

	[Style(name="zoomInIcon", type="Class", inherit="no")]
	[Style(name="zoomOutIcon", type="Class", inherit="no")]
    
	/**
	 * The TreeMapBranchHeader class defines the appearance of the header buttons
	 * of the branches in a TreeMap.
	 * 
	 * @author Josh Tynjala
	 * @see com.flextoolbox.controls.TreeMap
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
				//TODO: Define all styles with metadata
				this.fillAlphas = [1.0, 1.0];
				this.paddingTop = 0;
				this.paddingRight = 6;
				this.paddingBottom = 0;
				this.paddingLeft = 6;
 				this.textAlign = "left";
				this.upSkin = TreeMapBranchHeaderSkin;
				this.downSkin = TreeMapBranchHeaderSkin;
				this.overSkin = TreeMapBranchHeaderSkin;
				this.disabledSkin = TreeMapBranchHeaderSkin;
				this.selectedUpSkin = TreeMapBranchHeaderSkin;
				this.selectedDownSkin = TreeMapBranchHeaderSkin;
				this.selectedOverSkin = TreeMapBranchHeaderSkin;
				this.selectedDisabledSkin = TreeMapBranchHeaderSkin;
				this.zoomButtonUpSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonDownSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonOverSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonDisabledSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonSelectedUpSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonSelectedDownSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonSelectedOverSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomButtonSelectedDisabledSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.zoomInIcon = TreeMapZoomInIcon;
				this.zoomOutIcon = TreeMapZoomOutIcon;
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
			this.tabEnabled = false;
		}
	
    //----------------------------------
	//  Properties
    //----------------------------------
	
		protected var selectionButton:Button;
		protected var zoomButton:Button;
	
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
			this._data = value;
			this.invalidateProperties();
		}
	
		protected var zoomEnabled:Boolean = false;
	
		private var _selectionButtonStyleFilter:Object = 
		{
			upSkin: "upSkin",
			downSkin: "downSkin",
			overSkin: "overSkin",
			disabledSkin: "disabledSkin",
			selectedUpSkin: "selectedUpSkin",
			selectedDownSkin: "selectedDownSkin",
			selectedOverSkin: "selectedOverSkin",
			selectedDisabledSkin: "selectedDisabledSkin",
			paddingTop: "paddingTop",
			paddingRight: "paddingRight",
			paddingBottom: "paddingBottom",
			paddingLeft: "paddingLeft"
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
			zoomButtonSelectedDisabledSkin: "selectedDisabledSkin"
		};
		
		protected function get zoomButtonStyleFilter():Object
		{
			return this._zoomButtonStyleFilter;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "zoomInIcon")
			{
				this.refreshZoomInIcon();
			}
			
			if(allStyles || styleProp == "zoomOutIcon")
			{
				this.refreshZoomOutIcon();
			}
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
			this.refreshZoomInIcon();
			this.refreshZoomOutIcon();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			var branchRenderer:ITreeMapBranchRenderer = this.data as ITreeMapBranchRenderer;
			if(branchRenderer)
			{
				var treeMap:TreeMap = branchRenderer.owner as TreeMap;
				var branch:Object = branchRenderer.data;
				var branchData:TreeMapBranchData = IDropInTreeMapItemRenderer(branchRenderer).treeMapData as TreeMapBranchData;
				
				this.selectionButton.selected = branchRenderer.selected;
				this.selectionButton.label = branchData.label;
				
				//only enable the zoom button if treemap zoom is enabled and the branch data isn't the root
				this.zoomEnabled = treeMap.zoomEnabled && !treeMap.itemIsRoot(branch);
				
				this.zoomButton.visible = this.zoomEnabled;
				this.zoomButton.selected = branch == treeMap.zoomedBranch;
			}
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
	
		protected function refreshZoomInIcon():void
		{
			if(!this.zoomButton)
			{
				return;
			}
			
			var zoomStyleName:StyleProxy = StyleProxy(this.zoomButton.styleName);
			var zoomInIcon:Class = this.getStyle("zoomInIcon");
			this.zoomButton.setStyle("upIcon", zoomInIcon);
			this.zoomButton.setStyle("overIcon", zoomInIcon);
			this.zoomButton.setStyle("downIcon", zoomInIcon);
			this.zoomButton.setStyle("disabledIcon", zoomInIcon);
			
			//if I don't call this,  zoomButton.getStyle("overIcon") returns undefined!
			//I have no idea why!
			this.zoomButton.regenerateStyleCache(false);
		}
	
		protected function refreshZoomOutIcon():void
		{
			if(!this.zoomButton)
			{
				return;
			}
			
			var zoomOutIcon:Class = this.getStyle("zoomOutIcon");
			this.zoomButton.setStyle("selectedUpIcon", zoomOutIcon);
			this.zoomButton.setStyle("selectedOverIcon", zoomOutIcon);
			this.zoomButton.setStyle("selectedDownIcon", zoomOutIcon);
			this.zoomButton.setStyle("selectedDisabledIcon", zoomOutIcon);
			
			this.zoomButton.regenerateStyleCache(false);
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
