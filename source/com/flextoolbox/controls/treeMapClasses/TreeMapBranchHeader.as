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
	import com.flextoolbox.controls.TreeMap;
	import com.flextoolbox.events.TreeMapBranchEvent;
	import com.flextoolbox.events.TreeMapEvent;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderSkin;
	import com.flextoolbox.skins.halo.TreeMapBranchHeaderZoomButtonSkin;
	import com.flextoolbox.skins.halo.TreeMapResizeIcon;
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

	/**
	 * The icon for the zoom button when clicking the button causes the branch
	 * to zoom in.
	 */
	[Style(name="zoomInIcon", type="Class", inherit="no")]

	/**
	 * The icon for the zoom button when clicking the button causes the branch
	 * to zoom out.
	 */
	[Style(name="zoomOutIcon", type="Class", inherit="no")]
	
	[ExcludeClass]
	/**
	 * The TreeMapBranchHeader class defines the appearance of the header buttons
	 * of the branches in a TreeMap.
	 * 
	 * @see com.flextoolbox.controls.TreeMap
	 * @author Josh Tynjala
	 */
	public class TreeMapBranchHeader extends UIComponent implements IDataRenderer
	{
	
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
	
		/**
		 * @private
		 * The button that, when clicked, selects the parent branch.
		 */
		protected var selectionButton:Button;
		
		/**
		 * @private
		 * The button that, when clicked, zooms the parent branch.
		 */
		protected var zoomButton:Button;
		
		/**
		 * @private
		 * An indicator that the header may be resized to show more.
		 */
		protected var resizeIndicator:DisplayObject;
		
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
	
		/**
		 * @private
		 * Flag indicating that it is possible to zoom.
		 */
		protected var zoomEnabled:Boolean = false;
		
		/**
		 * @private
		 * Storage for the parent in popup mode.
		 */
		private var _oldParent:UIComponent;
		
		/**
		 * @private
		 * Storage for the bounds in popup mode.
		 */
		private var _oldBounds:Rectangle;
		
		/**
		 * @private
		 */
		private var _openEffect:IEffect;
		
		/**
		 * @private
		 */
		private var _resize:Resize;
		
		/**
		 * @private
		 */
		private var _move:Move;
		
		/**
		 * @private
		 * A drop shadow to make the popup more prominent.
		 */
		private var _dropShadow:DropShadowFilter;
	
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
			
			if(allStyles || styleProp == "resizeIcon")
			{
				this.invalidateDisplayList();
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
		
		/**
		 * @private
		 */
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
			
			this.selectionButton.enabled = this.enabled;
			this.zoomButton.enabled = this.enabled;
			
			FlexFontUtil.applyTextStyles(this.label, this);
		}
		
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.layoutContents(unscaledWidth, unscaledHeight);
		}
		
		/**
		 * @private
		 */
		protected function layoutContents(width:Number, height:Number):void
		{
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			
			var contentWidth:Number = Math.max(0, width - paddingLeft - paddingRight);
			var contentHeight:Number = Math.max(0, height - paddingTop - paddingBottom);
				
			var showResizeIndicator:Boolean = width < this.measuredWidth || height < this.measuredHeight;
			this.zoomButton.visible = this.zoomEnabled && !showResizeIndicator;
			if(showResizeIndicator)
			{
				//reset the scroll rect so that width and height appear correctly
				this.refreshResizeIcon();
				this.resizeIndicator.x = Math.max(paddingLeft, width - this.resizeIndicator.width - paddingRight);
				this.resizeIndicator.y = Math.max(paddingTop, (height - this.resizeIndicator.height) / 2);
				this.resizeIndicator.scrollRect = new Rectangle(0, 0,
					Math.min(this.resizeIndicator.width, contentWidth), Math.min(this.resizeIndicator.height, contentHeight));
			}
			else if(this.zoomEnabled)
			{
				this.zoomButton.scrollRect = null;
				var zoomButtonWidth:Number = Math.min(this.zoomButton.measuredWidth, width / 2);
				this.zoomButton.setActualSize(zoomButtonWidth, height);
				//since the zoom button may get very small, we need to clip it in case the icon is larger
				this.zoomButton.scrollRect = new Rectangle(0, 0, zoomButtonWidth, height);
				var zoomButtonX:Number = Math.max(0, width - zoomButtonWidth);
				this.zoomButton.move(zoomButtonX, 0);
			}
			
			if(this.resizeIndicator)
			{
				this.resizeIndicator.visible = showResizeIndicator;
			}
			
			var selectionButtonWidth:Number = Math.max(0, width - ((!showResizeIndicator && this.zoomEnabled) ? this.zoomButton.scrollRect.width : 0));
			this.selectionButton.move(0, 0);
			this.selectionButton.setActualSize(selectionButtonWidth, height);
			
			var resizeIndicatorWidth:Number = showResizeIndicator ? (this.resizeIndicator.scrollRect.width + this.getStyle("horizontalGap")) : 0;
			this.label.width = Math.max(0, this.selectionButton.width - paddingLeft - paddingRight - resizeIndicatorWidth);
			this.label.height = Math.max(0, Math.min(this.label.textHeight + paddingTop + paddingBottom, contentHeight));
			
			this.label.x = paddingLeft;
			this.label.y = Math.max(0, (this.selectionButton.height - this.label.height) / 2);
		}
		
		/**
		 * @private
		 * Updates the resize indicator when it changes.
		 */
		protected function refreshResizeIcon():void
		{
			if(this.resizeIndicator)
			{
				this.removeChild(this.resizeIndicator);
				this.resizeIndicator = null;
			}
			
			var resizeIcon:Class = this.getStyle("resizeIcon");
			if(resizeIcon)
			{
				this.resizeIndicator = new resizeIcon();
				this.addChild(this.resizeIndicator);
			}
		}
	
    //----------------------------------
	//  Protected Event Handlers
    //----------------------------------
		
		/**
		 * @private
		 * Displays the popup when the mouse is over the header.
		 */
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
		
		/**
		 * @private
		 * Figures out the location for the popup.
		 */
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
		
		/**
		 * @private
		 * Close the popup if the mouse moves outside the stage.
		 */
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			var bounds:Rectangle = new Rectangle(this._move.xTo, this._move.yTo, this._resize.widthTo, this._resize.heightTo);
			if(!bounds.contains(event.stageX, event.stageY))
			{
				this.closePopUp();
			}
		}
		
		/**
		 * @private
		 * Removes the special growing popup.
		 */
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
		
		/**
		 * @private
		 * If the header is clicked, request a selection.
		 */
		protected function selectionButtonClickHandler(event:Event):void
		{
			this.dispatchEvent(new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_SELECT));
		}
		
		/**
		 * @private
		 * If the zoom button is clicked, close the pop up if it is open and
		 * request a zoom.
		 */
		protected function zoomButtonClickHandler(event:MouseEvent):void
		{
			this.closePopUp();
			this.dispatchEvent(new TreeMapBranchEvent(TreeMapBranchEvent.REQUEST_ZOOM));
		}
	}
}
