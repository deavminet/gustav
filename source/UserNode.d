module UserNode;

import Connection;
import gtk.Box;

public final class UserNode
{
    private Connection connection;
    private string username;

    private Box box;

    this(Connection connection, string username)
    {
        this.connection = connection;
        this.username = username;

        initBox();
    }

    private void initBox()
    {
        box = new Box(GtkOrientation.HORIZONTAL, 1);

        /* TODO: Implement me */
    }

    public Box getBox()
    {
        return box;
        /* TODO: Implement me */
    }
}