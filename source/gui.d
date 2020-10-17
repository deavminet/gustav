module gui;

import core.thread;
import gtk.MainWindow;
import gtk.ListBox;
import gtk.Label;
import gtk.Notebook;
import gdk.Threads : te = threadsEnter, tl = threadsLeave;
import gtk.MenuBar;
import gtk.Box;
import gtk.Menu;
import gtk.MenuItem;
import std.stdio;

import Connection;
import std.socket;

public class GUI : Thread
{
    /* Main window (GUI homepage) */
    public MainWindow mainWindow;
    private MenuBar menuBar;
    public Notebook notebook;


    private Connection[] connections;

    private ListBox list;
    

    this()
    {
        super(&worker);
    }

    private void worker()
    {
        initializeGUI();
        te();

        tl();
        writeln("brg");
        while(true)
        {

        }
    }

    private void initializeGUI()
    {
        initializeMainWindow();

        /* Test adding a connection */
        for(uint i = 0; i < 5; i++)
        {
            connections ~= new Connection(this, parseAddress("0.0.0.0", 7777));
        }
        
        
    }

    /**
    * Initializes the main home screen window
    */
    private void initializeMainWindow()
    {
        /* Get GTK lock */
        te();

        /* Create a window */
        mainWindow = new MainWindow("unamed");

        /**
        * Create a Box in vertical layout mode
        * and adds it to the window
        *
        * This lays out components like so:
        *
        * |component 1|
        * |component 2|
        */
        Box box = new Box(GtkOrientation.VERTICAL, 1);

        /**
        * Add needed components
        *
        * Menubar, tabbed pane switcher, statusbar
        */
        menuBar = initializeMenuBar();
        box.add(menuBar);
        notebook = new Notebook();
        box.add(notebook);
        //notebook.add(createServerTab());




        /* Add the Box to main window */
        mainWindow.add(box);

        mainWindow.showAll();

        /* Unlock GTK lock */
        tl();

        writeln("unlock gui setup");
    }

    private MenuBar initializeMenuBar()
    {
        MenuBar menuBar = new MenuBar();

        /* Gustav menu */
        MenuItem gustavMenuItem = new MenuItem();
        gustavMenuItem.setLabel("Gustav");
        Menu gustavMenu = new Menu();
        gustavMenuItem.setSubmenu(gustavMenu);
        
        MenuItem exitItem = new MenuItem();
        exitItem.setLabel("Exit");
        exitItem.addOnActivate(&exitButton);
        gustavMenu.add(exitItem);

        

        /* Add all menues */
        menuBar.add(gustavMenuItem);

        return menuBar;
    }

    private void exitButton(MenuItem)
    {
        writeln("bruh");

        /* TODO: Implement exit */

        
// tl();
        //te();

        
        shutdownConnections();


       // mainWindow.showAll();

       // tl();
    }

    private void shutdownConnections()
    {
        foreach(Connection connection; connections)
        {
            /**
            * TODO: This is called by signal handler, we need no mutexes for signal handler
            * hence it means that connection
            */
            connection.shutdown();
            Thread.sleep(dur!("seconds")(2));
        }
    }

    private void newServer()
    {

    }

    private Box createServerTab()
    {
        Box serverTab = new Box(GtkOrientation.HORIZONTAL, 1);

        serverTab.add(new Label("hello"));

        // serverTab.add();

        return serverTab;
    }
}