# Project 01 - Virtual Network Architecture & Security Lab
# Active Directory and DNS Validation
#
# Purpose:
# Reusable commands used to validate DC01 after promotion to the
# first Domain Controller in the ad.cyberlab.test forest.
#
# These commands were used during the post-promotion validation
# documented in:
# Evidence\014-DC01-ADDS-Promotion-and-DNS-Validation.txt


# ------------------------------------------------------------
# 1. Verify Domain Controller Identity and Role
# ------------------------------------------------------------

Get-ComputerInfo |
    Select-Object CsName, CsDomain, CsDomainRole


# ------------------------------------------------------------
# 2. Verify AD DS and DNS Services
# ------------------------------------------------------------

Get-Service NTDS,DNS


# ------------------------------------------------------------
# 3. Verify DNS Client Configuration
# ------------------------------------------------------------

Get-DnsClientServerAddress -InterfaceAlias "Ethernet0"


# ------------------------------------------------------------
# 4. Resolve Active Directory Domain
# ------------------------------------------------------------

Resolve-DnsName ad.cyberlab.test


# ------------------------------------------------------------
# 5. Verify LDAP Domain Controller SRV Record
# ------------------------------------------------------------

Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.ad.cyberlab.test


# ------------------------------------------------------------
# 6. Inspect Active Directory Domain Configuration
# ------------------------------------------------------------

Get-ADDomain |
    Select-Object DNSRoot, NetBIOSName, DomainMode, PDCEmulator,
                  RIDMaster, InfrastructureMaster


# ------------------------------------------------------------
# 7. Inspect Active Directory Forest Configuration
# ------------------------------------------------------------

Get-ADForest |
    Select-Object RootDomain, ForestMode, SchemaMaster,
                  DomainNamingMaster, GlobalCatalogs


# ------------------------------------------------------------
# 8. Verify Netlogon Service
# ------------------------------------------------------------

Get-Service Netlogon


# ------------------------------------------------------------
# 9. Run Domain Controller Diagnostics
# ------------------------------------------------------------

# Review and sanitize diagnostic output before publishing.
# Event logs and DCDIAG results may contain environment-specific identifiers.
dcdiag


# ------------------------------------------------------------
# 10. Inspect Recent DFS Replication Events
# ------------------------------------------------------------

Get-WinEvent -LogName "DFS Replication" -MaxEvents 10 |
    Select-Object TimeCreated, Id, LevelDisplayName, Message


# ------------------------------------------------------------
# 11. Check DFSR Warnings/Errors After Stabilization Point
# ------------------------------------------------------------

Get-WinEvent -LogName "DFS Replication" |
    Where-Object {
        $_.TimeCreated -gt [datetime]"2026-09-20 21:47:06" -and
        $_.LevelDisplayName -in "Warning","Error"
    } |
    Select-Object TimeCreated, Id, LevelDisplayName, Message


# ------------------------------------------------------------
# 12. Verify SYSVOL and NETLOGON Shares
# ------------------------------------------------------------

Get-SmbShare -Name SYSVOL,NETLOGON


# ------------------------------------------------------------
# 13. Check System Errors After Stabilization Point
# ------------------------------------------------------------

Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    Level     = 2
    StartTime = [datetime]'2026-09-20 21:47:06'
} |
    Select-Object TimeCreated, Id, ProviderName, Message


# ------------------------------------------------------------
# 14. Run Dedicated Active Directory DNS Diagnostic
# ------------------------------------------------------------

dcdiag /test:dns


# ------------------------------------------------------------
# 15. Verify Final DC Network Configuration
# ------------------------------------------------------------

Get-NetIPConfiguration -InterfaceAlias "Ethernet0"