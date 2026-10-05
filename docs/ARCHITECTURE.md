# Architecture

Status: design contracts for future implementation; no subsystem is implemented.

## Scope and boundaries

Initial targets are Pi 4/Pi 5 with Raspberry Pi OS 64-bit/AArch64. The core uses
portable C11/POSIX with no Pi-specific DSP code. Ordinary ARM64 and x86-64 Linux
are portability goals, not additional officially supported platforms.

```text
Audio plane
Shairport Sync -> input adapter -> bounded live ring -> scalar float DSP
                                                    -> bounded output queues
                                                       |-> ALSA/HDMI adapter
                                                       `-> OwnTone adapter

Control plane
Shairport session / metadata / artwork / source volume
    -> canonical state reducer -> snapshots/events -> output adapters / future API
Output status / errors ---------^
Session lifecycle -------------> optional external hooks
```

OwnTone is one replaceable output adapter. Neither its availability nor its
metadata interface can determine core DSP behavior. Shairport Sync is the sole
initial input. No generic input support is promised.

## Audio contract

Initial ingress is S16_LE interleaved stereo at 44,100 Hz; convert at the boundary
to float DSP samples. Define descriptors with explicit sample rate, frame count,
channel layout/order and timestamp/session generation so 48 kHz can be added
without changing algorithms' semantics. Do not hard-code time constants as
44.1 kHz sample counts. Buffer capacities are measured in frames.

Use named FL, FR, FC, LFE, SL, SR, BL and BR channels. Adapter mappings must be
explicit and tested; never assume device channel order matches internal order.
5.1 uses FL/FR/FC/LFE/SL/SR; 7.1 additionally uses BL/BR. Device layout variants
must be mapped explicitly or rejected. Exact coefficients and defaults are open.

Preserve FL/FR source content rather than replacing it with synthesized signals.
Global safety gain, limiting and deliberate alignment may affect all channels;
this is not a bit-perfect promise. Derive configurable center from stereo, LFE
through low-pass filtering, and side/rear ambience from stereo difference with
configurable delay/decorrelation. Headroom and limiting prevent DSP-induced
clipping. Downmix explicitly for outputs that need fewer channels, with tested
gains and LFE policy. Do not silently discard channels or assume OwnTone can
transport multichannel PCM.

Scalar C defines behavior. NEON and AVX2 come later, selected without requiring
unsupported instructions on baseline hardware. Each optimization needs reference
vectors, numerical tolerances and equivalence tests; no changed channel semantics,
latency policy or gain behavior. Exact tolerances must be fixed before SIMD work.

## Buffering and sessions

Target a small configurable live ring of approximately 100–250 ms. DSP-added
latency is separately budgeted below 20 ms; do not conceal buffering or transport
latency inside that figure. Avoid fixed delay beyond measured requirements.

State progression distinguishes session presence from actual audio activity.
A short source gap may insert bounded silence under a configurable time/frame
budget. Once exhausted, stop audio and report a stalled/stopped condition; never
produce endless silence. Source recovery may restart audio within a live session.
On session end/replacement, flush old frames, reset DSP/delay state, invalidate
old queued events and retire artwork references. New audio cannot inherit old
session data. Exact timeouts, priming and overrun policy require confirmation.

Expose underrun, overrun, gap duration/count, inserted-silence frames, queue depth,
dropped frames and reset counters. Separate upstream starvation from output
failures. Timestamp and measure with a monotonic clock; source position metadata
is not the audio scheduling clock.

## Concurrency and failure isolation

Audio work is bounded: preallocate buffers, avoid blocking allocation, disk I/O,
network I/O, metadata parsing and hook execution on the audio path. Transfer
control snapshots/events through bounded mechanisms with explicit ownership and
lifetimes. A slow consumer must not hold shared audio buffers indefinitely.

Each output owns a bounded queue and recovery state. A failed or slow secondary
output drops/resynchronizes its own stream and reports an error without blocking
healthy outputs. Reconnection joins the current session, never stale audio.
Fan-out timing and clock-drift policy need validation; multi-room output does not
by itself imply sample-accurate synchronization across heterogeneous transports.

Output state includes availability, selected/connected/playing flags, volume,
channel layout, sample rate, synchronization status and last error. Represent
unsupported, unknown and disconnected states explicitly. Report actual negotiated
capabilities and reject or explicitly downmix unsupported formats. Advertised
capabilities must not be confused with measured synchronization quality.

## Control, hooks and dependencies

The independent control plane owns canonical state, revisions, metadata, artwork,
source volume and output health; see `METADATA.md`. Publish state changes even
without PCM. Route source-volume events through AMB volume policy separately from
track metadata; prevent double application and feedback loops downstream.

Optional lifecycle hooks: `on_session_start`, `on_audio_start`, `on_audio_stop`,
`on_session_end`. Emit each on its matching transition; audio stop/start may occur
multiple times in a session. Run hooks outside the audio thread with bounded
execution and reported errors. CEC is optional external integration only.

Future runtime control lives outside DSP. No network listener, REST protocol,
UI, package installation or production deployment is included in bootstrap.
