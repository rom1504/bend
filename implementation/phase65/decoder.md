# P65-007: frame4 decoder experiment

Case-local field loads failed the fresh-request discriminator. Static per-tag
readers then passed the same controls and reduced first complete frame decode
from 64.47 to 27.13 ms (0.4208×). A same-image whole-request comparison is prepared;
the decoder result alone does not establish compiler speed. The helper is not
installed in the compiler.

## Measurement and first result

The selected State09 frame contains 35,378 book records and 11,379 prepared
records, with 224,332 fields. The original loop's unconditional nine reads per
record imply 420,813 source-level reads, but only 22 exceed the array extent.
Most unused reads access the next record. V8 may eliminate unused loads, so this
46.69% source reduction is not a prediction of CPU savings. Real segments are
aligned; the decoder's conditional alignment copy is inactive.

The isolated case-local helper passed all 87 unchanged Phase64 domain controls
and all eight fresh-process workers. Four balanced baseline/candidate pairs used
the identical cache and API identity. Each worker decoded the complete frame
seven times before importing the baseline oracle and comparing every graph node,
root, scalar, key order, prototype and sharing relationship. No compiler ran.

| Complete frame decode | Baseline median | Case-local median | Candidate / baseline |
| --- | ---: | ---: | ---: |
| First in fresh process | 62.33 ms | 65.29 ms | 1.0474× |
| Second | 69.55 ms | 60.15 ms | 0.8650× |
| Third | 59.21 ms | 35.75 ms | 0.6038× |
| Later four, pooled | 26.19 ms | 24.56 ms | 0.9378× |

Reject the first candidate: later improvement does not offset its fresh-decode
regression. The 19.94-second guarded microprobe avoided a compiler rebuild.
These clocks include frame parsing and digests, exclude module import/file read,
and retain seven graphs until post-clock equality. Later measurements therefore
mix tiering and GC effects and are not independent fresh-request samples.

The compact [result and trace evidence](evidence/decoder-case-local.json) pins
the clean report, raw trace and controller. The original source census is
[H6 review](evidence/state09-frame4-h6-review.json).

## What the V8 trace discriminates

The candidate `decodeBaseArena` has SFI `0x36abe4453589`, first visible at trace
line 19. The baseline oracle has a different SFI, `0x2e53da2efe81`, first visible
at line 107, after seven candidate decodes. They must not be combined.

The candidate repeatedly compiles to Maglev and TurboFan with compare/keyed
access/object-literal feedback failures, lost precision, a wrong call target
and allocation-site tenuring invalidations. TurboFan OSR compilation fields
include 24.7, 33.5 and 48.2 ms; one 31.1 ms compilation aborts on dependency
change. These background compiler durations are diagnostic and cannot be added
to request latency. The baseline oracle's later trace is not a clean baseline
timing comparison.

The trace supports testing a smaller optimization unit: a rarely encountered
constructor should not need to invalidate a large loop containing all twelve
constructors. It does not prove that tiering is the only cost or that splitting
will help. The next fresh-process result is the discriminator.

## Static-reader successor

`selfhost/tools/performance/phase65/latency/decoder/prepare-split.py` derives a
fresh candidate directly from the frozen State09 helper. The encoder, binary
schema, header/string parsing, record checks, object literals, roots and output
arrays stay unchanged. Twelve module-level readers retain the original tag
bodies; static reference/string/span functions retain the original checks. A
small loop validates record geometry, calls the indexed reader, then pushes the
node and kind. It adds one state object per decode, no per-record tuple or
dispatch closure. Source size increases from 285 to 348 lines (+63).

The same consumed controller and 87-control corpus are reused without changes.
Only a new factory, helper copies, exact patch and manifest are introduced.

| Artifact | SHA-256 |
| --- | --- |
| State09 baseline helper | `b58b927ac611f4ead292d4f736cfd427e955b81c1f0efa2f55d1e784755a0119` |
| Static-reader helper | `737d1958f3e035c04a266e770a4512e37464adc559deb3dc7263bc0bc509bd46` |
| Factory | `5105036185c4ccb80ce9f75acf03c5d21d9c20d5ea2a932a11d15eebf570133b` |
| Manifest | `c3781176ca1a5c2b9a972ebaa896ad8c19c0971d374aeaf36b1ecfcc761e1671` |
| Reused controller | `3f83781b31ddba121fa692ca214d092cd7087de0a3b2179caa51ab1c68948da8` |

Root's exact probe and optional separate trace commands are in
`selfhost/build/phase65/frame4-static-tags01/commands.txt`. Preparation used only
Python on CPU0. No live helper, cache, compiler source or consumed artifact was
modified. Independent cache-contract source review passed all twelve tag bodies,
literal fields/order, subtype masks, backward references, ABI, Unicode, span,
Boolean and legacy 6/7/8-field world checks.

## Static-reader result and next gate

All 87 domain controls and eight fresh-process workers passed. Complete graph
values and sharing matched the baseline. The four first-decode samples were
63.29–65.09 ms for baseline and 26.96–27.76 ms for the candidate; the separation
is much larger than variation within this small sample.

| Complete frame decode | Baseline median | Static-reader median | Candidate / baseline |
| --- | ---: | ---: | ---: |
| First in fresh process | 64.47 ms | 27.13 ms | 0.4208× |
| Second | 73.36 ms | 13.73 ms | 0.1872× |
| Third | 42.86 ms | 7.96 ms | 0.1856× |
| Later four, pooled | 25.98 ms | 9.08 ms | 0.3496× |

First book decoding fell from 50.77 to 18.05 ms; prepared decoding fell from
10.46 to 5.69 ms. Component medians do not add to the total median. Compact
[static-reader evidence](evidence/decoder-static-tags.json) pins inputs, controls,
results and the full-request plan without copying raw node arrays.

The mechanism is still a hypothesis: smaller static constructor functions appear
to give V8 more stable compilation units, while retaining fixed object shapes.
The earlier field-load reduction already tested load removal and failed, so it
cannot by itself explain this gain. A separate successor trace can test the
tiering explanation; it must not replace clean timings. Its command is already
prepared but no extra diagnostic target is needed before the request result.

`selfhost/build/phase65/host-static-tags01/plan.json` prepares the next gate:
two balanced baseline/candidate pairs for Numeric and Map, eight ordinary
fresh-process requests total. Each project has 109 pinned files; only the helper
differs. API, driver, source, runtimes, Base and cache bytes remain identical.
Complete emitted-module equality is checked after clocks. Use
`host-static-tags01/commands-balanced.json` for the two-round command; the factory's
default one-round recipe is not the selected comparison. This is diagnostic
same-image confirmation, followed by normal compiler qualification if selected.
