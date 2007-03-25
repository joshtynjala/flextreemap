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

package com.joshtynjala.controls
{
	import flash.utils.*;
	import flash.xml.XMLNode;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.core.ClassFactory;
	import mx.core.UITextField;
	import mx.core.IFlexDisplayObject;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.collections.ICollectionView;
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.collections.IViewCursor;
	import mx.states.State;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.skins.RectangularBorder;
	import mx.skins.halo.HaloBorder;
	import mx.utils.UIDUtil;
	
	import com.joshtynjala.controls.treeMapClasses.treemap_internal;
	import com.joshtynjala.events.TreeMapEvent;
	import com.joshtynjala.controls.treeMapClasses.*;

	use namespace treemap_internal;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the <code>selectedIndex</code> or <code>selectedItem</code> property
	 * changes as a result of user interaction.
	 *
	 * @eventType flash.events.event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Dispatched when the user rolls the mouse pointer over an node in the control.
	 *
	 * @eventType com.joshtynjala.events.TreeMapEvent.NODE_ROLL_OVER
	 */
	[Event(name="nodeRollOver", type="com.joshtynjala.events.TreeMapEvent")]
	
	/**
	 * Dispatched when the user rolls the mouse pointer out of an node in the control.
	 *
	 * @eventType com.joshtynjala.events.TreeMapEvent.NODE_ROLL_OUT
	 */
	[Event(name="nodeRollOut", type="com.joshtynjala.events.TreeMapEvent")]
	
	/**
	 * Dispatched when the user clicks on an node in the control.
	 *
	 * @eventType com.joshtynjala.events.TreeMapEvent.NODE_CLICK
	 */
	[Event(name="nodeClick", type="com.joshtynjala.events.TreeMapEvent")]
	
	/**
	 * Dispatched when the user double-clicks on an node in the control.
	 *
	 * @eventType com.joshtynjala.events.TreeMapEvent.NODE_DOUBLE_CLICK
	 */
	[Event(name="nodeDoubleClick", type="com.joshtynjala.events.TreeMapEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * The border skin of the component.
	 */
	[Style(name="borderSkin", type="Class")]
	
	/**
	 * The style name for the border skin.
	 */
	[Style(name="borderStyle", type="String")]
	
	/**
	 * Sets the style name for the header.
	 */
	[Style(name="headerStyleName", type="String")]
	
	/**
	 * Sets the style name for all standard nodes.
	 */
	[Style(name="nodeStyleName", type="String")]
	
	/**
	 * Sets the style name for all branches.
	 */
	[Style(name="branchStyleName", type="String")]
	
	/**
	 * A treemap is a space-constrained visualization of hierarchical
	 * structures. It is very effective in showing attributes of leaf nodes
	 * using size and color coding.
	 * 
	 * @author Josh Tynjala
	 * @see http://en.wikipedia.org/wiki/Treemapping
	 * @see http://www.cs.umd.edu/hcil/treemap-history/
	 */
	public class TreeMap extends UIComponent implements ITreeMapBranchRenderer
	{
		
	//--------------------------------------
	//  Class Variables
	//--------------------------------------
		
		/**
		 * @private
		 * The default width of the TreeMap.
		 */
		private static const DEFAULT_MEASURED_WIDTH:Number = 300;
		
		/**
		 * @private
		 * The default height of the TreeMap.
		 */
		private static const DEFAULT_MEASURED_HEIGHT:Number = 200;
		
    //----------------------------------
	//  Class Methods
    //----------------------------------
    
		/**
		 * @private
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeMap");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.backgroundColor = 0xffffff;
				this.backgroundAlpha = 1.0;
				
				this.paddingLeft = 0;
				this.paddingRight = 0;
				this.paddingTop = 0;
				this.paddingBottom = 0;
				
				this.borderSkin = HaloBorder;
				this.borderStyle = "solid";
				this.borderColor = 0xaaaaaa;
				this.borderThickness = 1;
				
				this.fontSize = 10;
				this.fontWeight = "bold";
				this.textAlign = "left";
			}
			
			StyleManager.setStyleDeclaration("TreeMap", selector, false);
		}
		
		//initialize the default styles
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMap()
		{
			super()
			this.doubleClickEnabled = true;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	    
	    /**
	     * The skinnable border.
	     */
		protected var border:IFlexDisplayObject;
		
		/**
		 * The header. Contains a label. Works like the Accordion's header.
		 * @see mx.containers.Accordion
		 */
		public var header:TreeMapHeader;
		
		/**
		 * The node that is currently zoomed. Null if none are zoomed.
		 */
		protected var zoomedNode:ITreeMapNodeRenderer;
		
		/**
		 * Stores true if this TreeMap is zoomed, false if not.
		 */
		protected var zoomed:Boolean = false;
		
		/**
		 * @private
		 * Storage for the zoomOutType property.
		 */
		private var _zoomOutType:String = TreeMapZoomOutType.PREVIOUS;
		
		/**
		 * Determines the way that zoom out actions work. Values are defined by the
		 * constants in the <code>TreeMapZoomOutType</code> class.
		 */
		public function get zoomOutType():String
		{
			return this._zoomOutType;
		}
		
		/**
		 * @private
		 */
		public function set zoomOutType(value:String):void
		{
			this._zoomOutType = value;
		}
		
		/**
		 * @private
		 * If true, and the zoomOutType property is set to <code>TreeMapZoomOutType.PREVIOUS</code>,
		 * zoom out operations will stop at this TreeMap.
		 */
		private var _stopZoomOut:Boolean = false;
		
		/**
		 * @private
		 * Stores UIDs for the data stored in each renderer that is a direct child of
		 * this TreeMap.
		 */
		private var _dataUIDs:Array = [];
		
		/**
		 * @private
		 * Nodes may be accessed by the layout classes.
		 */
		treemap_internal var nodes:Array = [];
		
		/**
		 * @private
		 * Caches previously-used node renderers to minmize display list manipulation.
		 */
		private var _freeNodeRenderers:Array = [];
		
		/**
		 * @private
		 * Caches previously-used branch renderers to minmize display list manipulation.
		 */
		private var _freeBranchRenderers:Array = [];
		
		/**
		 * @private
		 * Bounds are calculated from the padding styles and docked header size.
		 */
		treemap_internal var contentBounds:Rectangle = new Rectangle();
				
		/**
		 * @private
		 * Flag to indicate if the nodes need to be redrawn.
		 */
		private var _nodesNeedRedraw:Boolean = false;
	    
	    /**
	     * @private
	     * Storage for the node renderer factory.
	     */
	    private var _nodeRenderer:ClassFactory = new ClassFactory(TreeMapNodeRenderer);
	
	    /**
	     * The custom node renderer for the control.
	     * You can specify a drop-in, inline, or custom node renderer.
	     *
		 * <p>The default node renderer is TreeMapNodeRenderer.</p>
	     */
	    public function get nodeRenderer():ClassFactory
	    {
	        return _nodeRenderer;
	    }
	
	    /**
		 * @private
		 */
	    public function set nodeRenderer(value:ClassFactory):void
	    {
	    	if(this._nodeRenderer != value)
	    	{
				this._nodeRenderer = value;
	
				var freeRenderersCount:int = this._freeNodeRenderers.length
				for(var i:int = 0; i < freeRenderersCount; i++)
				{
					var node:ITreeMapNodeRenderer = this._freeNodeRenderers.pop() as ITreeMapNodeRenderer;
					this.removeChild(node as DisplayObject);
				}
	
		    	this._nodesNeedRedraw = true;
				this.invalidateProperties();
				this.invalidateDisplayList();	
	    	}
	    }
	
		/**
		 * @private
		 * Storage for the branch renderer factory.
		 */
		private var _branchRenderer:ClassFactory = new ClassFactory(TreeMap);
		
	    /**
	     * The custom branch renderer for the control. You can specify a drop-in,
	     * inline, or custom branch renderer. Unlike the renderers used by Tree
	     * components, nodes and branches in a TreeMap are quite different visually and
	     * functionally. As a result, it's easier to specify and customize seperate
	     * renderers for either type.
	     *
		 * <p>The default branch renderer is TreeMap.</p>
	     */
	    public function get branchRenderer():ClassFactory
	    {
	        return this._branchRenderer;
	    }
	
	    /**
		 * @private
		 */
	    public function set branchRenderer(value:ClassFactory):void
	    {
	    	if(this._branchRenderer != value)
	    	{
				this._branchRenderer = value;
	
				var freeRenderersCount:int = this._freeBranchRenderers.length;
				for(var i:int = 0; i < freeRenderersCount; i++)
				{
					var node:ITreeMapBranchRenderer = this._freeBranchRenderers.pop() as ITreeMapBranchRenderer;
					this.removeChild(node as DisplayObject);
				}
	
				this.invalidateProperties();
				this.invalidateDisplayList();
	    	}
	    }
	    
	    /**
	     * @private
	     * Storage for the original data set by the user.
	     */
		private var _data:Object;
	
		/**
		 * Used to render data when the <code>TreeMap</code> is a branch renderer
		 * for a parent <code>TreeMap</code>. For most applications, it is
		 * recommended that you use the <code>dataProvider</code> property.
		 * 
		 * @see TreeMap#dataProvider
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
			this.dataProvider = value;
		}
	    
		/**
		 * An ICollectionView that represents the data provider.
		 * When you set the <code>dataProvider</code> property,
		 * Flex wraps the data provider as necessary to 
		 * support the ICollectionView interface and 
		 * sets this property to the result.
		 * The TreeMap class then uses this property to access
		 * data in the provider.
		 * When you get the <code>dataProvider</code> property, 
		 * Flex returns this value.  
	     */
		protected var collection:ICollectionView = new ArrayCollection();
		
		/**
		 * @private
		 * Flag that is set when the collection of data displayed by the TreeMap
		 * component changes.
		 */
		private var _collectionChangedFlag:Boolean = false;
		
		[Bindable("collectionChange")]
		/**
	     * Set of data to be viewed.
	     * This property lets you use most types of objects as data providers.
		 * If you set the <code>dataProvider</code> property to an Array, 
		 * it will be converted to an ArrayCollection. If you set the property to
		 * an XML object, it will be converted into an XMLListCollection with
		 * only one item. If you set the property to an XMLList, it will be 
		 * converted to an XMLListCollection.  
		 * If you set the property to an object that implements the 
		 * ICollectionView interface, the object will be used directly.
		 *
		 * <p>As a consequence of the conversions, when you get the 
		 * <code>dataProvider</code> property, it will always be
		 * an ICollectionView, and therefore not necessarily be the type of object
		 * you used to set the property.
		 * This behavor is important to understand if you want to modify the data 
		 * in the data provider: changes to the original data may not be detected, 
		 * but changes to the ICollectionView object that you get back from the 
		 * <code>dataProvider</code> property will be detected.</p>
	     * 
	     * @default null
	     * @see mx.collections.ICollectionView
	     */
	    public function get dataProvider():Object
	    {
	        return collection;
	    }
	
	    /**
		 * @private
		 */
		public function set dataProvider(value:Object):void
	    {
	        if(collection)
	        {
	        	collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
	        }
	
			//handle strings and xml
	    	if(typeof(value) == "string")
	        	value = new XML(value);
	        else if(value is XMLNode)
				value = new XML(XMLNode(value).toString());
			else if(value is XMLList)
				value = new XMLListCollection(value as XMLList);
				
			//save the data
			this._data = value;
			
			if(value is XML)
			{
				collection = new XMLListCollection(value.elements());
			}
			//if already a collection dont make new one
	        else if(value is ICollectionView)
	        {
	            collection = ICollectionView(value);
	        }
	        else if(value is Array)
	        {
	            collection = new ArrayCollection(value as Array);
	        }
			//all other types get wrapped in an ArrayCollection
			else if(value is Object)
			{
				// convert to an array containing this one item
				var temp:Array = [];
	       		temp.push(value);
	    		collection = new ArrayCollection(temp);
	  		}
	  		else
	  		{
	  			collection = new ArrayCollection();
	  		}
	
	        this.collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
	
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.RESET;
	        this.collectionChangeHandler(event);
	        this.dispatchEvent(event);
	
		    this._nodesNeedRedraw = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
	    }
		
		/**
		 * @private
		 * Storage for the data descriptor used to crawl the data.
		 */
		private var _dataDescriptor:ITreeDataDescriptor = new DefaultDataDescriptor();
	
		/**
		 * Returns the current ITreeDataDescriptor.
		 *
		 * @default DefaultDataDescriptor
		 */
		public function get dataDescriptor():ITreeDataDescriptor
		{
			return ITreeDataDescriptor(this._dataDescriptor);
		}

		/**
		 * TreeMap delegates to the data descriptor for information about the data.
		 * This data is then used to parse and move about the data source.
		 * <p>When you specify this property as an attribute in MXML you must
		 * use a reference to the data descriptor, not the string name of the
		 * descriptor. Use the following format for the property:</p>
		 *
		 * <pre>&lt;mx:TreeMap id="treemap" dataDescriptor="{new MyCustomTreeDataDescriptor()}"/&gt;></pre>
		 *
		 * <p>Alternatively, you can specify the property in MXML as a nested
		 * subtag, as the following example shows:</p>
		 *
		 * <pre>&lt;mx:TreeMap&gt;
		 * &lt;mx:dataDescriptor&gt;
		 * &lt;myCustomTreeDataDescriptor&gt;</pre>
		 *
		 * <p>The default value is an internal instance of the
		 * DefaultDataDescriptor class.</p>
		 *
		 */
		public function set dataDescriptor(value:ITreeDataDescriptor):void
		{
			if(this._dataDescriptor != value)
			{
				this._dataDescriptor = value;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the strategy used for layout of nodes and branches.
		 */
		private var _layoutStrategy:ITreeMapLayoutStrategy = new Squarify();
	    
	    /**
	     * The custom layout algorithm for the control.
	     *
		 * <p>The default alogrithm is Squarify.</p>
	     */
	    public function get layoutStrategy():ITreeMapLayoutStrategy
	    {
	        return this._layoutStrategy;
	    }
	    
	    /**
		 * @private
		 */
	    public function set layoutStrategy(strategy:ITreeMapLayoutStrategy):void
	    {
	    	if(this._layoutStrategy != strategy)
	    	{
	    		this._layoutStrategy = strategy;
		    	this.invalidateDisplayList();
		    }
	    }
		
		/**
		 * @private
		 * Storage for the label's text.
		 */
		private var _labelText:String;
		
		/**
		 * @private
		 * Indicates if the label has been set by the user.
		 */
		private var _labelPropertySet:Boolean = false;
		
		/**
		 * A <code>TreeMap</code> may display a label in its header.
		 */
		public function get label():String
		{
			return this._labelText;
		}
		
		/**
		 * @private
		 */
		public function set label(value:String):void
		{
			//if the label is set by the user, we will ignore the labelField and labelFunction
			if(value) this._labelPropertySet = true;
			else this._labelPropertySet = false;
			
			if(this._labelText != value)
			{
				this._labelText = value;
				this.invalidateProperties();
			}
		}
		
		/**
		 * @private
		 * Storage for the header's tooltip text.
		 */
		private var _headerToolTip:String;
		
		/**
		 * @private
		 * Indicates if the tooltip has been set by the user.
		 */
		private var _toolTipPropertySet:Boolean = false;
		
		/**
		 * A <code>TreeMap</code> may display a tooltip on its header.
		 */
		public function get headerToolTip():String
		{
			return this._headerToolTip;
		}
		
		/**
		 * @private
		 */
		public function set headerToolTip(value:String):void
		{
			//if the tooltip is set by the user, we will ignore the toolTipField and toolTipFunction
			if(value) this._toolTipPropertySet = true;
			else this._toolTipPropertySet = false;
			
			if(this._headerToolTip != value)
			{
				this._headerToolTip = value;
				this.invalidateProperties();
			}
		}
		
	    
	//-- Weight
	
		private var _cachedWeights:Dictionary;
	
		/**
		 * @private
		 * Storage for the field used to calculate a node's weight.
		 */
		private var _weightField:String = "weight";
		[Bindable]
	    /**
	     * The name of the field in the data provider items to use in weight calculations.
	     */
	    public function get weightField():String
	    {
	    	return this._weightField;
	    }
	    
	    /**
		 * @private
		 */
	    public function set weightField(value:String):void
	    {
	    	if(this._weightField != value)
	    	{
		    	this._weightField = value;
		    	this.invalidateProperties();
		    	this.invalidateDisplayList();
		    }
	    }
	    
		/**
		 * @private
		 * Storage for the function used to calculate a node's weight.
		 */
		private var _weightFunction:Function;
		
	    [Bindable("weightFunctionChanged")]
	    /**
	     * A user-supplied function to run on each item to determine its weight.
	     *
		 * <p>The weight function takes one arguments, the item in the data provider.
		 * It returns a Number.
		 * <blockquote>
		 * <code>weightFunction(item:Object):Number</code>
		 * </blockquote></p>
	     */
	    public function get weightFunction():Function
	    {
	    	return this._weightFunction;
	    }
	    
	    /**
		 * @private
		 */
	    public function set weightFunction(value:Function):void
	    {
		    this._weightFunction = value;
		    this.invalidateProperties();
		    this.invalidateDisplayList();
	    	this.dispatchEvent(new Event("colorFunctionChanged"));
	    }
	    
	//-- Color
	    
		/**
		 * @private
		 * Storage for the field used to calculate a node's color.
		 */
		private var _colorField:String = "color";
		
	    [Bindable]
	    /**
	     * The name of the field in the data provider items to use as the color.
	     */
	    public function get colorField():String
	    {
	    	return this._colorField;
	    }
	    
	    /**
		 * @private
		 */
	    public function set colorField(value:String):void
	    {
	    	if(this._colorField != value)
	    	{
		    	this._colorField = value;
		    	this._nodesNeedRedraw = true;
		    	this.invalidateProperties();
			}
	    }
	    
		/**
		 * @private
		 * Storage for the function used to calculate a node's color.
		 */
		private var _colorFunction:Function;
		
	    [Bindable("colorFunctionChanged")]
	    /**
	     * A user-supplied function to run on each item to determine its color.
	     *
		 * <p>The color function takes one argument, the item in the data provider.
		 * It returns a uint.</p>
		 * 
		 * <blockquote>
		 * <code>colorFunction(item:Object):uint</code>
		 * </blockquote>
	     */
	    public function get colorFunction():Function
	    {
	    	return this._colorFunction;
	    }
	    
	    /**
		 * @private
		 */
	    public function set colorFunction(value:Function):void
	    {
			this._colorFunction = value;
			this._nodesNeedRedraw = true;
			this.invalidateProperties();
	    	this.dispatchEvent(new Event("colorFunctionChanged"));
	    }
	    
	//-- Label
	    
		/**
		 * @private
		 * Storage for the field used to calculate a node's label.
		 */
		private var _labelField:String = "label";
		
	    [Bindable]
	    /**
	     * The name of the field in the data provider items to display as the label
	     * of the data renderer. As a special case, if the nodes are <code>TreeMap</code>
	     * components, this function applies to the TreeMap label.
	     */
	    public function get labelField():String
	    {
	    	return this._labelField;
	    }
	    
	    /**
		 * @private
		 */
	    public function set labelField(value:String):void
	    {
	    	if(this._labelField != value)
	    	{
		    	this._labelField = value;
		    	this._nodesNeedRedraw = true;
		    	this.invalidateProperties();
		    }
	    }
	    
		/**
		 * @private
		 * Storage for the function used to calculate a node's label.
		 */
		private var _labelFunction:Function;
		
	    [Bindable("labelFunctionChanged")]
	    /**
	     * A user-supplied function to run on each item to determine its label.
	     *
		 * <p>The label function takes one argument, the item in the data provider.
		 * It returns a String.
		 * <blockquote>
		 * <code>labelFunction(item:Object):String</code>
		 * </blockquote></p>
	     */
	    public function get labelFunction():Function
	    {
	    	return this._labelFunction;
	    }
	    
	    /**
		 * @private
		 */
	    public function set labelFunction(value:Function):void
	    {
			this._labelFunction = value;
			this._nodesNeedRedraw = true;
			this.invalidateProperties();
	    	this.dispatchEvent(new Event("labelFunctionChanged"));
	    }
	    
	//-- ToolTip
	    
		/**
		 * @private
		 * Storage for the field used to calculate a node's tooltip.
		 */
		private var _toolTipField:String = "toolTip";
		
	    [Bindable]
	    /**
	     * The name of the field in the data provider items to display as the ToolTip
	     * of the data renderer.
	     */
	    public function get toolTipField():String
	    {
	    	return this._toolTipField;
	    }
		
	    /**
		 * @private
		 */
	    public function set toolTipField(value:String):void
	    {
	    	if(this._toolTipField != value)
	    	{
				this._toolTipField = value;
				this._nodesNeedRedraw = true;
				this.invalidateProperties();
			}
	    }
	    
		/**
		 * @private
		 * Storage for the function used to calculate a node's tooltip.
		 */
		private var _toolTipFunction:Function;
		
		[Bindable("toolTipFunctionChanged")]
	    /**
	     * A user-supplied function to run on each item to determine its ToolTip.
	     *
		 * <p>The tooltip function takes one argument, the item in the data provider.
		 * It returns a String.
		 * <blockquote>
		 * <code>toolTipFunction(item:Object):String</code>
		 * </blockquote></p>
	     */
	    public function get toolTipFunction():Function
	    {
	    	return this._toolTipFunction;
	    }
	    
	    /**
		 * @private
		 */
	    public function set toolTipFunction(value:Function):void
	    {
			this._toolTipFunction = value;
		    this._nodesNeedRedraw = true;
	    	this.invalidateProperties();
	    	
	    	this.dispatchEvent(new Event("toolTipFunctionChanged"));
	    }
		
	//-- Selection
	
		[Bindable]
		/**
		 * @private
		 * Storage for the selectable property.
		 */
		private var _selectable:Boolean = false;
		
	    /**
	     * Indicates if the node's within the TreeMap can be selected by the user.
		 */
		public function get selectable():Boolean
		{
			return this._selectable;
		}
		
	    /**
		 * @private
		 */
		public function set selectable(value:Boolean):void
		{
			if(this._selectable != value)
			{
				this._selectable = value;
				this.invalidateProperties();
			}
		}
	
		/**
		 * @private
		 * Storage for the selected property.
		 */
		private var _selected:Boolean = false;
		
	    /**
	     * If this TreeMap is a renderer for a parent TreeMap,
	     * it may be the selected node.
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
				this.invalidateProperties();
			}
		}
		
		/**
		 * @private
		 * Stores the node that is currently selected.
		 */
		private var _selectedNode:ITreeMapNodeRenderer;
		
		[Bindable("change")]
		/**
		 * The data for the currently selected node. May be the data for
		 * a grandchild or deeper ancestor.
		 */
		public function get selectedItem():Object
		{
			if(this._selectedNode is TreeMap)
			{
				return (this._selectedNode as TreeMap).selectedItem;
			}
			else if(this._selectedNode)
			{
				return this._selectedNode.data;
			}
			return null;
		}
		
	    /**
		 * @private
		 */
		public function set selectedItem(item:Object):void
		{
			var node:ITreeMapNodeRenderer = this.nodeDataToRenderer(item);
			this.selectNode(node);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Creates the zoomedIn state.
		 */
		override public function initialize():void
		{
			super.initialize();
			
			var zoomedIn:State = new State();
			zoomedIn.name = "zoomedIn";
			this.states.push(zoomedIn)
		}
	
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			super.styleChanged(styleProp);
			
			if(allStyles || styleProp == "borderSkin")
			{
				if(this.border)
				{
					this.removeChild(this.border as DisplayObject);
				}
				
				var borderSkin:Class = this.getStyle("borderSkin");
				if(borderSkin)
				{
					this.border = new borderSkin();
					if(this.border is ISimpleStyleClient)
					{
						(this.border as ISimpleStyleClient).styleName = this;
					}
					this.addChildAt(this.border as DisplayObject, 0);
				}
			}
			
			if(allStyles || styleProp == "headerStyleName")
			{
				if(this.header)
				{
					var headerStyleName:String = this.getStyle("headerStyleName");
					if(headerStyleName)
					{
						var headerStyleDecl:CSSStyleDeclaration = 
							StyleManager.getStyleDeclaration("." + headerStyleName);
						if(headerStyleDecl)
						{
							this.header.styleDeclaration = headerStyleDecl;
							this.header.regenerateStyleCache(true);
							this.header.styleChanged(null);
						}
					}
				}
			}
			
			if(allStyles || styleProp == "nodeStyleName")
			{
				var nodeStyleName:String = this.getStyle("nodeStyleName");
				var nodeCount:int = this.nodes.length;
				for(var i:int = 0; i < nodeCount; i++)
				{
					var currentNode:ITreeMapNodeRenderer = this.nodes[i] as ITreeMapNodeRenderer;
					
					//The style nodeStyleName doesn't apply to branches
					if(currentNode is ITreeMapBranchRenderer)
					{
						continue;
					}
					
					if(currentNode is ISimpleStyleClient)
					{
						(currentNode as ISimpleStyleClient).styleName = nodeStyleName;
					}
				}
			}
			
			if(allStyles || styleProp == "branchStyleName")
			{
				var branchStyleName:String = this.getStyle("branchStyleName");
				for(i = 0; i < this.nodes.length; i++)
				{
					var currentBranch:ITreeMapBranchRenderer = this.nodes[i] as ITreeMapBranchRenderer;
					
					//no need to check for null because null can't be an ISimpleStyleClient
					if(currentBranch is ISimpleStyleClient)
					{
						(currentBranch as ISimpleStyleClient).styleName = branchStyleName;
					}
				}
			}
		}
	
		/**
		 * Determines the label text for an item from the data provider.
		 */
		public function itemToLabel(item:Object):String
		{
			if(this.labelFunction != null)
			{
				return this.labelFunction(item);
			}
			else if(item.hasOwnProperty(this.labelField))
			{
				return item[this.labelField];
			}
			return null;
		}
	
		/**
		 * Determines the tooltip text for an item from the data provider.
		 */
		public function itemToToolTip(item:Object):String
		{
			if(this.toolTipFunction != null)
			{
				return this.toolTipFunction(item);
			}
			else if(item.hasOwnProperty(this.toolTipField))
			{
				return item[this.toolTipField];
			}
			return null;
		}
	
		/**
		 * Determines the color value for an item from the data provider.
		 */
		public function itemToColor(item:Object):uint
		{
			if(this.colorFunction != null)
			{
				return this.colorFunction(item);
			}
			else if(item.hasOwnProperty(this.colorField))
			{
				return item[this.colorField];
			}
			return 0x000000;
		}
	
		/**
		 * Determines the weight value for an item from the data provider.
		 */
		public function itemToWeight(item:Object):Number
		{
			var weight:Number = this._cachedWeights[item];
			if(isNaN(weight))
			{
				if(this.weightFunction != null)
				{
					weight = this.weightFunction(item);
				}
				else if(item.hasOwnProperty(this.weightField))
				{
					weight = item[this.weightField];
				}
				this._cachedWeights[item] = weight;
			}
			return weight;
		}
	    
	    /**
	     * Returns the node renderer that displays specific data.
	     * 
	     * @param data				the data for which to find a matching node renderer
	     * @return					the node renderer that matches the data
	     */
	    public function nodeDataToRenderer(data:Object):ITreeMapNodeRenderer
	    {
	    	var index:int = this._dataUIDs.indexOf(UIDUtil.getUID(data));
	    	if(index >= 0)
	    	{
	    		return this.nodes[index] as ITreeMapNodeRenderer;
	    	}
	    	
	    	var nodeCount:int = this.nodes.length;
	    	for(var i:int = 0; i < nodeCount; i++)
	    	{
	    		var node:ITreeMapNodeRenderer = this.nodes[i];
	    		if(node is ITreeMapBranchRenderer)
	    		{
	    			var renderer:ITreeMapNodeRenderer = (node as ITreeMapBranchRenderer).nodeDataToRenderer(data);
	    			if(renderer) return renderer;
	    		}
	    	}
	    	return null;
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
			
			if(!this.border)
			{
				var borderSkin:Class = this.getStyle("borderSkin");
				if(borderSkin)
				{
					this.border = new borderSkin();
					if(this.border is ISimpleStyleClient)
					{
						(this.border as ISimpleStyleClient).styleName = this;
					}
					this.addChildAt(this.border as DisplayObject, 0);
				}
			}
			
			if(!this.header)
			{
				this.header = new TreeMapHeader();
				this.addChild(this.header);
			}
			
			this.header.styleName = this;
			var headerStyleName:String = this.getStyle("headerStyleName");
			if(headerStyleName)
			{
				var headerStyleDecl:CSSStyleDeclaration = 
					StyleManager.getStyleDeclaration("." + headerStyleName);
				if(headerStyleDecl)
				{
					this.header.styleDeclaration = headerStyleDecl;
					this.header.regenerateStyleCache(true);
					this.header.styleChanged(null);
				}
			}
			this.header.visible = false;
			this.header.addEventListener(MouseEvent.CLICK, headerClickHandler, false, 0, true);
		}
	
		/**
		 * @private
		 * Create the renderers.
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			this._cachedWeights = new Dictionary(true);
			
			//remove the selected node before we handle the header selection!
			if(this.parent is ITreeMapNodeRenderer && !this.selected && this._selectedNode)
			{
				this._selectedNode.selected = false;
				this._selectedNode = null;
			}
			
			var startTime:int = flash.utils.getTimer();
			this.commitHeaderProperties();
			this.commitNodesAndBranches();
			trace((flash.utils.getTimer() - startTime), "ms");

			//move the header to the top child index
			this.setChildIndex(this.header, this.numChildren - 1);
				
			if(this.zoomedNode)
			{
				this.setChildIndex(this.zoomedNode as DisplayObject, this.numChildren - 1);
			}
			
		    this._nodesNeedRedraw = false;
			this._collectionChangedFlag = false;
		}
	
		/**
		 * @private
		 * Treemaps measure as the default size. The user or parent container
		 * will resize as needed.
		 */
		override protected function measure():void
		{
			super.measure();
			
			this.measuredWidth = DEFAULT_MEASURED_WIDTH;
			this.measuredHeight = DEFAULT_MEASURED_HEIGHT;
		}
	
		/**
		 * @private
		 * The layout strategy handles redrawing the nodes.
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(this.border)
			{
				this.border.setActualSize(unscaledWidth, unscaledHeight);
			}
			
			this.updateBackground();
			this.updateHeader();
			
			var startTime:int = flash.utils.getTimer();
			this._layoutStrategy.updateLayout(this);
			trace((flash.utils.getTimer() - startTime), "ms");
			
			if(this.zoomedNode)
			{
				this.zoomedNode.move(0, 0);
				this.zoomedNode.setActualSize(unscaledWidth, unscaledHeight);
			}
		}
		
		/**
		 * @private
		 */
		protected function requestZoom():void
		{
			this.zoomed = !this.zoomed;
			var zoomEvent:TreeMapEvent = new TreeMapEvent(TreeMapEvent.NODE_REQUEST_ZOOM, false, false, this);
			this.dispatchEvent(zoomEvent);
		}
		
		/**
		 * Selects a node.
		 */
		protected function selectNode(node:ITreeMapNodeRenderer):void
		{
			this._selectedNode = node;
			
			var nodeCount:int = this.nodes.length;
			for(var i:int = 0; i < nodeCount; i++)
			{
				var node:ITreeMapNodeRenderer = this.nodes[i] as ITreeMapNodeRenderer;
				node.selected = (node == this._selectedNode);
			}
			
			//dispatch the change event
			var changeEvent:Event = new Event(Event.CHANGE);
			this.dispatchEvent(changeEvent);	
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		private function commitHeaderProperties():void
		{
			if(!this._labelPropertySet && this.parent is ITreeMapBranchRenderer)
			{
				this._labelText = this.itemToLabel(this.data);
			}
			
			if(this._labelText)
			{
				this.header.label = this._labelText;
			}
			
			if(!this._toolTipPropertySet && this.parent is ITreeMapBranchRenderer)
			{
				this._headerToolTip = this.itemToToolTip(this.data);
			}
			
			if(this._headerToolTip)
			{
				this.header.toolTip = this._headerToolTip;
			}
			
			this.header.selected = this.selectable && (this.selected || this._selectedNode != null);
			this.header.visible = this.header.label.length > 0;
		}
		
		/**
		 * @private
		 * Iterate through the collection and add or remove nodes and branches as needed.
		 */
		private function commitNodesAndBranches():void
		{
			if(this._collectionChangedFlag) this._dataUIDs = [];
				
			var collectionIterator:IViewCursor = this.collection.createCursor();
			var nodeCount:int = 0;
			if(!collectionIterator.afterLast)
			{
			
				var nodeStyleName:String = this.getStyle("nodeStyleName");
				var branchStyleName:String = this.getStyle("branchStyleName");
				do
				{
					//get the current data and the current node. The node may not exist!
					var currentData:Object = collectionIterator.current;
					var currentNode:ITreeMapNodeRenderer = this.nodes[nodeCount];
					
					if(this.dataDescriptor.isBranch(currentData))
					{
						currentNode = this.updateBranch(currentNode, currentData);
						currentNode.styleName = branchStyleName;
					}
					else
					{
						currentNode = this.updateNode(currentNode, currentData);
						currentNode.styleName = nodeStyleName;
					}
					
					//generate a UID for the node's data so that we can get the node based on its data.
					if(this._collectionChangedFlag)
					{
						currentNode.data = currentData;
						if(currentNode is IDropInTreeMapNodeRenderer)
						{
							currentNode.treeMapData = this.generateTreeMapData(currentData);
						}
						this._dataUIDs.push(UIDUtil.getUID(currentData));
					}
					
					nodeCount++;
				}
				while(collectionIterator.moveNext());
			}
			//remove extra nodes if we have more nodes than there is items in the collection
			if(this.nodes.length > nodeCount)
			{
				var difference:int = this.nodes.length - nodeCount;
				for(var i:int = 0; i < difference; i++)
				{
					var lastNode:ITreeMapNodeRenderer = this.nodes[this.nodes.length - 1];
					this.removeNodeOrBranch(lastNode);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function updateBranch(node:ITreeMapNodeRenderer, data:Object):ITreeMapBranchRenderer
		{
			//make sure we're using the branch renderer
			if(!(node is this._branchRenderer.generator))
			{
				var index:int = this.nodes.length;
				if(node) index = this.removeNodeOrBranch(node);
				node = this.addBranch(index);
			}
			
			var branch:ITreeMapBranchRenderer = node as ITreeMapBranchRenderer;
			branch.labelField = this.labelField;
			branch.labelFunction = this.labelFunction;
			branch.toolTipField = this.toolTipField;
			branch.toolTipFunction = this.toolTipFunction;
			branch.weightField = this.weightField;
			branch.weightFunction = this.weightFunction;
			branch.colorField = this.colorField;
			branch.colorFunction = this.colorFunction;
				
			branch.nodeRenderer = this.nodeRenderer;
			branch.branchRenderer = this.branchRenderer;
				
			branch.layoutStrategy = this.layoutStrategy;
			branch.dataDescriptor = this.dataDescriptor;
			branch.selectable = this.selectable;
			branch.zoomOutType = this.zoomOutType;
			
			return branch;
		}
		
		private function updateNode(node:ITreeMapNodeRenderer, data:Object):ITreeMapNodeRenderer
		{
			if(!(node is this._nodeRenderer.generator))
			{
				var index:int = this.nodes.length;
				if(node) index = this.removeNodeOrBranch(node);
				node = this.addNode(index);
			}
			
			if(this._nodesNeedRedraw)
			{
				(node as UIComponent).invalidateProperties();
				(node as UIComponent).invalidateDisplayList();
			}
			
			return node;
		}
		
		/**
		 * @private
		 * Removes a node from the active listing and holds it in a cache for later use.
		 * @param nodeToRemove			an ITreeMapNodeRenderer to save in the pool
		 */
		private function removeNodeOrBranch(nodeToRemove:ITreeMapNodeRenderer):int
		{
	        DisplayObject(nodeToRemove).visible = false;
	        var index:int = this.nodes.indexOf(nodeToRemove);
			this.nodes.splice(index, 1);
	        
			if(nodeToRemove is ITreeMapBranchRenderer)
			{
				nodeToRemove.removeEventListener(TreeMapEvent.NODE_CLICK, childMapNodeClick);
				nodeToRemove.removeEventListener(TreeMapEvent.NODE_DOUBLE_CLICK, childMapNodeDoubleClick);
				nodeToRemove.removeEventListener(TreeMapEvent.NODE_ROLL_OVER, childMapNodeRollOver);
				nodeToRemove.removeEventListener(TreeMapEvent.NODE_ROLL_OUT, childMapNodeRollOut);	
				nodeToRemove.removeEventListener(TreeMapEvent.NODE_REQUEST_ZOOM, childMapNodeZoom);
				nodeToRemove.removeEventListener(Event.CHANGE, childMapSelectedNodeChange);
		        this._freeBranchRenderers.push(nodeToRemove);
			}
			else
			{
				nodeToRemove.removeEventListener(MouseEvent.CLICK, nodeClickHandler);
				nodeToRemove.removeEventListener(MouseEvent.DOUBLE_CLICK, nodeDoubleClickHandler);
				nodeToRemove.removeEventListener(MouseEvent.ROLL_OVER, nodeRollOverHandler);
				nodeToRemove.removeEventListener(MouseEvent.ROLL_OUT, nodeRollOutHandler);
		        this._freeNodeRenderers.push(nodeToRemove);
			}
			return index;
		}
		
		private function addNode(index:int):ITreeMapNodeRenderer
		{
			var nodeToAdd:ITreeMapNodeRenderer;
			if(this._freeNodeRenderers.length > 0)
			{
				nodeToAdd = this._freeNodeRenderers.pop();
		        DisplayObject(nodeToAdd).visible = true;
			}
			else
			{
				nodeToAdd = this._nodeRenderer.newInstance();
				this.addChild(nodeToAdd as DisplayObject);
			}
			
			nodeToAdd.addEventListener(MouseEvent.CLICK, nodeClickHandler, false, 0, true);
			nodeToAdd.addEventListener(MouseEvent.DOUBLE_CLICK, nodeDoubleClickHandler, false, 0, true);
			nodeToAdd.addEventListener(MouseEvent.ROLL_OVER, nodeRollOverHandler, false, 0, true);
			nodeToAdd.addEventListener(MouseEvent.ROLL_OUT, nodeRollOutHandler, false, 0, true);
			this.nodes.splice(index, 0, nodeToAdd);
			
			return nodeToAdd;
		}
		
		private function addBranch(index:int):ITreeMapBranchRenderer
		{
			var branchToAdd:ITreeMapBranchRenderer;
			if(this._freeBranchRenderers.length > 0)
			{
				branchToAdd = this._freeBranchRenderers.pop();
		        DisplayObject(branchToAdd).visible = true;
			}
			else
			{
				branchToAdd = this._branchRenderer.newInstance();
				this.addChild(branchToAdd as DisplayObject);
			}
			
			branchToAdd.addEventListener(TreeMapEvent.NODE_CLICK, childMapNodeClick, false, 0, true);
			branchToAdd.addEventListener(TreeMapEvent.NODE_DOUBLE_CLICK, childMapNodeDoubleClick, false, 0, true);
			branchToAdd.addEventListener(TreeMapEvent.NODE_ROLL_OVER, childMapNodeRollOver, false, 0, true);
			branchToAdd.addEventListener(TreeMapEvent.NODE_ROLL_OUT, childMapNodeRollOut, false, 0, true);
			branchToAdd.addEventListener(TreeMapEvent.NODE_REQUEST_ZOOM, childMapNodeZoom, false, 0, true);
			branchToAdd.addEventListener(Event.CHANGE, childMapSelectedNodeChange, false, 0, true);
			this.nodes.splice(index, 0, branchToAdd);
			
			return branchToAdd;
		}
		
		/**
		 * @private
		 */
		private function generateTreeMapData(data:Object):TreeMapNodeData
		{
			var label:String = this.itemToLabel(data);
			var weight:Number = this.itemToWeight(data);
			var color:uint = this.itemToColor(data);
			var toolTip:String = this.itemToToolTip(data);
			var uid:String = UIDUtil.getUID(data);
			return new TreeMapNodeData(label, weight, color, toolTip, uid, this);
		}
		
		/**
		 * @private
		 * Draws the background.
		 */
		private function updateBackground():void
		{
			var backgroundColor:uint = this.getStyle("backgroundColor");
			var backgroundAlpha:Number = this.getStyle("backgroundAlpha");
			
			this.graphics.clear();
			this.graphics.beginFill(backgroundColor, backgroundAlpha);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
		}
		
		/**
		 * @private
		 * Positions and sizes the header.
		 */
		private function updateHeader():void
		{
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			
			//include the border metrics
			if(this.border && this.border is RectangularBorder)
			{
				var rectBorder:RectangularBorder = this.border as RectangularBorder;
				paddingLeft += rectBorder.borderMetrics.left;
				paddingTop += rectBorder.borderMetrics.top;
				paddingRight += rectBorder.borderMetrics.right;
				paddingBottom += rectBorder.borderMetrics.bottom;
			}
			
			//this.header.move(paddingLeft, paddingTop);
			
			var headerWidth:Number = this.width;
			var headerHeight:Number = this.header.getExplicitOrMeasuredHeight();
			
			var minimumContentHeight:Number = 6;
			
			headerHeight = Math.min(headerHeight, unscaledHeight - (paddingTop + paddingBottom + minimumContentHeight));
			if(this.header.visible)
			{
				paddingTop += headerHeight;
			}
			
			this.contentBounds = new Rectangle(paddingLeft, paddingTop,
				unscaledWidth - (paddingLeft + paddingRight),
				unscaledHeight - (paddingTop + paddingBottom));
			
			this.header.setActualSize(headerWidth, headerHeight);
		}
		
		/**
		 * @private
		 * When the collection changes, we need to redraw.
		 */
		private function collectionChangeHandler(event:CollectionEvent):void
		{
			//we don't care about sorting or filters
			if(event.kind == CollectionEventKind.REFRESH) return;
			
			this._collectionChangedFlag = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Passes the node click event to external listeners.
		 */
		private function nodeClickHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapNodeRenderer = event.target as ITreeMapNodeRenderer;
			if(!renderer || renderer is ITreeMapBranchRenderer) return;
			
			if(this.selectable)
			{
				this.selectNode(renderer);
			}
			
			var click:TreeMapEvent = new TreeMapEvent(TreeMapEvent.NODE_CLICK, false, false, renderer);
			this.dispatchEvent(click);
		}
		
		/**
		 * @private
		 * Passes the node double click event to the outside world.
		 */
		private function nodeDoubleClickHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapNodeRenderer = event.target as ITreeMapNodeRenderer;
			if(!renderer || renderer is ITreeMapBranchRenderer) return;
			var doubleClick:TreeMapEvent = new TreeMapEvent(TreeMapEvent.NODE_DOUBLE_CLICK, false, false, renderer);
			this.dispatchEvent(doubleClick);
		}
		
		/**
		 * @private
		 * Passes the node roll over event to the outside world.
		 */
		private function nodeRollOverHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapNodeRenderer = event.target as ITreeMapNodeRenderer;
			if(!renderer || renderer is ITreeMapBranchRenderer) return;
			var rollOver:TreeMapEvent = new TreeMapEvent(TreeMapEvent.NODE_ROLL_OVER, false, false, renderer);
			this.dispatchEvent(rollOver);
		}
		
		/**
		 * @private
		 * Passes the node roll out event to the outside world.
		 */
		private function nodeRollOutHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapNodeRenderer = event.target as ITreeMapNodeRenderer;
			if(!renderer || renderer is ITreeMapBranchRenderer) return;
			var rollOut:TreeMapEvent = new TreeMapEvent(TreeMapEvent.NODE_ROLL_OUT, false, false, renderer);
			this.dispatchEvent(rollOut);
		}
		
		/**
		 * @private
		 * We're pretty much bubbling the click event, but it's more restricted.
		 */
		private function childMapNodeClick(event:TreeMapEvent):void
		{
			this.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * We're pretty much bubbling the double click event, but it's more restricted.
		 */
		private function childMapNodeDoubleClick(event:TreeMapEvent):void
		{
			this.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * We're pretty much bubbling the roll over event, but it's more restricted.
		 */
		private function childMapNodeRollOver(event:TreeMapEvent):void
		{
			this.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * We're pretty much bubbling the roll out event, but it's more restricted.
		 */
		private function childMapNodeRollOut(event:TreeMapEvent):void
		{
			this.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * Requests that this TreeMap be zoomed when the header is clicked.
		 */
		private function headerClickHandler(event:MouseEvent):void
		{
			this.requestZoom();
		}
		
		/**
		 * @private
		 * Handles a zoom request from a child treemap.
		 */
		private function childMapNodeZoom(event:TreeMapEvent):void
		{
			var nodeToZoom:ITreeMapNodeRenderer = event.target as ITreeMapNodeRenderer;
			if(this.zoomedNode != nodeToZoom) //request to zoom in
			{
				this.zoomedNode = nodeToZoom;
				if(!this.zoomed)
				{
					this.requestZoom();
				}
				//if we're already zoomed in
				else this._stopZoomOut = true;
				this.setChildIndex(this.zoomedNode as DisplayObject, this.numChildren - 1);
			}
			else //request to zoom out
			{
				this.zoomedNode = null;
				if(this._zoomOutType == TreeMapZoomOutType.FULL || 
					(this._zoomOutType == TreeMapZoomOutType.PREVIOUS && !this._stopZoomOut))
				{
					this.requestZoom();
				}
				this._stopZoomOut = false;
			}
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * If the selected node for a child TreeMap changes, select that child.
		 */
		private function childMapSelectedNodeChange(event:Event):void
		{
			var selectedBranch:ITreeMapBranchRenderer = event.target as ITreeMapBranchRenderer;
			this.selectNode(selectedBranch);
			
			if(!(this.parent is ITreeMapBranchRenderer))
				this.invalidateProperties();
		}
	}
}