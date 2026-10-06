# B2 → B3 direct emission

**The String.eq candidate's direct B2 image freshly type-checks its own source
and reproduces its complete bytes as B3.** These are separate passing gates:
the source check takes 35.39 seconds including setup, and exact reproduction
takes 250.72 seconds. The older host02 image's reproduction attempt was stopped
at its 300-second deadline. No baseline completion time is known.

The checked String.eq B1 is now installed and verified, including 42 legacy and
24 default/relocation checks. The ordinary default compiler image remains the
checked B1 route; selecting the direct JavaScript
*backend* does not mean the host driver is already using the self-emitted B2
*compiler image*. B2 is explicitly selected through `BEND_TYPED_API` in private
qualification projects. These results do not change that default or retire the
remaining legacy compiler-image clients.

## Exact candidate and outcomes

The independently checked candidate is `selfhost/build/phase56/checked-string01`.
Its source SHA256 is
`5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244`,
and its selected checked B1 API is
`128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`.
The complete **3,896,951-byte B2 and B3 images** share SHA256
`3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`.

| Gate | Observed result | Worker time |
|---|---|---:|
| Tiny diagnostic split versus ordinary unsplit emission | Exact bytes, 11 roots | 26.54 s |
| Checked candidate B1 emits its own source as B2 | Complete, 77 requested roots | 84.43 s |
| Ordinary-driver B1 versus B2 | Eight exact observations, including JS/C emission | Separate role receipts |
| B2 freshly checks its complete source | Type accepted; expected unsafe proof-trust failure | 35.39 s |
| B2 emits its complete source as B3 | Complete B2/B3 byte equality | 250.72 s |

Full emission selected 3,167 entries, including 3,054 definitions after Base,
specialization and reachability. That count differs from the **3,012 unique
definitions in the compiler source assembly**. The 77 requested roots are the
unchanged bootstrap interface; the emitter retains all eligible exports in its
selected closure, rather than filtering the finished module down to 77 keys.

Generation/driver receipts are under
`selfhost/build/phase56/bootstrap-string01-plan/`:

- `full/report.json`: SHA256
  `e65a5c34c097955e002910901b37f7ce6ff952dfae3d60003b6dd64925b3f077`.
- `driver-comparison.json`: SHA256
  `a3fec2f4b41b671f65d30cfad80142a1aeb3d7544221ac5c2323e7dd681028ff`.
- `image-pins.json`: SHA256
  `11c5e4982678ac88e86f7d304ba8c3fc12c22ec756b0b2fa43f615a23ab77619`.

## Fresh checking and proof trust

`selfhost/build/phase56/self-check-string01/report.json` passes, SHA256
`5a366be103a45895bb8a7d0669f1245a0d2e8a7692981101866cedde2d07868e`.
The actual B2 uses the unchanged ordinary driver with an initially empty private
Base cache. Its complete source check takes **29.68 seconds** inside the 35.39s
worker request. The supervisor records 35.57s and 798,896,128 bytes peak tree RSS.

The source contains exactly 3,012 unique `def` declarations, all explicitly
`@unsafe`. The driver reports `checked: true`, `typeAccepted: true`,
`kernelChecked: false`, and `proofTrust: "failed"`. Its ordinary verdict is
`status: "error"`, exit code 1, with the exact diagnostic enumerating those
3,012 unsafe definitions. The controller requires this result; it does not turn
the compiler into a mathematical proof or relabel the emitted image as a genuine
checked-development attempt. Fresh type acceptance and unsafe proof trust remain
separate facts.

## Complete reproduction

`selfhost/build/phase56/reproduce-string01/report.json` passes, SHA256
`a9d8233e26a1b614c7b6980abf7be204c796fa7f0d74641aa5e1a3c51df04e1d`.
The worker takes **250.7194 seconds**; its supervisor records 250.9148s and
1,071,415,296 bytes peak tree RSS. The complete B3 file is compared directly with
B2: no normalization, export filtering or alternate expected output is accepted.

[reproduce-v2.mjs](../../selfhost/tools/performance/phase56/bootstrap/reproduce-v2.mjs)
uses ordinary source discovery and retains TODO completion, specialization,
ownership, source reachability, annotation, emitted reachability and layout
checks. It requires the same roots and selected-definition counts, then invokes
**one ordinary `jd_library_selected(context, selected)` call**. No diagnostic
stage export is added to B2 and no split emitter is used in this reproduction.
The pinned runtime and ordinary module preamble are assembled exactly as for B2.

