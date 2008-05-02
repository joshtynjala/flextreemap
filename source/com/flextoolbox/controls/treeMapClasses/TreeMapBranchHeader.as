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
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.events.TreeMapEvent;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderSkin;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderZoomButtonSkin;
	import com.flextoolbox.skins.halo.TreeMapZoomInIcon;
	import com.flextoolbox.skins.halo.TreeMapZoomOutIcon;
	import com.flextoolbox.utils.FlexFontUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import mx.controls.Button;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
    //----------------------------------
	//  Styles
    //----------------------------------
	
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
	//  Static Properties
    //----------------------------------
		
		private static const SELECTION_BUTTON_STYLE_NAME:String = "com_flextoolbox_TreeMapBranchHeaderSelectionButton";
		private static const ZOOM_BUTTON_STYLE_NAME:String = "com_flextoolbox_TreeMapBranchHeaderZoomButton";
		
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
				this.selectionButtonStyleName = SELECTION_BUTTON_STYLE_NAME;
				this.zoomButtonStyleName = ZOOM_BUTTON_STYLE_NAME;
				this.paddingTop = 2;
				this.paddingRight = 6;
				this.paddingBottom = 2;
				this.paddingLeft = 6;
 				this.textAlign = "left";
 				this.fontWeight = "bold";
			}
			StyleManager.setStyleDeclaration("TreeMapBranchHeader", selector, false);
			
			selector = StyleManager.getStyleDeclaration("." + SELECTION_BUTTON_STYLE_NAME);
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			selector.defaultFactory = function():void
			{
				this.fillAlphas = [1.0, 1.0];
				this.upSkin = TreeMapBranchHeaderSkin;
				this.downSkin = TreeMapBranchHeaderSkin;
				this.overSkin = TreeMapBranchHeaderSkin;
				this.disabledSkin = TreeMapBranchHeaderSkin;
				this.selectedUpSkin = TreeMapBranchHeaderSkin;
				this.selectedDownSkin = TreeMapBranchHeaderSkin;
				this.selectedOverSkin = TreeMapBranchHeaderSkin;
				this.selectedDisabledSkin = TreeMapBranchHeaderSkin;
			};
			StyleManager.setStyleDeclaration("." + SELECTION_BUTTON_STYLE_NAME, selector, false);
			
			
			selector = StyleManager.getStyleDeclaration("." + ZOOM_BUTTON_STYLE_NAME);
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			selector.defaultFactory = function():void
			{
				this.fillAlphas = [1.0, 1.0];
				this.paddingTop = 2;
				this.paddingRight = 5;
				this.paddingBottom = 2;
				this.paddingLeft = 5;
				this.upSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.downSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.overSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.disabledSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.selectedUpSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.selectedDownSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.selectedOverSkin = TreeMapBranchHeaderZoomButtonSkin;
				this.selectedDisabledSkin = TreeMapBranchHeaderZoomButtonSkin;
				
				this.icon = TreeMapZoomInIcon;
				this.selectedUpIcon = TreeMapZoomOutIcon;
				this.selectedOverIcon = TreeMapZoomOutIcon;
				this.selectedDownIcon = TreeMapZoomOutIcon;
				this.selectedDisabledIcon = TreeMapZoomOutIcon;
			};
			StyleManager.setStyleDeclaration("." + ZOOM_BUTTON_STYLE_NAME, selector, false);
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
		 * The text field that displays the header's label.
		 * 
		 * We need a separate text field because Button performs poorly when
		 * resized quickly and it has a label.
		 */
		protected var label:TextField;
	
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
			this.invalidateSize();
			this.invalidateDisplayList();
		}
	
		protected var zoomEnabled:Boolean = false;
	
    //----------------------------------
	//  Public Methods
    //----------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "selectionButtonStyleName")
			{
				if(this.selectionButton)
				{
					this.selectionButton.styleName = this.getStyle("selectionButtonStyleName");
				}
			}
			
			if(allStyles || styleProp == "zoomButtonStyleName")
			{
				if(this.zoomButton)
				{
					this.zoomButton.styleName = this.getStyle("zoomButtonStyleName");
				}
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
				this.selectionButton.styleName = this.getStyle("selectionButtonStyleName");
				this.selectionButton.addEventListener(MouseEvent.CLICK, selectionButtonClickHandler);
				this.addChild(this.selectionButton);
			}
			
			if(!this.zoomButton)
			{
				this.zoomButton = new Button();
				this.zoomButton.styleName = this.getStyle("zoomButtonStyleName");
				this.zoomButton.addEventListener(MouseEvent.CLICK, zoomButtonClickHandler);
				this.addChild(this.zoomButton);
			}
			
			if(!this.label)
			{
				this.label = new TextField();
				this.label.mouseEnabled = false;
				this.label.selectable = false;
				this.addChild(this.label);
			}
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
				this.selectionButton.toolTip = branchData.dataTip;
				this.label.text = branchData.label;
				
				//only enable the zoom button if treemap zoom is enabled and the branch data isn't the root
				this.zoomEnabled = treeMap.zoomEnabled && !treeMap.itemIsRoot(branch);
				
				this.zoomButton.visible = this.zoomEnabled;
				this.zoomButton.selected = branch == treeMap.zoomedBranch;
			}
			
			FlexFontUtil.applyTextStyles(this.label, this);
		}
		
		override protected function measure():void
		{
			super.measure();
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			
			this.measuredWidth = this.label.textWidth + 4 + paddingLeft + paddingRight;
			this.measuredHeight = this.label.textHeight + 3 + paddingTop + paddingBottom;
			
			if(this.zoomEnabled)
			{
				this.measuredWidth += this.zoomButton.measuredWidth;
				this.measuredHeight = Math.max(this.measuredHeight, this.zoomButton.measuredHeight);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			
			var zoomButtonWidth:Number = 0;
			if(this.zoomEnabled)
			{
				zoomButtonWidth = Math.min(this.zoomButton.measuredWidth, unscaledWidth / 2);
				this.zoomButton.setActualSize(zoomButtonWidth, unscaledHeight);
				//since the zoom button may get very small, we need to clip it in case the icon is larger
				this.zoomButton.scrollRect = new Rectangle(0, 0, zoomButtonWidth, unscaledHeight);
				var zoomButtonX:Number = Math.max(0, unscaledWidth - zoomButtonWidth);
				this.zoomButton.move(zoomButtonX, 0);
			}
			
			var selectionButtonWidth:Number = Math.max(0, unscaledWidth - zoomButtonWidth);
			this.selectionButton.move(0, 0);
			this.selectionButton.setActualSize(selectionButtonWidth, unscaledHeight);
			
			this.label.width = Math.max(0, this.selectionButton.width - paddingLeft - paddingRight);
			this.label.height = Math.max(0, Math.min(this.label.textHeight + paddingTop + paddingBottom, unscaledHeight - paddingTop - paddingBottom));
			
			this.label.x = paddingLeft;
			this.label.y = Math.max(paddingTop, (this.selectionButton.height - this.label.height) / 2);
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
