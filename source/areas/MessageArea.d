/**
* MessageArea
*
* Represents the binding of a text entry, send button, user list (sometimes)
* and message log - basically the place where you message a channel or someone
*
* The sub-classes are "Direct Message" and "Channel"
*/

module areas.MessageArea;

import gtk.Box;

public class MessageArea
{
    /* TODO: Implement me */

    /* The area's Box (where everything is contained) */
    protected Box box;

    public Box getBox()
    {
        return box;
    }
}