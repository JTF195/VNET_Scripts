#Requires -Version 5

<#
.SYNOPSIS
    Applies audit policies corresponding to Netsurion's recommendations for EventTracker
.DESCRIPTION
    Configures local security policy to enforce the application of Advanced Audit Policy Configuration settings.
    Sets Advanced Audit Policy Configuration settings via auditpol.exe
.NOTES
    Version:        1.0
    Author:         Jason Foley
    Company:        Velocity Network, Inc.
    Creation Date:  2021-08-18
    Purpose/Change: Initial script release
.LINK
    https://www.netsurion.com/Corporate/media/Corporate/Files/Support-Docs/Advanced-Audit-Policy-Configuration-Complete-Reference.pdf
.LINK
    https://www.netsurion.com/Corporate/media/Corporate/Files/Support-Docs/Advanced-Audit-Policy-Configuration-Recommended-Audit-Settings.pdf
.LINK
    https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/getting-the-effective-audit-policy-in-windows-7-and-2008-r2/ba-p/399010
.LINK
    https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/auditpol-local-security-policy-results-differ
#>

# This script requires Administrator privileges, so elevate if not already running as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# Clear any previously existing audit policies (sanity check)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy" -Value "0"
auditpol /clear /y
gpupdate /force

# This registry key enforces the advanced audit policies from auditpol instead of legacy settings from other sources
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy" -Value "1"

# Apply the correct policies per EventTracker documentation
# Commented policies were not included in Netsurion's recommendations and default to disabled

# System
auditpol /set /subcategory:"Security System Extension"               /success:enable  /failure:enable
auditpol /set /subcategory:"System Integrity"                        /success:enable  /failure:enable
auditpol /set /subcategory:"IPsec Driver"                            /success:disable /failure:disable
auditpol /set /subcategory:"Other System Events"                     /success:disable /failure:disable
auditpol /set /subcategory:"Security State Change"                   /success:enable  /failure:enable

# Logon/Logoff
auditpol /set /subcategory:"Logon"                                   /success:enable  /failure:enable
auditpol /set /subcategory:"Logoff"                                  /success:enable  /failure:enable
auditpol /set /subcategory:"Account Lockout"                         /success:enable  /failure:enable
auditpol /set /subcategory:"IPsec Main Mode"                         /success:disable /failure:disable
auditpol /set /subcategory:"IPsec Quick Mode"                        /success:disable /failure:disable
auditpol /set /subcategory:"IPsec Extended Mode"                     /success:disable /failure:disable
auditpol /set /subcategory:"Special Logon"                           /success:enable  /failure:enable
auditpol /set /subcategory:"Other Logon/Logoff Events"               /success:enable  /failure:enable
auditpol /set /subcategory:"Network Policy Server"                   /success:enable  /failure:enable
#auditpol /set /subcategory:"User / Device Claims"                    /success:disable /failure:disable    #added
#auditpol /set /subcategory:"Group Membership"                        /success:disable /failure:disable    #added

# Object Access
auditpol /set /subcategory:"File System"                             /success:enable  /failure:enable
auditpol /set /subcategory:"Registry"                                /success:enable  /failure:enable
auditpol /set /subcategory:"Kernel Object"                           /success:enable  /failure:enable
auditpol /set /subcategory:"SAM"                                     /success:disable /failure:disable
auditpol /set /subcategory:"Certification Services"                  /success:enable  /failure:enable
auditpol /set /subcategory:"Application Generated"                   /success:enable  /failure:enable
auditpol /set /subcategory:"Handle Manipulation"                     /success:disable /failure:disable
auditpol /set /subcategory:"File Share"                              /success:enable  /failure:enable
auditpol /set /subcategory:"Filtering Platform Packet Drop"          /success:disable /failure:disable
auditpol /set /subcategory:"Filtering Platform Connection"           /success:disable /failure:disable
auditpol /set /subcategory:"Other Object Access Events"              /success:disable /failure:disable
auditpol /set /subcategory:"Detailed File Share"                     /success:disable /failure:disable
#auditpol /set /subcategory:"Removable Storage"                       /success:disable /failure:disable    #added
#auditpol /set /subcategory:"Central Policy Staging"                  /success:disable /failure:disable    #added

# Privilege Use
auditpol /set /subcategory:"Non Sensitive Privilege Use"             /success:enable  /failure:enable
auditpol /set /subcategory:"Other Privilege Use Events"              /success:enable  /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use"                 /success:enable  /failure:enable

# Detailed Tracking
auditpol /set /subcategory:"Process Creation"                        /success:enable  /failure:enable
auditpol /set /subcategory:"Process Termination"                     /success:enable  /failure:enable
auditpol /set /subcategory:"DPAPI Activity"                          /success:disable /failure:disable
auditpol /set /subcategory:"RPC Events"                              /success:enable  /failure:enable
#auditpol /set /subcategory:"Plug and Play Events"                    /success:disable /failure:disable    #added
#auditpol /set /subcategory:"Token Right Adjusted Events"             /success:disable /failure:disable    #added

# Policy Change
auditpol /set /subcategory:"Audit Policy Change"                     /success:enable  /failure:enable
auditpol /set /subcategory:"Authentication Policy Change"            /success:enable  /failure:enable
auditpol /set /subcategory:"Authorization Policy Change"             /success:enable  /failure:enable
auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change"         /success:disable /failure:disable
auditpol /set /subcategory:"Filtering Platform Policy Change"        /success:disable /failure:disable
auditpol /set /subcategory:"Other Policy Change Events"              /success:disable /failure:enable

# Account Management
auditpol /set /subcategory:"Computer Account Management"             /success:enable  /failure:enable
auditpol /set /subcategory:"Security Group Management"               /success:enable  /failure:enable
auditpol /set /subcategory:"Distribution Group Management"           /success:enable  /failure:enable
auditpol /set /subcategory:"Application Group Management"            /success:enable  /failure:enable
auditpol /set /subcategory:"Other Account Management Events"         /success:enable  /failure:enable
auditpol /set /subcategory:"User Account Management"                 /success:enable  /failure:enable

# DS Access
auditpol /set /subcategory:"Directory Service Access"                /success:enable  /failure:enable
auditpol /set /subcategory:"Directory Service Changes"               /success:enable  /failure:enable
auditpol /set /subcategory:"Directory Service Replication"           /success:disable /failure:disable
auditpol /set /subcategory:"Detailed Directory Service Replication"  /success:disable /failure:disable

# Account Logon
auditpol /set /subcategory:"Kerberos Service Ticket Operations"      /success:enable  /failure:enable
auditpol /set /subcategory:"Other Account Logon Events"              /success:enable  /failure:enable
auditpol /set /subcategory:"Kerberos Authentication Service"         /success:enable  /failure:enable
auditpol /set /subcategory:"Credential Validation"                   /success:enable  /failure:enable

# Apply the regkey and settings
gpupdate /force

# auditpol does not touch Group Policy or Local Security Policy GPOs, so this is the only way to see the correct effective policies.
auditpol /get /category:*

Pause