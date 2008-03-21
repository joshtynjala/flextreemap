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

package com.flextoolbox.controls
{
	import com.flextoolbox.controls.treeMapClasses.*;
	import com.flextoolbox.events.TreeMapEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.utils.UIDUtil;

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
	 * Dispatched when the user rolls the mouse pointer over a leaf item in the control.
	 *
	 * @eventType com.flextoolbox.events.TreeMapEvent.LEAF_ROLL_OVER
	 */
	[Event(name="leafRollOver", type="com.flextoolbox.events.TreeMapEvent")]
	
	/**
	 * Dispatched when the user rolls the mouse pointer out of a leaf item in the control.
	 *
	 * @eventType com.flextoolbox.events.TreeMapEvent.LEAF_ROLL_OUT
	 */
	[Event(name="leafRollOut", type="com.flextoolbox.events.TreeMapEvent")]
	
	/**
	 * Dispatched when the user clicks on a leaf item in the control.
	 *
	 * @eventType com.flextoolbox.events.TreeMapEvent.LEAF_CLICK
	 */
	[Event(name="leafClick", type="com.flextoolbox.events.TreeMapEvent")]
	
	/**
	 * Dispatched when the user double-clicks on a leaf item in the control.
	 *
	 * @eventType com.flextoolbox.events.TreeMapEvent.LEAF_DOUBLE_CLICK
	 */
	[Event(name="leafDoubleClick", type="com.flextoolbox.events.TreeMapEvent")]

	//--------------------------------------
	//  Styles
	//--------------------------------------
	
include "../styles/metadata/TextStyles.inc"
	
	/**
	 * A treemap is a space-constrained visualization of hierarchical
	 * structures. It is very effective in showing attributes of leaf nodes
	 * using size and color coding.
	 * 
	 * @author Josh Tynjala
	 * @see http://code.google.com/p/flex2treemap/
	 * @see http://en.wikipedia.org/wiki/Treemapping
	 * @see http://www.cs.umd.edu/hcil/treemap-history/
	 */
	public class TreeMap extends UIComponent
	{
		
	//--------------------------------------
	//  Static Properties
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
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
		
		public static function initializeStyles():void
		{
			
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function TreeMap()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		private var _discoveredRoot:Object = null;
	
		protected var dataProviderInvalid:Boolean = false;
	
		private var _rootData:ICollectionView;
		private var _dataProvider:ICollectionView = new ArrayCollection();
	
		public function get dataProvider():Object
		{
			return this._dataProvider;
		}
		
		public function set dataProvider(value:Object):void
		{
			if(this._dataProvider)
	        {
	        	this._dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
	        }
	
			//handle strings and xml variants
	    	if(typeof(value) == "string")
	    	{
	        	value = new XML(value);
	     	}
	        else if(value is XMLNode)
	        {
				value = new XML(XMLNode(value).toString());
	        }
			else if(value is XMLList)
			{
				value = new XMLListCollection(value as XMLList);
			}
			
			if(value is XML)
			{
				var list:XMLList = new XMLList();
				list += value;
				this._dataProvider = new XMLListCollection(list);
			}
			//if already a collection dont make new one
	        else if(value is ICollectionView)
	        {
	            this._dataProvider = ICollectionView(value);
	        }
	        else if(value is Array)
	        {
	            this._dataProvider = new ArrayCollection(value as Array);
	        }
			//all other types get wrapped in an ArrayCollection
			else if(value is Object)
			{
				// convert to an array containing this one item
	    		this._dataProvider = new ArrayCollection( [value] );
	  		}
	  		else
	  		{
	  			this._dataProvider = new ArrayCollection();
	  		}
	
	        this._dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
	        this._dataProvider.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
	        
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
			return this._dataDescriptor;
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
			this._dataDescriptor = value;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		
		/**
		 * @private
		 * Storage for the strategy used for layout of nodes and branches.
		 */
		private var _layoutStrategy:ITreeMapLayoutStrategy = new SquarifyLayout();
	    
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
	    	this._layoutStrategy = strategy;
		    this.invalidateDisplayList();
	    }
	    
	    /**
	     * @private
	     * Storage for the leafRenderer property.
	     */
	    private var _leafRenderer:IFactory = new ClassFactory(LiteTreeMapLeafRenderer);
	
		protected var leafRendererChanged:Boolean = false;
	
	    /**
	     * The custom leaf renderer for the control.
	     * You can specify a drop-in, inline, or custom leaf renderer.
	     *
		 * <p>The default node renderer is TODO.</p>
	     */
	    public function get leafRenderer():IFactory
	    {
	        return _leafRenderer;
	    }
	
	    /**
		 * @private
		 */
	    public function set leafRenderer(value:IFactory):void
	    {
			this._leafRenderer = value;
	    	this.leafRendererChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
	    }
	
		/**
		 * @private
		 * Storage for the branchRenderer property.
		 */
		private var _branchRenderer:IFactory = new ClassFactory(TreeMapBranchRenderer);
		
		protected var branchRendererChanged:Boolean = false;
		
	    /**
	     * The custom branch renderer for the control. You can specify a drop-in,
	     * inline, or custom branch renderer. Unlike the renderers used by Tree
	     * components, nodes and branches in a TreeMap are quite different visually and
	     * functionally. As a result, it's easier to specify and customize seperate
	     * renderers for either type.
	     *
		 * <p>The default branch renderer is TreeMapBranchRenderer.</p>
	     */
	    public function get branchRenderer():IFactory
	    {
	        return this._branchRenderer;
	    }
	
	    /**
		 * @private
		 */
	    public function set branchRenderer(value:IFactory):void
	    {
			this._branchRenderer = value;
			this.branchRendererChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
	    }
		
	    /**
		 * @private
		 * The branch renderer for the root branch.
		 */
		protected var rootBranchRenderer:ITreeMapBranchRenderer;
		
	    /**
		 * @private
		 * The complete collection of item renderers, including branches and
		 * leaves. Not every item in the collection may have a renderer.
		 */
		protected var itemRenderers:Array = [];
		
	    /**
		 * @private
		 * The complete collection of leaf renderers. Not every leaf in the
		 * data provider may have a renderer.
		 */
		protected var leafRenderers:Array = [];
		
	    /**
		 * @private
		 * The complete collection of leaf renderers. Not every branch in the
		 * data provider may have a renderer.
		 */
		protected var branchRenderers:Array = [];
		
		/**
		 * @private
		 */
		private var _leafRendererCache:Array = [];
		
		/**
		 * @private
		 */
		private var _branchRendererCache:Array = [];
		
		/**
		 * @private
		 * Hash to covert from a UID to the renderer for an item.
		 */
		private var _uidToItemRenderer:Dictionary;
		
		/**
		 * @private
		 * Hash to convert from the raw data to the TreeMapData.
		 */
		private var _itemToTreeMapData:Dictionary;
	    
	//-- Weight
	
		/**
		 * @private
		 * A cache of weights for every item in the dataProvider. Performance boost.
		 */
		private var _cachedWeights:Dictionary;
	
		/**
		 * @private
		 * Storage for the field used to calculate a node's weight.
		 */
		private var _weightField:String = "weight";
		[Bindable("weightFieldChanged")]
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
	    	this._weightField = value;
	    	this.invalidateProperties();
	    	this.invalidateDisplayList();
	    	this.dispatchEvent(new Event("weightFieldChanged"));
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
	    	this.dispatchEvent(new Event("weightFunctionChanged"));
	    }
	    
	//-- Color
	    
		/**
		 * @private
		 * Storage for the field used to calculate a node's color.
		 */
		private var _colorField:String = "color";
		
	    [Bindable("colorFieldChanged")]
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
	    	this._colorField = value;
	    	this.invalidateProperties();
	    	this.dispatchEvent(new Event("colorFieldChanged"));
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
			this.invalidateProperties();
	    	this.dispatchEvent(new Event("colorFunctionChanged"));
	    }
	    
	//-- Label
	    
		/**
		 * @private
		 * Storage for the field used to calculate a node's label.
		 */
		private var _labelField:String = "label";
		
	    [Bindable("labelFieldChanged")]
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
	    	this._labelField = value;
	    	this.invalidateProperties();
	    	this.dispatchEvent(new Event("labelFieldChanged"));
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
			this.invalidateProperties();
	    	this.dispatchEvent(new Event("labelFunctionChanged"));
	    }
	    
	//-- ToolTip
	    
		/**
		 * @private
		 * Storage for the field used to calculate a node's datatip.
		 */
		private var _dataTipField:String = "dataTip";
		
	    [Bindable("dataTipFieldChanged")]
	    /**
	     * The name of the field in the data provider items to display as the datatip
	     * of the data renderer.
	     */
	    public function get dataTipField():String
	    {
	    	return this._dataTipField;
	    }
		
	    /**
		 * @private
		 */
	    public function set dataTipField(value:String):void
	    {
			this._dataTipField = value;
			this.invalidateProperties();
	    	this.dispatchEvent(new Event("dataTipFieldChanged"));
	    }
	    
		/**
		 * @private
		 * Storage for the function used to calculate a node's datatip.
		 */
		private var _dataTipFunction:Function;
		
		[Bindable("dataTipFunctionChanged")]
	    /**
	     * A user-supplied function to run on each item to determine its datatip.
	     *
		 * <p>The datatip function takes one argument, the item in the data provider.
		 * It returns a String.
		 * <blockquote>
		 * <code>dataTipFunction(item:Object):String</code>
		 * </blockquote></p>
	     */
	    public function get dataTipFunction():Function
	    {
	    	return this._dataTipFunction;
	    }
	    
	    /**
		 * @private
		 */
	    public function set dataTipFunction(value:Function):void
	    {
			this._dataTipFunction = value;
	    	this.invalidateProperties();
	    	this.dispatchEvent(new Event("dataTipFunctionChanged"));
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
			this._selectable = value;
			this.invalidateProperties();
		}
	
		[Bindable]
		/**
		 * @private
		 * Storage for the branchesSelectable property.
		 */
		private var _branchesSelectable:Boolean = false;
		
	    /**
	     * Indicates if the node's within the TreeMap can be selected by the user.
		 */
		public function get branchesSelectable():Boolean
		{
			return this._branchesSelectable;
		}
		
	    /**
		 * @private
		 */
		public function set branchesSelectable(value:Boolean):void
		{
			this._branchesSelectable = value;
			if(!branchesSelectable && this.dataDescriptor.isBranch(this.selectedItem))
			{
				this.selectedItem = null;
			}
		}
		
		/**
		 * @private
		 * Storage for the selectedItem property.
		 */
		private var _selectedItem:Object;
		
		[Bindable("change")]
		/**
		 * The currently selected item.
		 */
		public function get selectedItem():Object
		{
			return this._selectedItem;
		}
		
		/**
		 * @private
		 */
		public function set selectedItem(value:Object):void
		{
			this._selectedItem = value;
			if(!this.branchesSelectable && this.dataDescriptor.isBranch(value))
			{
				this._selectedItem = null;
			}
			this.invalidateProperties();
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
	//-- ZOOMING
		
		/**
		 * @private
		 * The branches that are currently zoomed. Null if none are zoomed.
		 */
		private var _zoomedBranches:Array = [];
		
		/**
		 * The currently zoomed branch.
		 */
		public function get zoomedBranch():Object
		{
			if(this._zoomedBranches.length > 0)
			{
				return this._zoomedBranches[this._zoomedBranches.length - 1];
			}
			return null;
		}
		
		/**
		 * @private
		 */
		public function set zoomedBranch(value:Object):void
		{
			if(value)
			{
				this._zoomedBranches = [value];
			}
			else this._zoomedBranches = [];
			this.invalidateProperties();
		}
		
		/**
		 * @private
		 * Storage for the zoomEnabled property.
		 */
		private var _zoomEnabled:Boolean = true;
		
		/**
		 * TODO: document
		 */
		public function get zoomEnabled():Boolean
		{
			return this._zoomEnabled;
		}
		
		/**
		 * @private
		 */
		public function set zoomEnabled(value:Boolean):void
		{
			this._zoomEnabled = value;
			this.invalidateProperties();
		}
		
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
			//doesn't immediately affect anything, so we
			//don't need to invalidate.
		}
		
		/**
		 * @private
		 * Storage for the maximumDepth property.
		 */
		private var _maximumDepth:int = -1;
		
		/**
		 * If value is >= 0, the treemap will only render branches to a specific depth.
		 */
		public function get maximumDepth():int
		{
			return this._maximumDepth;
		}
		
		/**
		 * @private
		 */
		public function set maximumDepth(value:int):void
		{
			this._maximumDepth = value;
			this.invalidateProperties();
		}
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * Determines the UID for a data provider item.  All items
		 * in a data provider must either have a unique ID (UID)
		 * or one will be generated and associated with it.  This
		 * means that you cannot have an object or scalar value
		 * appear twice in a data provider.  For example, the following
		 * data provider is not supported because the value "foo"
		 * appears twice and the UID for a string is the string itself
		 *
		 * <blockquote>
		 * 		<code>var sampleDP:Array = ["foo", "bar", "foo"]</code>
		 * </blockquote>
		 *
		 * Simple dynamic objects can appear twice if they are two
		 * separate instances.  The following is supported because
		 * each of the instances will be given a different UID because
		 * they are different objects.
		 *
		 * <blockquote>
		 * 		<code>var sampleDP:Array = [{label: "foo"}, {label: "foo"}]</code>
		 * </blockquote>
		 *
		 * Note that the following is not supported because the same instance
		 * appears twice.
		 *
		 * <blockquote>
		 * 		<code>var foo:Object = {label: "foo"};
		 * 		sampleDP:Array = [foo, foo];</code>
		 * </blockquote>
		 *
		 * @param item		The data provider item
		 *
		 * @return			The UID as a string
		 */
		protected function itemToUID(item:Object):String
		{
			if(!item)
			{
				return "null";
			}
			return UIDUtil.getUID(item);
		}
		/**
		 * Determines the label text for an item from the data provider.
		 * If no label is specfied, returns the result of the item's
		 * toString() method. If item is null, returns an empty string.
		 */
		public function itemToLabel(item:Object):String
		{
			if(item === null) return "";
			
			if(this.labelFunction != null)
			{
				return this.labelFunction(item);
			}
			else if(item.hasOwnProperty(this.labelField))
			{
				return item[this.labelField];
			}
			return item.toString();
		}
	
		/**
		 * Determines the datatip text for an item from the data provider.
		 * If no datatip is specified, returns an empty string.
		 */
		public function itemToDataTip(item:Object):String
		{
			if(item === null) return "";
			
			if(this.dataTipFunction != null)
			{
				return this.dataTipFunction(item);
			}
			else if(item.hasOwnProperty(this.dataTipField))
			{
				return item[this.dataTipField];
			}
			//normally, I'd do toString(), but I think an
			//empty string makes sense so that there's no dataTip.
			return "";
		}
	
		/**
		 * Determines the color value for an item from the data provider.
		 * If color not available, returns black (0x000000).
		 */
		public function itemToColor(item:Object):uint
		{
			if(item === null) return 0x000000;
			
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
			if(item === null) return 0;
			
			var weight:Number = this._cachedWeights[item];
			if(isNaN(weight))
			{
				//automatically determine branch weight from sum of children
				if(this.dataDescriptor.isBranch(item))
				{
					weight = 0;
					var iterator:IViewCursor = this.dataDescriptor.getChildren(item).createCursor();
					while(!iterator.afterLast)
					{
						weight += this.itemToWeight(iterator.current);
						iterator.moveNext();
					}
					return weight;
				}
				
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
	     * Returns the item renderer that displays specific data.
	     * 
	     * @param item				the data for which to find a matching item renderer
	     * @return					the item renderer that matches the data
	     */
	    public function itemToItemRenderer(item:Object):ITreeMapItemRenderer
	    {
	    	var uid:String = this.itemToUID(item);
	    	return this._uidToItemRenderer[uid];
	    }
	
		/**
		 * @private
		 * 
	     * Returns the TreeMapData object that matches an item from the data
	     * provider.
	     * 
	     * @param item				the data for which to find a matching TreeMapData
	     * @return					the TreeMapData object for the item
		 */
		protected function itemToTreeMapData(item:Object):BaseTreeMapData
		{
			return this._itemToTreeMapData[item];
		}
	
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			this._cachedWeights = new Dictionary(true);
			
			//if something has changed in the data provider,
			//we need to update/create/destroy item renderers
			if(this.dataProviderInvalid)
			{
				this._uidToItemRenderer = new Dictionary(true);
				this.createCache();
				this.refreshRenderers();
				this.clearCache();
				this.dataProviderInvalid = false;
			}
			
			this.commitRootDropInBranchData();
			
			this.commitZoom();
			this.commitSelection();
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			this.measuredWidth = DEFAULT_MEASURED_WIDTH;
			this.measuredHeight = DEFAULT_MEASURED_HEIGHT;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(this.rootBranchRenderer)
			{
				this.rootBranchRenderer.setActualSize(unscaledWidth, unscaledHeight);
			}
		}
		
		/**
		 * @private
		 * Creates caches to reuse leaf and branch renderers.
		 */
		protected function createCache():void
		{
			this.itemRenderers = [];
			
			if(!this.leafRendererChanged)
			{
				//reuse leaf renderers if the factory hasn't changed.
				this._leafRendererCache = this.leafRenderers.concat();
			}
			this.leafRenderers = [];
			
			if(!this.branchRendererChanged)
			{
				//reuse branch renderers if the factory hasn't changed.
				this._branchRendererCache = this.branchRenderers.concat();
			}
			this.rootBranchRenderer = null;
			this.branchRenderers = [];
		}
		
		/**
		 * @private
		 * Creates/updates the renderers and populates with new data.
		 */
		protected function refreshRenderers():void
		{
			if(!this.dataProvider)
			{
				return;
			}
			
			this._discoveredRoot = this.dataProvider;
			this._rootData = ICollectionView(this.dataProvider);
			
			//if we have only one item, and that item is a branch,
			//we're safe to make it the root
			if(this._rootData.length == 1)
			{
				var firstChild:Object = this._dataProvider[0];
				if(this.dataDescriptor.isBranch(firstChild))
				{
					this._discoveredRoot = firstChild;
					this._rootData = this.dataDescriptor.getChildren(firstChild);
				}
				else firstChild = null;
			}
			
			this.rootBranchRenderer = this.getBranchRenderer();
			this.commitBranchChildren(this._rootData, 0);
			
			this.rootBranchRenderer.data = this._rootData;
			var uid:String = this.itemToUID(this._rootData);
			this._uidToItemRenderer[uid] = this.rootBranchRenderer;
		}
		
		/**
		 * @private
		 * Creates the child renderers of a branch and updates their data.
		 */
		protected function commitBranchChildren(children:ICollectionView, depth:int):void
		{
			var iterator:IViewCursor = children.createCursor();
			while(!iterator.afterLast)
			{
				var item:Object = iterator.current;
				var childRenderer:ITreeMapItemRenderer;
				var treeMapData:BaseTreeMapData;
				if(this.dataDescriptor.isBranch(item))
				{
					childRenderer = this.getBranchRenderer();
					
					var branchChildren:ICollectionView = this.dataDescriptor.getChildren(item);
					this.commitBranchChildren(branchChildren, depth + 1);
				}
				else
				{
					childRenderer = this.getLeafRenderer();
				}
				
				var uid:String = this.itemToUID(item);
				this._uidToItemRenderer[uid] = childRenderer;
				childRenderer.data = item;
				
				iterator.moveNext();
			}
		}
	
		protected function commitRootDropInBranchData():void
		{
			this._itemToTreeMapData = new Dictionary(true);
			
			var branchData:TreeMapBranchData = new TreeMapBranchData(this);
			branchData.weight = this.itemToWeight(this._rootData);
			branchData.layoutStrategy = this.layoutStrategy;
			if(this._discoveredRoot != this._rootData)
			{
				//show a label only if we have a proper root
				branchData.label = this.itemToLabel(this._discoveredRoot);
				branchData.showLabel = true;
			}
			else
			{
				branchData.label = "";
				branchData.showLabel = false;
			}
			branchData.closed = this.isDepthClosed(0);
			
			branchData.uid = this.itemToUID(this._rootData);
			this._itemToTreeMapData[this._rootData] = branchData;
			
			if(this.rootBranchRenderer is IDropInTreeMapItemRenderer)
			{
				IDropInTreeMapItemRenderer(this.rootBranchRenderer).treeMapData = branchData;
			}
			
			this.commitDropInBranchData(branchData, this._rootData, 0);
		}
	
		protected function commitDropInBranchData(branchData:TreeMapBranchData, children:ICollectionView, depth:int):void
		{
			var iterator:IViewCursor = children.createCursor();
			var closed:Boolean = this.isDepthClosed(depth);
			while(!iterator.afterLast)
			{
				var item:Object = iterator.current;
				var uid:String = this.itemToUID(item);
				var renderer:ITreeMapItemRenderer = ITreeMapItemRenderer(this._uidToItemRenderer[uid]);
				
				var treeMapData:BaseTreeMapData;
				if(this.dataDescriptor.isBranch(item))
				{
					var childBranchData:TreeMapBranchData = new TreeMapBranchData(this);
					childBranchData.layoutStrategy = this.layoutStrategy;
					childBranchData.closed = closed || this.isDepthClosed(depth + 1);
					treeMapData = childBranchData;
					
					var childBranchChildren:ICollectionView = this.dataDescriptor.getChildren(item);
					this.commitDropInBranchData(childBranchData, childBranchChildren, depth + 1);
				}
				else
				{
					var leafData:TreeMapLeafData = new TreeMapLeafData(this);
					leafData.color = this.itemToColor(item);
					leafData.dataTip = this.itemToDataTip(item);
					treeMapData = leafData;
				}
				treeMapData.uid = uid;
				treeMapData.weight = this.itemToWeight(item);
				treeMapData.label = this.itemToLabel(item);
				if(renderer is IDropInTreeMapItemRenderer)
				{
					IDropInTreeMapItemRenderer(renderer).treeMapData = treeMapData;
				}
				this._itemToTreeMapData[item] = treeMapData;
				
				var layoutData:TreeMapItemLayoutData = new TreeMapItemLayoutData(item);
				layoutData.weight = treeMapData.weight;
				branchData.addItem(layoutData);
				
				iterator.moveNext();
			}
		}
	
		/**
		 * @private
		 * Gets either a cached leaf or a new instance of the leaf renderer.
		 */
		protected function getLeafRenderer():ITreeMapLeafRenderer
		{
			var renderer:ITreeMapLeafRenderer;
			if(this._leafRendererCache.length > 0)
			{
				renderer = ITreeMapLeafRenderer(this._leafRendererCache.shift());
			}
			else
			{
				renderer = ITreeMapLeafRenderer(this.leafRenderer.newInstance());
				renderer.addEventListener(MouseEvent.CLICK, leafClickHandler, false, 0, true);
				renderer.addEventListener(MouseEvent.DOUBLE_CLICK, leafDoubleClickHandler, false, 0, true);
				renderer.addEventListener(MouseEvent.ROLL_OVER, leafRollOverHandler, false, 0, true);
				renderer.addEventListener(MouseEvent.ROLL_OUT, leafRollOutHandler, false, 0, true);
				this.addChild(UIComponent(renderer));
			}
			
			this.setChildIndex(UIComponent(renderer), this.itemRenderers.length);
			this.leafRenderers.push(renderer);
			this.itemRenderers.push(renderer);
			return renderer;
		}
		
		/**
		 * @private
		 * Gets either a cached branch or a new instance of the branch renderer.
		 */
		protected function getBranchRenderer():ITreeMapBranchRenderer
		{
			var renderer:ITreeMapBranchRenderer;
			if(this._branchRendererCache.length > 0)
			{
				renderer = ITreeMapBranchRenderer(this._branchRendererCache.shift());
			}
			else
			{
				renderer = ITreeMapBranchRenderer(this.branchRenderer.newInstance());
				renderer.addEventListener(TreeMapEvent.BRANCH_ZOOM, branchZoomHandler, false, 0, true);
				renderer.addEventListener(TreeMapEvent.BRANCH_SELECT, branchSelectHandler, false, 0, true);
				this.addChild(UIComponent(renderer));
			}
			
			this.setChildIndex(UIComponent(renderer), this.itemRenderers.length);
			this.branchRenderers.push(renderer);
			this.itemRenderers.push(renderer);
			return renderer;
		}
		
		/**
		 * @private
		 * If any renderers are left in the caches, remove them.
		 */
		protected function clearCache():void
		{
			//remove branches from cache
			var itemCount:int = this._branchRendererCache.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var renderer:ITreeMapItemRenderer = ITreeMapItemRenderer(this._branchRendererCache.pop());
				renderer.removeEventListener(TreeMapEvent.BRANCH_ZOOM, branchZoomHandler);
				renderer.removeEventListener(TreeMapEvent.BRANCH_SELECT, branchSelectHandler);
				this.removeChild(UIComponent(renderer));
			}
			
			//remove leaves from cache
			itemCount = this._leafRendererCache.length;
			for(i = 0; i < itemCount; i++)
			{
				renderer = ITreeMapItemRenderer(this._leafRendererCache.pop());
				renderer.removeEventListener(MouseEvent.CLICK, leafClickHandler);
				renderer.removeEventListener(MouseEvent.DOUBLE_CLICK, leafDoubleClickHandler);
				renderer.removeEventListener(MouseEvent.ROLL_OVER, leafRollOverHandler);
				renderer.removeEventListener(MouseEvent.ROLL_OUT, leafRollOutHandler);
				this.removeChild(UIComponent(renderer));
			}
		}
		
		/**
		 * @private
		 * Handles the display of the zoomed renderer.
		 */
		protected function commitZoom():void
		{
			if(!this.zoomedBranch) return;
			this.updateDepthsForZoomedBranch(this.zoomedBranch, 0);
		}
		
		/**
		 * @private
		 * Puts a branch and all of its children at the highest depths
		 * so that they may be zoomed.
		 */
		protected function updateDepthsForZoomedBranch(branch:Object, depth:int):void
		{
			var closed:Boolean = this.isDepthClosed(depth);
			
			var branchRenderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(this.itemToItemRenderer(branch));
			this.setChildIndex(UIComponent(branchRenderer), this.numChildren - 1);
			
			var branchData:TreeMapBranchData = TreeMapBranchData(this.itemToTreeMapData(branch));
			branchData.closed = closed;
			branchData.zoomed = true;
			
			if(branchRenderer is IDropInTreeMapItemRenderer)
			{
				//refresh with new closed state
				IDropInTreeMapItemRenderer(branchRenderer).treeMapData = branchData;
			}
			
			var childCount:int = branchData.itemCount;
			for(var i:int = 0; i < childCount; i++)
			{
				var child:Object = branchData.getItemAt(i).item;
				var childRenderer:ITreeMapItemRenderer = this.itemToItemRenderer(child);
				if(this.dataDescriptor.isBranch(child))
				{
					this.updateDepthsForZoomedBranch(child, depth + 1);
				}
				else if(!branchData.closed)
				{
					this.setChildIndex(UIComponent(childRenderer), this.numChildren - 1);
				} 
				childRenderer.visible = !closed;
			}
		}
		
		protected function isDepthClosed(depth:int):Boolean
		{
			return this.maximumDepth >= 0 && depth >= this.maximumDepth;
		}
		
		/**
		 * @private
		 * Sets the correct renderer to the selected state and removes selection
		 * from any others.
		 */
		protected function commitSelection():void
		{	
			var itemRendererCount:int = this.itemRenderers.length;
			for(var i:int = 0; i < itemRendererCount; i++)
			{
				var renderer:ITreeMapItemRenderer = ITreeMapItemRenderer(this.itemRenderers[i]);
				renderer.selected = this.selectable && renderer.data == this._selectedItem;
				
				if(!renderer.selected && renderer is ITreeMapBranchRenderer)
				{
					renderer.selected = this.selectable && this.branchContainsChild(renderer.data, this._selectedItem);
				} 
			}
		}
		
		/**
		 * @private
		 * Determines if a particular branch is the root of the TreeMap
		 */
		protected function isRootBranch(branch:Object):Boolean
		{
			return branch == this._rootData;
		}
		
		/**
		 * @private
		 * Determines the immediate parent branch for a given leaf.
		 */
		protected function getParentBranch(item:Object):Object
		{
			//use the stored item renderers to find the correct item
			var renderer:ITreeMapItemRenderer = this.itemToItemRenderer(item);
			var index:int = this.itemRenderers.indexOf(renderer);
			for(var i:int = index - 1; i >= 0; i--)
			{
				//we know the order in this.itemRenderers, so we can "cheat"
				var parentRenderer:ITreeMapBranchRenderer = this.itemRenderers[i] as ITreeMapBranchRenderer;
				if(parentRenderer && this.branchContainsChild(parentRenderer.data, item))
				{
					return parentRenderer.data;
				}
			}
			return null;
		}
	
		/**
		 * @private
		 * Determines if a branch contains a given leaf.
		 */
		protected function branchContainsChild(branch:Object, childToFind:Object):Boolean
		{
			//make sure we at least have a branch
			if(!dataDescriptor.isBranch(branch))
			{
				return false;
			}
			
			var treeMapBranchData:TreeMapBranchData = TreeMapBranchData(this.itemToTreeMapData(branch));
			var itemCount:int = treeMapBranchData.itemCount;
			for(var i:int = 0; i < itemCount; i++)
			{
				var child:Object = treeMapBranchData.getItemAt(i).item;
				if(child == childToFind) return true;
				if(this.dataDescriptor.isBranch(child) && this.branchContainsChild(child, childToFind))
				{
					return true;
				}
			}
			return false;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Refreshes the view if the dataProvider changes.
		 */
		protected function collectionChangeHandler(event:CollectionEvent):void
		{
			this.dataProviderInvalid = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Handles the clicking of a leaf. If selection is enabled, updates
		 * the selectedItem.
		 */
		protected function leafClickHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapLeafRenderer = ITreeMapLeafRenderer(event.currentTarget);
			var leafEvent:TreeMapEvent = new TreeMapEvent(TreeMapEvent.LEAF_CLICK, renderer);
			this.dispatchEvent(leafEvent);
			
			if(this._selectable)
			{
				this._selectedItem = renderer.data;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 */
		protected function leafDoubleClickHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapLeafRenderer = ITreeMapLeafRenderer(event.currentTarget);
			var leafEvent:TreeMapEvent = new TreeMapEvent(TreeMapEvent.LEAF_DOUBLE_CLICK, renderer);
			this.dispatchEvent(leafEvent);
		}
		
		/**
		 * @private
		 */
		protected function leafRollOverHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapLeafRenderer = ITreeMapLeafRenderer(event.currentTarget);
			var leafEvent:TreeMapEvent = new TreeMapEvent(TreeMapEvent.LEAF_ROLL_OVER, renderer);
			this.dispatchEvent(leafEvent);
		}
		
		/**
		 * @private
		 */
		protected function leafRollOutHandler(event:MouseEvent):void
		{
			var renderer:ITreeMapLeafRenderer = ITreeMapLeafRenderer(event.currentTarget);
			var leafEvent:TreeMapEvent = new TreeMapEvent(TreeMapEvent.LEAF_ROLL_OUT, renderer);
			this.dispatchEvent(leafEvent);
		}
		
		/**
		 * @private
		 * Handles a zoom request from a branch.
		 */
		protected function branchZoomHandler(event:TreeMapEvent):void
		{
			if(event.target != event.currentTarget) return;
			var renderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(event.target);
			
			//ignore the root renderer
			if(renderer == this.rootBranchRenderer) return;
			
			var oldZoomedBranch:Object = this.zoomedBranch;
			
			var branchToZoom:Object = renderer.data;
			if(this.zoomedBranch != branchToZoom) //zoom in
			{
				if(this.zoomOutType == TreeMapZoomOutType.PREVIOUS)
				{
					this._zoomedBranches.push(branchToZoom);
				}
				else this._zoomedBranches = [branchToZoom];
			}
			else //zoom out
			{
				switch(this.zoomOutType)
				{
					case TreeMapZoomOutType.PREVIOUS:
						this._zoomedBranches.pop();
						break;
					case TreeMapZoomOutType.PARENT:
						var parentBranch:Object = this.getParentBranch(branchToZoom);
						if(parentBranch)
						{
							this._zoomedBranches = [parentBranch];
							break;
						}
					default: //FULL
						this._zoomedBranches = [];
						break;
				}
			}
			
			if(this.zoomedBranch) //we have a new zoomed branch
			{
				if(!this.isRootBranch(this.zoomedBranch))
				{
					parentBranch = this.getParentBranch(this.zoomedBranch);
					this.itemToItemRenderer(parentBranch).invalidateDisplayList();
				}
				else this.rootBranchRenderer.invalidateDisplayList();
				this.itemToItemRenderer(this.zoomedBranch).invalidateDisplayList();
			} 
			else //we need to zoom out
			{
				//make sure we aren't getting null or the main data provider
				while(oldZoomedBranch && !isRootBranch(oldZoomedBranch))
				{
					oldZoomedBranch = this.getParentBranch(oldZoomedBranch)
					this.itemToItemRenderer(oldZoomedBranch).invalidateDisplayList();
				}
			}
			
			this.invalidateProperties();
		}
	
		/**
		 * @private
		 * Handles a selection request from a branch.
		 */
		protected function branchSelectHandler(event:TreeMapEvent):void
		{
			if(this.branchesSelectable)
			{
				this.selectedItem = ITreeMapBranchRenderer(event.target).data;
			}
		}
	}
}