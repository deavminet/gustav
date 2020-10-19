module Connection;

import core.thread;
import gui;
import gdk.Threads : te = threadsEnter, tl = threadsLeave;
import gtk.Box;
import std.stdio;
import libdnet.dclient;
import std.socket;
import gtk.ListBox;
import gtk.Label;

import Channel;
import std.string;

import core.sync.mutex;

import gtk.Notebook;

public final class Connection : Thread
{
    private GUI gui;
    private Box box;
    private ListBox channels;
    private ListBox users;
    private ListBox textArea;

    private DClient client;
    private Address address;
    private string[] auth;
    private string statusText;

    /* TODO: Check if we need to protect */
    /* TODO: So far usage is in signal handlers (mutex safved) and within te-tl lock for notifications */
    private string currentChannel; /* TODO: Used to track what notificaitons come throug */
    private Label currentChannelLabel; /* TODO: Using getChild would be nicer, but yeah, this is for the title */

    /**
    * All joined Channel-s in this Connection 
    */
    private Notebook notebookSwitcher;
    private Channel[] chans; /*TODO: Technically locking by GTK would make this not needed */
    private Mutex chansLock;
    private Channel focusedChan;


    // public void setPrescence(string pres)
    // {
    //     /* The new status */
    //     string newStatus = 
    //     statusText = "";
    //     statusText = 
    // }

    this(GUI gui, Address address, string[] auth)
    {
        super(&worker);
        this.gui = gui;
        this.address = address;
        this.auth = auth;

        /* Initialize locks */
        initializeLocks();

        statusText = "Hey there, I'm using Dnet!";

        /* Start the notification atcher */
        start();
    }

    /**
    * Initializes all locks (other than GDK)
    */
    private void initializeLocks()
    {
        chansLock =  new Mutex();
    }

    private void worker()
    {
        /* Create a new Label */
        currentChannelLabel = new Label("CHANNEL NAME GOES HERE");

        /**
        * Setup the tab for this connection
        */
        te();
        box = getChatPane();
        gui.notebook.add(box);
        gui.notebook.setTabReorderable(box, true);
        //gui.notebook    setChildPacking(box, true, true, 0, GtkPackType.START);
       // gui.mainWindow.
        gui.notebook.setTabLabelText(box, auth[0]~"@"~address.toString());
        gui.notebook.showAll();
        tl();


        /**
        * Connects and logs in
        */
        client = new DClient(address);
        client.auth(auth[0], auth[1]); /* TODO: DO this without auth (the list in the loop, crahses server) */

        /* Display all channels */
        //channelList();

        /**
        * Notification loop
        *
        * Awaits notifications and then displays them
        */
        while(true)
        {
            /* Receive a notification */
            byte[] notificationData = client.awaitNotification();
            writeln(notificationData);

            te();
            // import std.conv;
            // textArea.add(new Label(to!(string)(notificationData)));
            // textArea.showAll();
            

            process(notificationData);
            //gui.mainWindow.showAll();

            notebookSwitcher.showAll();
            

            tl();

            //Thread.sleep(dur!("seconds")(2));
        }
    }

    

	/**
	* Processes an incoming notification
	* accordingly
	*/
	private void process(byte[] data)
	{
		/* TODO: Implement me */

		/* TODO: Check notification type */
		ubyte notificationType = data[0];

		/* For normal message (to channel or user) */
		if(notificationType == 0)
		{
			/* TODO: Decode using tristanable */
			writeln("new message");
		}
		/* Channel notification (ntype=1) */
		else if(notificationType == 1)
		{
			/* Get the sub-type */
			ubyte subType = data[1];

			/* If the notification was leave (stype=0) */
			if(subType == 0)
			{
                /* LeaveInfo: <channel>,<username> */
				string[] leaveInfo = split(cast(string)data[2..data.length],",");
                writeln("LeaveInfo: ",leaveInfo);

                /* Decode the LeaveInfo */
                string channel = leaveInfo[0];
                string username = leaveInfo[1];

                /* Find the channel */
                Channel matchedChannel = findChannel(channel);

                /* Channel leave */
                matchedChannel.channelLeave(username);
			}
			/* If the notification was join (stype=1) */
			else if(subType == 1)
			{
                /* JoinInfo: <channel>,<username> */
				string[] joinInfo = split(cast(string)data[2..data.length],",");
                writeln("JoinInfo: ",joinInfo);

                /* Decode the JoinInfo */
                string channel = joinInfo[0];
                string username = joinInfo[1];

                /* Find the channel */
                Channel matchedChannel = findChannel(channel);

                /* Channel join */
                matchedChannel.channelJoin(username);
			}
			/* TODO: Unknown */
			else
			{
				
			}
		}
	}


