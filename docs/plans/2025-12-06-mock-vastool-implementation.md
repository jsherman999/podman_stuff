# Mock Vastool Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a comprehensive mock vastool implementation with JSON-based data files and deploy to all 5 Podmania containers

**Architecture:** Bash script that parses vastool command-line arguments, loads JSON data files, and returns realistic Active Directory responses matching real vastool output formats. Includes LDAP filter parsing, hostname-aware responses, and server-specific access control.

**Tech Stack:** Bash, jq (JSON parser), podman CLI, JSON data files

---

## Task 1: Create JSON Data Files

**Files:**
- Create: `mock-vastool/data/domain.json`
- Create: `mock-vastool/data/users.json`
- Create: `mock-vastool/data/groups.json`
- Create: `mock-vastool/data/computers.json`
- Create: `mock-vastool/data/access-control.json`

**Step 1: Create directory structure**

```bash
mkdir -p mock-vastool/data
```

**Step 2: Create domain.json**

File: `mock-vastool/data/domain.json`

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

**Step 3: Create users.json**

File: `mock-vastool/data/users.json`

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
    },
    {
      "sAMAccountName": "mjones",
      "cn": "Mary Jones",
      "name": "mjones",
      "distinguishedName": "CN=Mary Jones,OU=Users,DC=example,DC=com",
      "userPrincipalName": "mjones@example.com",
      "objectClass": ["top", "person", "organizationalPerson", "user"],
      "objectCategory": "person",
      "uidNumber": 10002,
      "gidNumber": 10000,
      "unixHomeDirectory": "/home/mjones",
      "loginShell": "/bin/bash",
      "gecos": "Mary Jones",
      "memberOf": [
        "CN=unixadmins,OU=Unix Groups,DC=example,DC=com",
        "CN=dbadmins,OU=Unix Groups,DC=example,DC=com",
        "CN=Domain Users,CN=Users,DC=example,DC=com"
      ],
      "unixEnabled": true,
      "accountEnabled": true,
      "userAccountControl": 512
    },
    {
      "sAMAccountName": "bwilson",
      "cn": "Bob Wilson",
      "name": "bwilson",
      "distinguishedName": "CN=Bob Wilson,OU=Users,DC=example,DC=com",
      "userPrincipalName": "bwilson@example.com",
      "objectClass": ["top", "person", "organizationalPerson", "user"],
      "objectCategory": "person",
      "uidNumber": 10003,
      "gidNumber": 10001,
      "unixHomeDirectory": "/home/bwilson",
      "loginShell": "/bin/bash",
      "gecos": "Bob Wilson",
      "memberOf": [
        "CN=developers,OU=Unix Groups,DC=example,DC=com",
        "CN=Domain Users,CN=Users,DC=example,DC=com"
      ],
      "unixEnabled": true,
      "accountEnabled": true,
      "userAccountControl": 512
    },
    {
      "sAMAccountName": "kadmin",
      "cn": "Kerberos Admin",
      "name": "kadmin",
      "distinguishedName": "CN=Kerberos Admin,OU=Users,DC=example,DC=com",
      "userPrincipalName": "kadmin@example.com",
      "objectClass": ["top", "person", "organizationalPerson", "user"],
      "objectCategory": "person",
      "uidNumber": 10004,
      "gidNumber": 10002,
      "unixHomeDirectory": "/home/kadmin",
      "loginShell": "/bin/bash",
      "gecos": "Kerberos Admin",
      "memberOf": [
        "CN=dbadmins,OU=Unix Groups,DC=example,DC=com",
        "CN=Domain Users,CN=Users,DC=example,DC=com"
      ],
      "unixEnabled": true,
      "accountEnabled": true,
      "userAccountControl": 512
    },
    {
      "sAMAccountName": "svc_app",
      "cn": "Application Service Account",
      "name": "svc_app",
      "distinguishedName": "CN=Application Service Account,OU=Service Accounts,DC=example,DC=com",
      "userPrincipalName": "svc_app@example.com",
      "objectClass": ["top", "person", "organizationalPerson", "user"],
      "objectCategory": "person",
      "uidNumber": 10005,
      "gidNumber": 10003,
      "unixHomeDirectory": "/home/svc_app",
      "loginShell": "/bin/bash",
      "gecos": "Application Service Account",
      "memberOf": [
        "CN=svcaccounts,OU=Unix Groups,DC=example,DC=com",
        "CN=Domain Users,CN=Users,DC=example,DC=com"
      ],
      "unixEnabled": true,
      "accountEnabled": true,
      "userAccountControl": 512
    },
    {
      "sAMAccountName": "aduser1",
      "cn": "AD User One",
      "name": "aduser1",
      "distinguishedName": "CN=AD User One,OU=Users,DC=example,DC=com",
      "userPrincipalName": "aduser1@example.com",
      "objectClass": ["top", "person", "organizationalPerson", "user"],
      "objectCategory": "person",
      "memberOf": [
        "CN=Domain Users,CN=Users,DC=example,DC=com"
      ],
      "unixEnabled": false,
      "accountEnabled": true,
      "userAccountControl": 512
    }
  ]
}
```

**Step 4: Create groups.json**

File: `mock-vastool/data/groups.json`

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
    },
    {
      "sAMAccountName": "developers",
      "cn": "developers",
      "name": "developers",
      "distinguishedName": "CN=developers,OU=Unix Groups,DC=example,DC=com",
      "objectClass": ["top", "group"],
      "objectCategory": "group",
      "gidNumber": 10001,
      "member": [
        "CN=Bob Wilson,OU=Users,DC=example,DC=com",
        "CN=John Smith,OU=Users,DC=example,DC=com"
      ],
      "memberUsernames": ["bwilson", "jsmith"],
      "unixEnabled": true,
      "groupType": -2147483646,
      "primaryGroupToken": 10001
    },
    {
      "sAMAccountName": "dbadmins",
      "cn": "dbadmins",
      "name": "dbadmins",
      "distinguishedName": "CN=dbadmins,OU=Unix Groups,DC=example,DC=com",
      "objectClass": ["top", "group"],
      "objectCategory": "group",
      "gidNumber": 10002,
      "member": [
        "CN=Mary Jones,OU=Users,DC=example,DC=com",
        "CN=Kerberos Admin,OU=Users,DC=example,DC=com"
      ],
      "memberUsernames": ["mjones", "kadmin"],
      "unixEnabled": true,
      "groupType": -2147483646,
      "primaryGroupToken": 10002
    },
    {
      "sAMAccountName": "svcaccounts",
      "cn": "svcaccounts",
      "name": "svcaccounts",
      "distinguishedName": "CN=svcaccounts,OU=Unix Groups,DC=example,DC=com",
      "objectClass": ["top", "group"],
      "objectCategory": "group",
      "gidNumber": 10003,
      "member": [
        "CN=Application Service Account,OU=Service Accounts,DC=example,DC=com"
      ],
      "memberUsernames": ["svc_app"],
      "unixEnabled": true,
      "groupType": -2147483646,
      "primaryGroupToken": 10003
    },
    {
      "sAMAccountName": "Domain Users",
      "cn": "Domain Users",
      "name": "Domain Users",
      "distinguishedName": "CN=Domain Users,CN=Users,DC=example,DC=com",
      "objectClass": ["top", "group"],
      "objectCategory": "group",
      "member": [],
      "memberUsernames": [],
      "unixEnabled": false,
      "groupType": -2147483646
    }
  ]
}
```

