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
import gtk.Tooltip;
import gtk.Widget;
import gtk.ScrolledWindow;
import gtk.Button;
import gtk.Entry;

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
    private Entry textInput;

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
        

        ScrolledWindow scrollTextChats = new ScrolledWindow(textArea);
        textBox.add(scrollTextChats);
        
        import gtk.Entry;
        textInput = new Entry();
        textInput.addOnActivate(&sendMessageEnter);

        Box textInputBox = new Box(GtkOrientation.HORIZONTAL, 1);
        textInputBox.packStart(textInput,1,1,0);
        

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

    private void sendMessageEnter(Entry)
    {
        /* Retrieve the message */
        string message = textInput.getBuffer().getText();

        /* TODO: Add the message to our log (as it won't be delivered to us) */
        sendMessage(message);

        /* Send the message */
        client.sendMessage(0, channelName, message);

        /* Clear the text box */
        textInput.getBuffer().setText("",0);

        box.showAll();
    }

    private void sendMessageBtn(Button)
    {
        /* Retrieve the message */
        string message = textInput.getBuffer().getText();

        /* TODO: Add the message to our log (as it won't be delivered to us) */
        sendMessage(message);

        /* Send the message */
        client.sendMessage(0, channelName, message);

        /* Clear the text box */
        textInput.getBuffer().setText("",0);

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
        /* Create a label */
        Label userLabel = new Label(username);

        /* Enable the tooltip */
        userLabel.setHasTooltip(true);
        
        /* Set the handler to run on hover */
        userLabel.addOnQueryTooltip(&userLabelHoverHandler);

        return userLabel;
    }

    /**
    * Event handler to be run when you hover over a user's
    * username in the Users sidebar list which will show
    * the status as text (and in an icon format), the user's
    * username and also their status message
    */
    private bool userLabelHoverHandler(int, int, bool, Tooltip tooltip, Widget userLabel)
    {
        /* The username hovered over */
        string userHover = (cast(Label)userLabel).getText();

        /* The final tooltip */
        string toolTipText = "<b>"~userHover~"</b>";

        /* Check if there is a `precensce` message */
        if(client.isProperty(userHover, "pres"))
        {
            /* Fetch the precensce */
            string prescence = client.getProperty(userHover, "pres");

            /* Set the icon */
            tooltip.setIconFromIconName(statusToGtkIcon(prescence), GtkIconSize.DIALOG);

            /* Append the precesnee to the tooltip text */
            toolTipText ~= "\n"~prescence;
        }

        /* Check if there is a `status` message */
        if(client.isProperty(userHover, "status"))
        {
            /* Next is status message */
            string status = client.getProperty(userHover, "status");

            /* Append the status to the tooltip text */
            toolTipText ~= "\n<i>"~status~"</i>";
        }

        /* Set the tooltip text */
        tooltip.setMarkup(toolTipText);

        /* TODO: Point of return value? */        
        return 1;
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

    public void channelJoin(string username)
    {
        /* The label to add */
        /* TODO: Bababooey these `-->` being parsed as HTML for Pango */
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
        /* TODO: Bababooey these `-->` being parsed as HTML for Pango */
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

    public void sendMessage(string message)
    {
        /* TOOD: Pass in connection perhaps */
        string username = "Yourself";

        /* Create the MessageBox */
        Box messageBox = new Box(GtkOrientation.VERTICAL, 1);

        /* Create and add the username */
        Label usernameLabel = new Label("");
        usernameLabel.setMarkup("<b>"~username~"</b>");
        usernameLabel.setHalign(GtkAlign.END);
        messageBox.add(usernameLabel);

        /* Create and add the message */
        Label messageLabel = new Label(message);
        messageLabel.setHalign(GtkAlign.END);
        messageBox.add(messageLabel);

        /* Add the message to the log */
        textArea.add(messageBox);
    }

    public void receiveMessage(string username, string message)
    {
        /* Create the MessageBox */
        Box messageBox = new Box(GtkOrientation.VERTICAL, 1);

        /* Create and add the username */
        Label usernameLabel = new Label("");
        usernameLabel.setMarkup("<b>"~username~"</b>");
        usernameLabel.setHalign(GtkAlign.START);
        messageBox.add(usernameLabel);

        /* Create and add the message */
        Label messageLabel = new Label(message);
        messageLabel.setHalign(GtkAlign.START);
        messageBox.add(messageLabel);

        // import gtk.Image;
        // Image d = new Image("/home/deavmi/Downloads/5207740.jpg");
        // messageBox.add(d);

        /* Add the message to the log */
        textArea.add(messageBox);
    }
}