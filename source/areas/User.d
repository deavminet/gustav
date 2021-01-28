module areas.User;

import areas.MessageArea;

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
    * The container for this User
    */
    private Box box;

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

    private void initializeBox()
    {

    }
}