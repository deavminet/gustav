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

public final class Channel
{
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

    this(string channelName)
    {
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
        import gtk.TextView;
        textBox.add(new TextView());
        

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

}