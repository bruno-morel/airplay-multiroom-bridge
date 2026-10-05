# Plan

## Scope and status

Only repository bootstrap is implemented. Initial product scope is Shairport Sync
input and ALSA/HDMI plus OwnTone outputs on Pi 4/Pi 5 with Raspberry Pi OS
64-bit/AArch64. Portable C11/POSIX is the core goal. Other ARM64/x86-64 Linux builds
are portability checks, not additional official support. See `ARCHITECTURE.md`
and `METADATA.md` for behavioral contracts; `IDEAS.md` is not committed scope.

## Source of truth and current position

This file is the living task checklist. Reconciled with the final repository
handoff and preceding design discussion in **AirPlay Speaker Setup** on
2026-10-05. The final 12-stage ordering supersedes earlier alternative orderings.
The chat called these phases 0–11; the bootstrap table uses steps 1–12.
**Step = phase + 1.** Use the stable task IDs below when reporting progress.

**Current:** bootstrap code/docs and CI are complete; one recovered phase-0
formatting/lint task remains. Application implementation has not started.
**Active:** P0.5 — establish formatting/lint rules and checks.
**Next:** P1.1 — settle
the scalar DSP contract and test expectations before implementation.

Completed bootstrap evidence:

- `9658010`: repository documentation and C11 scaffold.
- `5c38a62`: updated pinned checkout action.
- Local AppleClang configure/build and CTest: 1/1 scaffold tests passed;
  test-disabled configuration/build also passed.
