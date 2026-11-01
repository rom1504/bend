# Phase150 evidence

[`phase150.tar.gz`](phase150.tar.gz) is an8.90MiB capsule with591 unique payloads
and236 byte-identical aliases. [`capsule.json`](capsule.json) records every size,
SHA256, alias and omitted large product. Every archive member was reopened and
checked against the original bytes.

The capsule contains frozen source assemblies and all three small lexer variants,
guard/command receipts, failed-source snapshots, complete graph/token outputs,
native acquisition receipts, raw bounded profiles, stage reports, independent
qualification receipts, and three complete parser QBE reference products.
Large executables/objects and duplicate large products remain in the66 verified
local retention closures linked by [`../retention.json`](../retention.json).
Nothing was pruned. Full reruns require the pinned compiler/runtime/toolchain
assets; this is not a standalone binary compiler distribution.

Extract into a fresh directory. Payload names retain repository-relative paths;
for a deduplicated alias, the manifest's `payload` names its exact bytes. Preserve
the original immutable evidence and use fresh output roots for reruns.

Useful retained records:

- `selfhost/build/phase150/variants01/selection.json`: literal, grouped and
  scalar module identities. The preferred scalar module is also the current
  `selfhost/tests/phase150/lexer-candidate.bend`; initial literal code is in
  Git commit `6e88473`.
- `source-baseline01/`, `parser-source01/`, `source-scalar01/`: exact full input
  and component sources. Historical diagnostic entry names are retained; the
  parser implementation itself uses current maintained declaration bodies.
- `lexer-scalar-checks01.json`, `parser-scalar-timing01.json`,
  `parser-acquisition01.json`, `parser-acquisition02.json`,
  `parser-scalar-acquisition01.json`: exact root-owned commands and outcomes.
- `parser-acquisition-profile01/`: frozen recipe/capture/stage evidence, with
  existing profiler input identities linked by the committed research plan.
- `parallel-trials01.json`, `parallel-host-{before,after}01.txt`, all four
  `parallel-{serial,parallel}0{1,2}/` trees and their guards: scheduling evidence.

The production source and installed selections were unchanged. Component
success, source checking, independent output tests, kernel proof and full native
self-reproduction are distinct gates; see the report's scope table and
[`../qualification.json`](../qualification.json).
