# Project 01 - Virtual Network Architecture & Security Lab
# Windows Network and Firewall Validation
#
# Purpose:
# Reusable PowerShell and Windows networking commands used to
# validate VMnet2 connectivity, investigate asymmetric ICMP
# behavior, and configure a narrowly scoped Windows Firewall rule.
#
# These commands were used during the troubleshooting documented in:
# Evidence\009-Windows-VMnet2-Connectivity-and-Firewall.txt


# ------------------------------------------------------------
# 1. Verify VMnet2 IPv4 Configuration
# ------------------------------------------------------------

Get-NetIPAddress -InterfaceAlias "VMware Network Adapter VMnet2" `
    -AddressFamily IPv4


# ------------------------------------------------------------
# 2. Verify VMnet2 Adapter Status
# ------------------------------------------------------------

# Review and sanitize command output before publishing.
# Adapter and ARP output may contain unique MAC addresses.
Get-NetAdapter -Name "VMware Network Adapter VMnet2" |
    Select-Object Name, Status, MacAddress, LinkSpeed, InterfaceDescription


# ------------------------------------------------------------
# 3. Test Connectivity to UBUNTU01
# ------------------------------------------------------------

ping 10.10.10.40


# ------------------------------------------------------------
# 4. Inspect Windows ARP Table
# ------------------------------------------------------------

arp -a


# ------------------------------------------------------------
# 5. Check VMnet2 Network Profile
# ------------------------------------------------------------

Get-NetConnectionProfile -InterfaceAlias "VMware Network Adapter VMnet2"


# ------------------------------------------------------------
# 6. Inspect Built-in ICMPv4 Firewall Rules
# ------------------------------------------------------------

Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" |
    Where-Object {$_.DisplayName -like "*Echo Request*"} |
    Select-Object DisplayName, Enabled, Profile, Direction, Action


# ------------------------------------------------------------
# 7. Create Scoped VMnet2 ICMPv4 Rule
# ------------------------------------------------------------

New-NetFirewallRule `
    -DisplayName "Cyber Lab - Allow ICMPv4 from VMnet2" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -RemoteAddress 10.10.10.0/24 `
    -Action Allow


# ------------------------------------------------------------
# 8. Verify Firewall Rule Remote-Address Scope
# ------------------------------------------------------------

Get-NetFirewallRule -DisplayName "Cyber Lab - Allow ICMPv4 from VMnet2" |
    Get-NetFirewallAddressFilter |
    Select-Object RemoteAddress


# ------------------------------------------------------------
# 9. Verify Firewall Rule Protocol and ICMP Type
# ------------------------------------------------------------

Get-NetFirewallRule -DisplayName "Cyber Lab - Allow ICMPv4 from VMnet2" |
    Get-NetFirewallPortFilter |
    Select-Object Protocol, IcmpType