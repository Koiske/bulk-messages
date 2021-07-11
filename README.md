# Plugin: `discourse-bulk-messages`

Sending a private message in BCC-like fashion to a large number of forum users at once.

---

## Features

- Adds an admin widget on the plugin page at `%BASEURL%/admin/plugins/discourse-bulk-messages` that allows an admin user to send a private messages to a large list of users.

   <img src=docs/discourse-bulk-messages.png width=80%>

  - Users should be provided as a list of usernames, separated by newlines (one username per line).
  
  - The admin user can specify the title and body of the message, as well including a given group on each message.

  - Options are available to make the messages anonymous (i.e. sent from system user instead of the acting admin user), and automatically locking the messages after being sent, to avoid getting notified when users reply to the messages.
  
  - The private messages are sent in BCC-like fashion, i.e. it creates a new private message to each user, that only includes that user, the acting user, and optionally the given group.

  - Any occurrences of the phrase `%USER%` in the body of the message is replaced with the username of each user in their respective private messages.

---

## Impact

### Community

Forum users no longer get spammed with notifications whenever someone replies to a private message to a group that has a massive amount of users, which is the way that Developer Relations used to handle sending out notices to a large amount of users in private before. Each user gets their own conversation space.

### Internal

It is easier to inform hundreds or even thousands of users at once about special opportunities, surveys, and other important notices that are not necessarily fit for a public announcement.

### Resources

Some minor performance impact whenever a large operation is performed.

There is no performance impact when the widget is not in use.

### Maintenance

No manual maintenance needed.

---

## Technical Scope

A rails engine is defined to create new endpoints that can be used by the plugin. Standard functionality is used to route the endpoints to the right methods in the engine. The rails engine is constrained to only accept requests sent from forum sessions by an admin user.

The standard recommended functionality is used to add the widget for this plugin to the admin panel for plugins.