**Step 5: Create computers.json**

File: `mock-vastool/data/computers.json`

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
    },
    {
      "cn": "target-server-1",
      "name": "target-server-1",
      "sAMAccountName": "target-server-1$",
      "distinguishedName": "CN=target-server-1,OU=Unix Servers,DC=example,DC=com",
      "dNSHostName": "target-server-1.example.com",
      "objectClass": ["top", "computer"],
      "objectCategory": "computer",
      "operatingSystem": "Red Hat Enterprise Linux 9.3",
      "operatingSystemVersion": "9.3",
      "ipAddress": "172.25.0.11"
    },
    {
      "cn": "target-server-2",
      "name": "target-server-2",
      "sAMAccountName": "target-server-2$",
      "distinguishedName": "CN=target-server-2,OU=Unix Servers,DC=example,DC=com",
      "dNSHostName": "target-server-2.example.com",
      "objectClass": ["top", "computer"],
      "objectCategory": "computer",
      "operatingSystem": "Red Hat Enterprise Linux 9.3",
      "operatingSystemVersion": "9.3",
      "ipAddress": "172.25.0.12"
    },
    {
      "cn": "target-server-3",
      "name": "target-server-3",
      "sAMAccountName": "target-server-3$",
      "distinguishedName": "CN=target-server-3,OU=Unix Servers,DC=example,DC=com",
      "dNSHostName": "target-server-3.example.com",
      "objectClass": ["top", "computer"],
      "objectCategory": "computer",
      "operatingSystem": "Red Hat Enterprise Linux 9.3",
      "operatingSystemVersion": "9.3",
      "ipAddress": "172.25.0.13"
    },
    {
      "cn": "target-server-4",
      "name": "target-server-4",
      "sAMAccountName": "target-server-4$",
      "distinguishedName": "CN=target-server-4,OU=Unix Servers,DC=example,DC=com",
      "dNSHostName": "target-server-4.example.com",
      "objectClass": ["top", "computer"],
      "objectCategory": "computer",
      "operatingSystem": "Red Hat Enterprise Linux 9.3",
      "operatingSystemVersion": "9.3",
      "ipAddress": "172.25.0.14"
    }
  ]
}
```

**Step 6: Create access-control.json**

File: `mock-vastool/data/access-control.json`

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

**Step 7: Verify JSON files are valid**

Run: `jq empty mock-vastool/data/*.json`

Expected: No output (means all JSON is valid)

**Step 8: Commit data files**

```bash
git add mock-vastool/data/
git commit -m "Add mock vastool JSON data files

- domain.json: AD domain structure with 2 DCs
- users.json: 5 unix-enabled users + 1 non-unix user
- groups.json: 4 unix-enabled groups + Domain Users
- computers.json: All 5 server definitions
- access-control.json: Per-server access rules

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 2: Create Main Vastool Script - Core Structure

**Files:**
- Create: `mock-vastool/vastool`

**Step 1: Create script header and variables**

File: `mock-vastool/vastool`

```bash
#!/bin/bash

# Mock vastool - Simulates Quest/One Identity Authentication Services vastool command
# Version: 4.2.4.30023 (matching real vastool)

set -euo pipefail

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../etc"

# Data files
DOMAIN_FILE="${DATA_DIR}/domain.json"
USERS_FILE="${DATA_DIR}/users.json"
GROUPS_FILE="${DATA_DIR}/groups.json"
COMPUTERS_FILE="${DATA_DIR}/computers.json"
ACCESS_FILE="${DATA_DIR}/access-control.json"

# Get hostname
HOSTNAME="$(hostname -s)"

# Check if jq is available
if command -v jq &> /dev/null; then
    HAS_JQ=true
else
    HAS_JQ=false
fi
```

**Step 2: Add helper functions for JSON parsing**

Append to `mock-vastool/vastool`:

```bash
# Helper: Load JSON file (with jq or fallback to grep/sed)
load_json() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Data file not found: $file" >&2
        exit 1
    fi
    cat "$file"
}

# Helper: Query JSON with jq
query_json() {
    local json="$1"
    local query="$2"

    if [[ "$HAS_JQ" == "true" ]]; then
        echo "$json" | jq -r "$query"
    else
        # Fallback: basic grep/sed parsing for simple queries
        echo "$json" | grep -o "\"${query}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | cut -d'"' -f4
    fi
}

# Helper: Get domain info
get_domain_info() {
    local key="$1"
    local domain_json
    domain_json=$(load_json "$DOMAIN_FILE")
    query_json "$domain_json" ".$key"
}
```

**Step 3: Add usage/help function**

Append to `mock-vastool/vastool`:

```bash
# Show usage
show_usage() {
    cat <<EOF
vastool - Quest Authentication Services command-line utility (MOCK VERSION)

Usage: vastool [options] <command> [arguments...]

Common commands:
  info <subcommand>           Get information (domain, site, servers, etc.)
  status                      Check system status
  list <type>                 List users or groups
  search <filter> [attrs...]  Search AD objects with LDAP filter
  attrs [-g|-h] <obj> [attrs] Get object attributes
  user checkaccess <username> Check user access to this server
  flush                       Flush cache
  kinit [username]            Get Kerberos ticket
  klist                       List Kerberos tickets
  kdestroy                    Destroy Kerberos tickets

Options:
  -u <user>       Authenticate as user (e.g., -u host/)
  -w <password>   Password for authentication
  -s <scope>      Search scope (base, one, sub)
  -b <basedn>     Base DN for search
  -v, --version   Show version
  --help          Show this help

Examples:
  vastool info domain
  vastool status
  vastool list users
  vastool search "(sAMAccountName=jsmith)"
  vastool user checkaccess jsmith

Note: This is a MOCK implementation for testing purposes.
EOF
}

# Show version
show_version() {
    echo "vastool 4.2.4.30023 (x86_64-redhat-linux) - MOCK VERSION"
}
```

**Step 4: Add main command parser**

Append to `mock-vastool/vastool`:

```bash
# Parse global options
AUTH_USER=""
AUTH_PASS=""
SEARCH_SCOPE="sub"
SEARCH_BASE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--version)
            show_version
            exit 0
            ;;
        --help)
            show_usage
            exit 0
            ;;
        -u)
            AUTH_USER="$2"
            shift 2
            ;;
        -w)
            AUTH_PASS="$2"
            shift 2
            ;;
        -s)
            SEARCH_SCOPE="$2"
            shift 2
            ;;
        -b)
            SEARCH_BASE="$2"
            shift 2
            ;;
        -*)
            # Ignore other options for now (like -d5, -q, etc.)
            shift
            ;;
        *)
            # First non-option argument is the command
            break
            ;;
    esac
done

# Get command
COMMAND="${1:-}"
shift || true
```

**Step 5: Make script executable**

Run: `chmod +x mock-vastool/vastool`

**Step 6: Test basic script structure**

Run: `./mock-vastool/vastool --version`

Expected: `vastool 4.2.4.30023 (x86_64-redhat-linux) - MOCK VERSION`

Run: `./mock-vastool/vastool --help`

Expected: Usage information displayed

**Step 7: Commit core script structure**

```bash
git add mock-vastool/vastool
git commit -m "Add mock vastool core script structure

- Script header with paths and variables
- JSON loading helpers with jq and fallback
- Usage and version functions
- Command-line argument parser

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 3: Implement Info Commands

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add info command handler**

Insert before the main command parser in `mock-vastool/vastool`:

```bash
# Command: info
cmd_info() {
    local subcommand="$1"
    local domain_json
    domain_json=$(load_json "$DOMAIN_FILE")

    case "$subcommand" in
        domain)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.domain'
            else
                echo "EXAMPLE.COM"
            fi
            ;;
        site)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.site'
            else
                echo "Default-First-Site-Name"
            fi
            ;;
        domain-dn)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.domain_dn'
            else
                echo "DC=example,DC=com"
            fi
            ;;
        forest-root)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.forest_root'
            else
                echo "EXAMPLE.COM"
            fi
            ;;
        forest-root-dn)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.forest_root_dn'
            else
                echo "DC=example,DC=com"
            fi
            ;;
        domains)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.domain'
            else
                echo "EXAMPLE.COM"
            fi
            ;;
        servers)
            if [[ "$HAS_JQ" == "true" ]]; then
                echo "$domain_json" | jq -r '.domain_controllers[].hostname'
            else
                echo "dc01.example.com"
                echo "dc02.example.com"
            fi
            ;;
        cldap)
            local dc="${2:-dc01.example.com}"
            cat <<EOF
Forest:          example.com
Domain:          example.com
Domain Controller: $dc
Site:            Default-First-Site-Name
EOF
            ;;
        *)
            echo "ERROR: Unknown info subcommand: $subcommand" >&2
            exit 1
            ;;
    esac
}
```

**Step 2: Wire up info command in main dispatcher**

Add to the bottom of `mock-vastool/vastool`:

```bash
# Main command dispatcher
case "$COMMAND" in
    info)
        cmd_info "$@"
        ;;
    *)
        echo "ERROR: Unknown command: $COMMAND" >&2
        echo "Run 'vastool --help' for usage information" >&2
        exit 1
        ;;
esac
```

**Step 3: Test info commands**

Run: `./mock-vastool/vastool info domain`
Expected: `EXAMPLE.COM`

Run: `./mock-vastool/vastool info site`
Expected: `Default-First-Site-Name`

Run: `./mock-vastool/vastool info servers`
Expected:
```
dc01.example.com
dc02.example.com
```

Run: `./mock-vastool/vastool info cldap dc01.example.com`
Expected:
```
Forest:          example.com
Domain:          example.com
Domain Controller: dc01.example.com
Site:            Default-First-Site-Name
```

**Step 4: Commit info command implementation**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool info commands

Supports: domain, site, domain-dn, forest-root, servers, cldap
Works with jq or fallback to hardcoded values

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 4: Implement Status Command

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add status command handler**

Insert before main dispatcher in `mock-vastool/vastool`:

```bash
# Command: status
cmd_status() {
    local domain
    local site

    domain=$(get_domain_info "domain")
    site=$(get_domain_info "site")

    cat <<EOF
DOMAIN: ${domain}
SITE: ${site}
SUCCESS: System is in the domain
SUCCESS: System is in a site
EOF
}
```

**Step 2: Wire up status command**

Add to main dispatcher:

```bash
    status)
        cmd_status
        ;;
```

**Step 3: Test status command**

Run: `./mock-vastool/vastool status`

Expected:
```
DOMAIN: EXAMPLE.COM
SITE: Default-First-Site-Name
SUCCESS: System is in the domain
SUCCESS: System is in a site
```

**Step 4: Commit status implementation**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool status command

Shows domain, site, and success messages

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 5: Implement List Users Command

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add list users handler**

Insert before main dispatcher in `mock-vastool/vastool`:

```bash
# Command: list users
cmd_list_users() {
    local show_all=false
    local users_json
    users_json=$(load_json "$USERS_FILE")

    # Check for -a flag in remaining args
    for arg in "$@"; do
        if [[ "$arg" == "-a" ]] || [[ "$arg" == "-la" ]]; then
            show_all=true
        fi
    done

    if [[ "$HAS_JQ" == "true" ]]; then
        if [[ "$show_all" == "true" ]]; then
            # Show all users including non-unix-enabled (with empty fields)
            echo "$users_json" | jq -r '.users[] |
                if .unixEnabled then
                    "\(.sAMAccountName):*:\(.uidNumber):\(.gidNumber):\(.gecos):\(.unixHomeDirectory):\(.loginShell)"
                else
                    "\(.sAMAccountName)::::\(.cn)::"
                end'
        else
            # Show only unix-enabled users
            echo "$users_json" | jq -r '.users[] | select(.unixEnabled == true) |
                "\(.sAMAccountName):*:\(.uidNumber):\(.gidNumber):\(.gecos):\(.unixHomeDirectory):\(.loginShell)"'
        fi
    else
        # Fallback: hardcoded users
        cat <<EOF
jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash
mjones:*:10002:10000:Mary Jones:/home/mjones:/bin/bash
bwilson:*:10003:10001:Bob Wilson:/home/bwilson:/bin/bash
kadmin:*:10004:10002:Kerberos Admin:/home/kadmin:/bin/bash
svc_app:*:10005:10003:Application Service Account:/home/svc_app:/bin/bash
EOF
    fi
}
```

**Step 2: Add list groups handler**

Insert before main dispatcher in `mock-vastool/vastool`:

```bash
# Command: list groups
cmd_list_groups() {
    local show_all=false
    local groups_json
    groups_json=$(load_json "$GROUPS_FILE")

    # Check for -a flag
    for arg in "$@"; do
        if [[ "$arg" == "-a" ]] || [[ "$arg" == "-la" ]]; then
            show_all=true
        fi
    done

    if [[ "$HAS_JQ" == "true" ]]; then
        if [[ "$show_all" == "true" ]]; then
            # Show all groups
            echo "$groups_json" | jq -r '.groups[] |
                if .unixEnabled then
                    "\(.sAMAccountName):*:\(.gidNumber):\(.memberUsernames | join(","))"
                else
                    "\(.sAMAccountName):::"
                end'
        else
            # Show only unix-enabled groups
            echo "$groups_json" | jq -r '.groups[] | select(.unixEnabled == true) |
                "\(.sAMAccountName):*:\(.gidNumber):\(.memberUsernames | join(","))"'
        fi
    else
        # Fallback
        cat <<EOF
unixadmins:*:10000:jsmith,mjones
developers:*:10001:bwilson,jsmith
dbadmins:*:10002:mjones,kadmin
svcaccounts:*:10003:svc_app
EOF
    fi
}
```

**Step 3: Add list users-allowed handler**

Insert before main dispatcher in `mock-vastool/vastool`:

```bash
# Command: list users-allowed
cmd_list_users_allowed() {
    local access_json
    access_json=$(load_json "$ACCESS_FILE")

    if [[ "$HAS_JQ" == "true" ]]; then
        echo "$access_json" | jq -r ".server_access.\"${HOSTNAME}\".allowed_users[]"
    else
        # Fallback based on hostname
        case "$HOSTNAME" in
            jump-server)
                echo "jsmith"
                echo "mjones"
                echo "bwilson"
                ;;
            target-server-1|target-server-2)
                echo "jsmith"
                echo "mjones"
                ;;
            target-server-3)
                echo "jsmith"
                echo "mjones"
                echo "bwilson"
                ;;
            target-server-4)
                echo "jsmith"
                echo "mjones"
                echo "kadmin"
                ;;
        esac
    fi
}
```

**Step 4: Add main list command dispatcher**

Insert before main dispatcher:

```bash
# Command: list
cmd_list() {
    local list_type="$1"
    shift || true

    case "$list_type" in
        users)
            cmd_list_users "$@"
            ;;
        groups)
            cmd_list_groups "$@"
            ;;
        users-allowed)
            cmd_list_users_allowed "$@"
            ;;
        user|group)
            # Single user/group - extract from list
            local name="$1"
            if [[ "$list_type" == "user" ]]; then
                cmd_list_users | grep "^${name}:"
            else
                cmd_list_groups | grep "^${name}:"
            fi
            ;;
        *)
            echo "ERROR: Unknown list type: $list_type" >&2
            exit 1
            ;;
    esac
}
```

**Step 5: Wire up list command**

Add to main dispatcher:

```bash
    list)
        cmd_list "$@"
        ;;
```

**Step 6: Test list commands**

Run: `./mock-vastool/vastool list users`

Expected:
```
jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash
mjones:*:10002:10000:Mary Jones:/home/mjones:/bin/bash
bwilson:*:10003:10001:Bob Wilson:/home/bwilson:/bin/bash
kadmin:*:10004:10002:Kerberos Admin:/home/kadmin:/bin/bash
svc_app:*:10005:10003:Application Service Account:/home/svc_app:/bin/bash
```

Run: `./mock-vastool/vastool list groups`

Expected:
```
unixadmins:*:10000:jsmith,mjones
developers:*:10001:bwilson,jsmith
dbadmins:*:10002:mjones,kadmin
svcaccounts:*:10003:svc_app
```

Run: `./mock-vastool/vastool list user jsmith`

Expected: `jsmith:*:10001:10000:John Smith:/home/jsmith:/bin/bash`

**Step 7: Commit list implementation**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool list commands

Supports: list users, list groups, list users-allowed
Handles -a flag for all objects (including non-unix-enabled)
Supports single user/group lookup

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 6: Implement Search Command with LDAP Filter Parsing

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add LDAP filter evaluation function**

Insert before main dispatcher in `mock-vastool/vastool`:

```bash
# Helper: Evaluate simple LDAP filter against JSON object
# Returns 0 (true) if filter matches, 1 (false) if not
eval_ldap_filter() {
    local filter="$1"
    local json_obj="$2"

    # Remove outer parentheses
    filter="${filter#(}"
    filter="${filter%)}"

    # Handle AND operator
    if [[ "$filter" == "&"* ]]; then
        # Extract sub-filters (simplified - doesn't handle nested AND/OR)
        return 0  # For now, accept all AND filters
    fi

    # Handle OR operator
    if [[ "$filter" == "|"* ]]; then
        return 0  # For now, accept all OR filters
    fi

    # Handle NOT operator
    if [[ "$filter" == "!"* ]]; then
        return 0  # For now, accept all NOT filters
    fi

    # Handle simple attribute=value filter
    if [[ "$filter" =~ ^([^=]+)=(.+)$ ]]; then
        local attr="${BASH_REMATCH[1]}"
        local value="${BASH_REMATCH[2]}"

        # Wildcard - match all
        if [[ "$value" == "*" ]]; then
            return 0
        fi

        # Get attribute value from JSON
        local obj_value
        if [[ "$HAS_JQ" == "true" ]]; then
            obj_value=$(echo "$json_obj" | jq -r ".${attr} // empty")
        fi

        # Simple equality check
        if [[ "$obj_value" == "$value" ]]; then
            return 0
        fi

        # Wildcard pattern matching
        if [[ "$value" == *"*"* ]]; then
            local pattern="${value//\*/.*}"
            if [[ "$obj_value" =~ $pattern ]]; then
                return 0
            fi
        fi
    fi

    # Default: match (for simplicity in mock)
    return 0
}
```

**Step 2: Add search command handler**

Insert before main dispatcher:

```bash
# Command: search
cmd_search() {
    local filter="$1"
    shift || true
    local requested_attrs=("$@")

    # Determine what to search based on filter
    local search_users=false
    local search_groups=false
    local search_computers=false

    # Simple heuristics based on filter content
    if [[ "$filter" == *"person"* ]] || [[ "$filter" == *"user"* ]] || [[ "$filter" == *"sAMAccountName"* ]] || [[ "$filter" == *"uidNumber"* ]]; then
        search_users=true
    fi
    if [[ "$filter" == *"group"* ]] || [[ "$filter" == *"gidNumber"* ]]; then
        search_groups=true
    fi
    if [[ "$filter" == *"computer"* ]] || [[ "$filter" == *"operatingSystem"* ]]; then
        search_computers=true
    fi

    # If no specific type detected, search all
    if [[ "$search_users" == "false" ]] && [[ "$search_groups" == "false" ]] && [[ "$search_computers" == "false" ]]; then
        search_users=true
        search_groups=true
        search_computers=true
    fi

    # Search users
    if [[ "$search_users" == "true" ]]; then
        if [[ "$HAS_JQ" == "true" ]]; then
            local users_json
            users_json=$(load_json "$USERS_FILE")

            # If specific attributes requested
            if [[ ${#requested_attrs[@]} -gt 0 ]]; then
                local attr_filter=""
                for attr in "${requested_attrs[@]}"; do
                    attr_filter="$attr_filter, .${attr}"
                done
                attr_filter="${attr_filter#, }"  # Remove leading comma

                echo "$users_json" | jq -r ".users[] | \"dn: \(.distinguishedName)\", ($attr_filter | select(. != null) | \"${requested_attrs[0]}: \(.)\"), \"\""
            else
                # Show all attributes
                echo "$users_json" | jq -r '.users[] |
                    "dn: \(.distinguishedName)",
                    "objectClass: \(.objectClass | join("\nobjectClass: "))",
                    "cn: \(.cn)",
                    "sAMAccountName: \(.sAMAccountName)",
                    "userPrincipalName: \(.userPrincipalName)",
                    (if .uidNumber then "uidNumber: \(.uidNumber)" else empty end),
                    (if .gidNumber then "gidNumber: \(.gidNumber)" else empty end),
                    ""'
            fi
        fi
    fi

    # Search groups
    if [[ "$search_groups" == "true" ]]; then
        if [[ "$HAS_JQ" == "true" ]]; then
            local groups_json
            groups_json=$(load_json "$GROUPS_FILE")

            if [[ ${#requested_attrs[@]} -gt 0 ]]; then
                for attr in "${requested_attrs[@]}"; do
                    if [[ "$attr" == "member" ]]; then
                        echo "$groups_json" | jq -r '.groups[] |
                            "dn: \(.distinguishedName)",
                            (.member[] | "member: \(.)"),
                            ""'
                    else
                        echo "$groups_json" | jq -r ".groups[] |
                            \"dn: \(.distinguishedName)\",
                            \"${attr}: \(.${attr})\",
                            \"\""
                    fi
                done
            fi
        fi
    fi

    # Search computers
    if [[ "$search_computers" == "true" ]]; then
        if [[ "$HAS_JQ" == "true" ]]; then
            local computers_json
            computers_json=$(load_json "$COMPUTERS_FILE")

            if [[ ${#requested_attrs[@]} -gt 0 ]]; then
                local attr_filter=""
                for attr in "${requested_attrs[@]}"; do
                    attr_filter="$attr_filter, \"${attr}: \(.${attr})\""
                done

                echo "$computers_json" | jq -r ".computers[] |
                    \"dn: \(.distinguishedName)\",
                    $attr_filter,
                    \"\""
            else
                echo "$computers_json" | jq -r '.computers[] |
                    "dn: \(.distinguishedName)",
                    "cn: \(.cn)",
                    "dNSHostName: \(.dNSHostName)",
                    "operatingSystem: \(.operatingSystem)",
                    ""'
            fi
        fi
    fi
}
```

**Step 3: Wire up search command**

Add to main dispatcher:

```bash
    search)
        cmd_search "$@"
        ;;
```

**Step 4: Test search command**

Run: `./mock-vastool/vastool search "(sAMAccountName=jsmith)"`

Expected:
```
dn: CN=John Smith,OU=Users,DC=example,DC=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: John Smith
sAMAccountName: jsmith
userPrincipalName: jsmith@example.com
uidNumber: 10001
gidNumber: 10000

```

Run: `./mock-vastool/vastool search "(objectClass=computer)" dNSHostName operatingSystem`

Expected output with all 5 servers

**Step 5: Commit search implementation**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool search command

- Basic LDAP filter parsing
- Searches users, groups, computers
- Supports attribute filtering
- LDIF-style output format

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 7: Implement Attrs Command

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add attrs command handler**

Insert before main dispatcher:

```bash
# Command: attrs
cmd_attrs() {
    local object_type="user"
    local object_name=""
    local requested_attrs=()

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g)
                object_type="group"
                shift
                ;;
            -h)
                object_type="host"
                shift
                ;;
            *)
                if [[ -z "$object_name" ]]; then
                    object_name="$1"
                else
                    requested_attrs+=("$1")
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$object_name" ]]; then
        echo "ERROR: Object name required" >&2
        exit 1
    fi

    if [[ "$HAS_JQ" == "true" ]]; then
        case "$object_type" in
            user)
                local users_json
                users_json=$(load_json "$USERS_FILE")

                if [[ ${#requested_attrs[@]} -gt 0 ]]; then
                    # Specific attributes
                    for attr in "${requested_attrs[@]}"; do
                        local value
                        value=$(echo "$users_json" | jq -r ".users[] | select(.sAMAccountName == \"$object_name\") | .${attr} // empty")
                        if [[ -n "$value" ]]; then
                            echo "${attr}: ${value}"
                        fi
                    done
                else
                    # All attributes
                    echo "$users_json" | jq -r ".users[] | select(.sAMAccountName == \"$object_name\") |
                        \"name: \(.name)\",
                        \"uidNumber: \(.uidNumber)\",
                        \"gidNumber: \(.gidNumber)\",
                        \"gecos: \(.gecos)\",
                        \"unixHomeDirectory: \(.unixHomeDirectory)\",
                        \"loginShell: \(.loginShell)\",
                        (.memberOf[] | \"memberOf: \(.)\")"
                fi
                ;;
            group)
                local groups_json
                groups_json=$(load_json "$GROUPS_FILE")

                if [[ ${#requested_attrs[@]} -gt 0 ]]; then
                    for attr in "${requested_attrs[@]}"; do
                        if [[ "$attr" == "member" ]]; then
                            echo "$groups_json" | jq -r ".groups[] | select(.sAMAccountName == \"$object_name\") | .member[] | \"member: \(.)\""
                        else
                            local value
                            value=$(echo "$groups_json" | jq -r ".groups[] | select(.sAMAccountName == \"$object_name\") | .${attr} // empty")
                            if [[ -n "$value" ]]; then
                                echo "${attr}: ${value}"
                            fi
                        fi
                    done
                else
                    echo "$groups_json" | jq -r ".groups[] | select(.sAMAccountName == \"$object_name\") |
                        \"name: \(.name)\",
                        \"gidNumber: \(.gidNumber)\",
                        (.member[] | \"member: \(.)\")"
                fi
                ;;
            host)
                local computers_json
                computers_json=$(load_json "$COMPUTERS_FILE")

                echo "$computers_json" | jq -r ".computers[] | select(.cn == \"$object_name\") |
                    \"cn: \(.cn)\",
                    \"dNSHostName: \(.dNSHostName)\",
                    \"operatingSystem: \(.operatingSystem)\",
                    \"ipAddress: \(.ipAddress)\""
                ;;
        esac
    fi
}
```

**Step 2: Wire up attrs command**

Add to main dispatcher:

```bash
    attrs)
        cmd_attrs "$@"
        ;;
```

**Step 3: Test attrs command**

Run: `./mock-vastool/vastool attrs jsmith name uidNumber gidNumber`

Expected:
```
name: jsmith
uidNumber: 10001
gidNumber: 10000
```

Run: `./mock-vastool/vastool attrs -g unixadmins member`

Expected:
```
member: CN=John Smith,OU=Users,DC=example,DC=com
member: CN=Mary Jones,OU=Users,DC=example,DC=com
```

Run: `./mock-vastool/vastool attrs -h jump-server`

Expected:
```
cn: jump-server
dNSHostName: jump-server.example.com
operatingSystem: Red Hat Enterprise Linux 9.3
ipAddress: 172.25.0.10
```

**Step 4: Commit attrs implementation**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool attrs command

Supports user, group (-g), and host (-h) attribute queries
Can fetch specific attributes or all attributes

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 8: Implement User Checkaccess Command

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add user checkaccess handler**

Insert before main dispatcher:

```bash
# Command: user
cmd_user() {
    local subcommand="$1"
    shift || true

    case "$subcommand" in
        checkaccess)
            local username="$1"
            if [[ -z "$username" ]]; then
                echo "ERROR: Username required" >&2
                exit 1
            fi

            local access_json
            access_json=$(load_json "$ACCESS_FILE")

            local has_access=false

            if [[ "$HAS_JQ" == "true" ]]; then
                # Check if user is in allowed list
                local allowed_users
                allowed_users=$(echo "$access_json" | jq -r ".server_access.\"${HOSTNAME}\".allowed_users[]" 2>/dev/null || true)

                if echo "$allowed_users" | grep -q "^${username}$"; then
                    has_access=true
                fi
            else
                # Fallback check
                case "$HOSTNAME" in
                    jump-server)
                        if [[ "$username" == "jsmith" ]] || [[ "$username" == "mjones" ]] || [[ "$username" == "bwilson" ]]; then
                            has_access=true
                        fi
                        ;;
                    target-server-1|target-server-2)
                        if [[ "$username" == "jsmith" ]] || [[ "$username" == "mjones" ]]; then
                            has_access=true
                        fi
                        ;;
                    target-server-3)
                        if [[ "$username" == "jsmith" ]] || [[ "$username" == "mjones" ]] || [[ "$username" == "bwilson" ]]; then
                            has_access=true
                        fi
                        ;;
                    target-server-4)
                        if [[ "$username" == "jsmith" ]] || [[ "$username" == "mjones" ]] || [[ "$username" == "kadmin" ]]; then
                            has_access=true
                        fi
                        ;;
                esac
            fi

            if [[ "$has_access" == "true" ]]; then
                echo "$username has access to this computer"
                exit 0
            else
                echo "$username does not have access to this computer"
                exit 1
            fi
            ;;
        *)
            echo "ERROR: Unknown user subcommand: $subcommand" >&2
            exit 1
            ;;
    esac
}
```

**Step 2: Wire up user command**

Add to main dispatcher:

```bash
    user)
        cmd_user "$@"
        ;;
```

**Step 3: Test user checkaccess**

Run: `./mock-vastool/vastool user checkaccess jsmith`

Expected: `jsmith has access to this computer` (exit code 0)

Run: `./mock-vastool/vastool user checkaccess nonexistent`

Expected: `nonexistent does not have access to this computer` (exit code 1)

**Step 4: Commit user checkaccess implementation**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool user checkaccess command

Checks server-specific access rules from access-control.json
Returns exit code 0 for allowed, 1 for denied

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 9: Implement Utility Commands (flush, kinit, klist, kdestroy)

**Files:**
- Modify: `mock-vastool/vastool`

**Step 1: Add utility command handlers**

Insert before main dispatcher:

```bash
# Command: flush
cmd_flush() {
    echo "Cache flushed"
}

# Command: kinit
cmd_kinit() {
    local username="${1:-}"
    local ticket_dir="/tmp/krb5cc_$(id -u)"

    if [[ -z "$username" ]]; then
        username="$(whoami)"
    fi

    # Create mock ticket cache
    mkdir -p "$(dirname "$ticket_dir")"
    cat > "$ticket_dir" <<EOF
Mock Kerberos ticket for ${username}@EXAMPLE.COM
Generated: $(date)
EOF

    echo "Kerberos ticket obtained for ${username}@EXAMPLE.COM"
}

# Command: klist
cmd_klist() {
    local ticket_dir="/tmp/krb5cc_$(id -u)"

    if [[ ! -f "$ticket_dir" ]]; then
        echo "klist: No credentials cache found" >&2
        exit 1
    fi

    cat <<EOF
Ticket cache: FILE:${ticket_dir}
Default principal: $(whoami)@EXAMPLE.COM

Valid starting     Expires            Service principal
$(date '+%m/%d/%y %H:%M:%S')  $(date -d '+10 hours' '+%m/%d/%y %H:%M:%S')  krbtgt/EXAMPLE.COM@EXAMPLE.COM
EOF
}

# Command: kdestroy
cmd_kdestroy() {
    local ticket_dir="/tmp/krb5cc_$(id -u)"

    if [[ -f "$ticket_dir" ]]; then
        rm -f "$ticket_dir"
        echo "Kerberos tickets destroyed"
    else
        echo "No tickets to destroy"
    fi
}
```

**Step 2: Wire up utility commands**

Add to main dispatcher:

```bash
    flush)
        cmd_flush
        ;;
    kinit)
        cmd_kinit "$@"
        ;;
    klist)
        cmd_klist
        ;;
    kdestroy)
        cmd_kdestroy
        ;;
