# Virtual Network Architecture & Security Lab

**Project Status:** COMPLETE / PASS

**Technologies & Skills:** VMware Workstation Pro, Windows Server 2025, Active Directory Domain Services, DNS, Ubuntu Linux, Chrony/NTP, PowerShell, Bash, IPv4 Addressing, Routing, ARP, DHCP, NAT, Windows Firewall, SSH, Network Troubleshooting


## Project Overview

This project documents the design, configuration, validation, and
troubleshooting of a virtual cybersecurity lab built with VMware
Workstation Pro.

The lab provides the virtual network and core infrastructure foundation
for hands-on cybersecurity projects involving networking, Linux and Windows
systems, Active Directory, security monitoring, traffic analysis, SIEM
technologies, and SOC investigation workflows.

The initial phase focused on building and understanding the underlying
virtual network architecture before additional security services and
systems were deployed.

Building on that network foundation, the lab now includes a Windows
Server 2025 Active Directory environment with DC01 operating as the
first Domain Controller and DNS Server for the `ad.cyberlab.test`
domain.

Rather than relying entirely on VMware's automated networking features,
the lab includes a manually configured host-only network to practice
IPv4 addressing, subnetting, routing, ARP, host firewall configuration,
and structured network troubleshooting.

The completed infrastructure serves as the foundation for subsequent
portfolio projects. Active Directory identity, group, authorization, and
administrative exercises continue separately in `02-Active-Directory`,
while broader Windows and PowerShell administration is organized under
`03-Windows-PowerShell`.


## Table of Contents

