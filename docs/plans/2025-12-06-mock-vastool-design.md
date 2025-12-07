# Mock Vastool Design

**Date**: 2025-12-06
**Purpose**: Create a comprehensive mock vastool implementation for all 5 Podmania containers to simulate Quest/One Identity Authentication Services integration with Active Directory

---

## Overview

This design creates a fully functional mock `vastool` command-line utility that returns realistic Active Directory data across all 5 RHEL 9 containers in the Podmania environment. The mock implementation supports all major vastool commands with accurate output formatting.

## Mock Domain Architecture

### Domain Structure
- **Domain**: `EXAMPLE.COM`
- **Domain DN**: `DC=example,DC=com`
- **Forest Root**: `EXAMPLE.COM`
- **Forest Root DN**: `DC=example,DC=com`
- **Site**: `Default-First-Site-Name`

### Domain Controllers
- `dc01.example.com` (172.25.0.100)
- `dc02.example.com` (172.25.0.101)

### Mock Users (Unix-Enabled)
| Username | UID | GID | Full Name | Home | Shell | Groups |
|----------|-----|-----|-----------|------|-------|--------|
| jsmith | 10001 | 10000 | John Smith | /home/jsmith | /bin/bash | unixadmins, developers |
| mjones | 10002 | 10000 | Mary Jones | /home/mjones | /bin/bash | unixadmins, dbadmins |
| bwilson | 10003 | 10001 | Bob Wilson | /home/bwilson | /bin/bash | developers |
| kadmin | 10004 | 10002 | Kerberos Admin | /home/kadmin | /bin/bash | dbadmins |
| svc_app | 10005 | 10003 | Application Service Account | /home/svc_app | /bin/bash | svcaccounts |

### Mock Groups (Unix-Enabled)
| Group Name | GID | Members |
|------------|-----|---------|
| unixadmins | 10000 | jsmith, mjones |
| developers | 10001 | bwilson, jsmith |
| dbadmins | 10002 | mjones, kadmin |
| svcaccounts | 10003 | svc_app |

### Server Objects
Each container reports itself correctly:
- **jump-server**: `CN=jump-server,OU=Unix Servers,DC=example,DC=com` (172.25.0.10)
- **target-server-1**: `CN=target-server-1,OU=Unix Servers,DC=example,DC=com` (172.25.0.11)
- **target-server-2**: `CN=target-server-2,OU=Unix Servers,DC=example,DC=com` (172.25.0.12)
- **target-server-3**: `CN=target-server-3,OU=Unix Servers,DC=example,DC=com` (172.25.0.13)
- **target-server-4**: `CN=target-server-4,OU=Unix Servers,DC=example,DC=com` (172.25.0.14)

### Access Control Rules
- **jump-server**: All users have access (unixadmins, developers groups)
- **target-server-1**: Only unixadmins group (jsmith, mjones)
- **target-server-2**: Only unixadmins group (jsmith, mjones)
- **target-server-3**: developers and unixadmins groups (jsmith, mjones, bwilson)
- **target-server-4**: dbadmins and unixadmins groups (jsmith, mjones, kadmin)

---

## Script Architecture

### Directory Structure
```
/opt/quest/
├── bin/
│   └── vastool (main executable Bash script, mode 755)
└── etc/
    ├── domain.json          # Domain and site configuration
    ├── users.json           # All user objects with full AD attributes
    ├── groups.json          # All group objects with members
    ├── computers.json       # All computer/server objects
    └── access-control.json  # Per-server access rules
```

### Script Components

1. **Command Parser**
   - getopt-style argument processing
   - Support for short and long options
   - Handles `-u`, `-w`, `-s`, `-b`, `-q`, `-d5`, etc.

2. **Data Loading**
   - Parse JSON files using `jq` (if available) or pure Bash
   - Cache data in memory for performance
   - Hostname detection for server-specific responses

3. **Command Handlers**
   - Dedicated function for each command category
   - LDAP filter parser for search operations
   - Output formatter for each command type

4. **Helper Functions**
   - LDIF output generator
   - Passwd/group format converter
   - DN (Distinguished Name) parser
   - LDAP filter evaluator

---

## JSON Data File Schemas

### domain.json
```json
{
  "domain": "EXAMPLE.COM",
  "domain_dn": "DC=example,DC=com",
  "forest_root": "EXAMPLE.COM",
  "forest_root_dn": "DC=example,DC=com",
  "site": "Default-First-Site-Name",
  "domain_controllers": [
    {
      "hostname": "dc01.example.com",
      "ip": "172.25.0.100",
      "site": "Default-First-Site-Name"
    },
    {
      "hostname": "dc02.example.com",
      "ip": "172.25.0.101",
      "site": "Default-First-Site-Name"
    }
  ]
}
```

