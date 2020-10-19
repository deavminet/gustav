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
import gtk.Button;

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

        // import gtk.Expander;
        // Expander g = new Expander("Bruh");
        // g.setExpanded(true)
        // g.add(users);
        userBox.add(users);
        
        /* The text box */
        Box textBox = new Box(GtkOrientation.VERTICAL, 1);
        textBox.add(new Label(channelName));
        textArea = new ListBox();
        import gtk.ScrolledWindow;

        ScrolledWindow scrollTextChats = new ScrolledWindow(textArea);
        textBox.add(scrollTextChats);
        
        textInput = new TextView();
        Box textInputBox = new Box(GtkOrientation.HORIZONTAL, 1);
        textInputBox.packStart(textInput,1,1,0);
        import gtk.Button;

        /* The send button */
        Button sendButton = new Button("Send");
        sendButton.addOnClicked(&sendMessageBtn);
        textInputBox.add(sendButton);
        textBox.add(textInputBox);
        

        // import gtk.TextView;
        // TextView f = new TextView();
        // textBox.add(f);



    
        box.add(textBox);
        box.packEnd(userBox,0,0,0);

        textBox.setChildPacking(scrollTextChats, true, true, 0, GtkPackType.START);
        box.setChildPacking(textBox, true, true, 0, GtkPackType.START);

    }

    private void sendMessageBtn(Button)
    {
        /* Retrieve the message */
        string message = textInput.getBuffer().getText();

        /* TODO: Add the message to our log (as it won't be delivered to us) */
        addMessage(message);

        /* Send the message */
        client.sendMessage(0, channelName, message);

        /* Clear the text box */
        textInput.getBuffer().setText("");

        box.showAll();
    }

    public Box getBox()
    {
        return box;
    }

    public string getName()
    {
        return channelName;
    }

    /**
    * Returns a Label with the tooltip event such
    * that it will run that handler on hover
    */
    private Label getUserLabel(string username)
    {
        Label bruh = new Label(username);
        bruh.setHasTooltip(true);
        // import gtk.Window;
        // Window k = new Window(GtkWindowType.POPUP);
            
        // bruh.setTooltipWindow(k);
        bruh.addOnQueryTooltip(&kak);

        return bruh;
    }

    public void populateUsersList()
    {
        string[] memberList = client.getMembers(channelName);

        foreach(string member; memberList)
        {
            Label bruh  = getUserLabel(member);
            users.add(bruh);
            usersString~=member;
        }
    }

    import gtk.Tooltip;
    import gtk.Widget;


    private static string statusToGtkIcon(string status)
    {
        /* The GTK icon */
        string gtkIcon = "image-missing";

        if(cmp(status, "available") == 0)
        {
            gtkIcon = "user-available";
        }
        else if(cmp(status, "away") == 0)
        {
            gtkIcon = "user-away";
        }
        else if(cmp(status, "busy") == 0)
        {
            gtkIcon = "user-busy";
        }
        /* TODO: This doesn't make sense */
        else if(cmp(status, "offline") == 0)
        {
            gtkIcon = "user-offline";
        }
        
        return gtkIcon;
    }

    private bool kak(int,int,bool, Tooltip d, Widget poes)
    {
        import std.stdio;
        writeln("ttoltip activatd");

        

        /* The username hovered over */
        string userHover = (cast(Label)poes).getText();

        /* Fetch the status message */
        string[] statusMessage = split(client.getMemberInfo(userHover), ",");
        writeln(statusMessage);

        /* First one is prescence */
        string prescence = statusMessage[0];

        d.setIconFromIconName(statusToGtkIcon(prescence), GtkIconSize.DIALOG);

        d.setText(userHover~"\n"~prescence);

        // /* The notification box */
        // Box notificationBox = new Box(GtkOrientation.VERTICAL, 1);

        // Label title = new Label((cast(Label)poes).getText());
        // Label status = new Label("status goes here");

        // notificationBox.add(title);
        // notificationBox.add(status);
        
        // import gtk.Style;
        // // title.setStyle(new Style());

        // d.setCustom(notificationBox);

        
        
        return 1;
    }

    public void channelJoin(string username)
    {
        /* The label to add */
        Label joinLabel = new Label("--> <i>"~username~" joined the channel</i>");
        joinLabel.setHalign(GtkAlign.START);
        joinLabel.setUseMarkup(true);

        /* Add join message to message log */
        textArea.add(joinLabel);

        /* Add user to user list */
        users.add(getUserLabel(username));

        usersString~=username;
    }


    public void channelLeave(string username)
    {
        /* The label to add */
        Label leaveLabel = new Label("<-- <i>"~username~" left the channel</i>");
        leaveLabel.setHalign(GtkAlign.START);
        leaveLabel.setUseMarkup(true);

        /* Add leave message to message log */
        textArea.add(leaveLabel);

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
            users.add(getUserLabel(currentUser));
        }

        /* Remove user from user list */
        /* TODO: Do this better */
        // foreach(Label label; users.get)
        // users.add(new Label(username));
        // users.showAll();
        // box.showAll();+
    }

    

    public void addMessage(string s)
    {
        textArea.add(new Label(s));
    }
}