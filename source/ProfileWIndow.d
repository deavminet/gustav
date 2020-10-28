/**
* Profile window
*
* User profile window
*/

import Connection;
import gtk.Window;
import gtk.Label;
import gtk.Image;
import std.conv;
import gtk.Box;

public final class ProfileWindow
{
    private Connection connection;
    private string username;

    this(Connection connection, string username)
    {
        this.connection = connection;
        this.username = username;

        showWindow();
    }

    private void showWindow()
    {
        /* Create the window with the username as the title */
        Window profileWindow = new Window(username);

        /* Create a Box for contents */
        Box profileBox = new Box(GtkOrientation.VERTICAL, 1);
    
        /* Create the username label */
        Label usernameTitle = new Label("");
        usernameTitle.setMarkup("<span size=\"10000\">"~username~"</span>");
        profileBox.add(usernameTitle);
        

        Image profileImage = new Image("/home/deavmi/Downloads/5207740.jpg");
        //profileWindow.add(profileImage);

        
        string[] props = connection.getClient().getProperties(username);
        profileBox.add(new Label(to!(string)(props)));

        profileWindow.add(profileBox);
        profileWindow.showAll();
    }
}