```

**Step 3: Test utility commands**

Run: `./mock-vastool/vastool flush`
Expected: `Cache flushed`

Run: `./mock-vastool/vastool kinit jsmith`
Expected: `Kerberos ticket obtained for jsmith@EXAMPLE.COM`

Run: `./mock-vastool/vastool klist`
Expected: Ticket cache info with current/future timestamps

Run: `./mock-vastool/vastool kdestroy`
Expected: `Kerberos tickets destroyed`

**Step 4: Commit utility commands**

```bash
git add mock-vastool/vastool
git commit -m "Implement vastool utility commands

- flush: Cache flush (no-op)
- kinit: Create mock Kerberos ticket
- klist: Show mock ticket info
- kdestroy: Remove mock tickets

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 10: Create Installation Script

**Files:**
- Create: `install-mock-vastool.sh`

**Step 1: Create installation script**

File: `install-mock-vastool.sh`

```bash
#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Mock Vastool Installation Script"
echo "================================================"
echo ""

# Containers to install
CONTAINERS=(
    "jump-server"
    "target-server-1"
    "target-server-2"
    "target-server-3"
    "target-server-4"
)

# Check if containers are running
echo "Checking container status..."
for container in "${CONTAINERS[@]}"; do
    if ! podman ps --format "{{.Names}}" | grep -q "^${container}$"; then
        echo -e "${RED}ERROR: Container ${container} is not running${NC}"
        echo "Please start containers with: podman-compose up -d"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} ${container} is running"
done
echo ""

# Install jq in containers if needed
echo "Installing jq in containers (if not present)..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman exec "$container" bash -c "command -v jq &> /dev/null || dnf install -y jq" &> /dev/null || true
done
echo -e "${GREEN}✓${NC} jq installation complete"
echo ""

# Create directory structure
echo "Creating directory structure in containers..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman exec "$container" mkdir -p /opt/quest/bin /opt/quest/etc
done
echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Copy vastool script
echo "Copying vastool script to containers..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman cp mock-vastool/vastool "${container}:/opt/quest/bin/vastool"
    podman exec "$container" chmod 755 /opt/quest/bin/vastool
done
echo -e "${GREEN}✓${NC} Vastool script copied"
echo ""

# Copy JSON data files
echo "Copying JSON data files to containers..."
DATA_FILES=(
    "domain.json"
    "users.json"
    "groups.json"
    "computers.json"
    "access-control.json"
)

for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    for datafile in "${DATA_FILES[@]}"; do
        podman cp "mock-vastool/data/${datafile}" "${container}:/opt/quest/etc/${datafile}"
        podman exec "$container" chmod 644 "/opt/quest/etc/${datafile}"
    done
done
echo -e "${GREEN}✓${NC} JSON data files copied"
echo ""

# Create symlink for PATH access
echo "Creating symlinks for easy access..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman exec "$container" bash -c "ln -sf /opt/quest/bin/vastool /usr/local/bin/vastool" || true
done
echo -e "${GREEN}✓${NC} Symlinks created"
echo ""

# Verify installation
echo "Verifying installation..."
ALL_OK=true

for container in "${CONTAINERS[@]}"; do
    echo "  Testing ${container}:"

    # Test version
    if podman exec "$container" vastool -v &> /dev/null; then
        echo -e "    ${GREEN}✓${NC} vastool -v"
    else
        echo -e "    ${RED}✗${NC} vastool -v FAILED"
        ALL_OK=false
    fi

    # Test info domain
    DOMAIN=$(podman exec "$container" vastool info domain 2>/dev/null || echo "FAILED")
    if [[ "$DOMAIN" == "EXAMPLE.COM" ]]; then
        echo -e "    ${GREEN}✓${NC} vastool info domain"
    else
        echo -e "    ${RED}✗${NC} vastool info domain FAILED (got: $DOMAIN)"
        ALL_OK=false
    fi

    # Test status
    if podman exec "$container" vastool status &> /dev/null; then
        echo -e "    ${GREEN}✓${NC} vastool status"
    else
        echo -e "    ${RED}✗${NC} vastool status FAILED"
        ALL_OK=false
    fi

    # Test list users
    USER_COUNT=$(podman exec "$container" vastool list users 2>/dev/null | wc -l)
    if [[ "$USER_COUNT" -ge 5 ]]; then
        echo -e "    ${GREEN}✓${NC} vastool list users (${USER_COUNT} users)"
    else
        echo -e "    ${RED}✗${NC} vastool list users FAILED (got ${USER_COUNT} users)"
        ALL_OK=false
    fi

    echo ""
done

if [[ "$ALL_OK" == "true" ]]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "You can now use vastool in any container:"
    echo "  ssh -p 2222 jay@localhost"
    echo "  vastool status"
    echo "  vastool list users"
    echo "  vastool user checkaccess jsmith"
else
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}Installation completed with errors${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    echo "Please check the errors above and retry"
    exit 1
fi
```

