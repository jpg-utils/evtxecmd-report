This is a powershell library designed to take the output of Eric Zimmerman's EVTXecmd tool and generate an HTML report showing logins, logouts, and suspicious account activity found on a standalone Windows Machine.

This script is NOT designed to be a catch-all on a system for finding suspicious activity. It is a starting point, not a panacea. Ultimately it falls onto the owner of the system what qualifies as "suspicious activity."

In addition, the library contains a script to run the rotation of event logs, the consolidation of application, system, and security logs into a csv (provided evtxecmd has been installed and added to PATH), and run the report as a weekly task. This is an easy way to give a user access to weekly security logs without making them a full administrator on the system- all they need is to be in the computer's 'event log readers' group.

More on EVTXecmd here:

https://github.com/EricZimmerman/evtx
