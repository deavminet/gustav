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

import gui;
import gdk.Threads : threadsEnter, threadsLeave;

import gtk.SelectionData;
import gtk.Widget;
void main()
{
	/* Initialize the framework with no arguments */
	string[] args;
	Main.initMultiThread(args);

// 	threadsEnter();

// 	/* Create the main window */
// 	MainWindow main = new MainWindow("unnamed");

	
	
// 	Box grid = new Box(GtkOrientation.VERTICAL, 1);

// 	MenuBar menu = new MenuBar();
	

// 	grid.add(menu);

// 	MenuItem fileMenu = new MenuItem("unamed");

// 	MenuItem thing1 = new MenuItem("poes");
// 	Menu bruh = new Menu();
// 	bruh.add(thing1);
// 	fileMenu.setSubmenu(bruh);

// menu.add(fileMenu);
// menu.add(new MenuItem("bruh"));


// 	/* Status bar */
// 	Statusbar statusBar = new Statusbar();

// 	statusBar.add(new Label("Gustav: Not connected"));
	
// 	grid.add(new Label("poo"));

// 	ListBox channels = new ListBox();

// 	Notebook tabs = new Notebook();
// 	tabs.add(channels);
// 	grid.add(tabs);

// 	grid.packEnd(statusBar, false, false, 0);
	
// 	Label k = new Label("dhjhfdjfhfjk");
// 	channels.add(k);

// 	main.add(grid);

// 	/* Display the window and all its components */
// 	main.showAll();

// 	k.setText("peoe");

// 	tabs.appendPage(new Label("lol"), "server2");

// 	main.showAll();

	

	GUI gui = new GUI();
	gui.start();


	/* Start the event loop */
	Main.run();
	

	
}



