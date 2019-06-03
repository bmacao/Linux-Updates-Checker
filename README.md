# Linux-Updates-Checker

Get server report for updates available ( Debian based )

Get all updates and security updates ( plus CVE ) from servers and combine them in a single file as JSON.
!Construct website/service to visualize the data created! or open JSON file and enjoy :) !

Depends:

- debscan installed in all hosts;
- ssh key of the operator ( with pwd configured - recommended);

The project has 2 methods to apply the scan:

Powershell script that get all data from servers configured in the script Scan.ps1:

\$prod_server = @{ <br />
prod1 = 'x.x.x.x' <br />
prod2 = 'x.x.x.x' <br />
prod3 = 'x.x.x.x' <br />
}

Bash script that currently only executes in single host

TO-DO in bash script:

- Create method to execute remotely the script ( without the need to establish ssh session);
- Retrive or send file generated to central point/server;
