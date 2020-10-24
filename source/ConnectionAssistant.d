module ConnectionAssistant;

/**
* ConnectionAssistant
*
* This provides a graphical utility for
* configuring new connections
*/

import gtk.Assistant;
import gtk.Label;
import gtk.Box;
import gtk.Entry;
import gui;
import std.conv;

public final class ConnectionAssistant : Assistant
{
    /* Associated GUI instance */
    private GUI gui;

    Entry serverAddress;
    Entry serverPort;
    Entry username;
    Entry password;

    /* Summary box */
    Box summaryBox;


    this(GUI gui)
    {
        this.gui = gui;

        initWindow();
    }

    private void initWindow()
    {   
        Assistant connectionAssistant = new Assistant();

        Label hello = new Label("");
        hello.setMarkup("<span size=\"15000\">Welcome to the connection setup</span>");
        connectionAssistant.insertPage(hello, 0);
        connectionAssistant.setPageTitle(hello, "Welcome");

        /* Configure a server */
        Box serverBox = new Box(GtkOrientation.VERTICAL, 1);
        Label serverBoxTitle = new Label("");
        serverBoxTitle.setMarkup("<span size=\"15000\">Server details</span>");
        serverBox.packStart(serverBoxTitle,0,0,30);
        serverAddress = new Entry();
        serverBox.add(serverAddress);
        serverAddress.setPlaceholderText("DNET server address");
        serverPort = new Entry();
        serverBox.add(serverPort);
        serverPort.setPlaceholderText("DNET server port");
        
        
        connectionAssistant.insertPage(serverBox, 1);
        connectionAssistant.setPageTitle(serverBox, "Network");

        /* Configure your profile details */
        Box profileBox = new Box(GtkOrientation.VERTICAL, 1);
        Label profileBoxTitle = new Label("");
        profileBoxTitle.setMarkup("<span size=\"15000\">Account details</span>");
        profileBox.packStart(profileBoxTitle,0,0,30);
        username = new Entry();
        profileBox.add(username);
        username.setPlaceholderText("username");
        password = new Entry();
        profileBox.add(password);
        password.setPlaceholderText("password");

        connectionAssistant.insertPage(profileBox, 2);
        connectionAssistant.setPageTitle(profileBox, "Account");
        
        /* TODO: We should actually verify inputs before doing this */
        connectionAssistant.setPageComplete(hello, true);
        connectionAssistant.setPageComplete(serverBox, true);
        connectionAssistant.setPageComplete(profileBox, true);


        /* Summary */
        summaryBox = new Box(GtkOrientation.VERTICAL, 1);
        Label summaryBoxTitle = new Label("");
        summaryBoxTitle.setMarkup("<span size=\"15000\">Summary</span>");
        summaryBox.packStart(summaryBoxTitle,0,0,30);

        
        


        connectionAssistant.insertPage(summaryBox, 4);
        connectionAssistant.setPageType(summaryBox, GtkAssistantPageType.SUMMARY);
        

        connectionAssistant.addOnClose(&assistentComplete);
        connectionAssistant.addOnCancel(&assistenctCancel);

        connectionAssistant.showAll();
    }

    private void assistenctCancel(Assistant e)
    {
         /* TODO: Get this to work */
         /* TODO: The `.close()` doesn't seem to work */
    }

    /* TODO: I want this code to run when we are on the summary page */
    private void kak()
    {
        /* Summary data */
        Label serverAddressLabel = new Label("");
        serverAddressLabel.setMarkup("<b>Server Address:</b> "~serverAddress.getBuffer().getText());

        Label serverPortLabel = new Label("");
        serverPortLabel.setMarkup("<b>Server Port:</b> "~serverPort.getBuffer().getText());

        Label accountUsername = new Label("");
        accountUsername.setMarkup("<b>Account username:</b> "~username.getBuffer().getText());

        Label accountPassword = new Label("");
        accountPassword.setMarkup("<b>Account password:</b> "~password.getBuffer().getText());

        
        
        summaryBox.add(serverAddressLabel);
        summaryBox.add(serverPortLabel);
        summaryBox.add(accountUsername);
        summaryBox.add(accountPassword);
    }

    private void assistentComplete(Assistant)
    {
        /* Get the server details */
        string serverAddress = serverAddress.getBuffer().getText();
        string serverPort = serverPort.getBuffer().getText();

        /* Get the account details */
        string accountUsername = username.getBuffer().getText();
        string accountPassword = password.getBuffer().getText();
        
        /* Create a new Connection */
        gui.connectServer(serverAddress, to!(ushort)(serverPort), [accountUsername, accountPassword]);
    }
}