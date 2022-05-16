# Main Client Code

This contains the main client code for Flamepaw

Two functions are exported:

``func Server()``

``func Test()``

Both are exposed by the commands ``server`` and ``test``

Server creates the discord clients, saves them to ``common.DiscordMain``, starts IPC and webserver if register commands is false, then calls slashbot to start slash command bots (which could just create command IRs,register commands and exit)