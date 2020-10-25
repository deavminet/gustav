module UserNode;

import Connection;
import libdnet.dclient;
import gtk.Box;
import gtk.Button;
import gtk.Image;
import gtk.Label;
import gtk.Tooltip;
import gtk.Widget;
import std.string;

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

        /* Layout [Button (Prescence Icon)] - Label <username> */
        Button userButton = new Button();
        Image userButtonImg = new Image("user-available", GtkIconSize.BUTTON);
        userButton.setImage(userButtonImg);

        /* Create a label */
        Label userLabel = new Label(username);

        /* Enable the tooltip */
        userLabel.setHasTooltip(true);
        
        /* Set the handler to run on hover */
        userLabel.addOnQueryTooltip(&userLabelHoverHandler);

        /* TODO: Implement me */

        /* Add both components */
        box.add(userButton);
        box.add(userLabel);
    }

    /**
    * Event handler to be run when you hover over a user's
    * username in the Users sidebar list which will show
    * the status as text (and in an icon format), the user's
    * username and also their status message
    */
    private bool userLabelHoverHandler(int, int, bool, Tooltip tooltip, Widget userLabel)
    {
        /* Get the client */
        DClient client = connection.getClient();

        /* The username hovered over */
        string userHover = (cast(Label)userLabel).getText();

        /* The final tooltip */
        string toolTipText = "<b>"~userHover~"</b>";

        /* Check if there is a `precensce` message */
        if(client.isProperty(userHover, "pres"))
        {
            /* Fetch the precensce */
            string prescence = client.getProperty(userHover, "pres");

            /* Set the icon */
            tooltip.setIconFromIconName(statusToGtkIcon(prescence), GtkIconSize.DIALOG);

            /* Append the precesnee to the tooltip text */
            toolTipText ~= "\n"~prescence;
        }

        /* Check if there is a `status` message */
        if(client.isProperty(userHover, "status"))
        {
            /* Next is status message */
            string status = client.getProperty(userHover, "status");

            /* Append the status to the tooltip text */
            toolTipText ~= "\n<i>"~status~"</i>";
        }

        /* Set the tooltip text */
        tooltip.setMarkup(toolTipText);

        /* TODO: Point of return value? */        
        return 1;
    }

    private static string statusToGtkIcon(string status)
    {
        /* The GTK icon */
        string gtkIcon = "image-missing";

        if(cmp(status, "available") == 0)
        {
            gtkIcon = "user-available";
        }
        else if(cmp(status, "away") == 0)
        {
            gtkIcon = "user-away";
        }
        else if(cmp(status, "busy") == 0)
        {
            gtkIcon = "user-busy";
        }
        /* TODO: This doesn't make sense */
        else if(cmp(status, "offline") == 0)
        {
            gtkIcon = "user-offline";
        }
        
        return gtkIcon;
    }

    public Box getBox()
    {
        return box;
        /* TODO: Implement me */
    }
}