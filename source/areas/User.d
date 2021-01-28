module areas.User;

import areas.MessageArea;

public final class User : MessageArea
{
    private DClient client;
    private Connection connection;

    /**
    * USername
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