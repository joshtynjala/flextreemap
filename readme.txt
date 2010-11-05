  __ _         _            _ _             
 / _| |_____ _| |_ ___  ___| | |__  _____ __
|  _| / -_) \ /  _/ _ \/ _ \ | '_ \/ _ \ \ /
|_| |_\___/_\_\\__\___/\___/_|_.__/\___/_\_\

TreeMap Component for Adobe Flex
Created by Josh Tynjala

---------------------------------------------------------------------------------
Links:
---------------------------------------------------------------------------------

Project Page:
   * http://github.com/joshtynjala/flextreemap
   
API Documentation:
   * http://www.flextoolbox.com/documentation/treemap/2/index.html

Mailing List:
	* http://groups.google.com/group/flextreemap

Author's Blog:
   * http://joshblog.net/

---------------------------------------------------------------------------------
Release Notes:
---------------------------------------------------------------------------------

Future Release
   * Fixed incorrect branch depth value.

October 15, 2010 - 2.2.0
   * Added StripLayout.
   * Fixed issue where border metrics and padding didn't combine.
   * Fixed bug where weightField and weightFunction changes at runtime
     would have no effect.
   * Fonts can now be embedded for leaf renderers.
   * Fixed bug where SquarifyLayout could get stuck in an infinite loop.
   * Now supports Flex 4.0.0. Minimum version is 3.5.0.

December 10, 2008 - 2.1.0
   * Reduced the number of display list manipulations in every redraw to
     improve performance.
   * Performance improvements in the skinning and font style code for
     TreeMapLeafRenderer.
   * Refactored SquarifyLayout to use a non-recursive algorithm. Now
     supports larger data sets.
   * Moved old implementation of SquarifyLayout to
     RecursiveSquarifyLayout class.
   * TreeMap now dispatches TreeMapEvent.BRANCH_ZOOM when the
     zoomedBranch property changes.
   * Added ASDoc comments where they were missing. Some branch and leaf
     renderer styles may not yet be documented.
   * The appearance of selected leaf nodes has been tweaked.
   * TreeMap now behaves correctly when enabled is set to false.
   * Added branchLabelField, branchLabelFunction, branchDataTipField,
     and branchDataTipFunction properties.
   * Requires at least Flex 3.2.0.

May 26, 2008 - 2.0.0
   * Many public APIs have been renamed to clarify purpose.
   * Refactored renderer and layout system to improve performance.
   * Special "lite" renderers are available to match classic treemap
     style.
   * Branches may be selected. See branchesAreSelectable property.
   * Header now includes a zoom button. Main header button controls
     selection.
   * Support for showRoot and hasRoot like Flex Tree.
   * Branch headers are now created with IFactory renderers and may be
     replaced.
   * Default branch header exposes zoom button.
   * Default branch header has resize transition to display truncated
     text.
   * Requires at least Flex 3.0.0.

January 21, 2008 - 1.0.1
   * Renamed the headerStyleName style to branchHeaderStyleName to avoid
     conflicts with other Flex components.
   * Updated build to use Flex SWCs external libraries to reduce build
     file size.

November 11, 2007 - 1.0.0
   * Initial Release for Flex 2.0.1