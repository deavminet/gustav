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
import gtk.ToolItem;
import gtk.SearchEntry;
import gtk.Image;

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

    private Box box;
    private Box welcomeBox;

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
    }


    /**
    * The welcome box is shown before
    * you have added any connections
    * (it takes place of the Notebook)
    * and shows information about the
    * application
    *
    * Once you make your first conneciton
    * it is removed and its space is taken
    * up by the Notebook
    */
    private Box getWelcomeBox()
    {
        /* Create a vertically stacking Box */
        Box welcomeBox = new Box(GtkOrientation.VERTICAL, 1);

        /* Add the logo */
        Image logo = new Image("user-available", GtkIconSize.DIALOG);
        logo.setPixelSize(250);
        welcomeBox.add(logo);

        /* Create the welcome text */
        Label title = new Label("<span size=\"100\">Gustav</span>");
        title.setMarkup("<span font_desc=\"Open Sans Extrabold\" size=\"50000\">Gustav</span>");
        welcomeBox.add(title);

        /* Create the welcome tagline */
        Label tagline = new Label("<span size=\"100\">Gustav</span>");
        tagline.setMarkup("<span size=\"30000\">GTK+ graphical DNET client</span>");
        welcomeBox.add(tagline);

        Label findServersLabel = new Label("<a href=\"\">fok</a>");
        findServersLabel.setMarkup("<a href=\"\">Find some servers</a>");
        welcomeBox.add(findServersLabel);

        Label configureConnectionsLabel = new Label("<a href=\"\">Configure connections</a>");
        configureConnectionsLabel.setMarkup("<a href=\"\">Configure connections</a>");
        configureConnectionsLabel.addOnActivateLink(&conifgureConnectionsAssistant);
        welcomeBox.add(configureConnectionsLabel);

        Label connectGenesisLabel = new Label("<a href=\"\">Connect to the genesis server</a>");
        connectGenesisLabel.setMarkup("<span size=\"12000\"> <a href=\"\">Connect to the genesis server</a></span>");
        connectGenesisLabel.addOnActivateLink(&welcomeGenesisLabelClick);
        welcomeBox.add(connectGenesisLabel);

        

        return welcomeBox;
    }

    private bool welcomeGenesisLabelClick(string, Label)
    {
        connectServer("0.0.0.0", 7777);

        return 1;
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
        box = new Box(GtkOrientation.VERTICAL, 1);

        /**
        * Add needed components
        *
        * Menubar, tabbed pane switcher, statusbar
        */
        menuBar = initializeMenuBar();
        box.add(menuBar);

        toolbar = getToolbar();
        box.add(toolbar);

        /* Create the welcome box and set it */
        welcomeBox = getWelcomeBox();
        box.add(welcomeBox);
        
        
        
        statusBar = new Statusbar();
        statusBar.add(new Label("Gustav: Bruh"));
        // import gtk.IconView;
        // IconView j = new IconView();
        // j.set
        // statusBar.add(d);
        


        
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
        /* Create a new Toolbar */
        Toolbar toolbar = new Toolbar();

        /* Status selector dropdown */
        /* TODO */


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


        /* The status box */
        Entry statusBox = new Entry();
        statusBox.addOnActivate(&setStatusMessage);
        statusBox.setPlaceholderText("I'm currently...");
        ToolItem statusBoxItem = new ToolItem();
        statusBoxItem.add(statusBox);
        toolbar.add(statusBoxItem);


        /* Add a seperator */
        toolbar.add(new SeparatorToolItem());


        /* List channels button */
        ToolButton channelListButton = new ToolButton("");
        channelListButton.setIconName("emblem-documents");
        channelListButton.setTooltipText("List channels");
        channelListButton.addOnClicked(&listChannels);
        toolbar.add(channelListButton);


        


        SearchEntry dd = new SearchEntry();
        ToolItem j = new ToolItem();
        j.add(dd);
        toolbar.add(j);
        




        
        
       


        return toolbar;
    }

    import gtk.Entry;
    import std.string;
    private void setStatusMessage(Entry f)
    {
        /* Get the current connection */
        Connection currentConnection = connections[notebook.getCurrentPage()];

        /* Get the input text (removing leading and trailing whitespace) */
        string statusTextInput = f.getBuffer().getText();
        statusTextInput = strip(statusTextInput);

        /* Set the text box to the stripped version */
        //f.getBuffer().setText(statusTextInput, cast(int)statusTextInput.length);

        /* If the status text is empty */
        if(cmp(statusTextInput, "") == 0)
        {
            /* Delete the status property */
            currentConnection.getClient().deleteProperty("status");
        }
        /* If the status text is non empty */
        else
        {
            /* Set the status */
            currentConnection.getClient().setProperty("status", statusTextInput);
        }

        //f.setInputHints(GtkInputHints.)

        /* Defocus the currently focused widget which would always be me if you are hitting enter */
        mainWindow.setFocus(null);
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

    import gtk.Button;

    /**
    * Returns a Box which contains channel list item
    */

    private class JoinButton : Button
    {
        private string channelName;
        this(string channelName)
        {
            this.channelName = channelName;
        }
        public string getChannelName()
        {
            return channelName;
        }
    }
    private Box channelItemList(Connection currentConnection, string channelName)
    {
        /* Create the main container */
        Box containerMain = new Box(GtkOrientation.HORIZONTAL, 1);



        /* Add the channel label */
        Label channelLabel = new Label("");
        channelLabel.setHalign(GtkAlign.START);
        channelLabel.setMarkup("<b>"~channelName~"</b>");

        /* Add the member count */
        ulong memberCount = currentConnection.getClient().getMemberCount(channelName);
        Label memberCountLabel = new Label("");
        memberCountLabel.setHalign(GtkAlign.START);
        memberCountLabel.setText(to!(string)(memberCount)~" members");

        /* Create the channel box */
        Box channelBox = new Box(GtkOrientation.VERTICAL, 1);
        channelBox.add(channelLabel);
        channelBox.add(memberCountLabel);

        /* Join button */
        JoinButton joinButton = new JoinButton(channelName);
        joinButton.setLabel("Join");
        


        /* Add this then a button */
        containerMain.add(channelBox);
        containerMain.packEnd(joinButton,0,0,0);

        
        
        joinButton.addOnClicked(&selectChannel);

        

        /* TODO: COnsider adding member list */
        /* TODO: Seperate queue for dynamic updates to this list */
        containerMain.setTooltipMarkup("<b>"~channelName~"</b>\n"~to!(string)(memberCount)~" members\n\n"~to!(string)(currentConnection.getClient().getMembers(channelName)));

        return containerMain;
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
            // channelsList.add(new Label(channel));
            channelsList.add(channelItemList(currentConnection, channel));
            writeln("bruh: "~channel);
            channelsList.showAll();
        }

        /* TODO: Add handler for clicking label that lets you join the channel */
        // channelsList.addOnSelectedRowsChanged(&selectChannel);
        //channelsList.add


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

    private void selectChannel(Button s)
    {
        /* Get the current connection */
        Connection currentConnection = connections[notebook.getCurrentPage()];

        /* Get the name of the channel selected */
        string channelSelected = (cast(JoinButton)s).getChannelName(); //(cast(Label)(s.getSelectedRow().getChild())).getText();

        /* Join the channel on this connection */
        currentConnection.joinChannel(channelSelected);
    }

    private bool conifgureConnectionsAssistant(string, Label)
    {
        setupConnection();
        return 0;
    }


    private void setupConnection()
    {
        import gtk.Assistant;
        Assistant connectionAssistant = new Assistant();

        Label hello = new Label("");
        hello.setMarkup("<span size=\"15000\">Welcome to the connection setup</span>");
        connectionAssistant.insertPage(hello, 0);

        connectionAssistant.showAll();
    }


    private void setStatus(ToolButton x)
    {
        /* If there are any available connections */
        if(connections.length)
        {
            /* Get the current connection */
            Connection currentConnection = connections[notebook.getCurrentPage()];

            /* Set the status */
            currentConnection.getClient().setStatus(x.getLabel()~",Hey there"); /* TODO: Remove */
            currentConnection.getClient().setProperty("pres", x.getLabel());
            //currentConnection.getClient().setProperty("status", "is plikking");


            
        }
        /* If there are no connections */
        else
        {
            import gtk.MessageDialog;
            MessageDialog errorDialog = new MessageDialog(mainWindow, GtkDialogFlags.MODAL, GtkMessageType.ERROR, GtkButtonsType.CLOSE, false, "Cannot list channels\n\nYou are not connected to a server");
            errorDialog.setIconName("user-available");
            // errorDialog.set
            errorDialog.run();
        }
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
        connectServer("0.0.0.0", 7777);
    }

    /**
    * Connects to the provided server,
    * add the tab as well
    *
    * NOTE: To be called only by a GTK signal
    * handler
    */
    private void connectServer(string address, ushort port)
    {
        /**
        * If this is our first connection then
        * create a new Notebook which will
        * hold the connection/session tabs
        * and remove the welcome page
        */
        if(!notebook)
        {
            notebook = new Notebook();
            notebook.setScrollable(true);
            box.add(notebook);
            box.setChildPacking(notebook, true, true, 0, GtkPackType.START);
            box.remove(welcomeBox);
            box.showAll();
        }
       
        /* Create the new Connection */
        Connection newConnection = new Connection(this, parseAddress(address, port), ["testGustav"~to!(string)(connections.length), "bruh"]);
        connections ~= newConnection;

        // import UserDirectory;
        // UserDirectory d = new UserDirectory(newConnection);

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