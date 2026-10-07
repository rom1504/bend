# Frame and export admission compatibility

`make-method-v6.py` generates `selfhost/build/phase61/latency-method05` from the
reviewed method04-v2 bytes. It retains the campaign-stable hashing protocol,
active input hashes, fresh-process rotation, clocks, prepared-byte equality,
cache priming, and one-request diagnostic capture. No targets were executed.
The two campaign SHA checks concern runner/sample verification. Fresh private
staging retains its original checked-attempt audit and Node pin/final checks, once
per prepared role. Reused preparation bypasses those staging reads; they are not
repeated per sampled case/round.

There was no 81-export cap in the original latency setup: checked roots come
from `bootstrap.exports`, direct emission roots must match the checked subject
exactly, and the adapter verifies every required function dynamically. The actual
compatibility defect was treating `-frame2.json` as plain JSON. Method05 detects
both frame suffixes, requires the selected driver's `decodeBaseCacheFrame`, and
checks supported metadata versions 4/6. Framed bytes retain the selected decoder's
raw payload digest checks; the tool does not substitute a reserialized tree hash.

New `make-bindings-v2.py` retains the original bindings/replay recipe and adds
paired optional `--candidate-admission` and `--candidate-roots-reference` inputs.
For the reviewed State06 image, use:

```
--candidate-admission selfhost/tools/performance/phase61/cache/carrier-admission01.json
--candidate-roots-reference selfhost/build/phase61/bootstrap-state06/roots-reference.json
```

The setup joins those receipts to the actual checked attempt/bootstrap and driver,
the historical root order, the four original prefix exports, and the admitted
supplementary roots. It checks the exact union and each new export; it does not
hardcode an 86-export count. Old baseline roles retain their genuine export set.
The roots/admission document is provenance, not a fabricated bootstrap report or
prefix-state permission certificate. State admission still belongs to the actual
selected driver and Bend API.

The bindings producer defaults to method05 and otherwise preserves its CLI.
Analysis owns materializing State06 bindings after the genuine full B2 emission
and its output qualification packet exist. Root owns preparation and screens.
The new runner can also reuse the unchanged State04 preparation with its exact
original bindings for a separate fast-method screen. Successful source generation
and syntax checks imply neither semantic nor speed qualification.
