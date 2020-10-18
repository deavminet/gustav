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

    this(GUI gui, Address address, string[] auth)
    {
        super(&worker);
        this.gui = gui;
        this.address = address;
        this.auth = auth;

        /* Initialize locks */
        initializeLocks();

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
        channelList();

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
			/* TODO: Decode using tristanable */
			/* TODO: Get the username of the user that left */
			//writeln("user left/join message");

			/* Get the sub-type */
			ubyte subType = data[1];

			/* If the notification was leave (stype=0) */
			if(subType == 0)
			{
                /* LeaveInfo: <channel>,<username> */
				string[] leaveInfo = split(cast(string)data[2..data.length],",");
                // textArea.add(new Label(("<-- "~username~" left the channel")));
                // textArea.showAll();
			}
			/* If the notification was join (stype=1) */
			else if(subType == 1)
			{
                /* JoinInfo: <channel>,<username> */
				string[] joinInfo = split(cast(string)data[2..data.length],",");

                /* Show joined message */
                // textArea.add(new Label(("--> "~username~" joined the channel")));
                // textArea.showAll();

                // /* Add the joined user to the members list */
                // users.add(new Label(username));
                // users.showAll();
			}
			/* TODO: Unknown */
			else
			{
				
			}
		}
	}





    private void channelList()
    {
        te();
        channelList_unsafe();
        tl();
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
    
    private Channel findChannel(string channelName)
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

    private void addChannel(Channel newChannel)
    {
        chansLock.lock();

        chans ~= newChannel;

        chansLock.unlock();
    }

    private void selectChannel(ListBox s)
    {
        /* Get the name of the channel selected */
        string channelSelected = (cast(Label)(s.getSelectedRow().getChild())).getText();

        /* Check if we have joined this channel already */
        Channel foundChannel = findChannel(channelSelected);

        /* If we have joined this channel before */
        if(foundChannel)
        {
            /* TODO: Switch to */
            writeln("nope time: "~channelSelected);

            
        }
        /* If we haven't joined this channel before */
        else
        {
            /* Join the channel */
            client.join(channelSelected);

            /* Create the Channel object */
            Channel newChannel = new Channel(client, channelSelected);

            /* Add the channel */
            addChannel(newChannel);

            /* Set as the `foundChannel` */
            foundChannel = newChannel;

            /* Get the Widgets container for this channel and add a tab for it */
            notebookSwitcher.add(newChannel.getBox());
            notebookSwitcher.setTabLabelText(newChannel.getBox(), newChannel.getName());

            writeln("hdsjghjsd");

            writeln("first time: "~channelSelected);

            /* Get the user's list */
            newChannel.populateUsersList();
        }

        /* Switch to the channel's pane */
        notebookSwitcher.setCurrentPage(foundChannel.getBox());

        box.showAll();
        // notebookSwitcher.showAll();

        /* TODO: Now add the widget */

        // /* Set this as the currently selected channel */
        // currentChannel = channelSelected;
        // currentChannelLabel.setText(currentChannel);
        // // currentChannelLabel.show();
        // // box.show();

        // /* Fetch a list of members */
        // string[] members = client.getMembers(channelSelected);

        // /* Display the members */
        // users.removeAll();
        // foreach(string member; members)
        // {
        //     users.add(new Label(member));
        //     users.showAll();
        // }

        // /* Clear the text area */
        // textArea.removeAll();
        // textArea.showAll();
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
        channels.addOnSelectedRowsChanged(&selectChannel);

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