import std.stdio;

import gtk.Main;
import gtk.MainWindow;
import gtk.MenuBar;
import gtk.Statusbar;
import gtk.Grid;
import gtk.Label;
import gtk.MenuItem;
import gtk.Menu;
//import gio.MenuModel;
import gtk.ListBox;
import gtk.Box;
import gtk.Notebook;

import gdk.Threads : threadsEnter, threadsLeave;

import gtk.SelectionData;
import gtk.Widget;


void main()
{
	/* Initialize the framework with no arguments */
	string[] args;
	Main.initMultiThread(args);




	/* Start the event loop */
	Main.run();
}



