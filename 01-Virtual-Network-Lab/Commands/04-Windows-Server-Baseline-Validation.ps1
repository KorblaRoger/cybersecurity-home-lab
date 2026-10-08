# Project 01 - Virtual Network Architecture & Security Lab
# Windows Server Baseline Validation
#
# Purpose:
# Reusable commands used to validate the DC01 Windows Server
# baseline before Active Directory Domain Services deployment.
#
# These commands were used during the baseline documented in:
# Evidence\012-DC01-Windows-Server-Baseline.txt


# ------------------------------------------------------------
# 1. Verify VMware Tools Service
# ------------------------------------------------------------

Get-Service VMTools


# ------------------------------------------------------------
# 2. Check Windows Licensing Status
# ------------------------------------------------------------

# Review and sanitize licensing output before publishing.
# Detailed licensing information may contain unique identifiers.
slmgr /xpr

slmgr /dlv


# ------------------------------------------------------------
# 3. Verify Hostname
# ------------------------------------------------------------

hostname


# ------------------------------------------------------------
# 4. Verify Computer Identity and Domain Role
# ------------------------------------------------------------

Get-ComputerInfo |
    Select-Object CsName, CsDomain, CsDomainRole


# ------------------------------------------------------------
# 5. Inspect Network Adapters
# ------------------------------------------------------------

Get-NetAdapter


# ------------------------------------------------------------
# 6. Inspect Complete TCP/IP Configuration
# ------------------------------------------------------------

ipconfig /all


# ------------------------------------------------------------
# 7. Test VMnet2 Connectivity
# ------------------------------------------------------------

ping 10.10.10.1


# ------------------------------------------------------------
# 8. Inspect DNS Client Configuration
# ------------------------------------------------------------

Get-DnsClientServerAddress -InterfaceAlias "Ethernet0"


# ------------------------------------------------------------
# 9. Verify AD DS Role Installation
# ------------------------------------------------------------

Get-WindowsFeature AD-Domain-Services


# ------------------------------------------------------------
# 10. Inspect Ethernet0 IP Configuration
# ------------------------------------------------------------

Get-NetIPConfiguration -InterfaceAlias "Ethernet0"