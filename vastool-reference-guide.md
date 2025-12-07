# Vastool Reference Guide

## Table of Contents
1. [Overview](#overview)
2. [Domain and Server Information](#domain-and-server-information)
3. [Querying User Records](#querying-user-records)
4. [Querying Group Records](#querying-group-records)
5. [Querying Computer/Server Records](#querying-computerserver-records)
6. [Finding Server Access Groups](#finding-server-access-groups)
7. [Enumerating Unix-Enabled Group Members](#enumerating-unix-enabled-group-members)
8. [Advanced Search with LDAP Filters](#advanced-search-with-ldap-filters)
9. [Common Administrative Commands](#common-administrative-commands)

---

## Overview

**vastool** is the command-line utility for Quest/One Identity Authentication Services (formerly Vintela Authentication Services - VAS). It's typically installed at `/opt/quest/bin/vastool` and provides comprehensive tools for integrating Unix/Linux systems with Active Directory.

### Key Authentication Patterns

Most vastool commands require authentication. Common patterns:
- `-u host/` - Use the host's machine account (most common)
- `-u username` - Use a specific user account
- `-u administrator -w password` - Use credentials explicitly

---

## Domain and Server Information

### Check Joined Domain Status

```bash
# Check if system is joined to a domain
vastool info domain
```

**Example Output:**
```
EXAMPLE.COM
```

**Error if not joined:**
```
ERROR: No domain could be found.
```

### Check System Status

```bash
# Check overall VAS service status
vastool status
```

**Example Output:**
```
DOMAIN: EXAMPLE.COM
SITE: Default-First-Site-Name
SUCCESS: System is in the domain
SUCCESS: System is in a site
```

### Query Domain Controllers

```bash
# List all domain controllers
vastool info servers

# List domain controllers for a specific domain
vastool info servers -d example.com

# List domain controllers for a specific site
vastool info servers -s "Default-First-Site-Name"
```

**Example Output:**
```
dc01.example.com
dc02.example.com
dc03.example.com
```

### Get Domain and Forest Information

```bash
# Get current domain
vastool info domain

# Get domain DN (Distinguished Name)
vastool info domain-dn

# Get forest root domain
vastool info forest-root

# Get forest root DN
vastool info forest-root-dn

# List all domains in forest
vastool info domains
```

**Example Output (domain-dn):**
```
DC=example,DC=com
```

**Example Output (domains):**
```
EXAMPLE.COM
SUBDOMAIN.EXAMPLE.COM
DEV.EXAMPLE.COM
```

### Check Site Information

```bash
# Get current site
vastool info site
```

**Example Output:**
```
Default-First-Site-Name
```

### Check Specific Domain Controller

```bash
# Query specific DC using CLDAP
vastool info cldap dc01.example.com
```

**Example Output:**
```
Forest:          example.com
Domain:          example.com
Domain Controller: dc01.example.com
Site:            Default-First-Site-Name
```

---

## Querying User Records

### List Unix-Enabled Users

```bash
# List all Unix-enabled users (from cache)
vastool list users

# List Unix-enabled users directly from AD (bypass cache)
vastool -u host/ list -l users

# List ALL users including non-Unix-enabled
vastool -u host/ list -la users
```

**Example Output (list users):**
```
jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash
mjones:*:10002:10000:Mary Jones:/home/mjones:/bin/bash
bwilson:*:10003:10001:Bob Wilson:/home/bwilson:/bin/bash
```

**Example Output (list -la users - includes non-Unix-enabled):**
```
jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash
mjones:*:10002:10000:Mary Jones:/home/mjones:/bin/bash
aduser1::::AD User One::
aduser2::::AD User Two::
```

### List Specific User

```bash
# Get specific user details
vastool list user jsmith
```

**Example Output:**
```
jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash
```

### Get User Attributes

```bash
# Get specific attributes for a user
vastool -u host/ attrs jsmith name uidnumber gidnumber gecos unixhomedirectory loginshell

# Get all attributes for a user
vastool -u host/ attrs jsmith
```

**Example Output (specific attributes):**
```
name: jsmith
uidnumber: 10001
gidnumber: 10000
gecos: John Smith
unixhomedirectory: /home/jsmith
loginshell: /bin/bash
```

### Search for Users with LDAP Filters

```bash
# Search for a specific user by sAMAccountName
vastool -u host/ search "(sAMAccountName=jsmith)"

# Search for all person objects, return specific attributes
vastool -u host/ search -b "DC=example,DC=com" "(objectCategory=person)" cn userPrincipalName

# Search for users whose password never expires
vastool -u host/ search -q "(&(objectCategory=person)(useraccountcontrol>=65536)(useraccountcontrol<=131072))" samAccountname
```

**Example Output (search for specific user):**
```
dn: CN=John Smith,OU=Users,DC=example,DC=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: John Smith
sAMAccountName: jsmith
userPrincipalName: jsmith@example.com
```

### List Users Allowed to Login

```bash
# List users with login permissions to this server
vastool list users-allowed
```

**Example Output:**
```
jsmith
mjones
bwilson
```

### Check User Access to Server

```bash
# Check if specific user can access this server
vastool user checkaccess jsmith
```

**Example Output (success):**
```
jsmith has access to this computer
```

**Example Output (denied):**
```
jsmith does not have access to this computer
```

---

## Querying Group Records

### List Unix-Enabled Groups

```bash
# List all Unix-enabled groups (from cache)
vastool list groups

# List Unix-enabled groups directly from AD (bypass cache)
vastool -u host/ list -l groups

# List ALL groups including non-Unix-enabled
vastool -u host/ list -la groups
```

**Example Output (list groups):**
```
unixadmins:*:10000:jsmith,mjones
developers:*:10001:bwilson,jsmith
dbadmins:*:10002:mjones
```

**Example Output with options:**
```bash
# Include objectSid in output
vastool -u host/ list -s groups

# Include primaryGroupToken in output
vastool -u host/ list -t groups
```

### List Specific Group

```bash
# Get specific group details
vastool list group unixadmins
```

**Example Output:**
```
unixadmins:*:10000:jsmith,mjones
```

### Get Group Attributes

```bash
# Get specific attributes for a group
vastool -u host/ attrs -g unixadmins

# Get group members
vastool -u host/ attrs unixadmins member
```

**Example Output (group members):**
```
member: CN=John Smith,OU=Users,DC=example,DC=com
member: CN=Mary Jones,OU=Users,DC=example,DC=com
```

### Search for Groups with LDAP Filters

```bash
# Search for a specific group by sAMAccountName
vastool -u host/ search "(sAMAccountName=unixadmins)"

# Search for group and return members
vastool -u host/ search "(&(grouptype=*)(samaccountname=unixadmins))" member

# Search for all groups in a specific OU
vastool -u host/ search -b "OU=Unix Groups,DC=example,DC=com" "(objectCategory=group)" cn
```

**Example Output (search with members):**
```
dn: CN=unixadmins,OU=Unix Groups,DC=example,DC=com
member: CN=John Smith,OU=Users,DC=example,DC=com
member: CN=Mary Jones,OU=Users,DC=example,DC=com
```

### Get Group Membership Using NSS

```bash
# Get group information via NSS
vastool -u host/ nss getgrnam unixadmins
```

**Example Output:**
```
unixadmins:*:10000:jsmith,mjones
```

---

## Querying Computer/Server Records

### Search for All Computers

```bash
# Search for all computer objects
vastool -u host/ search "(objectClass=computer)" dNSHostName

# Search for computers in a specific OU
vastool -u host/ search -b "OU=Servers,DC=example,DC=com" "(objectClass=computer)" dNSHostName
```

**Example Output:**
```
dNSHostName: server01.example.com
dNSHostName: server02.example.com
dNSHostName: server03.example.com
```

### Search for Linux/Unix Servers

```bash
# Search for Linux servers
vastool -u host/ search "(&(objectClass=computer)(operatingSystem=Linux))" dNSHostName operatingSystem

# Search for Linux servers in specific OU
vastool -u host/ search -s one -b "OU=Unix Machines,DC=example,DC=com" "(operatingSystem=Linux)" dNSHostName

# Search for RHEL servers (note: RHEL may show full version string)
vastool -u host/ search "(&(objectClass=computer)(operatingSystem=Red Hat Enterprise Linux*))" dNSHostName operatingSystem
```

**Example Output:**
```
dn: CN=RHEL-SERVER01,OU=Unix Machines,DC=example,DC=com
dNSHostName: rhel-server01.example.com
operatingSystem: Red Hat Enterprise Linux 9.3

dn: CN=RHEL-SERVER02,OU=Unix Machines,DC=example,DC=com
dNSHostName: rhel-server02.example.com
operatingSystem: Linux
```

**Note:** RHEL systems may show "Red Hat Enterprise Linux X.X" instead of just "Linux" as the operatingSystem attribute if redhat-lsb packages are installed during domain join.

### Search Alternate Domain

```bash
# Search for computers in a different domain
vastool -u host/ search -b DC=subdomain,DC=example,DC=com "(&(objectClass=computer)(operatingSystem=Linux))" dNSHostName
```

**Example Output:**
```
dNSHostName: dev-server01.subdomain.example.com
dNSHostName: dev-server02.subdomain.example.com
```

### Get Computer Attributes

```bash
# Get specific computer attributes
vastool -u host/ search "(cn=server01)" dNSHostName operatingSystem operatingSystemVersion

# Get all attributes for a computer
vastool -u host/ attrs -h server01
```

**Example Output:**
```
dn: CN=SERVER01,OU=Servers,DC=example,DC=com
dNSHostName: server01.example.com
operatingSystem: Red Hat Enterprise Linux 9.3
operatingSystemVersion: 9.3
```

---

## Finding Server Access Groups

Server access in VAS environments is typically controlled through group membership. Here are methods to find which groups have access to a server.

### Method 1: Check Host Attributes for Allowed Groups

```bash
# Check if a specific group is allowed for this host
vastool -u host/ attrs -h $(hostname) | grep -i group
```

**Example Output:**
```
memberOf: CN=Server-Access-Group,OU=Groups,DC=example,DC=com
memberOf: CN=Unix-Servers,OU=Groups,DC=example,DC=com
```

### Method 2: List Users Allowed and Check Their Groups

```bash
# List users allowed to access this server
vastool list users-allowed

# For each user, check their group memberships
vastool -u host/ search "(sAMAccountName=jsmith)" memberOf
```

**Example Output (user's groups):**
```
memberOf: CN=unixadmins,OU=Unix Groups,DC=example,DC=com
memberOf: CN=developers,OU=Unix Groups,DC=example,DC=com
memberOf: CN=Domain Users,CN=Users,DC=example,DC=com
```

### Method 3: Check VAS Configuration for Access Control

```bash
# Check VAS configuration for user-allow-groups setting
grep -i allow-groups /etc/opt/quest/vas/vas.conf
```

**Example Output:**
```
user-allow-groups = unixadmins, developers
```

### Method 4: Verify Group Has Host in Member List

```bash
# Check if this host is a member of a specific group
vastool -u host/ attrs -g "Server-Access-Group" member | grep "CN=$(hostname -s)"
```

**Example Output:**
```
member: CN=server01,OU=Servers,DC=example,DC=com
```

### Method 5: Query All Groups That Include This Host

```bash
# Search for groups where this host is a member
vastool -u host/ search "(&(objectCategory=group)(member=CN=$(hostname -s),*))" cn
```

**Example Output:**
```
cn: Unix-Servers
cn: RHEL-Servers
cn: Production-Servers
```

---

## Enumerating Unix-Enabled Group Members

Once you've identified the groups that have access to a server, you need to enumerate the Unix-enabled members of those groups.

### Method 1: List Group with Members (Fastest)

```bash
# List group and show members (from cache)
vastool list group unixadmins

# List group and show members (directly from AD)
vastool -u host/ list -l group unixadmins
```

**Example Output:**
```
unixadmins:*:10000:jsmith,mjones,bwilson
```

### Method 2: Get Group Members via Attrs

```bash
# Get member attribute for group
vastool -u host/ attrs unixadmins member
```

**Example Output:**
```
member: CN=John Smith,OU=Users,DC=example,DC=com
member: CN=Mary Jones,OU=Users,DC=example,DC=com
member: CN=Bob Wilson,OU=Users,DC=example,DC=com
```

### Method 3: Get Group Members via Search

```bash
# Search for group and return members
vastool -u host/ search "(&(objectCategory=group)(sAMAccountName=unixadmins))" member
```

**Example Output:**
```
dn: CN=unixadmins,OU=Unix Groups,DC=example,DC=com
member: CN=John Smith,OU=Users,DC=example,DC=com
member: CN=Mary Jones,OU=Users,DC=example,DC=com
member: CN=Bob Wilson,OU=Users,DC=example,DC=com
```

### Method 4: Get Unix Attributes for Each Member

For each member found, get their Unix attributes:

```bash
# Get Unix attributes for a specific user
vastool -u host/ attrs jsmith name uidNumber gidNumber unixHomeDirectory loginShell
```

**Example Output:**
```
name: jsmith
uidNumber: 10001
gidNumber: 10000
unixHomeDirectory: /home/jsmith
loginShell: /bin/bash
```

### Method 5: Filter Only Unix-Enabled Members

```bash
# List all Unix-enabled users
vastool -u host/ list -l users > /tmp/unix_users.txt

# Get group members
vastool -u host/ attrs unixadmins member > /tmp/group_members.txt

# Compare to find which group members are Unix-enabled
# (requires parsing the Distinguished Names from group_members.txt)
```

### Complete Workflow Example

Here's a complete workflow to find all Unix-enabled users who can access a server through a specific group:

```bash
# Step 1: Get the group members
echo "=== Members of unixadmins group ==="
vastool -u host/ attrs unixadmins member

# Step 2: List all Unix-enabled users who are in that group
echo -e "\n=== Unix-enabled members ==="
vastool list group unixadmins

# Step 3: For each member, get their full Unix attributes
echo -e "\n=== Detailed Unix attributes for each member ==="
for user in $(vastool list group unixadmins | cut -d: -f4 | tr ',' '\n'); do
    echo "--- User: $user ---"
    vastool -u host/ attrs $user name uidNumber gidNumber gecos unixHomeDirectory loginShell
    echo
done
```

**Example Output:**
```
=== Members of unixadmins group ===
member: CN=John Smith,OU=Users,DC=example,DC=com
member: CN=Mary Jones,OU=Users,DC=example,DC=com
member: CN=Bob Wilson,OU=Users,DC=example,DC=com

=== Unix-enabled members ===
unixadmins:*:10000:jsmith,mjones,bwilson

=== Detailed Unix attributes for each member ===
--- User: jsmith ---
name: jsmith
uidNumber: 10001
gidNumber: 10000
gecos: John Smith
unixHomeDirectory: /home/jsmith
loginShell: /bin/bash

--- User: mjones ---
name: mjones
uidNumber: 10002
gidNumber: 10000
gecos: Mary Jones
unixHomeDirectory: /home/mjones
loginShell: /bin/bash

--- User: bwilson ---
name: bwilson
uidNumber: 10003
gidNumber: 10001
gecos: Bob Wilson
unixHomeDirectory: /home/bwilson
loginShell: /bin/bash
```

### Finding Nested Group Memberships

Groups can be nested in Active Directory. To find all effective members including nested groups:

```bash
# Get direct members
vastool -u host/ attrs unixadmins member

# For each group found in members, recursively get their members
vastool -u host/ attrs nestedgroup member
```

**Example with nested groups:**
```bash
# Check if member is a group or user by searching for objectClass
vastool -u host/ search "(distinguishedName=CN=Developers,OU=Groups,DC=example,DC=com)" objectClass
```

**Example Output:**
```
objectClass: top
objectClass: group
```

---

## Advanced Search with LDAP Filters

The `vastool search` command supports full LDAP filter syntax for complex queries.

### LDAP Filter Operators

- `&` - AND operator
- `|` - OR operator
- `!` - NOT operator
- `=` - Equals
- `>=` - Greater than or equal
- `<=` - Less than or equal
- `~=` - Approximately equal
- `*` - Wildcard

### Search Scope Options

```bash
# -s base    - Search only the base object
# -s one     - Search one level below base
# -s sub     - Search entire subtree (default)
```

### Complex Filter Examples

#### Find All Unix-Enabled Users in a Specific OU

```bash
vastool -u host/ search -b "OU=Users,DC=example,DC=com" "(&(objectCategory=person)(uidNumber=*))" sAMAccountName uidNumber
```

**Example Output:**
```
dn: CN=John Smith,OU=Users,DC=example,DC=com
sAMAccountName: jsmith
uidNumber: 10001

dn: CN=Mary Jones,OU=Users,DC=example,DC=com
sAMAccountName: mjones
uidNumber: 10002
```

#### Find All Groups with Specific GID Range

```bash
vastool -u host/ search "(&(objectCategory=group)(gidNumber>=10000)(gidNumber<=10999))" cn gidNumber
```

**Example Output:**
```
dn: CN=unixadmins,OU=Unix Groups,DC=example,DC=com
cn: unixadmins
gidNumber: 10000

dn: CN=developers,OU=Unix Groups,DC=example,DC=com
cn: developers
gidNumber: 10001
```

#### Find All Disabled User Accounts

```bash
vastool -u host/ search "(&(objectCategory=person)(userAccountControl:1.2.840.113556.1.4.803:=2))" sAMAccountName
```

**Example Output:**
```
sAMAccountName: disableduser1
sAMAccountName: disableduser2
```

#### Find All Service Accounts

```bash
vastool -u host/ search "(&(objectCategory=person)(sAMAccountName=svc*))" sAMAccountName description
```

**Example Output:**
```
sAMAccountName: svc_apache
description: Apache Web Server Service Account

sAMAccountName: svc_postgres
description: PostgreSQL Database Service Account
```

#### Find Users with Specific Login Shell

```bash
vastool -u host/ search "(&(objectCategory=person)(loginShell=/bin/bash))" sAMAccountName loginShell
```

**Example Output:**
```
sAMAccountName: jsmith
loginShell: /bin/bash

sAMAccountName: mjones
loginShell: /bin/bash
```

#### Find Computers by Operating System Pattern

```bash
vastool -u host/ search "(&(objectClass=computer)(operatingSystem=*Enterprise Linux*))" dNSHostName operatingSystem
```

**Example Output:**
```
dNSHostName: rhel-server01.example.com
operatingSystem: Red Hat Enterprise Linux 9.3

dNSHostName: rhel-server02.example.com
operatingSystem: Red Hat Enterprise Linux 8.8
```

#### Find All OUs and Containers

```bash
vastool -u host/ search -b "DC=example,DC=com" -s one "(|(objectClass=container)(objectClass=organizationalUnit))" dn
```

**Example Output:**
```
dn: CN=Users,DC=example,DC=com
dn: OU=Unix Users,DC=example,DC=com
dn: OU=Unix Groups,DC=example,DC=com
dn: OU=Servers,DC=example,DC=com
```

#### Search by UID Number

```bash
vastool -u host/ search "uidNumber=10001" sAMAccountName name uidNumber
```

**Example Output:**
```
dn: CN=John Smith,OU=Users,DC=example,DC=com
sAMAccountName: jsmith
name: jsmith
uidNumber: 10001
```

---

## Common Administrative Commands

### Cache Management

```bash
# Flush the VAS cache (forces refresh from AD)
vastool flush

# Force cache update for a specific operation
vastool -u host/ list -f users
vastool -u host/ list -f groups
```

### Kerberos Operations

```bash
# Get a Kerberos ticket for a user
vastool kinit username

# Get a Kerberos ticket with password
vastool -u username -w password kinit

# List current Kerberos tickets
vastool klist

# Destroy Kerberos tickets
vastool kdestroy
```

**Example Output (klist):**
```
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: jsmith@EXAMPLE.COM

Valid starting     Expires            Service principal
12/06/25 10:30:00  12/06/25 20:30:00  krbtgt/EXAMPLE.COM@EXAMPLE.COM
```

### Time Synchronization

```bash
# Check time difference with domain controllers
vastool timesync

# Synchronize time with domain controllers (requires root)
vastool timesync -u
```

**Example Output:**
```
Domain controller: dc01.example.com
Local time:  Fri Dec  6 10:30:00 2025
Remote time: Fri Dec  6 10:30:01 2025
Difference: 1 seconds
```

### Configuration Management

```bash
# Configure PAM for domain authentication
vastool configure pam

# Configure NSS for domain users/groups
vastool configure nss

# Show current configuration
vastool info toconf
```

### Version and Help

```bash
# Check vastool version
vastool -v

# Get help for vastool
vastool --help

# Get help for specific command
vastool search --help
```

**Example Output (version):**
```
vastool 4.2.4.30023 (x86_64-redhat-linux)
```

### Joining and Unjoining Domain

```bash
# Join domain (requires admin credentials)
vastool -u administrator join example.com

# Join domain with specific OU
vastool -u administrator join -c "OU=Unix Servers,DC=example,DC=com" example.com

# Unjoin domain (requires admin credentials)
vastool -u administrator unjoin

# Force unjoin (local operation only)
vastool unjoin -f -l
```

---

## Performance and Cache Considerations

### Using Cache vs Direct LDAP Queries

**From Cache (Fast - No Credentials Needed):**
```bash
vastool list users
vastool list groups
```

**Direct from AD (Slower - Requires Credentials):**
```bash
vastool -u host/ list -l users
vastool -u host/ list -l groups
```

**Warning:** Using `-la` (list all including non-Unix-enabled) in large environments can be very slow and produce hundreds of thousands of lines of output.

### Best Practices

1. **Use cache for routine queries** - Faster and doesn't require authentication
2. **Use `-l` flag when you need current data** - Bypasses cache and queries AD directly
3. **Use `-f` flag to force cache refresh** - Updates cache from AD before returning results
4. **Be cautious with `-a` flag** - In large environments, this can return massive amounts of data
5. **Use specific LDAP filters** - More efficient than retrieving all objects and filtering locally
6. **Specify search base with `-b`** - Limits scope and improves performance

---

## Troubleshooting Tips

### Check Domain Join Status

```bash
vastool status
vastool info domain
```

### Verify User Can Access System

```bash
vastool user checkaccess username
```

### Test Group Membership

```bash
vastool list group groupname
vastool -u host/ attrs username memberOf
```

### Debug LDAP Searches

```bash
# Add verbosity to see what's happening
vastool -d5 search "(sAMAccountName=username)"
```

### Common Issues

1. **"ERROR: No domain could be found"** - System is not joined to a domain
2. **"INFO: 232 No srvinfo entry for joined domain"** - Informational, usually not a problem
3. **Empty results from search** - Check authentication, search base, and LDAP filter syntax
4. **Slow queries** - Use cache, limit search scope with `-b`, avoid `-a` flag

---

## References and Sources

This guide was compiled from official One Identity Safeguard Authentication Services documentation and community resources:

- [vastool cheat-sheet | BashPi](https://www.bashpi.org/?page_id=803)
- [vastool Man Pages](https://ohares.us/reference/VAS/VAS_Manpages/vastool.html)
- [Man pages for vastool command - 4.1.1](https://support.oneidentity.com/safeguard-authentication-services/kb/4267373/man-pages-for-vastool-command-4-1-1)
- [Safeguard Authentication Services Administration Guide](https://support-public.cfm.quest.com/71484_SafeguardAuthenticationServices_5.1.3_AdministrationGuide.pdf)
- [How to view all users who are allowed to log on to a unix server](https://support.oneidentity.com/kb/4280934/how-to-view-all-users-who-are-allowed-to-log-on-to-a-unix-server)
- [How to list and count users with vastool list command](https://support.oneidentity.com/safeguard-authentication-services/kb/4290480/how-to-list-and-count-users-with-vastool-list-command)
- [How to determine what groups a user belongs to](https://support.oneidentity.com/authentication-services/kb/92119/how-to-determine-what-groups-a-user-belongs-to-)
- [Vastool command to list Unix machine objects from a specified OU](https://support.oneidentity.com/authentication-services/kb/54452/vastool-command-to-list-unix-machine-objects-from-a-specified-ou)
- [How can I search an alternate domain using vastool?](https://support.oneidentity.com/safeguard-authentication-services/kb/4347546/how-can-i-search-an-alternate-domain-using-vastool)

---

*Last Updated: December 6, 2025*
