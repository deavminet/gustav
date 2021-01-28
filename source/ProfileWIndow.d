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
    

        /* Create a Image for the profile picture */
        Image profileImage = new Image("/home/deavmi/Downloads/logo.png");
        profileBox.add(profileImage);
        // profileImage.

        /* Create the username label */
        Label usernameTitle = new Label("");
        usernameTitle.setMarkup("<span size=\"20000\">"~username~"</span>");
        profileBox.add(usernameTitle);
        

        /* Display all props (keys) */
        string[] props = connection.getClient().getProperties(username);
        profileBox.add(new Label(to!(string)(props)));

        /* Display all props (values) */
        string[] propValues;
        foreach(string property; props)
        {
            propValues ~= connection.getClient().getProperty(username, property);
        }
        profileBox.add(new Label(to!(string)(propValues)));



        profileWindow.add(profileBox);
        profileWindow.showAll();
        // profileWindow.unmaximize();
        // profileWindow.setAttachedTo()
    }
}