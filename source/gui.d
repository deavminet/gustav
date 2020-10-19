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
import gtk.Statusbar;
import gtk.Toolbar;

import Connection;
import std.socket;

import std.conv;

public class GUI : Thread
{
    /* Main window (GUI homepage) */
    public MainWindow mainWindow;
    private MenuBar menuBar;
    private Toolbar toolbar;
    public Notebook notebook;

    private Statusbar statusBar;


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
            // connections ~= new Connection(this, parseAddress("0.0.0.0", 7777));
        }

        connections ~= new Connection(this, parseAddress("0.0.0.0", 7777), ["testGustav"~to!(string)(connections.length), "bruh"]);
        
        
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

        toolbar = getToolbar();
        box.add(toolbar);

        notebook = new Notebook();
        notebook.setScrollable(true);
        box.add(notebook);
        statusBar = new Statusbar();
        statusBar.add(new Label("Gustav: Bruh"));
        box.setChildPacking(notebook, true, true, 0, GtkPackType.START);
        box.packEnd(statusBar, 0, 0, 0);
        //notebook.add(createServerTab());
        



        /* Add the Box to main window */
        mainWindow.add(box);

        mainWindow.showAll();

        /* Unlock GTK lock */
        tl();

        writeln("unlock gui setup");
    }

    private Toolbar getToolbar()
    {
        Toolbar toolbar = new Toolbar();

        /* Status selector dropdown */
        import gtk.ComboBox;
        import gtk.ToolButton;

        // Menu menu = new Menu();
        // menu.add(new MenuItem(""));
        ComboBox statusBox = new ComboBox();
        statusBox.setTitle("Status");


        ToolButton setAvail = new ToolButton("");
        setAvail.setLabel("available");
        setAvail.setIconName("user-available");
        toolbar.add(setAvail);

        ToolButton setAway = new ToolButton("");
        setAway.setLabel("away");
        setAway.setIconName("user-away");
        toolbar.add(setAway);

        ToolButton setBusy = new ToolButton("");
        setBusy.setLabel("busy");
        setBusy.setIconName("user-busy");
        toolbar.add(setBusy);


        setAvail.addOnClicked(&setStatus);
        setAway.addOnClicked(&setStatus);
        setBusy.addOnClicked(&setStatus);
        

        
        //toolbar.add(new ToolButton("user-available,""Available"));
        // toolbar.add(new ToolButton("Away"));
        // toolbar.add(new ToolButton("Busy"));
        // toolbar.add(new Label("Away"));
        // toolbar.add(new Label("Busy"));
        // import gtk.ToolItem;
        
        // ToolItem toolItem = new ToolItem();
        // toolItem.add(new Label("Available"));


        // statusBox.add()

        //toolbar.add(statusBox);

      

        return toolbar;
    }

    import gtk.ToolButton;
    private void setStatus(ToolButton x)
    {
        /* Get the current connection */
        Connection currentConnection = connections[notebook.getCurrentPage()];

        /* Set the status */
        currentConnection.getClient().setStatus(x.getLabel());
    }

    private MenuBar initializeMenuBar()
    {
        MenuBar menuBar = new MenuBar();

        /* Gustav menu */
        MenuItem gustavMenuItem = new MenuItem();
        gustavMenuItem.setLabel("Gustav");
        Menu gustavMenu = new Menu();
        gustavMenuItem.setSubmenu(gustavMenu);
        
        /* Connect option */
        MenuItem connectItem = new MenuItem();
        connectItem.setLabel("Connect");
        connectItem.addOnActivate(&connectButton);
        gustavMenu.add(connectItem);

        /* Exit option */
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

    private void connectButton(MenuItem)
    {
       connections ~= new Connection(this, parseAddress("0.0.0.0", 7777), ["testGustav"~to!(string)(connections.length), "bruh"]);
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