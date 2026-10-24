# Independent object-cache review

Reviewed `../incremental/objects.py` before target builds. This review executed no
compiler, assembler, linker or generated program and changed no prototype code.

No blocking ABI/cache issue was found for the pinned QBE grammar, single-writer
cache and closed linked-image scope:

- The scanner retains complete declaration spans, masks comments/strings and
  includes all global references, including data relocations/address-taking.
- Cross-unit private definitions gain link visibility only when referenced from
  another unit; original exports remain. Every type declaration is carried into
  each unit. This is intentionally a changed object-level ABI.
- Exact unit bytes contain numeric FIDs, constructor IDs and static Term words.
  Context hashes include method, lexer, target flags, QBE/as/linker and runtime.
  External definition header/binding changes additionally invalidate the unit.
- Receipt admission verifies the object hash and current key/context. Failed or
  partial cache entries fail closed; the prototype does not repair them silently.
- Fresh and cached builds use the same complete current partition plan and
  independent cache stores. Equal allocated sections/addresses, including BSS
  sizes, strongly test object reuse under that plan.

The remaining comparison boundary is important: both arms share the partitioner.
They do not independently prove that splitting/promoting names preserved the
monolithic image's semantics. Retain ordinary output and compiler-request gates
against the independently built monolithic product. A baseline full build and a
fully rebuilt changed source are needed before claiming source-edit correctness.

Small hardening requests sent to the owner: compare ELF machine/entry/program
headers in addition to sections, verify plan pins again at comparison time, and
require a positive hit count when declaring a cache-reuse success. These are
independent-evidence improvements, not observed failures of the frozen product.

Hashing the complete new IR makes stale numeric bindings miss safely; it does
not stabilize identities or avoid the frontend. Grouping every1000 functions can
also churn subsequent groups after insertions. A warm backend-only gain must
include partition scanning/materialization and be labeled separately from total
source-to-native research-loop gain.

## Executed negative admission controls

The [five-control receipt](../../../../../research/phase132/cache-admission.json)
records actual calls into the unchanged `objects.py` admission/build function.
`cache-rejections.py` copied the first completed current cache entry into five
fresh locations and changed one input per control:

| Mutation | Actual rejection |
|---|---|
| One byte flipped in copied object, original expected hash retained | `Changed input` |
| Cached receipt's key replaced | `Cache admission differs` |
| Copied unit text changed, old pin retained | `Changed input` |
| Cross-unit binding symbol changed, old digest/key retained | `Cache key differs` |
| Copied runtime changed, old pin retained | `Changed input` |

All five rejected before any subprocess launch attempt. A tripwire on
`subprocess.run` would fail the control immediately if admission tried to compile,
assemble or link. It did not replace any admission predicate. Original plan,
receipt and object hashes were rechecked unchanged afterward. No compiler target
ran, and the original cache and frozen method were never edited.

These are specific integrity and stale-key checks, **not** proof of source-level
dependency completeness. They do not establish invalidation for an omitted
semantic dependency or a deliberately forged internally consistent receipt.
Reproduce with a fresh Phase132 path:

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase132/boundaries/cache-rejections.py \
  --build-report selfhost/build/phase132/object-changed-cached01/report.json \
  --out selfhost/build/phase132/object-admission-negatives-fresh
```
