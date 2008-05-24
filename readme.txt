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
   * http://flex2treemap.googlecode.com/
   
API Documentation:
   * http://www.flextoolbox.com/documentation/treemap/2/index.html

Getting Started:
   * http://code.google.com/p/flex2treemap/wiki/GettingStarted

Author's Blog:
   * http://www.zeuslabs.us/

---------------------------------------------------------------------------------
Release Notes:
---------------------------------------------------------------------------------

05/26/2008 - 2.0.0 BETA
   * Many public APIs have been renamed to clarify purpose.
   * Refactored renderer and layout system to improve performance.
   * Special "lite" renderers are available to match classic treemap style.
   * Branches may be selected. See branchesAreSelectable property.
   * Header now includes a zoom button. Main header button controls selection.
   * Support for showRoot and hasRoot like Flex Tree.
   * Branch headers are now created with IFactory renderers and may be replaced.
   * Default branch header exposes zoom button.
   * Default branch header has resize transition to display truncated text.
   * Requires at least Flex 3.0.0.

01/21/2008 - 1.0.1
   * Renamed the headerStyleName style to branchHeaderStyleName to avoid conflicts
   * Updated build to use Flex SWCs external libraries to reduce build file size

11/11/2007 - 1.0.0
   * Initial Release for Flex 2.0.1