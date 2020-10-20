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
import gtk.ToolButton;
import gtk.ScrolledWindow;
import gtk.SeparatorToolItem;

import Connection;
import Channel;
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


        /* Set available button */
        ToolButton setAvail = new ToolButton("");
        setAvail.setLabel("available");
        setAvail.setIconName("user-available");
        toolbar.add(setAvail);

        /* Set away button */
        ToolButton setAway = new ToolButton("");
        setAway.setLabel("away");
        setAway.setIconName("user-away");
        toolbar.add(setAway);

        /* Set busy button */
        ToolButton setBusy = new ToolButton("");
        setBusy.setLabel("busy");
        setBusy.setIconName("user-busy");
        toolbar.add(setBusy);


        /* Assign actions */
        setAvail.addOnClicked(&setStatus);
        setAway.addOnClicked(&setStatus);
        setBusy.addOnClicked(&setStatus);

        /* Add a seperator */
        toolbar.add(new SeparatorToolItem());

        /* List channels button */
        ToolButton channelListButton = new ToolButton("");
        channelListButton.setIconName("emblem-documents");
        channelListButton.setTooltipText("List channels");
        channelListButton.addOnClicked(&listChannels);
        toolbar.add(channelListButton);

        return toolbar;
    }

    private void about(MenuItem)
    {
        import gtk.AboutDialog;
        AboutDialog about = new AboutDialog();

        about.setVersion("21893");

        /* TODO: License */
        /* TODO: Icon */
        /* TODO: Buttons or close */
        /* TODO: Set version based on compiler flag */

        about.setLogoIconName("user-available");
        about.setArtists(["i wonder if I could commision an artwork from her"]);

        /* Set all the information */
        about.setLicense("LICENSE GOES HERE");
        about.setComments("A clean GTK+ graphical DNET client");
        about.setWebsite("http://deavmi.assigned.network/docs/dnet/site");
        about.setDocumenters(["ss","fdsfsd"]);
        about.setAuthors(["Tristan B. Kildaire (Deavmi) - deavmi@disroot.org"]);

        /* Show the about dialog */
        about.showAll();
    }


    /**
    * List channels
    *
    * Brings up a window listing channels of the current server
    */
    private void listChannels(ToolButton)
    {
        import gtk.Window;

        /* Create the window */
        Window win = new Window(GtkWindowType.TOPLEVEL);

        /* Create the list of channels */
        ListBox channelsList = new ListBox();
        win.add(new ScrolledWindow(channelsList));

        /* Get the current connection */
        Connection currentConnection = connections[notebook.getCurrentPage()];

        /* Fetch the channels */
        string[] channels = currentConnection.getClient().list();

        /* Add each channel */
        foreach(string channel; channels)
        {
            channelsList.add(new Label(channel));
            channelsList.showAll();
        }

        /* TODO: Add handler for clicking label that lets you join the channel */
        channelsList.addOnSelectedRowsChanged(&selectChannel);

        win.showAll();
    }

    /**
    * Opens a new window for connecting to a server
    */
    private void connect(MenuItem)
    {
        import gtk.Window;

        /* Create the window */
        Window win = new Window(GtkWindowType.TOPLEVEL);

        
        //import gtk.Text

        

        win.showAll();
    }

    private void selectChannel(ListBox s)
    {
        /* Get the current connection */
        Connection currentConnection = connections[notebook.getCurrentPage()];

        /* Get the name of the channel selected */
        string channelSelected = (cast(Label)(s.getSelectedRow().getChild())).getText();

        /* Join the channel on this connection */
        currentConnection.joinChannel(channelSelected);
    }


    private void setStatus(ToolButton x)
    {
        /* Get the current connection */
        Connection currentConnection = connections[notebook.getCurrentPage()];

        /* Set the status */
        currentConnection.getClient().setStatus(x.getLabel()~",Hey there");
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

        /* Connect v2 option */
        MenuItem connectItem2 = new MenuItem();
        connectItem2.setLabel("Connect");
        connectItem2.addOnActivate(&connect);
        gustavMenu.add(connectItem2);

        

        /* Exit option */
        MenuItem exitItem = new MenuItem();
        exitItem.setLabel("Exit");
        exitItem.addOnActivate(&exitButton);
        gustavMenu.add(exitItem);


        /* Help menu */
        MenuItem helpMenuItem = new MenuItem();
        helpMenuItem.setLabel("Help");
        Menu helpMenu = new Menu();
        helpMenuItem.setSubmenu(helpMenu);

        /* About option */
        MenuItem aboutItem = new MenuItem();
        aboutItem.setLabel("About");
        aboutItem.addOnActivate(&about);
        helpMenu.add(aboutItem);

        

        

        /* Add all menues */
        menuBar.add(gustavMenuItem);
        menuBar.add(helpMenuItem);

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