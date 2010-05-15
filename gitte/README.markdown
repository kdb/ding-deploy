Gitte - Git repository updater
==============================

Recieves pings from Github and uses these to update Git checkouts.

The pings are recieved by a PHP script and forwarded to the gitte
process which should be running continously. gitte then processes
message from Github and updates the associated checkouts.