- [GitHub CI: GCC and Clang passed](https://github.com/bruno-morel/airplay-multiroom-bridge/actions/runs/37258878538).
- MIT license retained; local checkout and GitHub `main` synchronized at that commit.

These are scaffold checks, not audio correctness or Pi hardware validation.

## How to work through the plan

1. Take the first unchecked task in the current phase. Do not start a later phase
   until its predecessor's acceptance gate passes; record any agreed exception here.
2. Mark the active task and relevant open decisions before implementation. Break a
   large task into smaller checklist items when needed, preserving existing IDs.
3. Add behavioral tests with implementation; define expected results before tuning
   or optimizing. Run the checks relevant to the changed subsystem.
4. Check an item only when its deliverable and verification are complete. Record
   a commit/PR, test result or hardware report as evidence. A blocked task stays
   unchecked with its blocker and next action written down.
5. In the same change, update this file's current/next position, the affected design
   documents and changelog. Report completed task IDs, checks and next task.

Keep detailed work here instead of maintaining an unsynchronized second TODO list.
GitHub issues may link to these IDs if introduced later. Ideas remain in `IDEAS.md`.
This planning update does not start application implementation or authorize deployment.

## Ordered implementation roadmap

| Step | Milestone | Acceptance gate |
| --- | --- | --- |
| 1 | Repository / CI / safety | Documentation, build/test scaffold, restricted CI permissions; verify local checks and first GitHub run |
| 2 | Portable scalar DSP | Tested stereo to 5.1/7.1, preserved fronts, center/LFE/ambience, delay, downmix, headroom and limiting |
| 3 | Metadata + state/control-plane foundation | Canonical revisions, artwork lifecycle, separate source-volume events and output health tests |
| 4 | Shairport Sync live input | Confirmed PCM/metadata contracts; session start/stop and malformed input tests |
| 5 | Resilient buffering | Measured 100–250 ms target, bounded gap silence, clean reset, underrun/overrun/gap metrics |
| 6 | ALSA / multichannel output | Pi HDMI channel mapping, negotiated formats, failure/recovery and downmix tests |
| 7 | OwnTone output adapter | Verified transport/metadata capabilities; independent failure handling; explicit volume policy |
| 8 | Runtime control API | Versioned state/control contract, access policy, validation and concurrency tests; wire protocol undecided |
| 9 | ARM64 NEON | Scalar equivalence within agreed tolerances and measured Pi benefit |
| 10 | x86-64 AVX2 | Scalar equivalence, CPU feature fallback and portability tests |
| 11 | Packaging / systemd / documentation | Least-privilege service, install/upgrade/uninstall checks on test devices, operator docs |
| 12 | UI / appliance experience | Tested user flows grounded in real state and available capabilities |

Tests precede optimization. Every milestone must retain output fault isolation and
independent audio/control streams. Do not implement later ideas merely because a
placeholder directory exists. No schedule or release date is committed.

## Sequential task checklist

### Phase 0 / step 1 — Repository, CI and safety

- [x] P0.1 Create local Git repository, GitHub origin and retain the MIT license.
- [x] P0.2 Document scope, architecture, metadata, ideas and contributor safety rules.
- [x] P0.3 Configure/build the C11 scaffold and pass its CTest check locally.
- [x] P0.4 Pass GCC/Clang GitHub CI with read-only permissions and a pinned action.
- [ ] P0.5 Establish formatter/linter rules and reproducible checks; verify on the
  existing scaffold. This detail was present in the earlier chat but omitted from
  the condensed bootstrap handoff.

Gate: all bootstrap checks and P0.5 pass. Production Muffliatus remains untouched.
If useful later, capture sanitized installation-specific reference examples only
from user-provided or explicitly authorized sources; never make them defaults.

### Phase 1 / step 2 — Portable scalar DSP

- [ ] P1.1 Document the exact DSP contract, coefficients/ranges, channel ordering,
  gain/bypass behavior, delay semantics, reset behavior and numerical expectations.
  Resolve relevant decisions below before treating example values as defaults.
- [ ] P1.2 Add deterministic fixtures/tests: silence, left-only, right-only, mono,
  opposite-phase stereo, 1 kHz tone, bass/frequency sweeps, impulse and seeded noise.
- [ ] P1.3 Implement S16_LE stereo ingress, float internal processing and explicit
  interleaved S16_LE egress; test conversion boundaries and channel layouts.
- [ ] P1.4 Implement stereo bypass and scalar 5.1/7.1 processing: preserved FL/FR,
  configurable center, low-pass LFE, difference-derived ambience, side/rear delay
  and decorrelation. Verify sample-rate-aware timing and block-size independence.
- [ ] P1.5 Implement/test headroom, limiting, clean downmix and state reset, including
  clipping stress cases and no stale delay/filter history between sessions.
- [ ] P1.6 Add an offline WAV/raw PCM CLI: known stereo file in, inspectable stereo/
  5.1/7.1 file out; validate format/channel labels and malformed input handling.
- [ ] P1.7 Establish the future DSP dispatch boundary with scalar always available;
  no NEON/AVX2 implementation yet. Record baseline correctness and timing results.

Gate: offline deterministic tests and CLI checks pass, output channels are verified,
and there are no Shairport/ALSA/OwnTone dependencies in DSP. Pi results remain
pending until explicitly authorized test hardware is available.

### Phase 2 / step 3 — Metadata and state foundation

- [ ] P2.1 Implement canonical Now Playing, session/revision and output-state types
  with a bounded event/snapshot mechanism and explicit unknown values.
- [ ] P2.2 Implement/test coherent track updates, pause versus disconnect, stale-event
  rejection, progress ordering, and session/track generation resets.
- [ ] P2.3 Implement artwork validation, content hashing, bounded cache and stale-art
  prevention; define supported formats/limits and verify duplicate/invalid inputs.
- [ ] P2.4 Implement separate source-volume events and volume-policy tests, including
  downstream loop prevention; preserve independent audio/control-plane behavior.

Gate: metadata/artwork/volume and failure cases in `METADATA.md` pass without live
Shairport parsing or a UI. Avoid metadata flashes between packets of the same track.

### Phase 3 / step 4 — Shairport Sync live input

- [ ] P3.1 Verify chosen Shairport version and PCM/metadata transport contracts.
- [ ] P3.2 Ingest 44.1 kHz S16_LE stereo and classify metadata/artwork/volume events
  into the two planes; implement session detection and input reset behavior.
- [ ] P3.3 Test malformed/partial input, disconnect/reconnect, metadata bursts and
  stale sessions using development fixtures/harnesses.

Gate: both streams behave correctly in a development harness. This does not claim
end-to-end live playback or change the production Pi.

### Phase 4 / step 5 — Resilient buffering

- [ ] P4.1 Implement bounded ring, configurable priming, 100–250 ms target and an
  explicit overrun policy; avoid unnecessary fixed latency.
- [ ] P4.2 Implement bounded gap silence and termination/recovery/reset; test short
  gaps, exhausted silence budget and no stale samples/no endless silence.
- [ ] P4.3 Expose frames received/emitted, depth/max depth, underruns/overruns, gap
  count/largest gap, inserted silence, session duration and DSP processing time.

Gate: deterministic fault injection passes and buffer latency/metrics are measured.

### Phase 5 / step 6 — ALSA and multichannel output

- [ ] P5.1 Implement output boundary and ALSA adapter with configurable device,
  format negotiation, explicit channel mapping and clean downmix/rejection.
- [ ] P5.2 Test unavailable/slow/recovering outputs and bounded queue isolation.
- [ ] P5.3 On authorized non-production hardware, verify each 5.1/7.1 HDMI channel
  with offline fixtures, then listening tests, before live end-to-end playback.
- [ ] P5.4 Verify live input/buffering/output behavior on Pi 4 and Pi 5 and record
  evidence; implement/test bounded external lifecycle hooks where needed.

Gate: hardware mapping and recovery pass on both target platforms. The earlier
chat's WAV-to-HDMI listening checkpoint is retained here; moving it earlier requires
an explicit plan change and hardware authorization, not an implicit deployment.

### Phase 6 / step 7 — OwnTone adapter

- [ ] P6.1 Verify OwnTone version, PCM transport, supported layouts and metadata/
  artwork interfaces; select transport from evidence rather than assuming a FIFO.
- [ ] P6.2 Implement audio plus sanitized metadata/artwork forwarding and explicit
  volume mapping. Never forward source `pvol` blindly as track metadata.
- [ ] P6.3 Test multi-output continuity, reconnection, stale-state prevention and
  measured timing/synchronization limits. Keep OwnTone optional to core operation.

Gate: a secondary output failure cannot stop healthy playback; capabilities and
synchronization limits are documented and tested.

### Phase 7 / step 8 — Runtime control API

- [ ] P7.1 Decide schema/versioning, transport, access policy and event delivery.
- [ ] P7.2 Expose coherent status/Now Playing/artwork/output state and validated
  controls; use one human-readable configuration file for ordinary tuning.
- [ ] P7.3 Test invalid requests, concurrent updates, event ordering and failures;
  document volume precedence and safe configuration changes without recompilation.

Gate: API/configuration contracts and tests pass. REST, SSE and TOML remain format
candidates, not choices silently inherited from illustrative chat examples.

### Phase 8 / step 9 — ARM64 NEON

- [ ] P8.1 Profile scalar on Pi 4/Pi 5 and fix numerical tolerances/reference cases.
- [ ] P8.2 Optimize only measured hotspots, retain scalar fallback and pass
  equivalence tests; report latency, CPU and memory on both platforms.

Gate: measurable benefit with unchanged semantics and defined numerical tolerance.

### Phase 9 / step 10 — x86-64 AVX2

- [ ] P9.1 Add CPU feature dispatch and test fallback without AVX2 support.
- [ ] P9.2 Implement/profile selected hotspots and pass scalar equivalence tests.

Gate: x86-64 correctness/benefit demonstrated without expanding official platform claims.

### Phase 10 / step 11 — Packaging, systemd and documentation

- [ ] P10.1 Add least-privilege systemd service and packaging/install lifecycle.
- [ ] P10.2 Supply portable configuration examples, Shairport/OwnTone/ALSA guides,
  troubleshooting and optional external hook instructions.
- [ ] P10.3 Verify install/upgrade/uninstall and sustained performance on test Pi 4/5;
  record results against all performance gates before a release claim.

Gate: reproducible test-device installation and release documentation. Production
rollout/rollback requires a separate explicit authorization.

### Phase 11 / step 12 — UI and appliance experience

- [ ] P11.1 Agree UI form and user flows; consume the canonical API/state model.
- [ ] P11.2 Implement/test Now Playing, artwork, progress, rooms/output health,
  volume and graceful reconnect/error behavior without interrupting healthy audio.
- [ ] P11.3 Validate complete experience on the supported hardware and document limits.

Gate: tested user flows; specific touchscreen/web integrations remain choices to
settle, not reasons to delay the preceding functional milestones.

## Performance gates

Targets require measurement on both Pi 4 and Pi 5; no results exist yet.

- DSP-added latency below 20 ms, measured separately from ring and output latency.
- Normal-playback underruns: zero during an agreed sustained playback workload.
- No DSP-induced clipping across documented worst-case stimuli and supported gains.
- Pi 4 CPU comfortably below 25% of total system CPU capacity (normalize across
  all cores); agree the headroom threshold and adapter/workload mix before sign-off.
- Memory comfortably below 100 MB including bounded queues/artwork cache; agree
  RSS/cache accounting and headroom margin before sign-off.

Record hardware/OS, compiler/options, sample rate, channel layout, enabled outputs,
DSP settings, buffer depth, run duration, latency percentiles, CPU/RSS and gap/error
counters. Stress source gaps, stalled outputs, session churn and metadata bursts.
Do not equate a desktop scaffold test or generic Linux CI with Pi validation.

## Decisions requiring human confirmation before the affected task

The earlier chat gave illustrative tuning values (center 0.50, LFE 0.35, sides
0.60, rears 0.40, 120 Hz LFE cutoff, 15/30 ms side/rear delay, 6 dB headroom).
They are candidates for P1.1, not accepted defaults. In particular, reconcile a
30 ms rear effect delay with the under-20 ms DSP-added latency goal: define effect
delay versus common-path algorithmic latency and report both explicitly.

1. Upmix/downmix coefficients, center/LFE crossover, filter order, delay and
   decorrelation defaults, headroom/limiter settings and exact FL/FR guarantee.
2. Buffer priming, maximum inserted silence, overrun recovery and late-output policy.
3. Exact Shairport Sync and OwnTone versions, PCM/control transports, downstream
   channel/sample-rate capabilities and metadata/artwork forwarding mechanisms.
4. Master versus per-output volume precedence, source-volume normalization,
   mute mapping and feedback suppression policy.
5. Multi-room clock ownership, drift limits and synchronization acceptance criteria.
6. Artwork format/size/cache limits and retention; exact public state schema and
   runtime API transport/authentication policy.
7. Scalar/SIMD numerical tolerances, benchmark workload/duration and performance margins.

The repository owner selected the MIT license. No deployment to the production
Raspberry Pi or modification of Muffliatus is authorized by this plan.