- [Objectives](#objectives)
- [Lab Environment](#lab-environment)
- [VMware Network Architecture](#vmware-network-architecture)
- [VMnet2 Addressing Plan](#vmnet2-addressing-plan)
- [Network Architecture](#network-architecture)
- [Implementation Summary](#implementation-summary)
- [Validation Results](#validation-results)
- [Troubleshooting and Technical Analysis](#troubleshooting-and-technical-analysis)
- [Key Lessons Learned](#key-lessons-learned)
- [Evidence](#evidence)
- [Recovery Points](#recovery-points)
- [Project Status](#project-status)


## Objectives

The objectives of this project are to:

- Design a segmented VMware virtual network architecture.
- Understand the differences between NAT and host-only networking.
- Configure and validate static IPv4 addressing.
- Understand DHCP, DNS, default gateways, routing, and NAT.
- Verify Layer 2 and Layer 3 connectivity.
- Practice ARP and routing-table analysis.
- Troubleshoot asymmetric network connectivity.
- Apply least-privilege host firewall configuration.
- Maintain structured technical documentation, evidence, and recovery points.
- Deploy and validate a Windows Server Active Directory Domain Services
  and DNS infrastructure.
- Configure a reliable time-synchronization path for the isolated
  forest-root PDC Emulator.
- Establish a validated infrastructure foundation for subsequent Active
  Directory, Windows administration, PowerShell, Group Policy, SIEM, and
  SOC security projects.


## Lab Environment

### Host System

- Operating System: Windows 10 Home 64-bit
- Hypervisor: VMware Workstation Pro 17
- Processor: Intel Core i7-7700HQ
- Memory: Approximately 16 GB RAM

### Virtual Systems Used in This Project

| System | Purpose | Network Configuration |
|---|---|---|
| DC01 | Windows Server 2025 Domain Controller / DNS Server | VMnet2 (single-homed) |
| UBUNTU01 | Linux networking, administration, and NTP service | VMnet2 + VMnet8 |


## VMware Network Architecture

The VMware environment contains multiple virtual networks. Existing
networks that are not currently required by the project were left
unchanged to avoid unnecessary modifications.

Two networks are currently important to the lab:

| VMware Network | Type | Subnet | Purpose |
|---|---|---|---|
| VMnet8 | NAT | 192.168.112.0/24 | Internet-enabled VMware network |
| VMnet2 | Host-Only | 10.10.10.0/24 | Isolated cybersecurity lab LAN |

VMnet8 provides VMware DHCP, NAT, DNS forwarding, and access to external
networks.

VMnet2 is intentionally configured without VMware DHCP or NAT so that
network services and addressing can be configured manually as the lab
develops.


## VMnet2 Addressing Plan

The internal lab network uses:

`10.10.10.0/24`

Current, planned, and reserved addressing:

| System | IPv4 Address | Role |
|---|---|---|
| Windows Host VMnet2 Adapter | 10.10.10.1 | Host-side management access |
| DC01 | 10.10.10.10 | Windows Server / Domain Controller / DNS Server |
| WIN11-01 | 10.10.10.20 | Planned Windows workstation |
| KALI01 | 10.10.10.30 | Planned security testing system |
| UBUNTU01 | 10.10.10.40 | Linux server / administration / NTP service |
| SPLUNK01 | 10.10.10.50 | Planned SIEM system |
| Reserved Gateway | 10.10.10.254 | Reserved for future routing exercises; not currently configured |


## Network Architecture

Stage 3C architecture before dual-homing:

```text
                       External Networks
                              X
                              |
                    No default route
                    No NAT on VMnet2
                              |
                              X

                  VMnet2 Host-Only Network
                       10.10.10.0/24

             +-------------------------------+
             |                               |
             |                               |
       Windows Host                      UBUNTU01
       10.10.10.1/24                    10.10.10.40/24
             |                               |
             +----------- VMnet2 ------------+

       DHCP:             Disabled
       NAT:              Disabled
       Default Gateway:  None
       DNS:              None
       Local Network:    Operational
```

### Stage 3D Dual-Homed Architecture

UBUNTU01 was subsequently configured with a second virtual network
adapter to provide external connectivity while preserving its dedicated
VMnet2 internal lab connection.

```text
                         External Networks
                                |
                          VMware NAT
                                |
                     VMnet8 - 192.168.112.0/24
                                |
                    ens37 - 192.168.112.142/24
                         DHCP / Gateway / DNS
                                |
                         +-------------+
                         |  UBUNTU01   |
                         +-------------+
                                |
                      ens33 - 10.10.10.40/24
                         Static / No Gateway
                                |
                              VMnet2
                         10.10.10.0/24
                                |
                    Windows Host - 10.10.10.1/24

IPv4 Forwarding: Disabled
Internal Connectivity: Verified
External Connectivity: Verified
DNS Resolution: Verified
HTTPS Connectivity: Verified
```

### Stage 4 Active Directory Architecture

Stage 4 introduced DC01 as the first Windows Server and Active Directory
Domain Controller in the lab.

DC01 is connected only to the internal VMnet2 network. It uses a static
IPv4 address and does not have a default gateway, preserving the
isolated design of the Active Directory environment.

DC01 also hosts the DNS service required by the
`ad.cyberlab.test` Active Directory domain.

```text
                         External Networks
                                |
                          VMware NAT
                                |
                     VMnet8 - 192.168.112.0/24
                                |
                    ens37 - DHCP / Gateway / DNS
                                |
                         +-------------+
                         |  UBUNTU01   |
                         +-------------+
                                |
                       ens33 - 10.10.10.40/24
                                |
                              VMnet2
                         10.10.10.0/24
                           /         \
                          /           \
                         /             \
          +-------------------+     Windows Host
          |       DC01        |     10.10.10.1/24
          +-------------------+
          | 10.10.10.10/24    |
          | AD DS             |
          | DNS Server        |
          | Global Catalog    |
          +-------------------+

DC01 Default Gateway:         None
DC01 AD DNS Service:          Operational
Active Directory Domain:      ad.cyberlab.test
Internal VMnet2 Connectivity: Verified
UBUNTU01 IPv4 Forwarding:     Disabled
```

### Final Project Architecture - PDC Time Synchronization

After the Domain Controller baseline was established, the lab's time
synchronization architecture was completed without adding a default gateway
or second network adapter to DC01.

Because DC01 remains isolated on VMnet2, it cannot directly contact external
NTP servers. UBUNTU01 provides the controlled time-synchronization path.

UBUNTU01 uses its VMnet8 interface for external network connectivity and
Chrony for upstream time synchronization. Chrony is bound to the internal
VMnet2 address `10.10.10.40` to provide NTP service to DC01.

DC01, which holds the PDC Emulator FSMO role, is configured to use
`10.10.10.40` as its manual NTP peer.

```text
                       External NTP Sources
                               |
                               |
                         External Networks
                               |
                          VMware NAT
                               |
                   VMnet8 - 192.168.112.0/24
                               |
                       ens37 - DHCP
                               |
                     +------------------+
                     |    UBUNTU01      |
                     |     Chrony       |
                     +------------------+
                               |
                    ens33 - 10.10.10.40/24
                    NTP service - UDP/123
                               |
                              VMnet2
                         10.10.10.0/24
                               |
                     +------------------+
                     |      DC01        |
                     |  10.10.10.10/24 |
                     |  PDC Emulator    |
                     +------------------+

UBUNTU01 External Time Acquisition:  VMnet8
UBUNTU01 Lab NTP Address:             10.10.10.40
DC01 Manual NTP Peer:                 10.10.10.40,0x8
DC01 Default Gateway:                 None
DC01 External Network Adapter:        None
UBUNTU01 IPv4 Forwarding:             Disabled
```


## Implementation Summary

### Stage 1 - Host and VMware Network Discovery

The Windows host and existing VMware networking environment were
inventoried before making configuration changes.

The assessment identified the host system resources, VMware virtual
adapters, existing virtual subnets, DHCP settings, and NAT configuration.
This established a known baseline and helped ensure that unrelated VMware
networks were not modified unnecessarily.

### Stage 2 - VMnet2 Internal Lab Network

VMnet2 was selected as the dedicated host-only network for the
cybersecurity lab.

The network was configured as:

- Network: 10.10.10.0/24
- Windows host adapter: 10.10.10.1/24
- VMware DHCP: Disabled
- VMware NAT: Disabled

Static addressing was intentionally selected so that IP configuration,
routing, and future network services could be managed manually as the
lab develops.

### Stage 3A - UBUNTU01 Deployment

UBUNTU01 was deployed as the first Linux system in the lab.

The system was configured with the hostname `emrok-ubuntu01`, and
OpenSSH was installed and enabled to support remote administration.

Before moving Ubuntu to the isolated lab network, the system was
connected to VMware's VMnet8 NAT network to establish a known-good
networking baseline.

### Stage 3B - VMnet8 NAT Baseline

While connected to VMnet8, UBUNTU01 received its IPv4 configuration
through VMware DHCP.

The following functionality was verified:

- DHCP address assignment
- Default gateway configuration
- DNS resolution
- External IPv4 connectivity
- HTTPS connectivity
- OpenSSH service availability
- SSH access from the Windows host

This confirmed that the Ubuntu operating system, virtual network
adapter, TCP/IP configuration, DNS resolution, internet access, and SSH
service were functioning before the network architecture was changed.

A VMware snapshot was created to preserve this known-good state.

### Stage 3C - VMnet2 Static Host-Only Networking

UBUNTU01 was moved from the VMnet8 NAT network to the isolated VMnet2
host-only network.

Because VMware DHCP was disabled on VMnet2, Ubuntu initially had no
usable IPv4 address, route, or DNS configuration. This unconfigured
state was captured before making further changes.

UBUNTU01 was then manually configured with:

- IPv4 address: 10.10.10.40/24
- Default gateway: None
- DNS server: None

Ubuntu automatically installed a directly connected route for
10.10.10.0/24, allowing communication with systems on the same subnet
without requiring a router.

During connectivity testing, Windows successfully reached UBUNTU01,
while Ubuntu initially could not successfully ping the Windows VMnet2
adapter.

The issue was investigated by validating:

- Interface state
- IPv4 addressing
- Routing
- Route selection
- ARP/neighbor resolution
- Reverse-direction connectivity
- Windows ARP information
- Windows Firewall configuration

Layer 2 and Layer 3 configuration were verified as operational.
Windows Firewall inspection showed that the built-in inbound ICMPv4
Echo Request rules were disabled.

Rather than disabling Windows Firewall, a dedicated inbound rule was
created to permit ICMPv4 Echo Requests from only the 10.10.10.0/24 lab
subnet.

The stored firewall configuration was subsequently verified for the
expected source network, ICMPv4 protocol, and ICMP Echo Request type.

Final testing confirmed bidirectional communication between:

- Windows host: 10.10.10.1/24
- UBUNTU01: 10.10.10.40/24

External IPv4 connectivity remained unavailable by design because
VMnet2 had no default gateway or NAT configuration.

A second VMware snapshot was created to preserve the completed Stage 3C
configuration.

### Stage 3D - Dual-Homed Ubuntu Networking

UBUNTU01 was extended with a second virtual network adapter connected
to VMware's VMnet8 NAT network while retaining the existing VMnet2
internal lab interface.

The resulting interface configuration was:

- `ens33`: `10.10.10.40/24` on VMnet2 for internal lab communication
- `ens37`: `192.168.112.142/24` on VMnet8 for external connectivity
  (DHCP-assigned address observed during validation)

The VMnet2 interface retained its manually configured static IPv4
address and directly connected route for `10.10.10.0/24`.

The VMnet8 interface received its IPv4 configuration through VMware
DHCP, including:

- IPv4 address: `192.168.112.142/24`
- Default gateway: `192.168.112.2`
- DNS server: `192.168.112.2`

Routing analysis confirmed that traffic destined for the internal
`10.10.10.0/24` network continued to use `ens33`, while traffic to
external networks used the DHCP-provided default route through `ens37`.

The dual-homed configuration was validated by confirming:

- Internal connectivity to the Windows VMnet2 host
- External IPv4 connectivity through VMnet8
- DNS resolution through `ens37`
- Hostname-based external connectivity
- HTTPS connectivity to an external web service
- Route selection for external destinations

Linux IPv4 forwarding was also inspected and confirmed to be disabled.

Although UBUNTU01 is connected to both the internal VMnet2 network and
the internet-enabled VMnet8 network, it is not currently configured to
perform normal IPv4 routing between the two networks.

### Stage 4A - DC01 Windows Server Deployment and Baseline

DC01 was deployed as the first Windows Server system in the lab to
provide the foundation for Active Directory and Windows domain
administration.

The virtual machine was configured with Windows Server 2025 Standard
(Desktop Experience), 4 GB of memory, two virtual CPU cores, and a
60 GB virtual disk.

DC01 was connected exclusively to the internal VMnet2 network. Because
VMware DHCP is disabled on VMnet2, the server was manually configured
with the static IPv4 address `10.10.10.10/24`.

No default gateway was configured, keeping the server isolated from
external networks while allowing direct communication with systems on
the `10.10.10.0/24` lab network.

The server was renamed `DC01`, VMware Tools was installed and verified,
and local VMnet2 connectivity was successfully validated.

Before Active Directory configuration began, a VMware snapshot named
`DC01 - Baseline Configuration` was created to preserve the verified
standalone-server state.

### Stage 4B - Active Directory Domain Services Role Installation

After the standalone Windows Server baseline was validated, the Active
Directory Domain Services (AD DS) role was installed on DC01 in
preparation for creating the lab's first Active Directory forest.

The AD DS role and its required management components were installed
through Server Manager.

Following installation, the server was verified to confirm that the
Active Directory Domain Services role was installed successfully while
DC01 remained in its pre-promotion state.

Pre-promotion validation confirmed:

- Computer name: `DC01`
- Workgroup membership: `WORKGROUP`
- Domain role: Standalone Server
- Static IPv4 address: `10.10.10.10/24`
- No default IPv4 gateway
- AD DS server role installed
- Domain Controller promotion not yet performed

This distinction was important because installing the AD DS role alone
does not make a Windows Server a Domain Controller. Domain Controller
functionality is established during the subsequent promotion process.

The verified pre-promotion state was documented before proceeding with
creation of the new Active Directory forest.

### Stage 4C - New Forest Creation and Domain Controller Promotion

After the AD DS role and pre-promotion state were verified, DC01 was
promoted as the first Domain Controller in a new Active Directory
forest.

The new forest was configured with the following design:

- Root domain: `ad.cyberlab.test`
- NetBIOS domain name: `AD`
- Forest functional level: Windows Server 2025
- Domain functional level: Windows Server 2025
- DNS Server: Enabled
- Global Catalog: Enabled
- Read-Only Domain Controller (RODC): Disabled
- DNS delegation: Not created
- Active Directory database path: `C:\WINDOWS\NTDS`
- Active Directory log path: `C:\WINDOWS\NTDS`
- SYSVOL path: `C:\WINDOWS\SYSVOL`

Because this was the first Domain Controller in the new forest, DC01
became the first Domain Controller and DNS Server for the
`ad.cyberlab.test` domain.

The prerequisite check completed successfully before promotion. A DNS
delegation warning was reported because no authoritative parent DNS
zone existed for the lab domain. This was expected for the isolated
lab design and did not prevent promotion.

DC01 was then promoted and automatically restarted to complete the
Active Directory configuration.

### Stage 4D - Post-Promotion Validation and Troubleshooting

After promotion and restart, DC01 was systematically validated to
confirm that Active Directory Domain Services, DNS, and supporting
services were functioning correctly.

Post-promotion validation confirmed:

- Computer name: `DC01`
- Active Directory domain: `ad.cyberlab.test`
- Domain role: Primary Domain Controller
- AD DS (`NTDS`) service: Running
- DNS Server service: Running
- Netlogon service: Running
- DC01 DNS client configuration: Local DNS service
- Domain A record: Resolves to `10.10.10.10`
- LDAP Domain Controller SRV record: Registered and resolvable
- Domain functional level: Windows Server 2025
- Forest functional level: Windows Server 2025
- Global Catalog: `DC01.ad.cyberlab.test`
- All five FSMO roles: Hosted by DC01
- SYSVOL share: Available
- NETLOGON share: Available
- Dedicated `dcdiag` DNS tests: Passed

A full `dcdiag` assessment reported failures for the `DFSREvent` and
`SystemLog` tests. Rather than treating these results as proof of an
active Active Directory failure, the associated event logs were
investigated.

The DFS Replication log showed startup and initialization events
generated during the Domain Controller promotion process. Subsequent
events confirmed that DFS Replication successfully initialized SYSVOL
and updated its configuration.

Additional validation confirmed that:

- SYSVOL was shared successfully
- NETLOGON was shared successfully
- The Netlogon service was running
- `dcdiag` SysVolCheck passed
- `dcdiag` NetLogons passed
- No subsequent DFSR warnings or errors were observed after
  stabilization

The System log was also reviewed. Several recorded warnings and errors
were associated with the startup and promotion sequence, including
temporary service dependencies and DNS registration activity.

External Microsoft DNS lookups also generated timeout events because
DC01 intentionally has no default gateway and therefore cannot reach
external networks.

A subsequent query for new System Error-level events after the server
stabilized returned no results.

The investigation demonstrated that diagnostic failures must be
interpreted in context. Historical startup events can cause a diagnostic
test to report failure even when the associated service is currently
operational.

The original event logs were retained rather than cleared solely to
produce a clean diagnostic result.

### Stage 4E - Known-Good Domain Controller Baseline

After Active Directory, DNS, SYSVOL, NETLOGON, and the supporting
Domain Controller services were validated, DC01 was shut down normally
and a VMware snapshot was created.

The snapshot was named:

`DC01 - AD DS Domain Controller Baseline`

This recovery point preserves the verified Domain Controller state
before additional Active Directory administration begins.

At the time of the snapshot:

- DC01 was operational as the first Domain Controller for
  `ad.cyberlab.test`
- Active Directory Domain Services was operational
- DNS service and Active Directory DNS records were validated
- Global Catalog functionality was enabled
- All five FSMO roles were hosted by DC01
- SYSVOL and NETLOGON were operational
- Initial DFSR startup events had been investigated
- No subsequent DFSR warnings or errors were observed after
  stabilization
- No subsequent System Error-level events were observed after
  stabilization
- DC01 remained single-homed on VMnet2 at `10.10.10.10/24`
- No default gateway was configured

This snapshot provides a known-good recovery point before subsequent
Active Directory administration, including organizational structure,
users, groups, and authorization configuration, with additional
Group Policy and domain-member integration planned for later portfolio
development.

### Stage 5A - PDC Emulator Time Service Configuration

After the known-good Domain Controller baseline was established, the
forest-root PDC Emulator's time configuration was assessed.

Initial validation showed that DC01 was using the local hardware clock
rather than a reliable external time source. Because DC01 is intentionally
single-homed on VMnet2 with no default gateway, directly configuring it to
reach internet-based NTP servers would conflict with the existing isolated
network design.

UBUNTU01 was therefore configured to provide NTP service to the internal
lab network using Chrony.

The resulting time architecture was:

- UBUNTU01 obtains upstream time synchronization through its VMnet8
  internet-enabled interface.
- Chrony provides NTP service on UBUNTU01's VMnet2 address
  `10.10.10.40`.
- NTP access is permitted for the `10.10.10.0/24` lab network.
- Chrony listens for lab NTP requests on `10.10.10.40`.
- DC01 uses `10.10.10.40` as its manual NTP peer.
- DC01 remains single-homed on VMnet2 with no default gateway.
- Linux IPv4 forwarding remains disabled.

Chrony's configuration was validated before the Windows time-service
configuration was changed.

UDP port 123 was verified as listening on `10.10.10.40`, and DC01
successfully communicated with the NTP service before UBUNTU01 was
configured as the Domain Controller's manual NTP peer.

DC01 was configured with:

`10.10.10.40,0x8`

as its manual NTP peer.

After the Windows Time service configuration was updated and the service
was resynchronized, validation confirmed that DC01's active time source was:

`10.10.10.40,0x8`

The resulting hierarchy is:

```text
External NTP
     |
UBUNTU01 / Chrony
10.10.10.40
     |
DC01 / PDC Emulator
     |
Future Domain Members
```

During validation, DC01's Windows time zone was also found to be set to
Pacific time. The time zone was corrected to Mountain Standard Time
without changing the underlying NTP synchronization source.

This reinforced the distinction between time synchronization and local
time-zone display: NTP maintains system time synchronization, while the
configured time zone determines how that time is presented locally.

The final configuration provides the forest-root PDC Emulator with a
reliable time source without directly connecting the Domain Controller
to the external VMware network or enabling IP forwarding on UBUNTU01.


## Troubleshooting and Technical Analysis

During Stage 3C, UBUNTU01 was successfully configured with the static
IPv4 address `10.10.10.40/24` on VMnet2. Initial connectivity testing
revealed asymmetric communication between the Ubuntu VM and the Windows
host.

The Windows host at `10.10.10.1` could successfully ping UBUNTU01, but
UBUNTU01 could not initially ping the Windows host.

### Investigation

The issue was investigated systematically rather than assuming that
VMnet2 or the Ubuntu configuration had failed.

The following areas were verified:

- Network interface state
- IPv4 addressing and subnet membership
- Linux routing table
- Route selection to the Windows host
- ARP/neighbor resolution
- Reverse-direction connectivity
- Windows ARP resolution
- Windows Firewall configuration

Ubuntu correctly identified `10.10.10.1` as a directly connected
destination through `ens33` and successfully resolved the Windows
VMnet2 adapter's MAC address.

Windows also successfully resolved UBUNTU01's MAC address and could
ping `10.10.10.40`.

These results demonstrated that the virtual link, IPv4 addressing,
same-subnet routing, and ARP resolution were functioning.

### Firewall Investigation

Windows Firewall inspection showed that the built-in inbound ICMPv4
Echo Request rules for the Domain, Private, and Public profiles were
disabled.

Rather than disabling Windows Firewall or broadly enabling the built-in
File and Printer Sharing rules, a dedicated inbound rule was created
for the lab.

The rule permitted:

- Direction: Inbound
- Protocol: ICMPv4
- ICMP Type: 8 (Echo Request)
- Remote network: `10.10.10.0/24`
- Action: Allow

The stored firewall configuration was independently queried to verify
that the intended protocol, ICMP type, and source-network restriction
had been applied.

### Resolution

After applying the scoped firewall rule, UBUNTU01 successfully pinged
the Windows VMnet2 adapter at `10.10.10.1`.

Final testing confirmed bidirectional communication between the two
systems with 0% packet loss.

The troubleshooting exercise demonstrated that a failed ping does not
necessarily indicate a failed network. Layer 2 connectivity, IP
configuration, routing, ARP resolution, traffic direction, and host
firewall behavior must be considered separately when isolating a
connectivity problem.


## Validation Results

Validation was performed throughout each project stage to confirm that
the implemented network, system, and service configurations operated as
designed.

### Stage 3C VMnet2 Static Network Validation

| Validation Test | Expected Result | Status |
|---|---|---|
| VMnet2 configured as `10.10.10.0/24` | Dedicated host-only lab subnet | PASS |
| VMware DHCP disabled on VMnet2 | No automatic IPv4 assignment | PASS |
| VMware NAT disabled on VMnet2 | No VMware-provided external routing | PASS |
| Windows VMnet2 adapter | `10.10.10.1/24` | PASS |
| UBUNTU01 static IPv4 address | `10.10.10.40/24` | PASS |
| UBUNTU01 interface state | Connected / operational | PASS |
| Ubuntu directly connected route | `10.10.10.0/24` through `ens33` | PASS |
| Ubuntu ARP/neighbor resolution | Windows VMnet2 adapter resolved | PASS |
| Windows ARP resolution | UBUNTU01 resolved | PASS |
| Windows → UBUNTU01 ICMP | Successful | PASS |
| UBUNTU01 → Windows ICMP | Successful | PASS |
| Scoped Windows Firewall rule | Enabled for lab ICMPv4 Echo Requests | PASS |
| Firewall remote-address scope | `10.10.10.0/24` | PASS |
| Firewall protocol/type | ICMPv4 Type 8 | PASS |
| UBUNTU01 external IPv4 connectivity | Unavailable without a default route | EXPECTED |

### Final Stage 3C Network State

```text
Windows Host                         UBUNTU01
10.10.10.1/24                       10.10.10.40/24
     |                                   |
     +------------- VMnet2 --------------+
                 10.10.10.0/24

Local bidirectional connectivity:  VERIFIED
VMware DHCP:                       DISABLED
VMware NAT:                        DISABLED
Default gateway on UBUNTU01:       NONE
External IPv4 connectivity:        UNAVAILABLE BY DESIGN
```

**Stage 3C Validation Result: PASS**

### Stage 3D Dual-Homed Network Validation

After the Stage 3C isolated baseline was validated, a second network
adapter connected to VMnet8 was added to UBUNTU01.

The dual-homed configuration was validated independently to confirm
that external connectivity was restored without disrupting the
existing VMnet2 internal network.

| Validation Test | Expected Result | Status |
|---|---|---|
| Original VMnet2 interface | `ens33` remains operational | PASS |
| VMnet2 static IPv4 address | `10.10.10.40/24` retained | PASS |
| Second network interface | `ens37` connected to VMnet8 | PASS |
| VMnet8 IPv4 configuration | DHCP address assigned | PASS |
| VMnet8 IPv4 address | DHCP-assigned (`192.168.112.142/24` during validation) | PASS |
| VMnet8 default gateway | `192.168.112.2` | PASS |
| VMnet8 DNS server | `192.168.112.2` | PASS |
| Internal VMnet2 connectivity | Windows host `10.10.10.1` reachable | PASS |
| External IPv4 connectivity | `8.8.8.8` reachable through `ens37` | PASS |
| External route selection | Default route uses `ens37` via `192.168.112.2` | PASS |
| DNS resolution | `google.com` resolves through `ens37` | PASS |
| Hostname-based connectivity | `google.com` reachable | PASS |
| HTTPS connectivity | External HTTPS request returns `HTTP/2 200` | PASS |
| IPv4 forwarding | Disabled (`net.ipv4.ip_forward = 0`) | PASS |

### Final Stage 3D Network State

```text
Internal Lab                         External Network
10.10.10.0/24                       192.168.112.0/24
      |                                     |
    ens33                                 ens37
10.10.10.40/24                      192.168.112.142/24
      |                                     |
      +------------- UBUNTU01 --------------+

VMnet2 Internal Connectivity: VERIFIED
VMnet8 External Connectivity: VERIFIED
DNS Resolution:               VERIFIED
HTTPS Connectivity:           VERIFIED
IPv4 Forwarding:              DISABLED
```

**Stage 3D Validation Result: PASS**

### Stage 4 Active Directory Domain Controller Validation

DC01 was validated after promotion to confirm that the Active Directory
domain, DNS infrastructure, directory services, and supporting Domain
Controller components were operational.

| Validation Test | Expected Result | Status |
|---|---|---|
| Computer name | `DC01` | PASS |
| Active Directory domain | `ad.cyberlab.test` | PASS |
| Windows-reported domain role (`CsDomainRole`) | PrimaryDomainController | PASS |
| Static IPv4 address | `10.10.10.10/24` | PASS |
| Default IPv4 gateway | None | PASS |
| AD DS (`NTDS`) service | Running | PASS |
| DNS Server service | Running | PASS |
| Netlogon service | Running | PASS |
| Local DNS configuration | DC01 uses locally hosted DNS | PASS |
| Domain A record | `ad.cyberlab.test` resolves to `10.10.10.10` | PASS |
| LDAP DC SRV record | Resolves to `DC01.ad.cyberlab.test` | PASS |
| Domain functional level | Windows Server 2025 | PASS |
| Forest functional level | Windows Server 2025 | PASS |
| Global Catalog | DC01 registered as Global Catalog | PASS |
| FSMO role placement | All five roles hosted by DC01 | PASS |
| SYSVOL share | Available | PASS |
| NETLOGON share | Available | PASS |
| `dcdiag` SysVolCheck | Passed | PASS |
| `dcdiag` NetLogons | Passed | PASS |
| Dedicated `dcdiag` DNS test | Passed | PASS |
| DFSR post-stabilization state | No subsequent warnings/errors observed | PASS |
| System post-stabilization state | No subsequent Error-level events observed | PASS |

### Stage 4 Diagnostic Investigation

The initial full `dcdiag` assessment reported `DFSREvent` and
`SystemLog` failures because recent warning and error events remained in
the event logs from the Domain Controller promotion and startup process.

These results were investigated rather than treated as unresolved
service failures.

DFSR subsequently reported successful SYSVOL initialization and
configuration updates. SYSVOL and NETLOGON shares were present, the
associated `dcdiag` checks passed, and no new DFSR warnings or errors
were observed after stabilization.

The System log similarly contained startup, service dependency, DNS
registration, external DNS timeout, and other events associated with
the promotion and isolated network environment. No new System
Error-level events were observed after stabilization.

The original event history was retained for diagnostic and security
analysis purposes rather than cleared to alter the `dcdiag` result.

**Stage 4 Active Directory Validation Result: PASS**

### Stage 5A PDC Emulator Time Service Validation

The completed time-service configuration was validated from both the
Ubuntu NTP server and Windows Domain Controller perspectives.

| Validation Test | Expected Result | Status |
|---|---|---|
| UBUNTU01 upstream synchronization | Chrony synchronized with an external NTP source | PASS |
| Chrony lab-network access | `10.10.10.0/24` permitted | PASS |
| Chrony bind address | `10.10.10.40` | PASS |
| NTP listener | UDP/123 available on `10.10.10.40` | PASS |
| DC01-to-UBUNTU01 NTP communication | Successful | PASS |
| DC01 manual NTP peer | `10.10.10.40,0x8` | PASS |
| DC01 active time source | `10.10.10.40,0x8` | PASS |
| DC01 network isolation | Single-homed on VMnet2 with no default gateway | PASS |
| UBUNTU01 IPv4 forwarding | Disabled | PASS |
| DC01 time zone | Mountain Standard Time | PASS |

Validation confirmed that DC01 successfully uses UBUNTU01 as its NTP
source while preserving the existing isolated Domain Controller network
design.

The configuration does not require UBUNTU01 to forward DC01 traffic
between VMnet2 and VMnet8. Chrony independently obtains upstream time
through the internet-enabled network and provides NTP service to DC01
through the internal lab network.

**Stage 5A PDC Emulator Time Service Validation Result: PASS**


## Key Lessons Learned

### Network Connectivity Is Layered

A network adapter showing as connected does not necessarily mean that
the system has valid IP configuration or network connectivity.

Successful communication depends on multiple components, including:

- Interface/link state
- IPv4 addressing
- Subnet configuration
- Routing
- ARP/neighbor resolution
- Host firewall policy

Each component should be verified independently during troubleshooting.

### Same-Subnet Communication Does Not Require a Router

UBUNTU01 (`10.10.10.40/24`) and the Windows VMnet2 adapter
(`10.10.10.1/24`) belong to the same `10.10.10.0/24` network.

Because the destination is directly connected, the systems can
communicate without using a default gateway.

A router or another appropriate route becomes necessary when traffic
must reach a destination outside the local subnet.

### ARP Provides Layer 2 Resolution

Before communicating with another IPv4 host on the local subnet, a
system must determine the destination's Layer 2 MAC address.

During troubleshooting, both Windows and Ubuntu successfully resolved
each other's IP-to-MAC mappings. This helped demonstrate that local
Layer 2 communication was functioning even when the initial Ubuntu-to-
Windows ping failed.

### Ping Failure Does Not Automatically Mean Network Failure

The initial failed Ubuntu-to-Windows ping did not prove that VMnet2 was
broken.

Routing and ARP verification, combined with a successful
Windows-to-Ubuntu ping, showed that the underlying network path was
operational.

The investigation then moved to host-based traffic filtering rather
than unnecessarily rebuilding the virtual network.

### Bidirectional Testing Helps Isolate Problems

Testing communication in both directions helped identify asymmetric
behavior:

- Windows → UBUNTU01: Successful
- UBUNTU01 → Windows: Initially unsuccessful

This narrowed the investigation and helped identify Windows inbound
traffic handling as the area requiring further examination.

### Security Controls Should Be Modified Carefully

Windows Firewall was not disabled to resolve the connectivity issue.

Instead, a dedicated inbound rule was created for ICMPv4 Echo Requests
and restricted to the `10.10.10.0/24` lab subnet.

This demonstrated a least-privilege approach: permit the traffic
required for the lab without unnecessarily weakening the host firewall.

### Configuration Should Be Verified After It Is Applied

Successfully running a configuration command does not by itself prove
that the intended state was stored.

After creating the firewall rule, the stored Windows Firewall filters
were queried independently to verify:

- Remote network: `10.10.10.0/24`
- Protocol: ICMPv4
- ICMP Type: 8 (Echo Request)

Functional testing was then performed to confirm that the configuration
produced the expected result.

### Expected Failure Can Be a Successful Test

UBUNTU01 could communicate with systems on `10.10.10.0/24` but could
not reach `8.8.8.8`.

Because no default gateway or NAT service existed on VMnet2, this was
the expected behavior.

The test reinforced the importance of defining the expected network
state before deciding whether a test result represents success or
failure.

### Structured Troubleshooting Reduces Guesswork

The Stage 3C troubleshooting process followed a logical progression:

Interface → IP Address → Subnet → Route → ARP → Reverse Test →
Firewall → Remediation → Verification

Following a structured process helped isolate the problem without
making unnecessary configuration changes.

### A Multihomed Host Can Serve Multiple Network Roles

UBUNTU01 is connected to two different networks simultaneously:

- `ens33` connects to the internal VMnet2 network at `10.10.10.40/24`.
- `ens37` connects to the VMnet8 NAT network at `192.168.112.142/24`.

Each interface serves a different purpose. VMnet2 provides internal lab
communication, while VMnet8 provides access to external networks.

This demonstrates that a system can maintain connectivity to multiple
networks without requiring both interfaces to use the same addressing,
gateway, or DNS configuration.

### Routing Determines Which Interface Carries Traffic

Adding a default gateway through `ens37` did not cause all traffic to
use the VMnet8 interface.

Traffic destined for the directly connected `10.10.10.0/24` network
continued to use `ens33`, while destinations without a more specific
route used the default route through `ens37`.

The `ip route get` command was used to verify the actual route selected
for an external destination rather than assuming which interface would
be used.

### A Multihomed Host Is Not Automatically a Router

Although UBUNTU01 has interfaces on both VMnet2 and VMnet8, Linux IPv4
forwarding was verified as disabled:

`net.ipv4.ip_forward = 0`

This means the system is not currently configured to perform normal
IPv4 packet forwarding between the two networks.

Connecting a host to multiple networks and configuring a system to
route traffic between those networks are separate networking concepts.

### Installing AD DS Does Not Automatically Create a Domain Controller

Installing the Active Directory Domain Services role prepares a Windows
Server to provide Active Directory services, but the installation alone
does not make the server a Domain Controller.

After the AD DS role was installed on DC01, the system remained a
standalone server in the `WORKGROUP` workgroup until the Domain
Controller promotion process was completed.

The promotion process created the `ad.cyberlab.test` forest and domain,
configured DC01 as the first Domain Controller, installed the required
directory structure, and integrated DNS with Active Directory.

Separating role installation from promotion made it possible to verify
the server's pre-promotion state before making the more significant
directory-service configuration change.

### DNS Is Foundational to Active Directory

Active Directory relies heavily on DNS to allow domain members and
services to locate Domain Controllers and other directory resources.

After DC01 was promoted, it hosted the DNS service for the
`ad.cyberlab.test` domain and was configured to use its own locally
hosted DNS service.

Validation confirmed both the domain A record and the Active Directory
LDAP SRV record. The SRV lookup identified
`DC01.ad.cyberlab.test` as a Domain Controller for the domain.

This demonstrated that successful name resolution in an Active
Directory environment involves more than resolving a hostname to an IP
address. Active Directory also publishes service-location records that
clients use to discover services such as Domain Controllers.

The lab therefore treats DNS as part of the core Active Directory
infrastructure rather than as a separate optional network service.

### Diagnostic Failures Must Be Investigated in Context

A diagnostic tool reporting a failure does not automatically mean that
the associated service is currently broken.

During post-promotion validation, the full `dcdiag` assessment reported
failures for the `DFSREvent` and `SystemLog` tests. Further investigation
showed that these results were influenced by warning and error events
recorded during the recent Domain Controller promotion and startup
process.

Rather than relying on the diagnostic summary alone, the underlying
event logs and current service state were examined.

DFSR events showed that SYSVOL subsequently initialized successfully,
and additional validation confirmed that the SYSVOL and NETLOGON shares
were available. No new DFSR warnings or errors were observed after the
server stabilized.

The System log was similarly evaluated by timestamp and severity.
Historical startup and promotion events remained in the log, while no
new System Error-level events were observed after stabilization.

This demonstrated the importance of correlating diagnostic results with
event timestamps, service state, supporting evidence, and subsequent
system behavior before determining whether an active problem exists.

### Event Logs Should Be Preserved During Troubleshooting

Event logs provide historical evidence about system behavior and should
not be cleared simply to make a diagnostic test produce a cleaner
result.

During DC01 validation, historical warning and error events contributed
to the `DFSREvent` and `SystemLog` failures reported by `dcdiag`.

Instead of clearing the logs and rerunning the diagnostic, the events
were retained and investigated by timestamp, severity, source, and
relationship to the Domain Controller promotion process.

Current system health was then established through independent
validation, including service status, SYSVOL and NETLOGON availability,
DNS testing, DFSR events, and post-stabilization event-log queries.

Preserving the original events maintained an accurate record of what
occurred during deployment and allowed the diagnostic findings to be
explained rather than hidden.

This approach is particularly important in security monitoring and
incident response, where event logs may provide evidence needed to
reconstruct system activity and establish a reliable timeline.

### Domain Controller Network Design Should Be Deliberate

DC01 was intentionally configured as a single-homed server connected
only to the internal VMnet2 network.

The server uses the static IPv4 address `10.10.10.10/24` and currently
has no default gateway. This allows DC01 to provide Active Directory
and DNS services to the internal lab network without directly connecting
the Domain Controller to the VMnet8 external network.

This design differs from UBUNTU01, which is intentionally dual-homed
for networking and administration exercises.

Keeping DC01 single-homed also avoids introducing unnecessary routing
and DNS complexity into the Domain Controller configuration while
preserving the controlled network design established for the lab.

The isolated design has operational consequences. For example, external
DNS queries and direct access to internet-based services are unavailable
from DC01. The forest-root PDC Emulator time-source requirement was
therefore addressed through UBUNTU01 rather than by directly connecting
DC01 to the external VMware network.

This demonstrated that network isolation can improve control over a lab
environment, but the resulting service dependencies and limitations
must also be understood and documented.

### Time Synchronization and Time Zone Are Separate Concepts

During PDC time-service validation, DC01's NTP synchronization and local
time-zone configuration were evaluated separately.

DC01 successfully synchronized with the configured NTP source at
`10.10.10.40`, but its Windows time zone was initially configured for
Pacific time.

Changing the Windows time zone to Mountain Standard Time corrected the
local time display without changing the NTP source.

This demonstrated that time synchronization and time-zone presentation
solve different problems. A system can be synchronized with the correct
time source while still displaying an unexpected local time because of
its configured time zone.

### Providing a Network Service Does Not Require IP Forwarding

UBUNTU01 has interfaces on both VMnet2 and VMnet8, but IPv4 forwarding
remains disabled.

Despite this, UBUNTU01 can obtain upstream time through VMnet8 and provide
NTP service to DC01 through VMnet2.

This works because Chrony is an application running on UBUNTU01. It
synchronizes the Ubuntu system clock with upstream sources and separately
answers NTP requests received on the internal lab interface.

DC01's network packets are therefore not being routed or forwarded through
UBUNTU01 to an external NTP server.

This reinforced the distinction between a multihomed host providing a
service on multiple network interfaces and a system acting as an IP router
between those networks.

### Active Directory Requires a Deliberate Time Hierarchy

Time synchronization is an important supporting dependency in an Active
Directory environment.

For this lab, the forest-root PDC Emulator on DC01 was configured to use
UBUNTU01 as its reliable NTP source:

```text
External NTP
     |
UBUNTU01 / Chrony
     |
DC01 / PDC Emulator
     |
Future Domain Members
```

The design establishes a controlled time hierarchy while allowing DC01 to
remain isolated on the internal VMnet2 network.

The exercise demonstrated that infrastructure dependencies should be
considered as part of system architecture rather than addressed by
weakening an existing network-isolation design.


## Evidence

Detailed command outputs, configuration results, screenshots, and
troubleshooting records are maintained separately from this README.

Supporting project artifacts are organized in the
[Evidence](./Evidence/), [Commands](./Commands/), and
[Screenshots](./Screenshots/) directories.

The evidence files provide technical support for the implementation
and validation described throughout the project.

| Evidence | Description |
|---|---|
| `001-Host-Baseline.txt` | Documents the Windows host hardware, operating system, storage, network adapters, and initial lab environment. |
| `002-VMware-Virtual-Networks-Before-Configuration.png` | Captures the VMware virtual network configuration before VMnet2 was modified for the lab. |
| `003-VMware-Network-Discovery.txt` | Documents discovery and analysis of the existing VMware virtual networks, addressing, DHCP, and NAT configuration. |
| `004-VMnet2-Lab-LAN-Configuration.txt` | Documents the configuration of VMnet2 as the `10.10.10.0/24` host-only cybersecurity lab network. |
| `005-VMware-Virtual-Networks-After-VMnet2-Configuration.png` | Captures the VMware virtual network configuration after VMnet2 was configured for the lab. |
| `006-UBUNTU01-NAT-Baseline.txt` | Documents the known-good UBUNTU01 VMnet8 baseline, including DHCP, routing, DNS, internet connectivity, HTTPS, SSH service, and remote SSH access. |
| `007-UBUNTU01-VMnet2-Unconfigured-State.txt` | Captures UBUNTU01 immediately after moving to DHCP-disabled VMnet2, demonstrating the absence of usable IPv4 configuration and routing before static configuration. |
| `008-UBUNTU01-VMnet2-Static-IP-and-Connectivity.txt` | Documents static IPv4 configuration, routing, neighbor resolution, connectivity testing, troubleshooting, and final Ubuntu-side Stage 3C validation. |
| `009-Windows-VMnet2-Connectivity-and-Firewall.txt` | Documents Windows VMnet2 addressing, adapter state, ARP resolution, reverse connectivity testing, Windows Firewall investigation, scoped ICMPv4 configuration, and final validation. |
| `010-UBUNTU01-Pre-Dual-NIC-Baseline.txt` | Documents the verified Stage 3C network state immediately before adding the second network adapter, including the static VMnet2 configuration, local connectivity, absence of a default route, and expected inability to reach external IPv4 networks. |
| `011-UBUNTU01-Dual-NIC-Network-Validation.txt` | Documents the Stage 3D dual-homed configuration, VMnet8 DHCP addressing, routing and route selection, internal and external connectivity, DNS and HTTPS validation, and verification that Linux IPv4 forwarding remains disabled. |
| `012-DC01-Windows-Server-Baseline.txt` | Documents the DC01 Windows Server baseline and configuration before Active Directory deployment, including hostname configuration, static VMnet2 addressing, network validation, VMware Tools status, and the verified standalone-server state. |
| `013-DC01-AD-DS-Role-Installation-and-Pre-Promotion-Validation.txt` | Documents installation and verification of the Active Directory Domain Services role and the pre-promotion state of DC01 before creation of the new Active Directory forest. |
| `014-DC01-ADDS-Promotion-and-DNS-Validation.txt` | Documents DC01 promotion as the first Domain Controller and DNS Server for `ad.cyberlab.test`, including domain and forest configuration, FSMO role placement, DNS validation, SYSVOL and NETLOGON verification, `dcdiag` analysis, DFSR investigation, post-stabilization event-log validation, and final network state. |
| `015-DC01-PDC-Time-Service-Assessment-and-Configuration.txt` | Documents assessment and configuration of the forest-root PDC Emulator time service, including the initial local-clock condition, Chrony configuration on UBUNTU01, NTP service on `10.10.10.40`, DC01 NTP communication testing, Windows Time configuration, final synchronization-source validation, and time-zone correction. |
| `016-DC01-VMware-Time-Synchronization-Disabled.png` | Visually documents the VMware configuration with continuous guest-to-host time synchronization disabled for DC01 before validating the Domain Controller time-service architecture. |
| `017-UBUNTU01-Pre-Chrony-Time-Synchronization-Baseline.png` | Captures UBUNTU01's time-synchronization state before Chrony was configured as the lab NTP service. |
| `018-DC01-Active-Directory-Forest-Post-Promotion.png` | Shows the Active Directory administrative interface on DC01 with the `ad.cyberlab.test` domain available following Domain Controller promotion. |

### Evidence Methodology

Evidence was collected throughout the project rather than recreated
after configuration was completed.

Where applicable, evidence captures:

- The initial state
- The configuration change
- The resulting state
- Troubleshooting observations
- Remediation
- Final verification

This approach provides a traceable record of how the lab configuration
developed and how technical conclusions were reached.


## Recovery Points

VMware snapshots were created at significant configuration milestones
to preserve verified system states before further changes were made.

These recovery points allow individual lab systems to return to
known-good states if later networking, operating system, directory
service, or security configuration changes cause unexpected behavior.

### UBUNTU01 - VMnet8 NAT Baseline

This snapshot preserves the known-good Ubuntu configuration before the
system was moved to the isolated VMnet2 network.

Verified state at the time of the snapshot:

- UBUNTU01 connected to VMware VMnet8
- IPv4 configuration assigned through VMware DHCP
- Default route available through VMware NAT
- DNS resolution operational
- External IPv4 connectivity verified
- HTTPS connectivity verified
- OpenSSH installed and active
- Remote SSH access from the Windows host verified

This snapshot provides a recovery point for a working
internet-connected Ubuntu configuration.

### UBUNTU01 - VMnet2 Static Baseline

This snapshot preserves the completed Stage 3C configuration after
static host-only networking and connectivity troubleshooting were
successfully validated.

Verified state at the time of the snapshot:

- UBUNTU01 connected to VMnet2
- Static IPv4 address: `10.10.10.40/24`
- Directly connected `10.10.10.0/24` route
- No default IPv4 gateway
- VMware DHCP disabled on VMnet2
- VMware NAT disabled on VMnet2
- Windows host reachable at `10.10.10.1`
- Bidirectional local ICMP connectivity verified
- Windows scoped ICMPv4 firewall rule verified
- External IPv4 connectivity unavailable by design

This snapshot provides the known-good baseline for future development
of the isolated cybersecurity lab network.

### UBUNTU01 - Dual-Homed Network Baseline

This snapshot preserves the completed Stage 3D configuration after
dual-homed networking and connectivity were successfully validated.

Verified state at the time of the snapshot:

- `ens33` connected to VMnet2
- Static IPv4 address on `ens33`: `10.10.10.40/24`
- Internal VMnet2 connectivity verified
- `ens37` connected to VMnet8
- IPv4 configuration on `ens37` assigned through VMware DHCP
- VMnet8 IPv4 address: `192.168.112.142/24` (DHCP-assigned at the time of validation)
- Default route available through `192.168.112.2` on `ens37`
- DNS resolution through VMnet8 verified
- External IPv4 connectivity verified
- HTTPS connectivity verified
- IPv4 forwarding disabled (`net.ipv4.ip_forward = 0`)

This snapshot provides the known-good dual-homed baseline for future
Linux administration, networking, security monitoring, and lab
development exercises.

### DC01 - Baseline Configuration

This snapshot preserves the known-good DC01 configuration immediately
before Active Directory Domain Services was installed and the server was
promoted to a Domain Controller.

Verified state at the time of the snapshot:

- Windows Server 2025 Standard (Desktop Experience)
- Computer name: `DC01`
- Workgroup membership: `WORKGROUP`
- Domain role: Standalone Server
- `Ethernet0` connected to VMnet2
- Static IPv4 address: `10.10.10.10/24`
- No default IPv4 gateway
- VMnet2 local connectivity verified
- VMware Tools installed and operational
- Active Directory Domain Services not yet configured
- Server ready for AD DS role installation and forest creation

This snapshot provides a recovery point immediately before the Active
Directory deployment, allowing DC01 to be returned to its verified
standalone-server state if the domain installation needs to be rebuilt.

### DC01 - AD DS Domain Controller Baseline

This snapshot preserves the known-good DC01 configuration after
successful Active Directory Domain Services promotion and
post-promotion validation.

Verified state at the time of the snapshot:

- Windows Server 2025 Standard (Desktop Experience)
- Fully qualified domain name: `DC01.ad.cyberlab.test`
- Active Directory domain: `ad.cyberlab.test`
- NetBIOS domain name: `AD`
- Domain functional level: Windows Server 2025
- Forest functional level: Windows Server 2025
- DC01 operating as the first Domain Controller in the forest
- DNS Server role operational
- Global Catalog enabled
- All five FSMO roles hosted by DC01
- `Ethernet0` connected to VMnet2
- Static IPv4 address: `10.10.10.10/24`
- No default IPv4 gateway
- DC01 configured to use its locally hosted DNS service
- Active Directory domain DNS resolution verified
- LDAP Domain Controller SRV record verified
- Netlogon service operational
- SYSVOL and NETLOGON shares operational
- Dedicated `dcdiag` DNS tests passed
- Initial DFSR startup events investigated and SYSVOL initialization
  subsequently verified
- No new DFSR warnings or errors observed after stabilization
- No new Error-level events observed in the System log after stabilization
- Post-promotion validation documented in
  `014-DC01-ADDS-Promotion-and-DNS-Validation.txt`

This snapshot provides a known-good Active Directory infrastructure
recovery point before subsequent directory administration and
domain-member development performed in later portfolio projects.

### UBUNTU01 - Lab NTP Service Baseline

**Purpose**

Preserves the known-good UBUNTU01 state after Chrony NTP service
configuration and validation.

**Validated State**

- VMnet2 static address `10.10.10.40/24`
- VMnet8 provides external connectivity
- Chrony synchronized with an upstream NTP source
- NTP service available to the lab network on `10.10.10.40`
- UDP port 123 listening for NTP requests
- DC01 successfully communicated with the NTP service
- IPv4 forwarding remains disabled

This snapshot provides a recovery point for the Ubuntu system that
supplies time synchronization to the forest-root PDC Emulator.

### DC01 - PDC Time Service Baseline

**Purpose**

Preserves the known-good DC01 state after PDC Emulator time-service
configuration and validation.

**Validated State**

- DC01 remains single-homed on VMnet2
- Static IPv4 address `10.10.10.10/24`
- No default gateway configured
- AD DS and DNS operational
- SYSVOL and NETLOGON shares available
- Domain Controller health validation passed
- All five FSMO roles remain on DC01
- Manual NTP peer configured as `10.10.10.40,0x8`
- Active Windows Time source validated as `10.10.10.40,0x8`
- Windows time zone configured for Mountain Standard Time

This snapshot provides a recovery point for the validated Domain
Controller infrastructure after completion of the PDC Emulator
time-synchronization architecture.

Because additional Active Directory administration exercises had already
been completed before this snapshot was created, the snapshot also
contains the current directory objects from the subsequent Active
Directory project. It should therefore not be interpreted as a historical
pre-administration Active Directory state.

### Snapshot Strategy

Snapshots are created only at meaningful, verified milestones rather
than after every configuration change.

Before creating a baseline snapshot, the relevant configuration and
connectivity tests are completed and documented. This ensures that a
snapshot represents a known-good state rather than simply an earlier
state.


## Project Status

**Overall Status:** COMPLETE / PASS

Project 01 has reached its intended completion point. The VMware network
architecture, Linux networking foundation, Windows Server Domain
Controller, Active Directory-integrated DNS, and PDC Emulator time-service
architecture have been configured, validated, documented, and preserved
with recovery points.

### Completed Milestones

- Inventoried the Windows host and existing VMware virtual network environment.
- Designed and configured VMnet2 as an isolated `10.10.10.0/24` host-only cybersecurity lab network with manual addressing and VMware DHCP disabled.
- Deployed UBUNTU01 and validated DHCP, NAT, DNS, HTTPS, SSH, static IPv4 addressing, routing, ARP, and internal connectivity.
- Investigated asymmetric ICMP connectivity and implemented a subnet-scoped Windows Firewall rule instead of disabling the firewall.
- Configured and validated UBUNTU01 as a dual-homed Linux system using VMnet2 for the internal lab network and VMnet8 for external connectivity, with IPv4 forwarding disabled.
- Deployed DC01 on Windows Server 2025 with static addressing and a deliberately single-homed, isolated network configuration.
- Installed Active Directory Domain Services and created the `ad.cyberlab.test` forest, with DC01 operating as the Domain Controller, DNS Server, Global Catalog, and holder of all five FSMO roles.
- Validated Active Directory-integrated DNS, LDAP service records, Netlogon, SYSVOL, DFSR initialization, event-log state, and Domain Controller health.
- Configured UBUNTU01 as the lab's Chrony NTP service and configured the DC01 forest-root PDC Emulator to use `10.10.10.40,0x8` as its validated time source.
- Created known-good VMware recovery points at significant infrastructure milestones after validation.
- Maintained structured technical evidence throughout implementation and troubleshooting.
- Technical evidence completed through Evidence 015, with supporting screenshots organized through artifact 018.

### Current Verified Architecture

The completed and validated Project 01 infrastructure consists of:

```text
Host Windows 10
│
├── VMnet2 - LAB-LAN
│   ├── Network: 10.10.10.0/24
│   ├── Host Adapter: 10.10.10.1
│   ├── VMware DHCP: Disabled
│   │
│   ├── DC01
│   │   ├── 10.10.10.10/24
│   │   ├── Windows Server 2025
│   │   ├── Active Directory Domain Services
│   │   ├── DNS
│   │   ├── Forest Root: ad.cyberlab.test
│   │   ├── PDC Emulator
│   │   ├── NTP Peer: 10.10.10.40,0x8
│   │   └── Default Gateway: None
│   │
│   └── UBUNTU01
│       ├── ens33: 10.10.10.40/24
│       ├── Chrony NTP Service
│       ├── NTP Listener: 10.10.10.40:123/UDP
│       └── IPv4 Forwarding: Disabled
│
└── VMnet8 - LAB-INTERNET
    ├── Network: 192.168.112.0/24
    ├── Host Adapter: 192.168.112.1
    ├── VMware NAT Gateway/DNS: 192.168.112.2
    ├── VMware DHCP: Enabled
    │
    └── UBUNTU01
        └── ens37: DHCP / external connectivity
```

### Final Project Milestone

Project 01 concluded with completion and validation of the forest-root
PDC Emulator time-synchronization architecture.

The final milestone established UBUNTU01 as the controlled NTP service
for the isolated Active Directory environment while preserving DC01's
single-homed VMnet2 configuration.

Final validation confirmed:

- UBUNTU01 synchronizes with an upstream NTP source through VMnet8.
- Chrony provides NTP service on `10.10.10.40` through VMnet2.
- DC01 successfully communicates with the Ubuntu NTP service.
- DC01 uses `10.10.10.40,0x8` as its manual and active time source.
- DC01 remains single-homed with no default gateway.
- UBUNTU01 IPv4 forwarding remains disabled.
- Active Directory Domain Services and DNS remain operational.
- Domain Controller health checks pass.
- Recovery points preserve the final validated infrastructure state.

**Final Project Validation Result: COMPLETE / PASS**

### Project Handoff

With the virtual network and core infrastructure foundation validated,
further development continues in separate portfolio projects rather than
extending Project 01.

#### Project 02 - Active Directory

`02-Active-Directory` builds on the domain infrastructure established in
this project and focuses on identity, authorization, and directory
administration.

Its scope includes:

- Organizational Unit design
- Standard user and administrative account management
- Security group creation and membership
- AGDLP-based authorization
- NTFS role-based access control
- Active Directory administration with PowerShell
- Directory and Domain Controller validation
- Active Directory security observations and lessons learned

#### Project 03 - Windows & PowerShell Administration

`03-Windows-PowerShell` continues with broader Windows system
administration and deeper PowerShell skills that are not specific to
Active Directory authorization design.

Later portfolio projects will build on the same infrastructure for
Linux administration, networking and traffic analysis, Windows security
monitoring, SIEM deployment, and SOC attack-and-detection exercises.

Project 01 therefore serves as the validated infrastructure foundation
for the remaining cybersecurity lab portfolio.