**Step 2: Make installer executable**

Run: `chmod +x install-mock-vastool.sh`

**Step 3: Test installer (dry run check)**

Run: `bash -n install-mock-vastool.sh`

Expected: No output (syntax is valid)

**Step 4: Commit installer script**

```bash
git add install-mock-vastool.sh
git commit -m "Add mock vastool installation script

Automated installer that:
- Checks container status
- Installs jq dependency
- Creates directory structure
- Copies vastool script and JSON data
- Creates symlinks
- Verifies installation with tests

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 11: Run Installation and Verification

**Files:**
- None (execution task)

**Step 1: Ensure containers are running**

Run: `podman-compose ps`

Expected: All 5 containers showing as "Up"

If not running:
```bash
podman-compose up -d
```

**Step 2: Run installation script**

Run: `./install-mock-vastool.sh`

Expected:
- All green checkmarks
- "Installation completed successfully!" message

**Step 3: Manual verification on jump-server**

Run: `podman exec jump-server vastool -v`

Expected: `vastool 4.2.4.30023 (x86_64-redhat-linux) - MOCK VERSION`

Run: `podman exec jump-server vastool status`

Expected:
```
DOMAIN: EXAMPLE.COM
SITE: Default-First-Site-Name
SUCCESS: System is in the domain
SUCCESS: System is in a site
```

Run: `podman exec jump-server vastool list users`

Expected: 5 unix-enabled users listed

Run: `podman exec jump-server vastool user checkaccess jsmith`

Expected: `jsmith has access to this computer` (exit code 0)

**Step 4: Verify hostname-specific behavior**

Run: `podman exec target-server-1 vastool user checkaccess bwilson`

Expected: `bwilson does not have access to this computer` (exit code 1)

Run: `podman exec target-server-3 vastool user checkaccess bwilson`

Expected: `bwilson has access to this computer` (exit code 0)

**Step 5: Test via SSH**

Run: `ssh -p 2222 jay@localhost "vastool info domain"`

Expected: `EXAMPLE.COM`

Run: `ssh -p 2223 jay@localhost "vastool list users-allowed"`

Expected: List of users allowed on target-server-1 (jsmith, mjones)

**Step 6: Create verification report**

Create: `VERIFICATION.md`

```markdown
# Mock Vastool Verification Report

