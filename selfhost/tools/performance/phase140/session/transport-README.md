# Authenticated P140/2 byte transport

`transport.py` reconstructs the compiler's rendered output. It does not parse
QBE, choose reusable units, compile source, or modify runtime/optimization rules.
Use the versioned Bend writer `../render/native-v02.bend`; v01's newline marker
is ambiguous when the same marker occurs inside a payload and is not accepted.

The compatible experimental `transport-v02.py` now has the same protocol/API
with bounded whole-header reading and per-epoch pin deduplication. All 31 original
plus six boundary/mutation controls pass. One full retained B replay improved
7.986s→4.809s with exact payload/wire equality; see
[the bounded transport report](../../../../../implementation/phase140/audit/transport-overhead.md).
The original remains frozen for comparison. New experimental session runners
may import v02; producer-status qualification requirements remain unchanged.

The v2 wire format is:

```text
# P140/2 BEGIN CURRENT ENDING BYTE_LENGTH\n
<exactly BYTE_LENGTH bytes>
\n# P140/2 END CURRENT\n
# P140/2 REUSE CURRENT PRIOR\n
# P140/2 DONE PIECE_COUNT\n
```

BEGIN and REUSE are alternatives for one ordinal. CURRENT must increase from
zero without gaps. ENDING is zero or one; a true flag requires the counted
payload to include the original extra legacy newline. END's leading newline
is framing, not payload. Partial lines, UTF-8, NUL, and literal protocol markers
inside the counted bytes are copied unchanged. No bytes may follow DONE.

The native byte count matches the pinned runtime's `io_utf8` width thresholds
at `runtime-borrow01/runtime.c:2488`: one byte below 128, two below 2048, three
below 65536, otherwise four. File.write uses that routine for every SCon
character. Counting adds one String traversal but makes no escaped or joined
copy. Each payload is bounded to 64MiB by the host, well below U32 length
overflow; native frame-size/count controls are exported as `p140rw_controls`.
Their compilation/execution is separate from the host controls described below.

## Context and invocation

Supply a separately pinned JSON manifest; no paths or identity claims are
accepted from the wire:

```json
{
  "kind": "phase140-transport-context",
  "protocol": 2,
  "session": "one-native-process-session-id",
  "producer": {"file": "/absolute/compiler", "bytes": 0, "sha256": "..."},
  "runtime": {"file": "/absolute/runtime.o", "bytes": 0, "sha256": "..."},
  "source": {"file": "/absolute/revision.bend", "bytes": 0, "sha256": "..."},
  "policy": {"target": "qbe", "description": "fixed experimental policy"},
  "inputs": []
}
```

The zero byte counts above are placeholders. Generate real pins with the
module's `pin(path)` helper. `inputs` can bind other policy/tool manifests.
Producer, runtime, policy and session must equal the prior report's epoch.
The current source may differ, but both source identities are verified. Keep
old and new source files distinct and immutable while the session runs.

```sh
python3 -B selfhost/tools/performance/phase140/session/transport.py \
  --stream /absolute/current.frames \
  --out /absolute/fresh-output \
  --context /absolute/context.json --context-sha256 CONTEXT_SHA \
  --prior /absolute/prior-output/report.json --prior-sha256 PRIOR_REPORT_SHA
```

Omit both prior options for the first stream. `--stream -` reads binary stdin;
an ordinary file or FIFO also works. The existing supervisor must enforce the
producer/decoder deadline and terminate remaining children on either failure.
`--expected-payload-sha256` optionally checks a complete frozen output oracle.

Output is one `payload.bin` plus `report.json`. Rows contain contiguous offsets,
lengths, SHA-256 values, ending flags and source ordinals. REUSE seeks only into
the authenticated `payload.bin` beside the pinned prior report; it cannot name
another file. Copy buffers are at most 64KiB. Limits are 100,000 records,
64MiB per piece and 512MiB reconstructed output. The report retains ordinal
metadata, not whole payload bytes in memory. On a stream error, incomplete
payload bytes are removed and a failure report remains.

**Transport completion is not producer success.** Every report explicitly has
`producerSuccessAttested:false`. Before publication or qualification, join the
native producer's zero exit, stderr policy, exact command/source/image/runtime
identities and the successful A/B decoder report pins. A valid DONE record
followed by a crashed producer is not an accepted compiler build. Prior A can
be used during the same still-running A→B process, but neither output becomes a
qualified result until that complete process succeeds.

This transport intentionally materializes the authenticated prior bytes on
disk, because the Bend render cache retains ordinal references rather than
linked Strings. It does not claim to eliminate the cache artifact itself.
The machine builder may consume the reconstructed output separately; this tool
does not change machine compilation or linking.

## Finite evidence

`transport-controls.py` ran 31 host-only controls in 0.13s on CPU1. All passed:
`selfhost/build/phase140/transport-controls01/report.json`, SHA-256
`5864af153d07016c7274aafcca7e0c18a7640e083515c72efca18d735783283d`.
These cover marker payloads, Unicode/NUL, partial lines, a payload crossing the
copy-buffer boundary, zero-length pieces, reordered prior ordinals, source
changes within an epoch, malformed versions/counts/flags, truncation, trailing
bytes, corrupt prior bytes/digests/offsets, context mismatches, and path escape.
Fixtures are small ordinary byte files; no compiler or generated program ran.
The native writer and actual compiler-generated frames still require a source
check and differential bridge in the coordinating campaign.