### users.json
```json
{
  "users": [
    {
      "sAMAccountName": "jsmith",
      "cn": "John Smith",
      "name": "jsmith",
      "distinguishedName": "CN=John Smith,OU=Users,DC=example,DC=com",
      "userPrincipalName": "jsmith@example.com",
      "objectClass": ["top", "person", "organizationalPerson", "user"],
      "objectCategory": "person",
      "uidNumber": 10001,
      "gidNumber": 10000,
      "unixHomeDirectory": "/home/jsmith",
      "loginShell": "/bin/bash",
      "gecos": "John Smith",
      "memberOf": [
        "CN=unixadmins,OU=Unix Groups,DC=example,DC=com",
        "CN=developers,OU=Unix Groups,DC=example,DC=com",
        "CN=Domain Users,CN=Users,DC=example,DC=com"
      ],
      "unixEnabled": true,
      "accountEnabled": true,
      "userAccountControl": 512
    }
  ]
}
```

### groups.json
```json
{
  "groups": [
    {
      "sAMAccountName": "unixadmins",
      "cn": "unixadmins",
      "name": "unixadmins",
      "distinguishedName": "CN=unixadmins,OU=Unix Groups,DC=example,DC=com",
      "objectClass": ["top", "group"],
      "objectCategory": "group",
      "gidNumber": 10000,
      "member": [
        "CN=John Smith,OU=Users,DC=example,DC=com",
        "CN=Mary Jones,OU=Users,DC=example,DC=com"
      ],
      "memberUsernames": ["jsmith", "mjones"],
      "unixEnabled": true,
      "groupType": -2147483646,
      "primaryGroupToken": 10000
    }
  ]
}
```

### computers.json
```json
{
  "computers": [
    {
      "cn": "jump-server",
      "name": "jump-server",
      "sAMAccountName": "jump-server$",
      "distinguishedName": "CN=jump-server,OU=Unix Servers,DC=example,DC=com",
      "dNSHostName": "jump-server.example.com",
      "objectClass": ["top", "computer"],
      "objectCategory": "computer",
      "operatingSystem": "Red Hat Enterprise Linux 9.3",
      "operatingSystemVersion": "9.3",
      "ipAddress": "172.25.0.10"
    }
  ]
}
```

### access-control.json
```json
{
  "server_access": {
    "jump-server": {
      "allowed_groups": ["unixadmins", "developers"],
      "allowed_users": ["jsmith", "mjones", "bwilson"]
    },
    "target-server-1": {
      "allowed_groups": ["unixadmins"],
      "allowed_users": ["jsmith", "mjones"]
    },
    "target-server-2": {
      "allowed_groups": ["unixadmins"],
      "allowed_users": ["jsmith", "mjones"]
    },
    "target-server-3": {
      "allowed_groups": ["unixadmins", "developers"],
      "allowed_users": ["jsmith", "mjones", "bwilson"]
    },
    "target-server-4": {
      "allowed_groups": ["unixadmins", "dbadmins"],
      "allowed_users": ["jsmith", "mjones", "kadmin"]
    }
  }
}
```

---

## Command Implementation

### High-Priority Commands (Must Have Perfect Output)

#### 1. Info Commands
```bash
vastool info domain           # → EXAMPLE.COM
vastool info site             # → Default-First-Site-Name
vastool info servers          # → dc01.example.com\ndc02.example.com
vastool info domain-dn        # → DC=example,DC=com
vastool info forest-root      # → EXAMPLE.COM
vastool info forest-root-dn   # → DC=example,DC=com
vastool info domains          # → EXAMPLE.COM
vastool info cldap dc01.example.com  # → Formatted CLDAP output
```

#### 2. Status Command
```bash
vastool status
```
**Output:**
```
DOMAIN: EXAMPLE.COM
SITE: Default-First-Site-Name
SUCCESS: System is in the domain
SUCCESS: System is in a site
```

#### 3. List Commands
```bash
# List Unix-enabled users
vastool list users
# Output: jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash

# List all users including non-Unix-enabled
vastool list -la users

# List Unix-enabled groups
vastool list groups
# Output: unixadmins:*:10000:jsmith,mjones

# List users allowed on this server
vastool list users-allowed
# Output: jsmith\nmjones (varies by server)
```

**Flags:**
- `-l`: Bypass cache (no-op in mock)
- `-a`: Include non-Unix-enabled objects
- `-s`: Include objectSid
- `-t`: Include primaryGroupToken
- `-f`: Force refresh (no-op in mock)

#### 4. Search Command
```bash
# Search for user
vastool -u host/ search "(sAMAccountName=jsmith)"

# Search with attributes
vastool -u host/ search "(objectCategory=person)" cn uidNumber

# Search with base DN
vastool -u host/ search -b "OU=Users,DC=example,DC=com" "(uidNumber=10001)"

# Complex filters
vastool -u host/ search "(&(objectClass=computer)(operatingSystem=*Linux*))" dNSHostName
```

**LDAP Filters Supported:**
- Simple: `(attribute=value)`
- Wildcards: `(attribute=*value*)`, `(attribute=value*)`
- AND: `(&(filter1)(filter2)...)`
- OR: `(|(filter1)(filter2)...)`
- NOT: `(!(filter))`
- Presence: `(attribute=*)`

**Output Format:** LDIF-style
```
dn: CN=John Smith,OU=Users,DC=example,DC=com
sAMAccountName: jsmith
cn: John Smith
uidNumber: 10001
```