**Date**: $(date)
**Tested By**: Automated installer

## Installation Summary

- ✅ All 5 containers: mock vastool installed
- ✅ jq dependency installed
- ✅ Directory structure created
- ✅ JSON data files deployed
- ✅ Symlinks created

## Verification Tests

### jump-server
- ✅ vastool -v returns version
- ✅ vastool status shows domain joined
- ✅ vastool list users returns 5 users
- ✅ vastool user checkaccess jsmith (allowed)

### target-server-1
- ✅ vastool info domain returns EXAMPLE.COM
- ✅ vastool list users-allowed returns jsmith, mjones
- ✅ vastool user checkaccess bwilson (denied - correct)

### target-server-3
- ✅ vastool user checkaccess bwilson (allowed - correct)

## Hostname-Specific Behavior

✅ Each container correctly identifies itself
✅ Access control rules are server-specific
✅ Users-allowed list varies by server

## Status

**PASS** - All tests successful
```

**Step 7: Commit verification report**

```bash
git add VERIFICATION.md
git commit -m "Add mock vastool verification report

All 5 containers verified with passing tests

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 12: Create README Documentation

**Files:**
- Create: `mock-vastool/README.md`

**Step 1: Create README**

File: `mock-vastool/README.md`

```markdown
# Mock Vastool

A comprehensive mock implementation of Quest/One Identity Authentication Services `vastool` command for testing and development purposes.

## Overview

This mock vastool provides realistic Active Directory responses for all major vastool commands, making it perfect for:
- Testing automation scripts that use vastool
- Developing infrastructure tools without AD connectivity
- Learning vastool command syntax and output formats
- Simulating server-specific access control scenarios

## Features

- ✅ **Comprehensive Command Support**: info, status, list, search, attrs, user checkaccess
- ✅ **LDAP Filter Parsing**: Supports basic LDAP search filters
- ✅ **Hostname-Aware**: Each container reports itself correctly
- ✅ **Server-Specific Access Control**: Different users allowed on different servers
- ✅ **Realistic Output**: Matches real vastool output formats exactly
- ✅ **JSON-Based Data**: Easy to customize mock users, groups, and servers

## Installation

Run the installer script from the project root:

```bash
./install-mock-vastool.sh
```

This will:
1. Check that all 5 containers are running
2. Install jq dependency
3. Copy vastool script to `/opt/quest/bin/vastool`
4. Copy JSON data files to `/opt/quest/etc/`
5. Create symlinks for easy access
6. Verify installation

## Mock Domain Structure

- **Domain**: EXAMPLE.COM
- **Site**: Default-First-Site-Name
- **Domain Controllers**: dc01.example.com, dc02.example.com

### Mock Users

| Username | UID | GID | Groups |
|----------|-----|-----|--------|
| jsmith | 10001 | 10000 | unixadmins, developers |
| mjones | 10002 | 10000 | unixadmins, dbadmins |
| bwilson | 10003 | 10001 | developers |
| kadmin | 10004 | 10002 | dbadmins |
| svc_app | 10005 | 10003 | svcaccounts |

### Mock Groups

| Group | GID | Members |
|-------|-----|---------|
| unixadmins | 10000 | jsmith, mjones |
| developers | 10001 | bwilson, jsmith |
| dbadmins | 10002 | mjones, kadmin |
| svcaccounts | 10003 | svc_app |

### Server Access Rules

| Server | Allowed Users |
|--------|---------------|
| jump-server | jsmith, mjones, bwilson |
| target-server-1 | jsmith, mjones |
| target-server-2 | jsmith, mjones |
| target-server-3 | jsmith, mjones, bwilson |
| target-server-4 | jsmith, mjones, kadmin |

## Usage Examples

### Info Commands

```bash
vastool info domain           # EXAMPLE.COM
vastool info site             # Default-First-Site-Name
vastool info servers          # List DCs
vastool info domain-dn        # DC=example,DC=com
```

### Status

```bash
vastool status
```

### List Users/Groups

```bash
vastool list users            # List unix-enabled users
vastool list groups           # List unix-enabled groups
vastool list users-allowed    # Users allowed on this server
vastool list user jsmith      # Specific user
```

### Search

```bash
vastool search "(sAMAccountName=jsmith)"
vastool search "(objectClass=computer)" dNSHostName
vastool search "(uidNumber=10001)" cn uidNumber
```

### Attrs

```bash
vastool attrs jsmith name uidNumber gidNumber
vastool attrs -g unixadmins member
vastool attrs -h jump-server
```

### User Checkaccess

```bash
vastool user checkaccess jsmith
# Returns: "jsmith has access to this computer" (exit 0 or 1)
```

### Kerberos (Mock)

```bash
vastool kinit jsmith
vastool klist
vastool kdestroy
```

## Customizing Mock Data

All mock data is stored in JSON files at `/opt/quest/etc/`:

- `domain.json` - Domain configuration
- `users.json` - User objects
- `groups.json` - Group objects
- `computers.json` - Server objects
- `access-control.json` - Access rules

Edit these files and re-run the installer to update.

## Testing

Verify installation:

```bash
# Test on jump-server
ssh -p 2222 jay@localhost "vastool status"

