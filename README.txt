Addon:          Rested
Description:    Rested XP Tracker for Turtle Wow
Note:           This should work everywhere but, other servers may not have the same
                max rested xp cap screwing up the calculations
Author:         Quiver
Date:           03/29/2021

Dedicated to Turtle Wow, the best custom vanilla World of Warcraft server.
Websiite:       http://turtle-wow.org
Discord:        https://discord.com/invite/mBGxmHy


Change Log:
    03/30/2021: Added slash commands. /rested or /exp will printout your rested status
    03/30/2021: Added loading message
    03/30/2021: Added timed refresh
    03/31/2021: Added configuration with the use of the set keyword
    04/06/2021: Fixed bug where the addon would sometimes get a gmatch error
    04/06/2021: Changed the preset save location to your toons folder (multiple configurations)
    04/07/2021: Added Smart Mode
    04/07/2021: Code Cleanup
    04/07/2021: Added debug mode
    04/07/2021: Updated the help
    04/08/2021: Formatted strings allowing more localization


Todo:
    - More localization


Multiple Configs:
    Rested now supports per character configuration


Modes:
    Smart Mode:     monitors your rested status and alerts you when it changes
    Refresh Mode:   updates you every few seconds

    ** Smart Mode is sufficent for most users, you do not need to enable both **


Slash Commands:
    Display rested status --------------------- /rested
    Smart Mode -------------------------------- /rested set smartmode true

    Automatically start in Refresh Mode ------- /rested set autostart false
    Start Refreshing -------------------------- /rested start
    Stop refreshing --------------------------- /rested stop
    Set refresh rate (in seconds) ------------- /rested set refresh 30

    Help -------------------------------------- /rested help
    Debug ------------------------------------- /rested debug

* Alternitivly you can use /exp instead of /rested for all commands
