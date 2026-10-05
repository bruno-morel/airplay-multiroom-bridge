# Contributor and agent rules

This repository currently contains bootstrap scaffolding and design documentation.
Do not describe planned features as implemented or tested.

- Read `docs/ARCHITECTURE.md` before changing subsystem boundaries or public interfaces.
- Read `docs/PLAN.md` before implementing planned work or changing roadmap/scope.
- Work through its task IDs sequentially. Update current/next status and check off
  completed items with verification evidence in the same change; record blockers
  without marking incomplete work done.
- Read `docs/METADATA.md` before modifying metadata, artwork, volume-event or state behavior.
- `docs/IDEAS.md` is not an implementation queue. Obtain an explicit scope decision
  and update the plan before implementing speculative features.
- Keep DSP independent of Raspberry Pi, Shairport Sync, ALSA, OwnTone and CEC.
- OwnTone is an output adapter, never a core architectural dependency.
- Shairport Sync is the only initially supported input.
- Pi 4 and Pi 5 with Raspberry Pi OS 64-bit/AArch64 are the initial supported/tested
  platform scope; hardware verification is pending. Do not imply broader official support.
- Scalar C is the behavioral reference. NEON/AVX2 require numerical equivalence tests
  with documented tolerances and must never change audio semantics.
- Audio and metadata/control are independent first-class streams.
- Avoid unnecessary fixed latency. Bound all buffers, queues and recovery behavior.
- One failed output must not interrupt healthy outputs.
- Add tests before optimizing behavior. Test boundary cases and failure recovery.
- Never run artwork parsing, filesystem/network operations, external hooks, or
  unbounded work on the real-time audio path.
- Do not deploy to the production Raspberry Pi or modify Muffliatus.

Before submitting scaffold changes, run:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
cmake --build build --parallel
ctest --test-dir build --output-on-failure --no-tests=error
```

For C or quality-tooling changes, also run the `format-check` and `lint` targets
as described in `docs/DEVELOPMENT.md`; use the pinned tool versions.

Keep changes focused. Record behavioral changes in `CHANGELOG.md`; update design
contracts when behavior changes. Do not add empty production APIs or pretend
placeholder tests establish runtime correctness. Never commit secrets, recordings,
artwork caches, credentials, or machine-specific configuration.
