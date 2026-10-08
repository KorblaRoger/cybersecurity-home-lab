# Project 01 - Virtual Network Architecture & Security Lab
# Windows PDC Time Service Configuration and Validation
#
# Purpose:
# Reusable commands used to assess, configure, and validate
# Windows Time on DC01, the forest-root PDC Emulator.
#
# These commands were used during the time-service work documented in:
# Evidence\015-DC01-PDC-Time-Service-Assessment-and-Configuration.txt


# ------------------------------------------------------------
# 1. Verify Windows Time Service
# ------------------------------------------------------------

Get-Service W32Time


# ------------------------------------------------------------
# 2. Inspect Current Windows Time Status
# ------------------------------------------------------------

w32tm /query /status


# ------------------------------------------------------------
# 3. Inspect Windows Time Configuration
# ------------------------------------------------------------

# Review and sanitize command output before publishing.
# Windows Time diagnostics may reveal environment-specific NTP sources.
w32tm /query /configuration


# ------------------------------------------------------------
# 4. Test NTP Communication with UBUNTU01
# ------------------------------------------------------------

w32tm /stripchart /computer:10.10.10.40 /dataonly /samples:5


# ------------------------------------------------------------
# 5. Inspect Current NTP Peer State
# ------------------------------------------------------------

w32tm /query /peers


# ------------------------------------------------------------
# 6. Configure UBUNTU01 as Manual NTP Peer
# ------------------------------------------------------------

w32tm /config /manualpeerlist:"10.10.10.40,0x8" `
    /syncfromflags:manual /reliable:yes /update


# ------------------------------------------------------------
# 7. Verify Stored Windows Time Configuration
# ------------------------------------------------------------

w32tm /query /configuration


# ------------------------------------------------------------
# 8. Restart Windows Time Service
# ------------------------------------------------------------

Restart-Service W32Time

Get-Service W32Time


# ------------------------------------------------------------
# 9. Force Time-Source Rediscovery and Resynchronization
# ------------------------------------------------------------

w32tm /resync /rediscover


# ------------------------------------------------------------
# 10. Verify Active Time Source
# ------------------------------------------------------------

w32tm /query /source


# ------------------------------------------------------------
# 11. Verify Synchronization Status
# ------------------------------------------------------------

w32tm /query /status


# ------------------------------------------------------------
# 12. Verify Final NTP Peer State
# ------------------------------------------------------------

w32tm /query /peers


# ------------------------------------------------------------
# 13. Inspect Windows Time Zone
# ------------------------------------------------------------

Get-TimeZone


# ------------------------------------------------------------
# 14. Configure Mountain Time Zone
# ------------------------------------------------------------

Set-TimeZone -Id "Mountain Standard Time"


# ------------------------------------------------------------
# 15. Verify Corrected Time Zone
# ------------------------------------------------------------

Get-TimeZone


# ------------------------------------------------------------
# 16. Verify Local Time and NTP Source
# ------------------------------------------------------------

Get-Date

w32tm /query /source