    public void joinChannel(string channelName)
    {
        /* Check if we have joined this channel already */
        Channel foundChannel = findChannel(channelName);

        /* If we have joined this channel before */
        if(foundChannel)
        {
            /* TODO: Switch to */
            writeln("nope time: "~channelName);

            
        }
        /* If we haven't joined this channel before */
        else
        {
            /* Join the channel */
            client.join(channelName);

            /* Create the Channel object */
            Channel newChannel = new Channel(client, channelName);

            /* Add the channel */
            addChannel(newChannel);

            /* Set as the `foundChannel` */
            foundChannel = newChannel;

            /* Get the Widgets container for this channel and add a tab for it */
            notebookSwitcher.add(newChannel.getBox());
            notebookSwitcher.setTabReorderable(newChannel.getBox(), true);
            notebookSwitcher.setTabLabelText(newChannel.getBox(), newChannel.getName());

            writeln("hdsjghjsd");

            writeln("first time: "~channelName);

            /* Get the user's list */
            newChannel.populateUsersList();
        }

        /* Switch to the channel's pane */
        //currentConnection.notebookSwitcher.setCurrentPage(foundChannel.getBox());

        /* Render recursively all children of the container and then the container itself */
        box.showAll();
    }


    private void channelList()
    {
        te();
        channelList_unsafe();
        tl();
    }

    public DClient getClient()
    {
        return client;
    }

    /**
    * Lists all channels and displays them
    *
    * Only to be aclled when locked (i.e. by the event
    * loop signal dispatch or when we lock it
    * i.e. `channelList`)
    */
    private void channelList_unsafe()
    {
        string[] channelList = client.list();

        foreach(string channel; channelList)
        {
            channels.add(new Label(channel));
            channels.showAll();
        }
    }
    
    public Channel findChannel(string channelName)
    {
        Channel result;

        chansLock.lock();

        foreach(Channel channel; chans)
        {
            if(cmp(channel.getName(), channelName) == 0)
            {
                result = channel;
                break;
            }
        }

        chansLock.unlock();

        return result;
    }

    /**
    * Adds the given channel to the tarcking list
    *
    * This adds the Channel object to the list of
    * channels joined
    *
    * TODO: Migrate the gui.d channel join selectChannel
    * here
    * NOTE: You must manually join it though
    */
    public void addChannel(Channel newChannel)
    {
        /* Add the channel to the `chans` tracking list */
        chansLock.lock();
        chans ~= newChannel;
        chansLock.unlock();

        /* Add the channel to the channels list (sidebar) */
        channels.add(new Label(newChannel.getName()));
    }

    /**
    * Called when you select a channel in the sidebar
    *
    * This moves you to the correct notebook tab for
    * that channel
    */
    private void viewChannel(ListBox s)
    {
        /* Get the name of the channel selected */
        string channelSelected = (cast(Label)(s.getSelectedRow().getChild())).getText();

        /* Check if we have joined this channel already */
        Channel foundChannel = findChannel(channelSelected);

        /* Switch to the channel's pane */
        notebookSwitcher.setCurrentPage(foundChannel.getBox());

        box.showAll();
    }


    /**
    * Creates a message box
    *
    * A message box consists of two labels
    * one being the name of the person who sent
    * the message and the next being the message
    * itself
    */
    private Box createMessageBox()
    {
        return null;
    }

    private Box getChatPane()
    {
        /* The main page of the tab */
        Box box = new Box(GtkOrientation.HORIZONTAL, 1);

        /* The channels box */
        Box channelBox = new Box(GtkOrientation.VERTICAL, 1);

        /* The channel's list */
        channels = new ListBox();
        channels.addOnSelectedRowsChanged(&viewChannel);

        channelBox.add(new Label("Channels"));
        channelBox.add(channels);

        // /* The user's box */
        // Box userBox = new Box(GtkOrientation.VERTICAL, 1);

        // /* The user's list */
        // users = new ListBox();

        // userBox.add(new Label("Users"));
        // userBox.add(users);
        
        // /* The text box */
        // Box textBox = new Box(GtkOrientation.VERTICAL, 1);
        // textBox.add(currentChannelLabel);
        // textArea = new ListBox();
        // import gtk.ScrolledWindow;

        // ScrolledWindow scrollTextChats = new ScrolledWindow(textArea);
        // textBox.add(scrollTextChats);
        // import gtk.TextView;
        // textBox.add(new TextView());
        

        // import gtk.TextView;
        // TextView f = new TextView();
        // textBox.add(f);
        
        notebookSwitcher = new Notebook();
        notebookSwitcher.setScrollable(true);
        //notebookSwitcher.add(newnew Label("test"));

        box.add(channelBox);
        box.add(notebookSwitcher);
        // box.add(textBox);
        //box.packEnd(notebookSwitcher,0,0,0);

        // textBox.setChildPacking(scrollTextChats, true, true, 0, GtkPackType.START);
        box.setChildPacking(notebookSwitcher, true, true, 0, GtkPackType.START);
        
        

        return box;
    }

    private int getPageNum()
    {
        return gui.notebook.pageNum(box);
    }

    public void shutdown()
    {
        /* This is called from gui.d */
        int pageNum = getPageNum();

        if(pageNum == -1)
        {
            /* TODO: Error handling */
        }
        else
        {
            gui.notebook.removePage(pageNum);
            gui.notebook.showAll();
        }
    }
}