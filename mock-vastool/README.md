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
