package com.flextoolbox.events
{
	import flash.events.Event;

	public class TreeMapLayoutEvent extends Event
	{
		public static const BRANCH_LAYOUT_CHANGE:String = "branchLayoutChange";
		
		public function TreeMapLayoutEvent(type:String, branch:Object)
		{
			super(type);
			this.branch = branch;
		}
		
		public var branch:Object;
		
		override public function clone():Event
		{
			return new TreeMapLayoutEvent(this.type, this.branch);
		}
		
	}
}