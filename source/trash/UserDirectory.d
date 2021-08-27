module UserDirectory;

import trash.Connection;
import gtk.SearchBar;
import gtk.Entry;
import gtk.Window;

public final class UserDirectory
{
    /* The associated connection */
    private Connection connection;

    this(Connection connection)
    {
        this.connection = connection;

        initWindow();
    }

    private void initWindow()
    {
        Window userWindow = new Window(GtkWindowType.TOPLEVEL);
        userWindow.setTitle("User directory");

        SearchBar searchBar = new SearchBar();
        Entry searchEntry = new Entry();
        searchEntry.setText("fsdhjsdfhjkdsfhjksdfhjk");
        // searchBar.handleEvent()
        searchBar.connectEntry(searchEntry);
        userWindow.add(searchBar);


        userWindow.showAll();
    }
}