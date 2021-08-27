module areas.User;

import areas.MessageArea;

import gtk.Box;
import gtk.ListBox;
import gtk.Label;
import gtk.TextView;
import libdnet.client;
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
import trash.Connection;

import gogga;

public final class User : MessageArea
{
    private DClient client;
    private Connection connection;

    /**
    * Username
    */
    private string username;

    /**
    * UI components
    *
    */
    // private ListBox users;
    private ListBox textArea;
    private Entry textInput;
    

    /* TODO: No mutexes should be needed (same precaution) as the GTK lock provides safety */
    // private string[] usersString;

    this(Connection connection, string username)
    {
        this.client = connection.getClient();
        this.connection = connection;
        this.username = username;
        
        initializeBox();
    }

    public string getUsername()
    {
        return username;
    }

    private void initializeBox()
    {
        box = new Box(GtkOrientation.HORIZONTAL, 1);

        // box.add(new Label("poes"));
        /* The text box */
        Box textBox = new Box(GtkOrientation.VERTICAL, 1);

        /* Channel title */
        Label channelTitleLabel = new Label(username);
        channelTitleLabel.setMarkup("<span size=\"large\"><b>"~username~"</b></span>");
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
        // box.packEnd(userBox,0,0,0);

        textBox.setChildPacking(scrollTextChats, true, true, 0, GtkPackType.START);
        box.setChildPacking(textBox, true, true, 0, GtkPackType.START);

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
        client.sendMessage(1, username, message);

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
        client.sendMessage(1, username, message);

        /* Clear the text box */
        textInput.getBuffer().setText("",0);

        box.showAll();
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

    private void uploadFileDialog(Button e)
    {
        import gtk.FileChooserDialog; /* TODO: Set parent */
        FileChooserDialog fileChooser = new FileChooserDialog("Send file to "~username, null, FileChooserAction.OPEN);
        fileChooser.run();
        gprintln("Selected file: "~fileChooser.getFilename());
    }
}