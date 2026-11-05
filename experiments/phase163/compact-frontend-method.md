# Compact-App frontend workload

Module: `selfhost/tests/phase163/compact-frontend.bend`; append unchanged to both
maintained baseline and private compact-App assemblies. It has no imports/main.
Its 41 declarations include pure API wrappers and optional native IO transport.
The extracted pure closure is about 522 KB baseline / 526 KB compact, rather than
the entire backend. No backend algorithm or emitted-IR verifier is replaced.

Exports are `p163f_parse(base: String, source: String) -> String` and
`p163f_check(base: String, source: String) -> String`. They cold-prepare Base using
`p86_prepare`, then perform the actual prepared-prefix source path copied from
`p86_plan` through `f_prefix_graph_trace`. The checking entry uses the identical
256-suffix branch between `p143cb_program(load,Nil{},world,True{})` and
`check_program_diagnostic_world(load,Nil{},world)`. It stops at DResult, before
proof/unsafe-dependency reporting, owned/main eligibility, annotation or lowering.
Consequently unsafe acceptance means body/type checking completed; no separate
proof-report verdict or native compilation success is claimed.

No new prepared carrier is required. Supply the exact pinned 75,064-byte Base,
SHA256 `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`, from
`selfhost/.bootstrap/upstream-phase66/bend2/base.bend`. Both binaries parse and
check their Base internally. Input sources must import Base and no additional
module, matching the active native request admission. Immutable source identities
are `/phase163/Base.bend` and `/phase163/Main.bend`, with the same UTF-16 source
ranges as p86; external file paths do not perturb diagnostics.

The observation is complete FResult (event book, error and imports) or complete
DResult (checked book, error and every DDiagnostic field). Every KDef variant,
constructor subtree, index shape and payload is included. Term tag, name, ID,
quantity, children/order, removed names, spans, explicit Lambda quantity flag,
literal flag/number/text and physical variant code are included. Only the private
App code 3 is mapped to generic code 0. Length-prefixed strings and tagged records
make the result unambiguous; this is complete serialization, not a checksum or
truncated summary. Prefix cache state and FLoadTrace bookkeeping are not the
published outcome and are not serialized. The exact checker admission remains
responsible for them. The structural compact controls separately retain physical
App identity and test its update laws.

For native measurement, supply a tiny `main() -> IO(U32)` wrapper calling
`p163f_main()`. IO argument contract:

```
phase163-frontend parse|check ABS_SOURCE ABS_BASE DISTINCT_ABS_OUTPUT
```

Use the established runtime-specific argv0/sentinel convention. The entry checks
absolute/distinct paths, reads complete files with `p86_read_file`, prepares Base,
loads, optionally checks, and streams one serialized definition at a time to the
fresh output. Parser/checker errors are fully written then exit nonzero; Base
preparation failure writes its tagged error and exits nonzero. Empty/short output
is never an expected successful request. Stderr separates read, Base preparation,
parse/load, checking, and observation/write milliseconds. Process time includes
all phases and destruction. Boundary clock printing is small harness overhead;
these stage clocks are descriptive, not a replacement for paired process timing.

Start admission with the three existing Phase162 sources `unsafe-valid.bend`,
`unsafe-type-error.bend` and `parse-error.bend`, requiring the independently
expected success/type-refusal/parse-refusal and exact full output agreement.
Then use the actual 645-declaration checker input:

* `selfhost/build/phase156/inputs01/checker.bend`, 182,039 bytes,
  SHA256 `a33aface7ce9002c95063978f98387e9b4b6d7d51f6a1a57fffc45c559188a1a`.

Its complete frontend work is substantially more meaningful than a construction
loop, though its type/pattern mix is not the full compiler. For the full transfer,
use the identical qualified maintained compiler source:

* `selfhost/build/phase152/production-source02/compiler.bend`, 3,085,157 bytes,
  SHA256 `027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.

Compare full observation files byte for byte before interpreting timings. Pure
API timing includes serialization and Base preparation; native stage timing can
separate these costs. Both paths use the same algorithm. No public KTerm host ABI
is required by the String outcome wrappers. The optional prepared API below is
private to a generated image and does not use the public typed-driver marshaller.

## Prepared API and checked acquisition

The final API also exports `p163f_prepare(base) -> P86Preparation`,
`p163f_parse_prepared(seed,source) -> String`, and
`p163f_check_prepared(seed,source) -> String`. In the generated raw JS API,
require `prepared.$ === "P86PreparationReady"`, then pass `prepared.seed` back
only to that same image. Prepare baseline and compact seeds independently;
never transport one image's compact internal values into the other image.
This excludes repeated Base preparation from request timing while preserving
its ordinary checked admission. Prepared-entry time still includes complete
observation; the native entry separates observation clocks.

Both pure API acquisitions pass the upstream checker:

* Baseline: `selfhost/build/phase163/frontend-baseline-api03/report.json`;
  source `frontend-baseline-source03/compiler.bend`, 522,297 bytes,
  SHA256 `f36ab7b38ef881ea1b3609c2dec60e8a7e35b14f10e1effa1e0736e3061380ce`.
* Compact: `selfhost/build/phase163/frontend-compact-api02/report.json`;
  source `frontend-compact-source02/compiler.bend`, 526,885 bytes,
  SHA256 `4b0fbd4bc71b879b3f328840ac4eb495c42043195d61dceced505336009e8a35`.

Each runs under the shared guard with CPU3, 2 GiB RSS, 16 GiB available-memory
floor, 32 MiB disk budget and 5 GiB reserve. Wall acquisition is 5.447/5.240s;
peak process-tree RSS is 611.6/646.0 MiB. These are acquisition receipts, not
frontend performance results. The extracted pure APIs do not retain the optional
native IO entry; that entry still needs source checking in its actual assembly.
No frontend input was executed by this preparation task.

Retained earlier failures: baseline API01 rejected a match-order error in the
private wrapper; its corrected simultaneous seed/loaded match is in the admitted
sources. Baseline API02 passed before prepared entries were added. All failed and
superseded roots are retained rather than rewritten.
