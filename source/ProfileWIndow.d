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
        Window profileWindow = new Window(username);

        

        Image profileImage = new Image("/home/deavmi/Downloads/5207740.jpg");
        //profileWindow.add(profileImage);

        string[] props = connection.getClient().getProperties(username);
        profileWindow.add(new Label(to!(string)(props)));

        profileWindow.showAll();
    }
}