# Engineer Coverage Checks Script / Project

## Version 1.0 Information Gathered

- Active Directory:
  - Domain controller list:
  - Version of OS
  - Disk usage on AD DS volume(s)
  - Global catalog state
  - AD DS service status (netlogon, NTDS & DNS)
  - Domain / Forest info
  - Domain functional level
  - Forest functional level
  - SYSVOL accessibility
  - NETLOGON accessibility
  - Operations masters
  - SYSVOL DFSR backlog
- Object info
  - Users with non-expiring passwords
  - Users with PW stored with reversible encryption
  - Count of OUs / containers / critical objects without protection from accidental deletion
- General server info:
  - Stopped auto-starting services & those with non-standard users (i.e. eciadmin or other domain accounts)
  - Local administrator list
  - Disk space on all volumes
  - Non-SYSVOL DFSR Backlogs
  - Get pending reboots
  - Find all printers and check state
  - Find all scheduled tasks running under local or domain / administrative accounts
  - Last Windows update check
  - Certificates with < 30 days until expiry


## Possible data points to gather

- Get AD health
  - DFL / FFL
  - DC versions
  - FRS / DFS replication state / partners / groups / DFS backlog
  - Test replication directly with test.txt
  - SYSVOL / NETLOGON accessibility
  - FSMO roles / operations masters
  - AD DS service status (netlogon, ntds, dns)
  - Users with non-expiring passwords
  - Users with PW stored with reversible encryption
  - Failed logins last 24 hours (sorted)
- Azure AD connect / Azure AD health??
- Get Exchange health
  - EMS … ?
  - DAG health
  - Services running
  - Ports open and responding
- For clients with virtual hosts (VMware or otherwise)
  - Host health / network / datastore
  - Any VMs that are stopped / errored
  - Any VMs with a snapshot
- Get stopped auto-starting services
- NetApp SAN
  - Check all volume free space
  - Check snapshots are working
- Veritas – Check failed jobs in last 24 hours
- KIS backup server
  - Check it’s running
  - Check logfile activity
  - Check share path accessible
- Symantec Endpoint Protection manager
  - Get out of date / infected / attention required hosts
- Qualys
  - Get new / rogue hosts via API
- Get all non-standard local admins on servers?
- Get server disk space (Priority to: transaction logs, SMTP queue / critical data)
- Get server utilisation / performance (including disks?)
- Check RAM and CPU usage
- Check Critical and Error event logs 
- Get / find SMART data for physical servers???
- Get all network shares
- Get all printers are reachable 
- Get scheduled tasks running with admin creds
- Get services running with admin creds / nonstandard users
- Ping / port scanning?
- Web server checks
  - Pingable
  - Find virtual hosts / bindings 
  - HTML GET / POST tests (Invoke-WebRequest)
- Software inventory?
- Get installed Windows roles & features
  - Based on installed features do XYZ
