# Bounded native-frame transport improvement

The original `session/transport.py` is preserved unchanged, SHA-256
`02153e24f435d9ca731bfc559845be25ec656e2ae731cc89c5d7387899550c46`.
The experimental `session/transport-v02.py` changes two host-only operations:

1. Read a complete header with bounded `readline(256)`, updating the wire digest
   once instead of one Python call/hash update per byte. A newline at byte 256
   remains valid; a later newline remains rejected.
2. Deduplicate identical `(path, byte count, hash)` pins within a verification
   epoch. Preflight and postflight have **different** memo sets. Conflicting pins
   for one path are still checked, and inputs changed during decoding still
   fail postflight. Manifest-before/after-reading checks remain unchanged.

The wire protocol, payload bounds, artifact map, producer-status obligations,
report schema and byte semantics are unchanged. No compiler source, runtime,
machine builder, cache eligibility decision or installed selection changed.

All original **31 transport controls passed**, followed by six additional
controls for exact header bounds, conflicting pins and postflight mutation
detection. Compact receipts are [transport-controls02.json](transport-controls02.json)
and [transport-edge02.json](transport-edge02.json).

After the coordinating native/API lanes became idle, the retained full B frames
were decoded serially on CPU1, first with the original and then with v02. Both
used the same pinned original A artifact map, current context and expected B
payload digest. No compiler or generated program ran.

| Observation | Original | v02 |
|---|---:|---:|
| Complete decode wall time | 7.986s | 4.809s |
| Process CPU time | 7.952s | 4.750s |
| Output bytes | 106,285,793 | 106,285,793 |
| Pieces / reused pieces | 66,974 / 66,802 | 66,974 / 66,802 |

This one pair saved **3.176s, or 39.8%**, in host transport. The payload is
byte-identical, SHA-256
`a5149b2410d70546b7a28ff907aa312b6431cf8c5348107e7b675b9e9f54702e`.
The complete wire digest and fresh/reused byte counts also match. The
[replay receipt](transport-replay02.json) binds both methods, retained native
frames, contexts, original prior report and payload, and fresh output reports.

This is an old→new transport pair, not a balanced multi-round benchmark or a
compiler-speed measurement. It does not independently separate the contribution
of the header change from pin deduplication. The replay uses the retained native
B digest as a byte-equivalence oracle; independent source compilation and
qualification belong to the coordinating campaign. Remaining host cost,
including report serialization and copying reused bytes, is not claimed to have
been eliminated.