#### 5. Attrs Command
```bash
# Get user attributes
vastool -u host/ attrs jsmith name uidNumber gidNumber

# Get all user attributes
vastool -u host/ attrs jsmith

# Get group attributes
vastool -u host/ attrs -g unixadmins member

# Get host attributes
vastool -u host/ attrs -h jump-server
```

**Output Format:**
```
name: jsmith
uidNumber: 10001
gidNumber: 10000
```

#### 6. User Checkaccess
```bash
vastool user checkaccess jsmith
```

**Output (success):**
```
jsmith has access to this computer
```
Exit code: 0

**Output (denied):**
```
jsmith does not have access to this computer
```
Exit code: 1

### Medium-Priority Commands

#### 7. Kerberos Commands
```bash
vastool kinit username          # Create mock ticket
vastool klist                   # Show mock tickets
vastool kdestroy                # Remove mock tickets
```

#### 8. Cache Management
```bash
vastool flush                   # No-op, prints "Cache flushed"
```

#### 9. Version and Help
```bash
vastool -v                      # → vastool 4.2.4.30023 (x86_64-redhat-linux)
vastool --version               # Same as -v
vastool --help                  # Usage information
```

---

## Installation & Deployment

### Method: Direct Copy (Method A)

Installation will be handled by `install-mock-vastool.sh` script that runs on the Mac host.

### Installation Steps

1. **Create directory structure in each container**
   ```bash
   podman exec <container> mkdir -p /opt/quest/bin /opt/quest/etc
   ```

2. **Copy files to containers**
   ```bash
   podman cp vastool <container>:/opt/quest/bin/vastool
   podman cp domain.json <container>:/opt/quest/etc/
   podman cp users.json <container>:/opt/quest/etc/
   podman cp groups.json <container>:/opt/quest/etc/
   podman cp computers.json <container>:/opt/quest/etc/
   podman cp access-control.json <container>:/opt/quest/etc/
   ```

3. **Set permissions**
   ```bash
   podman exec <container> chmod 755 /opt/quest/bin/vastool
   podman exec <container> chmod 644 /opt/quest/etc/*.json
   ```

4. **Create symlink for PATH access**
   ```bash
   podman exec <container> ln -sf /opt/quest/bin/vastool /usr/local/bin/vastool
   ```

5. **Install jq (if needed for JSON parsing)**
   ```bash
   podman exec <container> dnf install -y jq
   ```

### Containers to Install
- jump-server
- target-server-1
- target-server-2
- target-server-3
- target-server-4

### Verification Tests

After installation, verify each container:
```bash
# Version check
vastool -v

# Domain check
vastool info domain

# Status check
vastool status

# List users
vastool list users

# Search test
vastool search "(sAMAccountName=jsmith)" cn

# Access check
vastool user checkaccess jsmith
```

---

## Implementation Plan

### Phase 1: Core Data Files
1. Create `domain.json` with domain configuration
2. Create `users.json` with 5 mock users and full attributes
3. Create `groups.json` with 4 mock groups
4. Create `computers.json` with all 5 servers
5. Create `access-control.json` with per-server rules

### Phase 2: Main Vastool Script
1. Create command parser and argument handling
2. Implement JSON data loading (with jq and Bash fallback)
3. Implement hostname detection
4. Create helper functions (DN parser, filter evaluator, formatters)

### Phase 3: Command Implementations
1. Implement `info` commands
2. Implement `status` command
3. Implement `list` commands with all flags
4. Implement `search` command with LDAP filter parsing
5. Implement `attrs` command
6. Implement `user checkaccess` command
7. Implement Kerberos commands (mock)
8. Implement cache and utility commands
9. Add help and version output

### Phase 4: Installation
1. Create `install-mock-vastool.sh` installer script
2. Test installation on one container
3. Deploy to all 5 containers
4. Run verification tests

### Phase 5: Testing & Validation
1. Test each command on each container
2. Verify hostname-specific behavior
3. Test access control rules
4. Validate output formatting matches real vastool
5. Test LDAP filter parsing with complex queries

---

## Success Criteria

- ✅ All 5 containers have functional `vastool` command
- ✅ `vastool -v` returns version information
- ✅ `vastool status` shows domain joined status
- ✅ `vastool list users` returns all mock users in correct format
- ✅ `vastool search` handles basic and complex LDAP filters
- ✅ `vastool user checkaccess` correctly enforces server-specific access rules
- ✅ Each container reports its own hostname and IP correctly
- ✅ Output formatting matches real vastool examples from reference guide

---

## Future Enhancements

- Add non-Unix-enabled users/groups for testing `-a` flag
- Add nested group support
- Add password policy attributes
- Add user account status (locked, disabled, expired)
- Add Kerberos ticket validation simulation
- Add `vastool configure` simulation for PAM/NSS
- Add `vastool timesync` simulation

---

## References

- [vastool-reference-guide.md](../vastool-reference-guide.md) - Comprehensive vastool command reference
- One Identity Safeguard Authentication Services documentation
- LDAP filter syntax specification (RFC 4515)
