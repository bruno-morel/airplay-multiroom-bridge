# Plan

## Scope and status

Only repository bootstrap is implemented. Initial product scope is Shairport Sync
input and ALSA/HDMI plus OwnTone outputs on Pi 4/Pi 5 with Raspberry Pi OS
64-bit/AArch64. Portable C11/POSIX is the core goal. Other ARM64/x86-64 Linux builds
are portability checks, not additional official support. See `ARCHITECTURE.md`
and `METADATA.md` for behavioral contracts; `IDEAS.md` is not committed scope.

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

## Decisions requiring human confirmation before implementation

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
