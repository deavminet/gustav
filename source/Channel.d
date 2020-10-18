/**
* Channel
*
* Represents a channel which is a collection
* of the channel name the users list widget,
* the title widget and the chat list box widget
* along with the input box state
*/

import gtk.Box;
import gtk.ListBox;
import gtk.Label;
import gtk.TextView;
import libdnet.dclient;
import gtk.Label;
import std.string;

public final class Channel
{
    private DClient client;

    /**
    * Channel details
    */
    private string channelName;

    /**
    * The container for this Channel
    */
    private Box box;

    /**
    * UI components
    *
    * Users's box
    *    - Label users
    *    - ListBox users
    */
    private ListBox users;
    private ListBox textArea;
    private TextView textInput;

    /* TODO: No mutexes should be needed (same precaution) as the GTK lock provides safety */
    private string[] usersString;

    this(DClient client, string channelName)
    {
        this.client = client;
        this.channelName = channelName;
        
        initializeBox();
    }

    private void initializeBox()
    {
        box = new Box(GtkOrientation.HORIZONTAL, 1);

        /* The user's box */
        Box userBox = new Box(GtkOrientation.VERTICAL, 1);

        /* The user's list */
        users = new ListBox();

        userBox.add(new Label("Users"));
        userBox.add(users);
        
        /* The text box */
        Box textBox = new Box(GtkOrientation.VERTICAL, 1);
        textBox.add(new Label(channelName));
        textArea = new ListBox();
        import gtk.ScrolledWindow;

        ScrolledWindow scrollTextChats = new ScrolledWindow(textArea);
        textBox.add(scrollTextChats);
        
        textInput = new TextView();
        textBox.add(textInput);
        

        // import gtk.TextView;
        // TextView f = new TextView();
        // textBox.add(f);



    
        box.add(textBox);
        box.packEnd(userBox,0,0,0);

        textBox.setChildPacking(scrollTextChats, true, true, 0, GtkPackType.START);
        box.setChildPacking(textBox, true, true, 0, GtkPackType.START);

    }

    public Box getBox()
    {
        return box;
    }

    public string getName()
    {
        return channelName;
    }

    public void populateUsersList()
    {
        string[] memberList = client.getMembers(channelName);

        foreach(string member; memberList)
        {
            users.add(new Label(member));
            usersString~=member;
        }
    }

    public void channelJoin(string username)
    {
        /* Add join message to message log */
        textArea.add(new Label("--> "~username~" joined the channel"));

        /* Add user to user list */
        users.add(new Label(username));

        usersString~=username;
    }

    public void channelLeave(string username)
    {
        /* Add leave message to message log */
        textArea.add(new Label("<-- "~username~" left the channel"));

        /* TODO: Better way with just removing one dude */
        
        /* Remove the user form users list */
        string[] newUsers;

        foreach(string currentUser; usersString)
        {
            if(cmp(currentUser, username))
            {
                newUsers ~= currentUser;
            }
        }

        usersString = newUsers;

        /* Clear list */
        users.removeAll();

        foreach(string currentUser; usersString)
        {
            users.add(new Label(currentUser));
        }

        /* Remove user from user list */
        /* TODO: Do this better */
        // foreach(Label label; users.get)
        // users.add(new Label(username));
    }

    

    public void addMessage(string s)
    {
        
    }
}