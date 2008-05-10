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
	import com.flextoolbox.events.TreeMapLayoutEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
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
	import mx.events.FlexEvent;
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
	 * Sets the style name for all leaf nodes.
	 */
	[Style(name="leafStyleName", type="String", inherit="no")]
	
	
	/**
	 * Sets the style name for all branch nodes.
	 */
	[Style(name="branchStyleName", type="String", inherit="no")]
	
	/**
	 * A treemap is a space-constrained visualization of hierarchical
	 * structures. It is very effective in showing attributes of leaf nodes
	 * using size and color coding.
	 * 
	 * @author Josh Tynjala
	 * @see http://code.google.com/p/flex2treemap/
	 * @see http://en.wikipedia.org/wiki/Treemapping
	 * @see http://www.cs.umd.edu/hcil/treemap-history/
	 * @includeExample examples/TreeMapExample.mxml
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
		
		/**
		 * @private
		 * Initializes the default style values.
		 */
		public static function initializeStyles():void
		{
			//TODO: add defaults that may be different than the framework's defaults
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TreeMap()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * @private
		 * Storage for the hasRoot property.
		 */
		private var _hasRoot:Boolean = false;
		
		/**
		 * Indicates that the current dataProvider has a root item; for example, 
		 * a single top node in a hierarchical structure. XML and Object 
		 * are examples of types that have a root. Lists and arrays do not.
		 * 
		 * @see #showRoot
		 */
		public function get hasRoot():Boolean
		{
			return this._hasRoot;
		}
		
		/**
		 * @private
		 * Storage for the showRoot property.
		 */
		private var _showRoot:Boolean = true;
		
		[Bindable]
		/**
		 * Sets the visibility of the root item.
		 *
		 * If the dataProvider data has a root node, and this is set to 
		 * <code>false</code>, the TreeMap control does not display the root item. 
		 * Only the decendants of the root item are displayed.  
		 * 
		 * This flag has no effect on non-rooted dataProviders, such as List and Array. 
		 *
		 * @default true
		 * @see #hasRoot
		 */
		public function get showRoot():Boolean
		{
			return this._showRoot;
		}
		
		/**
		 * @private
		 */
		public function set showRoot(value:Boolean):void
		{
			this._showRoot = value;
			
			this.dataProviderChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
	
		/**
		 * The root discovered from the data provider. May be the data provider
		 * itself, or its first and only child if that child is a branch.
		 */
		private var _discoveredRoot:Object = null;
		
		/**
		 * @private
		 * The visible root renderer isn't always the "discovered" root of the
		 * data provider. If the treemap is zoomed, it may be the zoomed branch
		 * instead. This is an optimization to minimize the number of required
		 * item renderers.
		 */
		private var _displayedRoot:Object = null;
	
		/**
		 * @private
		 * Flag indicating that a new data provider has been set
		 * or that the existing data provider has been modified.
		 */
		protected var dataProviderChanged:Boolean = false;
	
		/**
		 * @private
		 * Storage for the dataProvider property.
		 */
		private var _dataProvider:ICollectionView = new ArrayCollection();
	
		/**
		 * An object that contains the data to be displayed.
		 * When you assign a value to this property, the TreeMap class handles
		 * the source data object as follows:
		 * <p>
		 * <ul>
		 * 	<li>A String containing valid XML text is converted to an XMLListCollection.</li>
		 * 	<li>An XMLNode is converted to an XMLListCollection.</li>
		 * 	<li>An XMLList is converted to an XMLListCollection.</li>
		 * 	<li>Any object that implements the ICollectionView interface is cast to
		 *  an ICollectionView.</li>
		 * 	<li>An Array is converted to an ArrayCollection.</li>
		 * 	<li>Any other type object is wrapped in an Array with the object as its sole
		 *  entry.</li>
		 * </ul>
		 * </p>
		 *
		 *  @default an empty ArrayCollection
		 */
		public function get dataProvider():Object
		{
			return this._dataProvider;
		}
		
		/**
		 * @private
		 */
		public function set dataProvider(value:Object):void
		{
			if(this._dataProvider)
	        {
	        	this._dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
	        }
	
			//starting fresh with a new data provider
			this._hasRoot = false;
	
			//convert to data types that the treemap understands
	    	if(typeof(value) == "string")
	    	{
	    		//string becomes XML
	        	value = new XML(value);
	     	}
	        else if(value is XMLNode)
	        {
	        	//AS2-style XMLNodes become AS3 XML
				value = new XML(XMLNode(value).toString());
	        }
			else if(value is XMLList)
			{
				//XMLLists become XMLListCollections
				value = new XMLListCollection(value as XMLList);
			}
			else if(value is Array)
			{
				value = new ArrayCollection(value as Array);
			}
			
			if(value is XML)
			{
				this._hasRoot = true;
				var list:XMLList = new XMLList();
				list += value;
				this._dataProvider = new XMLListCollection(list);
			}
			//if already a collection dont make new one
	        else if(value is ICollectionView)
	        {
	            this._dataProvider = ICollectionView(value);
	    		if(this._dataProvider.length == 1 && !(this._dataProvider[0] is ICollectionView))
	    		{
	    			this._hasRoot = true;
	    		}
	        }
			else if(value is Object)
			{
				// convert to an array containing this one item
				this._hasRoot = true;
	    		this._dataProvider = new ArrayCollection( [value] );
	  		}
	  		else
	  		{
	  			this._dataProvider = new ArrayCollection();
	  		}
	
	        this._dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
	        this._dataProvider.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
	
			//it's a new data provider, so we can't have the same zoomed branch
			this.zoomedBranch = null;
	        
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the data descriptor used to crawl the data.
		 */
		private var _dataDescriptor:ITreeDataDescriptor = new DefaultDataDescriptor();
	
		[Bindable]
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
	    
	    [Bindable]
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
	    	this.invalidateProperties();
		    this.invalidateDisplayList();
	    }
	    
		/**
		 * @private
		 * Flag indicating that the leaf renderer type has changed.
		 */
		protected var leafRendererChanged:Boolean = false;
		
	    /**
	     * @private
	     * Storage for the leafRenderer property.
	     */
	    private var _leafRenderer:IFactory = new ClassFactory(TreeMapLeafRenderer);
	
		[Bindable]
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
		 * Flag indicating that the branch renderer type has changed.
		 */
		protected var branchRendererChanged:Boolean = false;
	
		/**
		 * @private
		 * Storage for the branchRenderer property.
		 */
		private var _branchRenderer:IFactory = new ClassFactory(TreeMapBranchRenderer);
		
		[Bindable]
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
		 * data provider may have an associated renderer.
		 */
		protected var leafRenderers:Array = [];
		
	    /**
		 * @private
		 * The complete collection of leaf renderers. Not every branch in the
		 * data provider may have an associated renderer.
		 */
		protected var branchRenderers:Array = [];
		
		/**
		 * @private
		 * Holds the leftover leaf renderers for reuse.
		 */
		private var _leafRendererCache:Array = [];
		
		/**
		 * @private
		 * Holds the leftover branch renderers for reuse.
		 */
		private var _branchRendererCache:Array = [];
		
		/**
		 * @private
		 * Hash to covert from an item's UID to the associated renderer.
		 */
		private var _uidToItemRenderer:Object;
	    
		/**
		 * @private
		 * Hash to convert from a UID to the children of a branch. We can't trust
		 * ICollectionView to return the same children every time.
		 */
	    private var _uidToChildren:Object;
	    
	    /**
	     * @private
	     * Hash to convert from a branch's UID to the depth of the branch.
	     */
	    private var _uidToDepth:Object;
	    
	//-- Weight
	
		/**
		 * @private
		 * A cache of weights for every item in the dataProvider. Performance boost.
		 */
		private var _uidToWeight:Object;
	
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
	
		/**
		 * @private
		 * Storage for the selectable property.
		 */
		private var _selectable:Boolean = false;
		
		[Bindable]
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
	
		/**
		 * @private
		 * Storage for the branchesSelectable property.
		 */
		private var _branchesSelectable:Boolean = false;
		
		[Bindable]
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
		
		[Bindable("valueCommit")]
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
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
	//-- ZOOMING
		
		/**
		 * @private
		 * Flag indicating if the zoomed branch has changed.
		 */
		protected var zoomChanged:Boolean = false;
		
		/**
		 * @private
		 * The branches that are currently zoomed. Null if none are zoomed.
		 */
		private var _zoomedBranches:Array = [];
		
		[Bindable("zoomChange")]
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
			else
			{
				this._zoomedBranches = [];
			}
			this.dispatchEvent(new Event("zoomChange"));
			this.zoomChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the zoomEnabled property.
		 */
		private var _zoomEnabled:Boolean = true;
		
		[Bindable]
		/**
		 * If true, branches may be zoomed in (maximized) to display in the full bounds of the treemap.
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
		
		[Bindable]
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
		private var _maxDepth:int = -1;
		
		[Bindable]
		/**
		 * If value is >= 0, the treemap will only render branches to a specific depth.
		 */
		public function get maxDepth():int
		{
			return this._maxDepth;
		}
		
		/**
		 * @private
		 */
		public function set maxDepth(value:int):void
		{
			this._maxDepth = value;
			this.zoomChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
		}
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
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
			if(item === null)
			{
				return 0;
			}
			
			var uid:String = this.itemToUID(item);
			var weight:Number = this._uidToWeight[uid];
			if(isNaN(weight))
			{
				//automatically determine branch weight from sum of children
				if(this.dataDescriptor.isBranch(item))
				{
					weight = 0;
					
					var children:ICollectionView = this.branchToChildren(item);
					var iterator:IViewCursor = children.createCursor();
					while(!iterator.afterLast)
					{
						var childItem:Object = iterator.current;
						weight += this.itemToWeight(childItem);
						iterator.moveNext();
					}
				}
				else if(this.weightFunction != null)
				{
					weight = this.weightFunction(item);
				}
				else if(item.hasOwnProperty(this.weightField))
				{
					weight = item[this.weightField];
				}
				else
				{
					weight = 0;
				}
				this._uidToWeight[uid] = weight;
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
	     * Determines if an item is the root node
	     * 
	     * @param item				the data for which to check against the root
	     * @return					true if the item is the root data, false if not
	     */
		public function itemIsRoot(item:Object):Boolean
		{
			return item == this._discoveredRoot;
		}
	
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "leafStyleName")
			{
				var leafStyleName:String = this.getStyle("leafStyleName");
				var leafRendererCount:int = this.leafRenderers.length;
				for(var i:int = 0; i < leafRendererCount; i++)
				{
					var leafRenderer:ITreeMapLeafRenderer = ITreeMapLeafRenderer(this.leafRenderers[i]);
					leafRenderer.styleName = leafStyleName;
				}
			}
			
			if(allStyles || styleProp == "branchStyleName")
			{
				var branchStyleName:String = this.getStyle("branchStyleName");
				var branchRendererCount:int = this.branchRenderers.length;
				for(i = 0; i < branchRendererCount; i++)
				{
					var branchRenderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(this.branchRenderers[i]);
					branchRenderer.styleName = branchStyleName;
				}
			}
		}
	
	//--------------------------------------
	//  Protected Methods
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
		 * @private
		 * Takes a branch and finds the saved data for its children.
		 */
		protected function branchToChildren(branch:Object):ICollectionView
		{
			var uid:String = this.itemToUID(branch) as String;
			return ICollectionView(this._uidToChildren[uid]);
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.dataProviderChanged)
			{
				this.initializeData();
			}
			
			//if something has changed in the data provider,
			//we need to update/create/destroy item renderers
			if(this._dataProvider.length > 0 &&
				(this.dataProviderChanged || this.zoomChanged || this.leafRendererChanged || this.branchRendererChanged))
			{
				this._displayedRoot = this._discoveredRoot;
				if(this.zoomedBranch)
				{
					this._displayedRoot = this.zoomedBranch;
				}
				this.createCache();
				this.rootBranchRenderer = this.getBranchRenderer();
				this.refreshBranchChildRenderers(this.rootBranchRenderer, this._displayedRoot, 0);
				this.clearCache();
			
				this.dataProviderChanged = false;
				this.zoomChanged = false;
			}
			
			if(this._dataProvider.length > 0)
			{
				this.commitBranchProperties(this._displayedRoot, 0);
			}

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
			
			var renderer:ITreeMapBranchRenderer = this.rootBranchRenderer;
			if(this.zoomedBranch)
			{
				//no need to draw nodes hidden behind the zoomed branch
				//they will be set invisible
				renderer = ITreeMapBranchRenderer(this.itemToItemRenderer(this.zoomedBranch));
			}
			
			if(renderer)
			{
				renderer.move(0, 0);
				renderer.setActualSize(unscaledWidth, unscaledHeight);
			}
		}
		
		/**
		 * @private
		 * Determines the true root of the tree and initializes the branch lookup.
		 */
		protected function initializeData():void
		{
			this._uidToChildren = {};
			this._uidToDepth = {};
			this._uidToWeight = {};
			
			//we want to find the root of the tree. it might be the data provider
			//but if the data provider has only a single child and that's a branch,
			//then the real root of the tree is that child branch
			this._discoveredRoot = this._dataProvider;
			if(this.hasRoot && this._dataProvider.length == 1)
			{
				var firstChild:Object = this._dataProvider[0];
				if(this.dataDescriptor.isBranch(firstChild))
				{
					this._discoveredRoot = firstChild;
				}
			}
			
			this.initializeBranch(this._discoveredRoot, 0);
		}
		
		/**
		 * @private
		 * Because the reference to the each data item may change every time we call getChildren(),
		 * we need to cache the values returned from getChildren() for lookup every time we loop
		 * through a branch's children.
		 */
		private function initializeBranch(branch:Object, depth:int):void
		{
			var uid:String = this.itemToUID(branch);
			var children:ICollectionView;
			if(branch is ICollectionView)
			{
				children = ICollectionView(branch);
			}
			else
			{
				children = this.dataDescriptor.getChildren(branch);
			}
			
			this._uidToChildren[uid] = children;
			this._uidToDepth[uid] = depth;
			
			var iterator:IViewCursor = children.createCursor();
			while(!iterator.afterLast)
			{
				var item:Object = iterator.current;
				if(this.dataDescriptor.isBranch(item))
				{
					this.initializeBranch(item, depth + 1);
				}
				iterator.moveNext();
			}
		}
		
		/**
		 * @private
		 * Creates caches to reuse leaf and branch renderers.
		 */
		protected function createCache():void
		{
			this._uidToItemRenderer = {};
			this.itemRenderers = [];
			
			this._leafRendererCache = this._leafRendererCache.concat(this.leafRenderers);
			if(this.leafRendererChanged)
			{
				//if we have a different leaf renderer, we need to start fresh
				this.clearLeafRendererCache();
			}
			this.leafRenderers = [];
			
			this._branchRendererCache = this._branchRendererCache.concat(this.branchRenderers);
			if(this.branchRendererChanged)
			{
				//if we have a new branch renderer, we need to start fresh
				this.clearBranchRendererCache();
			}
			this.branchRenderers = [];
	
			this.rootBranchRenderer = null;
		}
		
		/**
		 * @private
		 * Creates the child renderers of a branch and updates their data.
		 */
		protected function refreshBranchChildRenderers(renderer:ITreeMapBranchRenderer, branch:Object, zoomDepth:int):void
		{
			renderer.data = branch;
			
			var uid:String = this.itemToUID(branch);
			this._uidToItemRenderer[uid] = renderer;
			
			if(this.isMaxDepthActive())
			{
				zoomDepth++;
				if(zoomDepth > this.maxDepth)
				{
					return;
				}
			}
			var children:ICollectionView = this.branchToChildren(branch);
			if(!children)
			{
				return;
			}
			
			var iterator:IViewCursor = children.createCursor();
			while(!iterator.afterLast)
			{
				var item:Object = iterator.current;
				if(this.dataDescriptor.isBranch(item))
				{
					var childBranchRenderer:ITreeMapBranchRenderer = this.getBranchRenderer();
					this.refreshBranchChildRenderers(childBranchRenderer, item, zoomDepth);
				}
				else
				{
					var leafUID:String = this.itemToUID(item);
					var childLeafRenderer:ITreeMapLeafRenderer = this.getLeafRenderer();
					childLeafRenderer.data = item;
					this._uidToItemRenderer[leafUID] = childLeafRenderer;
				}
				
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
				renderer.styleName = this.getStyle("leafStyleName");
				renderer.addEventListener(MouseEvent.CLICK, leafClickHandler);
				renderer.addEventListener(MouseEvent.DOUBLE_CLICK, leafDoubleClickHandler);
				renderer.addEventListener(MouseEvent.ROLL_OVER, leafRollOverHandler);
				renderer.addEventListener(MouseEvent.ROLL_OUT, leafRollOutHandler);
				this.addChild(UIComponent(renderer));
			}
			
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
				renderer.styleName = this.getStyle("branchStyleName");
				this.addChild(UIComponent(renderer));
			}
			
			renderer.addEventListener(TreeMapEvent.BRANCH_ZOOM, branchZoomHandler);
			renderer.addEventListener(TreeMapEvent.BRANCH_SELECT, branchSelectHandler);
			renderer.addEventListener(TreeMapLayoutEvent.BRANCH_LAYOUT_CHANGE, branchLayoutChangeHandler);
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
			//optimization when maxDepth is defined. we keep renderers
			//around even if they aren't being used. saves display list
			//manipulations. if the data provider changes, then we start
			//from scratch because it could have been a major change
			if(this.isMaxDepthActive())
			{
				var itemCount:int = this._branchRendererCache.length;
				for(var i:int = 0; i < itemCount; i++)
				{
					var extraRenderer:UIComponent = UIComponent(this._branchRendererCache[i]);
					extraRenderer.removeEventListener(TreeMapEvent.BRANCH_ZOOM, branchZoomHandler);
					extraRenderer.removeEventListener(TreeMapEvent.BRANCH_SELECT, branchSelectHandler);
					extraRenderer.removeEventListener(TreeMapLayoutEvent.BRANCH_LAYOUT_CHANGE, branchLayoutChangeHandler);
					extraRenderer.visible = false;
				}
				
				itemCount = this._leafRendererCache.length;
				for(i = 0; i < itemCount; i++)
				{
					extraRenderer = UIComponent(this._leafRendererCache[i]);
					extraRenderer.visible = false;
				}
			}
			
			if(!this.dataProviderChanged)
			{
				return;
			}
			
			this.clearBranchRendererCache();
			this.clearLeafRendererCache();
		}
		
		/**
		 * @private
		 * Removes any remaining branch renderers that aren't being used.
		 */
		protected function clearBranchRendererCache():void
		{
			var itemCount:int = this._branchRendererCache.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var renderer:ITreeMapItemRenderer = ITreeMapItemRenderer(this._branchRendererCache.pop());
				renderer.removeEventListener(TreeMapEvent.BRANCH_ZOOM, branchZoomHandler);
				renderer.removeEventListener(TreeMapEvent.BRANCH_SELECT, branchSelectHandler);
				renderer.removeEventListener(TreeMapLayoutEvent.BRANCH_LAYOUT_CHANGE, branchLayoutChangeHandler);
				this.removeChild(UIComponent(renderer));
			}
		}
		
		/**
		 * @private
		 * Removes any remaining branch renderers that aren't being used.
		 */
		protected function clearLeafRendererCache():void
		{
			var itemCount:int = this._leafRendererCache.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var renderer:ITreeMapItemRenderer = ITreeMapItemRenderer(this._leafRendererCache.pop());
				renderer.removeEventListener(MouseEvent.CLICK, leafClickHandler);
				renderer.removeEventListener(MouseEvent.DOUBLE_CLICK, leafDoubleClickHandler);
				renderer.removeEventListener(MouseEvent.ROLL_OVER, leafRollOverHandler);
				renderer.removeEventListener(MouseEvent.ROLL_OUT, leafRollOutHandler);
				this.removeChild(UIComponent(renderer));
			}
		}
	
		/**
		 * @private
		 * Updates a branches properties.
		 */
		protected function commitBranchProperties(branch:Object, zoomDepth:int):void
		{
			var branchRenderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(this.itemToItemRenderer(branch));
			
			var branchData:TreeMapBranchData = new TreeMapBranchData(this);
			branchData.layoutStrategy = this.layoutStrategy;
			branchData.closed = this.isDepthClosed(zoomDepth);
			branchData.zoomed = branch == this.zoomedBranch;
			
			//only display a label on the branch renderer if it's not the root
			//or if the root is a true root and showRoot == true
			if(this.itemIsRoot(branch) && (!this.hasRoot || !this.showRoot))
			{
				branchData.displaySimple = true;
			}
			else
			{
				branchData.displaySimple = false;
			}
			
			var branchDepth:int = this._uidToDepth[branch];
			
			this.commitItemProperties(branch, branchData, branchDepth, zoomDepth);
			
			if(this.isMaxDepthActive())
			{
				zoomDepth++;
				if(zoomDepth > this.maxDepth)
				{
					return;
				}
			}
			this.commitBranchChildProperties(branch, branchData, branchDepth + 1, zoomDepth);
		}
	
		/**
		 * @private
		 * Loops through a branch's children and updates properties.
		 */
		protected function commitBranchChildProperties(branch:Object, branchData:TreeMapBranchData, depth:int, zoomDepth:int):void
		{
			var branchRenderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(this.itemToItemRenderer(branch));
			branchRenderer.removeAllItems(); //start fresh
			var children:ICollectionView = this.branchToChildren(branch);
			if(!children)
			{
				return;
			}
			var iterator:IViewCursor = children.createCursor();
			while(!iterator.afterLast)
			{
				var item:Object = iterator.current;
				if(this.dataDescriptor.isBranch(item))
				{
					this.commitBranchProperties(item, zoomDepth);
				}
				else
				{
					var leafData:TreeMapLeafData = new TreeMapLeafData(this);
					leafData.color = this.itemToColor(item);
					this.commitItemProperties(item, leafData, depth, zoomDepth);
				}
				
				var layoutData:TreeMapItemLayoutData = new TreeMapItemLayoutData(item);
				layoutData.weight = this.itemToWeight(item);
				branchRenderer.addItem(layoutData);
				
				iterator.moveNext();
			}
		}
	
		/**
		 * @private
		 * Updates the item's treeMapData. Sets visibility and depth.
		 */
		protected function commitItemProperties(item:Object, treeMapData:BaseTreeMapData, depth:int, zoomDepth:int):void
		{
			var uid:String = this.itemToUID(item);
			treeMapData.uid = uid;
			treeMapData.depth = depth;
			treeMapData.weight = this.itemToWeight(item);
			if(!(treeMapData is TreeMapBranchData) || !TreeMapBranchData(treeMapData).displaySimple)
			{
				treeMapData.label = this.itemToLabel(item);
				treeMapData.dataTip = this.itemToDataTip(item);
			}
			
			var renderer:ITreeMapItemRenderer = this.itemToItemRenderer(item);
			if(renderer is IDropInTreeMapItemRenderer)
			{
				IDropInTreeMapItemRenderer(renderer).treeMapData = treeMapData;
			}
			renderer.visible = this.isDepthVisible(zoomDepth);
			this.setChildIndex(UIComponent(renderer), this.numChildren - 1);
		}
		
		/**
		 * @private
		 * Determines if we need to account for max depth.
		 * Zoom must be enabled, and maxDepth must be set.
		 */
		protected function isMaxDepthActive():Boolean
		{
			return this.zoomEnabled && this.maxDepth >= 0;
		}
		
		/**
		 * @private
		 * Determines if an item renderer at the specified depth should be visible.
		 * It may exist, but be hidden due to zooming or maxDepth.
		 */
		protected function isDepthVisible(depth:int):Boolean
		{
			if(!this.isMaxDepthActive())
			{
				return true;
			}
			
			if(depth >= 0 && depth <= this.maxDepth)
			{
				return true;
			}
			
			return false;
		}
		
		/**
		 * @private
		 * Determines if a branch renderer at the specified depth should be closed.
		 */
		protected function isDepthClosed(depth:int):Boolean
		{
			if(!this.isMaxDepthActive())
			{
				return false;
			}
			
			if(depth < this.maxDepth)
			{
				return false;
			}
			
			return true; 
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
				renderer.selected = this.selectable && renderer.data === this._selectedItem;
				
				if(!renderer.selected && renderer is ITreeMapBranchRenderer)
				{
					renderer.selected = this.selectable && this.branchContainsChild(renderer.data, this._selectedItem);
				} 
			}
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
			//make sure we at least have a branch and that the child isn't null
			if(!childToFind || !dataDescriptor.isBranch(branch))
			{
				return false;
			}
			
			var children:ICollectionView = this.branchToChildren(branch);
			var iterator:IViewCursor = children.createCursor();
			while(!iterator.afterLast)
			{
				var child:Object = iterator.current;
				if(child === childToFind)
				{
					return true;
				}
				if(this.dataDescriptor.isBranch(child) && this.branchContainsChild(child, childToFind))
				{
					return true;
				}
				iterator.moveNext();
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
			this.dataProviderChanged = true;
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
				this.selectedItem = renderer.data;
				this.dispatchEvent(new Event(Event.CHANGE));
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
			if(!this.zoomEnabled)
			{
				return;
			}
			
			var renderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(event.target);
			
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
					{
						this._zoomedBranches.pop();
						break;
					}
					case TreeMapZoomOutType.PARENT:
					{
						var parentBranch:Object = this.getParentBranch(branchToZoom);
						if(parentBranch)
						{
							this._zoomedBranches = [parentBranch];
							break;
						}
						
						this._zoomedBranches = [];
						break;
					}
					default: //FULL
					{
						this._zoomedBranches = [];
						break;
					}
				}
			}
			
			this.dispatchEvent(new Event("zoomChange"));
			
			this.zoomChanged = true;
			this.invalidateProperties();
			this.invalidateDisplayList();
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
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		protected function branchLayoutChangeHandler(event:TreeMapLayoutEvent):void
		{
			var branchRenderer:ITreeMapBranchRenderer = ITreeMapBranchRenderer(event.target);
			
			var itemCount:int = branchRenderer.itemCount;
			for(var i:int = 0; i < itemCount; i++)
			{
				var itemLayoutData:TreeMapItemLayoutData = branchRenderer.getItemAt(i);
				var item:Object = itemLayoutData.data;
				
				//skip zoomed items because the treemap itself will draw and position them
				if(item != this.zoomedBranch)
				{
					var renderer:ITreeMapItemRenderer = this.itemToItemRenderer(item);
					renderer.move(itemLayoutData.x, itemLayoutData.y);
					renderer.setActualSize(Math.max(0, itemLayoutData.width), Math.max(0, itemLayoutData.height));
				}
			}
		}
	}
}