# AirPlay Multiroom Bridge

A planned resilient live-audio bridge for Shairport Sync, with buffering, DSP,
stereo-to-multichannel upmixing, metadata/artwork preservation, and multi-room outputs.

**Status:** repository bootstrap only. No audio processing, input/output adapters,
network service, runtime API, or UI exists yet. Performance figures below are
acceptance targets, not measured results.

## Initial scope

- Supported target platforms: Raspberry Pi 4 and Pi 5, Raspberry Pi OS 64-bit/AArch64.
  Hardware validation is pending; this scaffold does not establish platform support.
- Portability goal: portable C11/POSIX core on ordinary ARM64 and x86-64 Linux.
  Other Linux distributions are build-portability targets, not officially supported platforms.
- Input: **Shairport Sync only**, initially S16_LE stereo at 44.1 kHz.
- Outputs: ALSA/HDMI and an independent OwnTone adapter, subject to downstream
  capabilities. OwnTone is not a core dependency or a promise of multichannel transport.
- Audio: float DSP, preserved FL/FR content, configurable derived center, low-pass
  LFE, difference-derived ambience, delays/decorrelation, headroom/limiting,
  5.1/7.1 layouts and clean downmix where required.
- Metadata, artwork, source-volume events, session state, and output state form a
  first-class control plane independent of PCM delivery.

The live buffer targets approximately 100–250 ms. DSP-added latency targets
under 20 ms, with zero normal-playback underruns, no DSP-induced clipping,
CPU comfortably below 25% of total Pi 4 capacity, and memory comfortably below
100 MB. Buffer, transport, and DSP latency must be reported separately.

## Build and test the scaffold

Requires CMake 3.20+, a C11 compiler, and a native build tool (Make or Ninja).
No Shairport Sync, ALSA, OwnTone, or Raspberry Pi dependencies are required.

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
cmake --build build --parallel
ctest --test-dir build --output-on-failure --no-tests=error
```

The `amb` interface library declares the C11/header contract; `amb_scaffold_test`
only checks that a C11 consumer compiles and runs. It does not validate audio.
Use `-DBUILD_TESTING=OFF` for a configure-only interface target build.
GitHub Actions performs scaffold checks with GCC and Clang on x86-64 Linux.
Pi hardware and ARM64 validation remain required before any supported release.

## Project documentation

- [Architecture](docs/ARCHITECTURE.md): boundaries and behavioral contracts.
- [Plan](docs/PLAN.md): living sequential checklist, current/next task, acceptance gates and open decisions.
- [Metadata](docs/METADATA.md): canonical state, artwork and volume semantics.
- [Ideas](docs/IDEAS.md): uncommitted proposals, not an implementation queue.
- [Contributor rules](AGENTS.md) and [changelog](CHANGELOG.md).

`src/` and `include/amb/` reserve implementation and public-header locations;
`tests/` holds tests; `examples/` and `packaging/systemd/` reserve future examples
and packaging. There is no runnable daemon or deployment procedure yet.

## License

MIT; see [LICENSE](LICENSE).
