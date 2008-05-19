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
	import com.yahoo.astra.utils.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import mx.controls.Button;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.effects.IEffect;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	import mx.managers.PopUpManager;
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
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
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
		
		private var _oldParent:UIComponent;
		private var _oldBounds:Rectangle;
	
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
			this.layoutContents(unscaledWidth, unscaledHeight);
		}
		
		protected function layoutContents(width:Number, height:Number):void
		{
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			
			var zoomButtonWidth:Number = 0;
			if(this.zoomEnabled)
			{
				zoomButtonWidth = Math.min(this.zoomButton.measuredWidth, width / 2);
				if(width < this.measuredWidth)
				{
					//hide the zoom button if it's too small
					zoomButtonWidth = 0;
				}
				this.zoomButton.setActualSize(zoomButtonWidth, height);
				//since the zoom button may get very small, we need to clip it in case the icon is larger
				this.zoomButton.scrollRect = new Rectangle(0, 0, zoomButtonWidth, height);
				var zoomButtonX:Number = Math.max(0, width - zoomButtonWidth);
				this.zoomButton.move(zoomButtonX, 0);
			}
			
			var selectionButtonWidth:Number = Math.max(0, width - zoomButtonWidth);
			this.selectionButton.move(0, 0);
			this.selectionButton.setActualSize(selectionButtonWidth, height);
			
			this.label.width = Math.max(0, this.selectionButton.width - paddingLeft - paddingRight);
			this.label.height = Math.max(0, Math.min(this.label.textHeight + paddingTop + paddingBottom, unscaledHeight - paddingTop - paddingBottom));
			
			this.label.x = paddingLeft;
			this.label.y = Math.max(paddingTop, (this.selectionButton.height - this.label.height) / 2);
		}
	
    //----------------------------------
	//  Protected Event Handlers
    //----------------------------------
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if(this.unscaledWidth < this.measuredWidth || this.unscaledHeight < this.measuredHeight)
			{
				//stop listening for roll over events while we're in pop up mode
				this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				
				//a drop shadow helps to distinguish this header from any others
				//that are displayed in the treemap
				this._dropShadow = new DropShadowFilter(2, 45, 0, 1, 25, 25, 1);
				var filters:Array = this.filters;
				filters.push(this._dropShadow);
				this.filters = filters;
				
				this._oldParent = UIComponent(this.parent);
				this._oldBounds = new Rectangle(this.x, this.y, this.unscaledWidth, this.unscaledHeight);
				
				var startPosition:Point = DisplayObjectUtil.localToLocal(new Point(this.x, this.y), this.parent, DisplayObject(this.systemManager));
				var globalBounds:Rectangle = this.calculateGlobalBounds();
				PopUpManager.addPopUp(this, this.parent);
				
				this.x = startPosition.x;
				this.y = startPosition.y;
				this.width = this._oldBounds.width;
				this.height = this._oldBounds.height;
				
				//if the resize effect is running, we need to stop it so that it
				//doesn't conflict with the new resize effect
				if(this._openEffect && this._openEffect.isPlaying)
				{
					this._openEffect.pause();
				}
				
				var parallel:Parallel = new Parallel(this);
				parallel.duration = 150;
				
				this._resize = new Resize();
				this._resize.widthTo = globalBounds.width;
				this._resize.heightTo = globalBounds.height;
				parallel.addChild(this._resize);
				
				this._move = new Move();
				this._move.xTo = globalBounds.x;
				this._move.yTo = globalBounds.y;
				parallel.addChild(this._move);
				
				this._openEffect = parallel;
				this._openEffect.play();
				
				this.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			}
		}
		
		private var _openEffect:IEffect;
		private var _resize:Resize;
		private var _move:Move;
		private var _dropShadow:DropShadowFilter;
		
		protected function calculateGlobalBounds():Rectangle
		{	
			var newWidth:Number = Math.max(this.unscaledWidth, this.measuredWidth);
			var newHeight:Number = Math.max(this.unscaledHeight, this.measuredHeight);
				
			var branchRenderer:ITreeMapBranchRenderer = this.data as ITreeMapBranchRenderer;
			var treeMap:TreeMap = branchRenderer.owner as TreeMap;
			
			var treeMapPosition:Point = DisplayObjectUtil.localToLocal(new Point(this.x, this.y), this.parent, treeMap);
			
			var xPosition:Number = treeMapPosition.x;
			if(xPosition + newWidth > treeMap.width)
			{
				xPosition -= ((xPosition + newWidth) - treeMap.width);
			}
			if(xPosition < 0)
			{
				xPosition = 0;
			}
			
			var yPosition:Number = treeMapPosition.y;
			if(yPosition + newHeight > treeMap.height)
			{
				yPosition -= ((yPosition + newHeight) - treeMap.height);
			}
			if(yPosition < 0)
			{
				yPosition = 0;
			}
			
			var globalPosition:Point = DisplayObjectUtil.localToLocal(new Point(xPosition, yPosition), treeMap, DisplayObject(this.systemManager));
			return new Rectangle(globalPosition.x, globalPosition.y, newWidth, newHeight);
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			var bounds:Rectangle = new Rectangle(this._move.xTo, this._move.yTo, this._resize.widthTo, this._resize.heightTo);
			if(!bounds.contains(event.stageX, event.stageY))
			{
				this.closePopUp();
			}
		}
		
		protected function closePopUp():void
		{
			if(this.parent is ITreeMapBranchRenderer)
			{
				return;
			}
			
			if(this._openEffect && this._openEffect.isPlaying)
			{
				this._openEffect.pause();
				this._openEffect = null;
			}
			
			var filters:Array = this.filters;
			filters.splice(this.filters.indexOf(this._dropShadow), 1);
			this.filters = filters;
			
			this.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			
			PopUpManager.removePopUp(this);
			this._oldParent.addChild(this);
			this.x = this._oldBounds.x;
			this.y = this._oldBounds.y;
			this.width = NaN;
			this.height = NaN;
			this.setActualSize(this._oldBounds.width, this._oldBounds.height);
		}
		
		protected function selectionButtonClickHandler(event:Event):void
		{
			this.dispatchEvent(new TreeMapEvent(TreeMapEvent.BRANCH_SELECT));
		}
		
		protected function zoomButtonClickHandler(event:MouseEvent):void
		{
			this.closePopUp();
			this.dispatchEvent(new TreeMapEvent(TreeMapEvent.BRANCH_ZOOM));
		}
	}
}
