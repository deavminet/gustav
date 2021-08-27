module ng.client;

import gtk.Main : Main;
import gdk.Threads : te = threadsEnter, tl = threadsLeave;
import gtk.MainWindow : MainWindow;


import gtk.MenuBar : MenuBar;
import gtk.MenuItem : MenuItem;
import gtk.Menu : Menu;


/**
* Gustav
*
* Represents an instance of the GUI
*/
public class Gustav
{
    private MainWindow window;
    private MenuBar menuBar;

    this()
    {
        /* Initialize libdnet API */
        initAPI();

        /* Initialize the GUI */
        initGUI();

        /* Loop */
        /* FIXME: Depending on how we setup lidbnet do something ehre that does something */

        run();
    }

    private void initAPI()
    {
        /* FIXME: Requires a working libdnet */
        /* FIXME: ABove requires eventy to be completed as well */
    }

    /**
    * Initializes the GUI
    *
    * 1. Initialize GTK's mutex's and event loop
    * 2. Furthermore call the builder functions
    *    to build the main window
    */
    private void initGUI()
    {
        initGTK();

        initMainWindow();
    }

    private void initGTK()
    {
        /* Initialize the framework with no arguments */
        string[] args;
        Main.initMultiThread(args);
    }

    /**
    * No need to call te, tl as the GUI is not yet running
    * hence no signal handlers that could manioulate GTK state
    * whilst we do potentially causing a race condition fault
    * to happen is possible
    */
    private void initMainWindow()
    {
        window = new MainWindow("Gustav");

        /**
        * Create a Box in vertical layout mode
        * and adds it to the window
        *
        * This lays out components like so:
        *
        * |Menu bar|
        * |Toolbar|
        * |ConnectionArea (tabbed)|
        * |Status bar|
        */
        import gtk.Box : Box, GtkOrientation;
        Box windowBox = new Box(GtkOrientation.VERTICAL, 1);

        

        /* Add Menu bar */
        menuBar = getMenuBar();
        windowBox.add(menuBar);



        /* Add Toolbar */

        /* Add ConnectionArea */
        // windowBox.add()

        // /* Add StatusBar */
        
        // import gtk.Label : Label;
        // Label lab = new Label("Poes");
        // windowBox.add(lab);

        window.add(windowBox);
        
        // windowBox.show();

        menuBar.show();
        // lab.show();

        window.show();
    }
    
    private MenuBar getMenuBar()
    {
        MenuBar menuBar = new MenuBar();

        /**
        * TODO
        *
        * Add menu item's:
        * Gustav
        *    Quit
        * etc
        */
        MenuItem gustavMenuItem = new MenuItem();
        gustavMenuItem.setLabel("Gustav");
        Menu gustavMenu = new Menu();
        gustavMenuItem.setSubmenu(gustavMenu);

        menuBar.add(gustavMenuItem);

        return menuBar;
    }

    private void run()
    {
        /* Start the event loop */
        Main.run();
    }
}