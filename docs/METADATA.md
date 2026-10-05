# Metadata and canonical state

Status: required design model, not an implemented schema/API. Metadata and artwork
are first-class streams, independently processed from audio delivery.

## Canonical Now Playing model

| Field | Intended semantics |
| --- | --- |
| session_id | Unique session generation; never reuse old-session events |
| revision | Monotonically increasing state revision within a session |
| playback_state | Unknown, stopped, buffering, playing, paused or stalled; preserve unknown when source cannot distinguish |
| title, artist, album, album_artist | Optional text; unknown differs from an empty supplied value |
| duration | Optional nonnegative duration with explicit units (proposed milliseconds) |
| position | Optional position plus monotonic observation timestamp; do not infer certainty from stale metadata |
| artwork | Optional content identity, validated MIME/size, cache reference, status and track/session association |
| source_volume | Latest source event in documented source units plus normalized value/mute if mapping is known |

Model output state separately for each stable output ID: availability,
selected/connected/playing, volume, channel layout, sample rate, synchronization
status and last error (code/message/time). State must represent unknown values
without turning them into zero volume, zero duration or successful synchronization.

## Ingestion and ordering

The Shairport adapter parses metadata into typed events; it never exposes raw
transport payloads as the public canonical model. Confirm upstream framing,
encoding, session boundaries and volume semantics against the chosen Shairport
version before implementation. Bound field/payload sizes and validate text/numbers.
Malformed events are counted and rejected without interrupting healthy audio.

A single logical state reducer serializes updates and publishes immutable snapshots
or revisioned deltas. Assign session generation and receive sequence on ingestion;
discard stale-session events. Batch correlated track changes where upstream framing
permits it. Track identity/generation must distinguish consecutive tracks, including
repeated titles, without depending on an optional title field alone.

A new session starts with unknown/empty track state. A new track invalidates old
track-specific fields and artwork before publishing new data. Partial updates must
not carry an old album or artist into a new track. Late work checks both session
and track generation before attachment. When source ordering is ambiguous, expose
unknown rather than guessing an association.

## Source volume is an event

Source volume is separate from normal track metadata even if it shares a transport.
Normalize only after source units/range/mute sentinel are established. Preserve
origin and revision so output acknowledgements cannot feed back as new user input.

AMB volume policy decides where master gain and per-output trim are applied and
what control commands each adapter receives. Do not apply volume twice, and do not
blindly forward source-volume metadata to OwnTone. Track forwarding excludes volume;
any downstream volume command must be an explicit adapter operation. Exact mapping,
mute handling and master/output precedence remain open decisions.

## Artwork lifecycle

Proposed identity: SHA-256 over validated original bytes with explicit MIME, byte
size and decoded dimensions. Identical content reuses a cache entry; titles/URLs
alone are not content identity. Validation bounds byte size, decoded dimensions,
formats and resource use; isolate parsing/decoding from real-time audio.

Use an application-owned bounded cache with safe content-derived paths, atomic
writes, reference-aware eviction and explicit cache-miss handling. Never trust an
incoming filename or arbitrary filesystem path. Persisting artwork is optional
policy; artwork preservation and correct in-session association are required.
No implicit fetching of arbitrary artwork URLs is specified.

Clear the active artwork reference on session/track changes; content may remain
cached subject to retention policy. Validate session and track generation after
asynchronous validation/cache writes before publishing. Missing/invalid artwork
must yield a clear state, never the previous track's image. Eviction and failed
reads must not expose broken or stale references as valid artwork.

## Verification required before integration

Test partial/malformed metadata, late and reordered events, repeated track titles,
session replacement, position discontinuities, unknown duration, source mute,
volume feedback suppression, duplicate artwork, invalid/oversized images, cache
limits, eviction and stale asynchronous completion. Metadata/artwork failures must
not block or reset healthy audio outputs. Downstream forwarding requires explicit
field mapping and capability checks; transport choices are pending.
