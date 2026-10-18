# Phase110 native selected-library source

`prepare.py` assembles a candidate image source using the unchanged mature
checked frontend and the same experimental ownership/Nx modules as hosted
workers. Preparation executes no compiler. The root campaign separately checks,
acquires and qualifies an image; the installed compiler and Phase109 selection
remain unchanged.

```sh
python3 -B selfhost/tools/performance/phase110/native/prepare.py \
  --out selfhost/build/phase110/native-source-FRESH
python3 -B selfhost/tools/performance/phase110/native/prepare-check.py \
  --source selfhost/build/phase110/native-source-FRESH \
  --out selfhost/build/phase110/native-entry-check-FRESH
```

The first manifest records the full image source, source contracts, Base/cache,
portable image runtime, exact declaration overrides, and guarded acquisition
commands. The second manifest provides a small full-book typecheck command with
exact interface types and explicit semantic mocks. **Never execute the mocked
main or count it as frontend correctness evidence.** The full image uses the
actual `p86_plan`, checked erasure and `ns_body` fact lookup.

`--profile baseline|compact-general|compact-general-stored|compact-general-wrapper` selects
the runtime-template composition baked into the candidate source. The manifest
records that selection and every exact override. General helpers precede their
import declarations; the optional stored-field change remains a separate
profile. Earlier source snapshots keep their original contents.
The stored profile additionally requires `--worker-runtime AUTHENTICATED_DIR`;
preparation runs the source-only `stored-field-admit.py` check against the exact
composed compiler source and that runtime, and binds its receipt before issuing
acquisition commands. It cannot silently select stored-field omission without
those admitted source/runtime components.
The wrapper profile uses the exclusive alternative wrapper-spare template and
its matching source/runtime admission helper under the same requirement.

After acquisition, raw requests have this shape:

```text
IMAGE --threads 1 --gpu off -- phase110 ABS_INPUT CONTRACT FORMAT POLICY cache|live
```

`FORMAT` is `qbe`, matched `c`, or canonical `ir` JSON. The source file must match
the exact bytes recorded for its contract. Each request checks and erases that
source through the mature Bend frontend before ownership lowering. Output is a
library, whose runtime and entry harness must match the recorded ABI.

| Contract | Selected source definitions | Exported workers |
| --- | --- | --- |
| reverse | `nt_reverse`, `String.reverse.go` | `nx_list_reverse`, `nx_string_reverse` |
| discard | `p109_list_discard`, `p109_string_discard` | `nx_list_reverse`, `nx_string_reverse` |
| duplicate | `p109_list_duplicate`, `p109_string_duplicate` | `nx_list_reverse`, `nx_string_reverse` |
| tail | `List.tail` | `nx_list_tail` |
| last | `List.last.go` | `nx_list_last` |
| append | `nt_reverse`, `nt_append` | `nx_list_append`; reverse is private |

Policies are `raw`, `trusted`, `fused`, `tagged`, `specialized`, `pair`,
`pair-take`, `runtime-ir-single`, and `runtime-ir-atomic`. The first seven use
the closed ordinary-call library boundary; pair policies additionally produce
typed two-result statements. The runtime-ir policies use the separate verified
runtime-template boundary. Both boundaries derive the ordinary-call catalogue
from actual worker definitions, including the private reverse dependency used
by append; runtime imports cannot be declared owning ordinary callees.

The fixed contracts establish owning-Term roles for List<String>/String inputs
and results. General constructor/type/layout admission is still absent. Native
ordinary calls use the host stack when the existing self-tail loop does not
apply; arbitrary recursion depth is unqualified. Image acquisition still uses
the mature C/cproc/QBE chain. These limits are distinct from the native direct-IR
path used by an admitted ordinary request.

The additive `prepare-general.py` composes the bounded typed-entry gate after a
complete real-source closure qualification. It checks that the exact admission
modules occur in the API source that passed those probes, and preserves the
fixed image snapshot. Initial general composition accepts baseline and
compact-general profiles; stored/spare source-bound receipts cannot transfer to
new compiler bytes.

```text
prepare-general.py --source native-source03 --qualification closure-check03/report.json --out native-source04
prepare-general-check.py --source native-source04 --out native-entry-check04
IMAGE --threads 1 --gpu off -- phase110 ABS_INPUT general SOURCE_ENTRY qbe|c|ir POLICY live
```

