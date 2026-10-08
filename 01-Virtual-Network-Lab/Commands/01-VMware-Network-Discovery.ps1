# Project 01 - Virtual Network Architecture & Security Lab
# Windows VMware Network Discovery
#
# Purpose:
# Inventory VMware virtual network adapters, IPv4/IPv6 addressing,
# routing entries, and the broader Windows TCP/IP configuration.
#
# These commands were used during the initial VMware network
# discovery documented in:
# Evidence\003-VMware-Network-Discovery.txt


# ------------------------------------------------------------
# 1. VMware Virtual Adapter IP Address Discovery
# ------------------------------------------------------------

Get-NetIPAddress |
    Where-Object {$_.InterfaceAlias -like "*VMware*"} |
    Select-Object InterfaceAlias, IPAddress, PrefixLength


# ------------------------------------------------------------
# 2. VMware Virtual Adapter Route Discovery
# ------------------------------------------------------------

Get-NetRoute |
    Where-Object {$_.InterfaceAlias -like "*VMware*"} |
    Select-Object InterfaceAlias, DestinationPrefix, NextHop, RouteMetric


# ------------------------------------------------------------
# 3. Targeted VMnet2 IP Address Validation
# ------------------------------------------------------------

Get-NetIPAddress |
    Where-Object {$_.InterfaceAlias -eq "VMware Network Adapter VMnet2"} |
    Select-Object InterfaceAlias, IPAddress, PrefixLength


# ------------------------------------------------------------
# 4. Targeted VMnet2 Route Validation
# ------------------------------------------------------------

Get-NetRoute |
    Where-Object {$_.InterfaceAlias -eq "VMware Network Adapter VMnet2"} |
    Select-Object InterfaceAlias, DestinationPrefix, NextHop


# ------------------------------------------------------------
# 5. Complete Windows TCP/IP Configuration
# ------------------------------------------------------------

# Review and sanitize output before publishing.
# Full output may include physical host network details.
ipconfig /all