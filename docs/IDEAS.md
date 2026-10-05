# Ideas and proposals

Everything below is speculative: no commitment, priority or schedule. This file is
not an implementation queue. Move an idea into `PLAN.md` only after an explicit
scope decision and architecture review. Initial input remains Shairport Sync only.

## Platform and transport exploration

- macOS/CoreAudio and Windows/WASAPI.
- PipeWire, PulseAudio, Snapcast and RTP/network audio.
- Additional inputs or direct AirPlay input.
- Multichannel AirPlay 2 and OwnTone multichannel enhancements, subject to actual
  protocol and implementation capabilities; no support is implied.
- Capability discovery and heterogeneous clock synchronization beyond the initial
  explicitly tested adapter combinations.
- Additional sample formats/rates, including 48 kHz, and AVX-512 optimization.

## Processing exploration

- Per-output DSP, room correction, convolution and EQ.
- Crossover management, loudness compensation and calibration.
- LV2/LADSPA plugin hosting with explicit real-time and isolation constraints.

## Experience and integration exploration

- Web UI, touchscreen UI and Home Assistant integration.
- REST as a possible runtime control API protocol; milestone 8 commits to a control
  API, not to REST or a specific endpoint/authentication design.
- Rich metrics export and dashboards beyond required internal health counters.
- Broader metadata forwarding/transformation integrations beyond the initial
  adapters' required canonical metadata and artwork preservation.

Milestone 12 reserves UI/appliance work; these specific forms and integrations
remain proposals. Initial multi-room output does not promise universal clock
synchronization, automatic capability discovery or arbitrary transport support.