The initial source04 full Base literal exceeded its acquisition guard. Fresh
source05 uses `prepare-general-comparison.py` to replace that literal with an
exact packed U32 comparison. It requires the same authenticated Base, an exact
packing inverse, 11 hosted controls, 14 native controls, and the completed
minimal comparator emission. The comparison checks full Unicode codepoints,
the exact length and the empty suffix. It changes no compiler/static allocation
cap or runtime, and source04's failed receipt is preserved.

The new command exports `nx_entry`. It reads Base from the compiled path,
requires exact complete compiled Base bytes, creates the mature checked seed
internally, and derives every callee from the resulting same-source request.
No raw seed, provenance flag, KDef or serialized certificate enters that command.
The root and all dependencies must have canonical monomorphic String or
List<&2,String> roles and must be reachable from checked main. Aliases, generic
callees, dependent/higher-order roles and missing erased facts refuse. This is
bounded canonical admission, not general datatype support.

The root campaign can qualify the exact native production bridge and image:

1. Run `build-bridge-api.py --source native-source05/bridge/source.bend --out API_DIR` under the serial process guard.
2. Run `emit-general.mjs API_DIR/api.mjs native-source05 closure-check03/report.json EXPECTED_DIR runtime-ir-single`. All dependency discovery and emission remain in Bend.
3. Run `qualify-general.py --source native-source05 --image IMAGE_DIR --expected EXPECTED_DIR --semantics controls/admission/native-semantics/manifest.json --out QUALIFY_DIR` under the guard. It checks the acquisition chain, eight exact positive QBE/C products and four refusals.
4. Compile the actual native stdout worker products with the independently frozen `closure-native-semantics01/harness.c`, selecting `-DP110_CLOSURE_ROOT=0..3`. Check their stdout with `controls/admission/native-semantics/check.py --root N --stdout FILE`.

The expected-emission API is bound to the exact production bridge. The native
qualifier authenticates compiler source → emitted C → metadata bridge → image,
and compares the native products byte-for-byte, accounting for IO.print's one
newline. That check is distinct from executing the independently constructed
ownership graphs and observing aliases, both release orders and final heap
balance in the final harness gate.

`run-semantics.py --qualification QUALIFY_DIR/report.json --prepared
closure-native-semantics01 --runtime-object RUNTIME.o --out FRESH_DIR` performs
that final gate under the root's outer guard. It builds both QBE and Clang
workers by default (`--backends qbe` selects one), links the same pinned runtime
object, and requires all 36 independent observations per backend. All generated
worker input files are the native qualifier's actual stdout products.

The compiled comparator has 14 dynamic native mismatch controls in its isolated
probe. No Base mismatch has been injected into the full compiler image, and the
canonical Base assets are never modified by these qualification tools.

After the general image qualifies, `qualify-fixed.py --source native-source05
--image IMAGE_DIR --qualification QUALIFY_DIR/report.json --expected
native-fixed-expected01 --out FRESH_DIR` checks eight actual QBE/C products for
the existing reverse, tail, last and append contracts against their earlier
qualified emissions. It uses the existing cached fixed route by default;
`--mode live` selects its live route. The actual `reverse-qbe.stdout` can be
compiled with the old ownership harness as a separate preservation check.

`run-string-append.py --source native-source05 --image IMAGE_DIR --qualification
QUALIFY_DIR/report.json --prepared base-string-append-controls01
--runtime-object RUNTIME.o --out FRESH_DIR` exercises the actual Base
`String.append` through general live admission. It emits and compiles QBE and
Clang products and checks 20 independently frozen complete-value observations
per backend. That corpus bounds non-tail recursion to 1,024 first-input cells;
it makes no claim about arbitrary native stack depth.

`run-transfer.py --plan native-transfer-plan01 --runtime-object RUNTIME.o --out
FRESH_DIR` runs the frozen QBE transfer comparison after qualification. It
compares `fused` with the already selected `runtime-ir-single`, reuses actual
qualified selected products, and requests only the two missing fused products
from the native image. Five fixed cases receive five alternating paired rounds;
there is no policy search. Both workers first pass their full original oracle,
and every timed job must still match its case oracle. String observations run
on every repetition, with later output sent to `/dev/null`; construction,
observation and release remain outside the worker timer. Recursion limits and
graph inputs remain unchanged.
