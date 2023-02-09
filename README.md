IPRes_v1 - README File
----------------------
A tool for reporting host IP and client connection status en masse.
Output curated with minimal noise specifically for follow-on use.

To Run:
cd to directory containing IPres.ps1 (\IPRes by default), 
then run .\IPRes.ps1 with the following argument:
 - Filepath of file containing list of hostnames.

Example:
PS C:\IPRes> .\IPRes.ps1 .\hostnames.txt

Passing "-help" will display these instructions in the console.

Example:
PS C:\> .\IPRes.ps1 -help

Check \data\dns for resolved IPs and unresolved hostnames.
Check \data\pings successful and failed ping reports, formatted with hostnames and IPs.
Check \reports for full reports.

*** NOTE: running IPRes.ps1 will clear files in "data" directory ***
