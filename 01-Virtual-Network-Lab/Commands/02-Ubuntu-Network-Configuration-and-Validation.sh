#!/bin/bash

# Project 01 - Virtual Network Architecture & Security Lab
# Ubuntu Network Configuration and Validation
#
# Purpose:
# Reusable commands used to configure and validate UBUNTU01 networking.
#
# These commands were used during the VMnet2 static networking stage
# documented in:
# Evidence\008-UBUNTU01-VMnet2-Static-IP-and-Connectivity.txt


# ------------------------------------------------------------
# 1. NetworkManager Connection Discovery
# ------------------------------------------------------------

nmcli connection show


# ------------------------------------------------------------
# 2. Configure Static IPv4 Address on VMnet2
# ------------------------------------------------------------

sudo nmcli connection modify "Wired connection 1" \
    ipv4.method manual \
    ipv4.addresses 10.10.10.40/24 \
    ipv4.gateway "" \
    ipv4.dns ""


# ------------------------------------------------------------
# 3. Reactivate NetworkManager Connection
# ------------------------------------------------------------

sudo nmcli connection down "Wired connection 1"

sudo nmcli connection up "Wired connection 1"


# ------------------------------------------------------------
# 4. Verify Interface and IPv4 Address
# ------------------------------------------------------------

ip addr show ens33


# ------------------------------------------------------------
# 5. Verify Routing Table
# ------------------------------------------------------------

ip route


# ------------------------------------------------------------
# 6. Verify NetworkManager Device Status
# ------------------------------------------------------------

nmcli device status


# ------------------------------------------------------------
# 7. Verify Route Selection to VMnet2 Host
# ------------------------------------------------------------

ip route get 10.10.10.1


# ------------------------------------------------------------
# 8. Inspect Neighbor / ARP Resolution
# ------------------------------------------------------------

ip neigh show 10.10.10.1


# ------------------------------------------------------------
# 9. Test Local-Subnet Connectivity
# ------------------------------------------------------------

ping -c 4 10.10.10.1


# ------------------------------------------------------------
# 10. Test External-Network Behavior
# ------------------------------------------------------------

ping -c 4 8.8.8.8


# ------------------------------------------------------------
# 11. Verify Hostname
# ------------------------------------------------------------

hostname


# ------------------------------------------------------------
# 12. Display Concise Interface and Address Summary
# ------------------------------------------------------------

ip -br addr


# ------------------------------------------------------------
# 13. Verify Route Selection to an External Destination
# ------------------------------------------------------------

ip route get 8.8.8.8


# ------------------------------------------------------------
# 14. Inspect VMnet8 Interface and IPv4 Configuration
# ------------------------------------------------------------

nmcli -f GENERAL,IP4 device show ens37


# ------------------------------------------------------------
# 15. Inspect DNS and Resolver State
# ------------------------------------------------------------

resolvectl status


# ------------------------------------------------------------
# 16. Test DNS Resolution
# ------------------------------------------------------------

resolvectl query google.com


# ------------------------------------------------------------
# 17. Test Hostname-Based Connectivity
# ------------------------------------------------------------

ping -c 4 google.com


# ------------------------------------------------------------
# 18. Test HTTPS Connectivity
# ------------------------------------------------------------

curl -I https://www.google.com


# ------------------------------------------------------------
# 19. Verify IPv4 Forwarding State
# ------------------------------------------------------------

sysctl net.ipv4.ip_forward

cat /proc/sys/net/ipv4/ip_forward