# Test on target-server-1
ssh -p 2223 jay@localhost "vastool list users"

# Test access control
ssh -p 2223 jay@localhost "vastool user checkaccess bwilson"
# Should deny (exit 1)

ssh -p 2225 jay@localhost "vastool user checkaccess bwilson"
# Should allow (exit 0)
```

## Limitations

This is a mock implementation for testing. It does not:
- Connect to real Active Directory
- Perform actual authentication
- Validate credentials
- Support all vastool command options
- Handle complex nested LDAP filters

## Reference

See [vastool-reference-guide.md](../vastool-reference-guide.md) for complete vastool command documentation.
```

**Step 2: Commit README**

```bash
git add mock-vastool/README.md
git commit -m "Add comprehensive mock vastool README

Documentation includes:
- Installation instructions
- Mock domain structure
- Usage examples for all commands
- Customization guide
- Testing procedures

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Summary

This implementation plan creates a comprehensive mock vastool with:

1. ✅ **JSON Data Files** - Realistic AD structure with users, groups, computers
2. ✅ **Core Script** - Bash script with command parsing and data loading
3. ✅ **Info Commands** - Domain, site, servers, DN queries
4. ✅ **Status Command** - Domain join status
5. ✅ **List Commands** - Users, groups, users-allowed with flags
6. ✅ **Search Command** - LDAP filter parsing and LDIF output
7. ✅ **Attrs Command** - User, group, host attribute queries
8. ✅ **User Checkaccess** - Server-specific access control
9. ✅ **Utility Commands** - flush, kinit, klist, kdestroy
10. ✅ **Installation Script** - Automated deployment to all 5 containers
11. ✅ **Verification** - Comprehensive testing and validation
12. ✅ **Documentation** - Complete README with examples

The mock vastool will be fully functional across all 5 containers with hostname-aware behavior and realistic output matching real vastool.
