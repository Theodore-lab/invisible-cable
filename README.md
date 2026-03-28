# The Invisible Cable

**Offline Radio Mesh Network for Android**

Turn your phone's Wi-Fi into a relay node — no router, no internet, no SIM needed.

### Vision
- Phone A connects to Phone B (~100m range)
- Phone B automatically relays traffic to Phone C
- Works in forests, basements, planes, or disaster zones

### Planned Features
- Mesh Voice Calls (UDP, high quality)
- End-to-end Encrypted Texting (ED25519)
- Remote Desktop / Admin Control (VNC-like over mesh)
- Efficient C++ relay engine for low battery/CPU usage

### Tech Stack
- Flutter (UI)
- Wi-Fi Direct (via flutter_p2p_connection)
- C++ NDK (for packet forwarding & routing)
- End-to-end encryption

**Current Stage:** Setting up basic discovery so phones can "see" each other.

Built as a true "Invisible Cable" — lean, offline-first, and resource-friendly.
