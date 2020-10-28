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
import UserNode;

import pango.PgAttributeList;
import pango.PgAttribute;
import Connection;

public final class Channel
{
    private DClient client;
    private Connection connection;

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

    this(Connection connection, string channelName)
    {
        this.client = connection.getClient();
        this.connection = connection;
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

        /* Channel title */
        Label channelTitleLabel = new Label(channelName);
        channelTitleLabel.setMarkup("<span size=\"large\"><b>"~channelName~"</b></span>");
        textBox.add(channelTitleLabel);

        /* The messages box */
        textArea = new ListBox();
        ScrolledWindow scrollTextChats = new ScrolledWindow(textArea);
        textBox.add(scrollTextChats);
        

        /* The Box for the whole |attach button| text field| send button| */
        Box textInputBox = new Box(GtkOrientation.HORIZONTAL, 1);

        import gtk.Image;

        /* The attachment button */
        Button attachFileButton = new Button("Upload");
        Image attachFileButtonIcon = new Image("user-available", GtkIconSize.BUTTON); /* TODO: Fix icon now showing */
        attachFileButton.setImage(attachFileButtonIcon);
        attachFileButton.addOnClicked(&uploadFileDialog);
        textInputBox.add(attachFileButton);

        /* The text input */
        textInput = new Entry();
        textInput.addOnActivate(&sendMessageEnter);
        textInput.addOnChanged(&textChangd);
        
        textInputBox.packStart(textInput,1,1,0);
        

        /* The send button */
        Button sendButton = new Button("Send");
        sendButton.addOnClicked(&sendMessageBtn);
        textInputBox.add(sendButton);
        textBox.add(textInputBox);
        
        box.add(textBox);
        box.packEnd(userBox,0,0,0);

        textBox.setChildPacking(scrollTextChats, true, true, 0, GtkPackType.START);
        box.setChildPacking(textBox, true, true, 0, GtkPackType.START);

    }

    private void uploadFileDialog(Button e)
    {
        import gtk.FileChooserDialog; /* TODO: Set parent */
        FileChooserDialog fileChooser = new FileChooserDialog("Send file to "~channelName, null, FileChooserAction.OPEN);
        fileChooser.run();
    }

    import gtk.EditableIF;
    private void textChangd(EditableIF)
    {
        /* If the text box just became empty stop ssending typing notifications */
        /* Send typing stats */
        // client.sendIsTyping(channelName, true);
        /* TODO: Client implement wiht different tag? */
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

    


    private Box getUserListItem(string username)
    {
        /* This is an item for a username in this Channel's user list */
        Box box = new Box(GtkOrientation.HORIZONTAL, 1);


        import gtk.IconView;
        IconView icon = new IconView();
        import gtk.StatusIcon;
        StatusIcon d = new StatusIcon("user-available");

        return box;
    }


    // private bool userLabelPopup(Widget)
    // {
    //     import std.stdio;
    //     writeln("NOWNOWNOWNOWNOW");

    //     return true;
    // }

    


    public void populateUsersList()
    {
        string[] memberList = client.getMembers(channelName);

        foreach(string member; memberList)
        {
            /* Create the user entry in the list */
            UserNode userNode = new UserNode(connection, member);
            users.add(userNode.getBox());

            /* Add the user to the tracking list */
            usersString~=member;
        }
    }

   


   
    public void channelJoin(string username)
    {
        /* The label to add */
        Label joinLabel = new Label("--> "~username~" joined the channel");
        joinLabel.setHalign(GtkAlign.START);
        PgAttributeList joinLabelAttrs = new PgAttributeList();
        PgAttribute joinLabelAttr = PgAttribute.styleNew(PangoStyle.ITALIC);
        joinLabelAttrs.insert(joinLabelAttr);
        joinLabel.setAttributes(joinLabelAttrs);

        /* Add join message to message log */
        textArea.add(joinLabel);

        /* Create the user entry in the list */
        UserNode userNode = new UserNode(connection, username);
        users.add(userNode.getBox());

        /* Add the user to the tracking list */
        usersString~=username;
    }

    public void channelLeave(string username)
    {
        /* The label to add */
        Label leaveLabel = new Label("<-- "~username~" left the channel");
        leaveLabel.setHalign(GtkAlign.START);
        PgAttributeList leaveLabelAttrs = new PgAttributeList();
        PgAttribute leaveLabelAttr = PgAttribute.styleNew(PangoStyle.ITALIC);
        leaveLabelAttrs.insert(leaveLabelAttr);
        leaveLabel.setAttributes(leaveLabelAttrs);

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
            /* Create the user entry in the list */
            UserNode userNode = new UserNode(connection, currentUser);
            users.add(userNode.getBox());
        }
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
        messageLabel.setSelectable(true);
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
        messageLabel.setSelectable(true);
        messageBox.add(messageLabel);

        // import gtk.Image;
        // Image d = new Image("/home/deavmi/Downloads/5207740.jpg");
        // messageBox.add(d);

        /* Add the message to the log */
        textArea.add(messageBox);
    }
}