This is an **emission fixed point** for the exact candidate source and image.
The reproduction receipt itself uses the inherited exact-source bootstrap proof;
the independently executed fresh source check above supplies the separate B2
type-checking evidence. Equality alone would not establish that check.

## Preserved baseline and unexecuted branch

The initial B2 was the Phase55 host02 image, SHA256
`ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091`,
from source
`e4383fa08d621716acac437224de182af52e0b16c32b3f29b2614fc1ad1d6710`.
Its reproduction supervisor is
`selfhost/build/phase56/reproduce-b2-01-supervisor/run.json`, SHA256
`f6b9d4a7bbff8793c4aeb816f6d2f7ac78640f0a9fa2b451307735f5e0b72422`.
It records `stoppedFor: "deadline"`, 300.0817s and 945,446,912 bytes peak tree RSS.
This was a deadline failure, not an observed out-of-memory failure.

Preserved progress records 124.80s in emitted reachability and entry into
unsplit library emission at elapsed 209.91s. The process was killed before a
complete image or worker report existed. That run therefore supplies neither
an equality result nor a completed baseline time. The candidate includes both
cleanup and the definition-only String.eq change; these differently scoped,
single diagnostic runs are not a controlled speedup measurement.

The cleanup-only [reproduce-clean.mjs](../../selfhost/tools/performance/phase56/bootstrap/reproduce-clean.mjs)
and its [recorded derivation](../../selfhost/tools/performance/phase56/bootstrap/reproduce-clean-derivation.json)
were statically reviewed but **not executed**. They would independently bind
`checked-clean01` source
`19498b7f40324cb5ff78345775d665f7530d413af87f7cbb6afeae6274294d5e`
while retaining the old image-origin proof. They are not evidence for the selected
candidate. Frozen host02 setup/reproduction workers and all failed attempts remain
unchanged; Phase54 and Phase55 evidence receives no new writes.

## Admission and reproducible tooling

[prepare-candidate.py](../../selfhost/tools/performance/phase56/bootstrap/prepare-candidate.py)
reuses the Phase55 split-emission and ordinary-driver algorithms. Its recorded
local derivatives relocate imports and update the diagnostic stage exposer's
whole-core hash after exact comparison of the three library-composition functions.
The tiny split/unsplit gate precedes full generation; the eight driver comparisons
precede creation of the explicit image-pin file. Historical `phase55-*` report
schema labels remain visible, with actual Phase56 producer and subject identities.

[setup-v2.mjs](../../selfhost/tools/performance/phase56/bootstrap/setup-v2.mjs)
joins the genuine attempt, exact source/B1/B2/runtime, 77-root inventory and
generation/driver receipts. It reconstructs the diagnostic tool derivatives from
their recorded edits, then copies the unchanged driver, dependencies, runtimes,
manifest and actual API into a fresh private project. Ordinary `loadApi()` must
return that image's named API. There is no injected facade, TypeScript fallback
or fabricated bootstrap sidecar. Base caches are private and bound to the actual
API and Base hashes; final inputs and copies are rehashed.

This is the executed command shape. Use **new output suffixes** for any repeat;
existing receipts and images must not be overwritten:

```sh
python3 selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 300 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase56/reproduce-string02-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase56/bootstrap/reproduce-v2.mjs \
  selfhost/build/phase56/bootstrap-string01-plan/image-pins.json \
  selfhost/build/phase56/reproduce-string02
```

## Remaining cost, without causal attribution

The successful B2 request spends 18.27s loading, 8.87s specializing, 4.01s
annotating, **89.03s in emitted reachability**, 6.06s in layout proof and
**111.68s in unsplit library emission**. These are useful boundaries for the next
profile. They do not identify which lookup, string operation, allocation, SCC
body, wrapper or runtime representation causes the remaining cost.

The checked B1's 84.43s split-generation run and B2's 250.72s unsplit reproduction
use different compiler images and diagnostic paths. They are not warmed paired
latency measurements or proof of a particular threefold mechanism. All runs here
are bounded single observations with progress and provenance overhead. Broader
compiler-latency results belong to their separate protocol and report.
