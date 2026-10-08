#!/bin/bash

# Project 01 - Virtual Network Architecture & Security Lab
# Ubuntu Chrony NTP Validation
#
# Purpose:
# Reusable commands used to assess UBUNTU01's original time
# synchronization state, deploy Chrony, and validate the internal
# NTP service used by DC01.
#
# These commands were used during the time-service work documented in:
# Evidence\015-DC01-PDC-Time-Service-Assessment-and-Configuration.txt


# ------------------------------------------------------------
# 1. Inspect Linux Time and Synchronization State
# ------------------------------------------------------------

timedatectl


# ------------------------------------------------------------
# 2. Inspect systemd-timesyncd Service
# ------------------------------------------------------------

systemctl status systemd-timesyncd --no-pager


# ------------------------------------------------------------
# 3. Inspect systemd-timesyncd Synchronization
# ------------------------------------------------------------

timedatectl timesync-status


# ------------------------------------------------------------
# 4. Check for Existing NTP Server Packages
# ------------------------------------------------------------

dpkg -l | grep -E 'chrony|ntpsec|^ii  ntp '

systemctl list-unit-files | grep -E 'chrony|ntp'


# ------------------------------------------------------------
# 5. Update Package Repository Metadata
# ------------------------------------------------------------

sudo apt update


# ------------------------------------------------------------
# 6. Install Chrony
# ------------------------------------------------------------

sudo apt install chrony


# ------------------------------------------------------------
# 7. Verify Chrony Service
# ------------------------------------------------------------

systemctl status chrony --no-pager


# ------------------------------------------------------------
# 8. Verify systemd-timesyncd Handoff
# ------------------------------------------------------------

systemctl status systemd-timesyncd --no-pager


# ------------------------------------------------------------
# 9. Validate Chrony Upstream Synchronization
# ------------------------------------------------------------

chronyc tracking

# Review and sanitize command output before publishing.
# NTP source details may reveal environment-specific server addresses.
chronyc sources -v


# ------------------------------------------------------------
# 10. Back Up Chrony Configuration
# ------------------------------------------------------------

sudo cp /etc/chrony/chrony.conf \
    /etc/chrony/chrony.conf.pre-lab-ntp

ls -l /etc/chrony/chrony.conf*


# ------------------------------------------------------------
# 11. Validate Chrony Configuration Syntax
# ------------------------------------------------------------

sudo chronyd -p


# ------------------------------------------------------------
# 12. Verify NTP UDP/123 Listener
# ------------------------------------------------------------

sudo ss -lunp | grep ':123'


# ------------------------------------------------------------
# 13. Review Chrony Configuration Documentation
# ------------------------------------------------------------

man chrony.conf


# ------------------------------------------------------------
# 14. Revalidate Upstream Synchronization
# ------------------------------------------------------------

chronyc tracking