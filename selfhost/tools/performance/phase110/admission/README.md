This is a small entry representation prototype. It does not replace the native
frontend's frozen source contracts. The parent campaign owns all checker and
target execution.

`nxe_entry(source_book, erased_facts, name)` reads the original checked source
telescope and matching erased fact from one authenticated request. It admits
one to eight explicit live parameters, each canonical `String` or
`List<&2,String>`, and a result of either role. It consumes exactly the declared
source arity before classifying the result, so a function-valued result cannot
be mistaken for an additional machine argument. Aliases, erased parameters,
dependent or higher-order types, unsupported element types and unknown names
refuse without normalization.

The Base `String`, `List` and `Char` parent definitions and constructor
telescopes are checked structurally, including constructor order, arities,
quantities, field order and alpha-bound variable references. The trusted loader
sets the parent provenance bit only for Base. The four output constructor IDs
remain bound to the existing authenticated runtime ABI. A same-shape user
datatype cannot acquire that identity. This is a bounded descriptor check,
not general datatype admission or a new runtime layout.

The certificate retains the exact original typed definition and erased fact,
the ordered parameter/result roles and the four constructor identities. It
does not prove that arbitrary host-supplied KDefs came from a checker. The
standalone probe authenticates both books as products of one checked capture;
the live native factory in `../native/general.bend` reads Base at the compiled
canonical path, requires equality with the compiled complete Base text, then
constructs `p86_prepare` and `p86_plan` internally. It extracts typed and erased
facts from that resulting checked request. No seed, provenance boolean, book,
or certificate is accepted by the command interface. The older unintegrated
`request.bend` experiment still assumes a trusted seed and is not used by this
factory. The standalone transport likewise requires the actual driver Base
path and pinned bytes in capture inputs and source files. `nxe_entry` alone
certifies no provenance. A reusable consumer must regenerate this evidence at
that trusted request boundary. Body shape, ownership and closed call targets
remain independent mandatory gates.

Root workflow:

```text
prepare.py --source CHECKED_PHASE110_SOURCE --out FRESH_PROTOTYPE_SOURCE
stage0-library.mjs FRESH_PROTOTYPE_SOURCE/source.bend API nxe_entry nxe_layout_ok
phase109/capture.mjs controls/admission/source.bend FRESH_CAPTURE
admission/check.mjs API FRESH_CAPTURE FRESH_PROBES
```

The independent coverage oracle has 14 real-source cases. The probe additionally
labels nine malformed-data controls separately; they are never called checked
source. It compares complete ordered roles, retains each accepted certificate,
and checks the exact source/fact bindings. The ill-typed source in the coverage
manifest is a separate frontend refusal check. The generic `nt_reverse`
dependency deliberately refuses: a concrete wrapper's entry certificate does
not grant a closed-library certificate or implicit generic specialization.


`nxe_close(source_book, erased_facts, roots)` discovers dependencies in Bend
from each actual erased body's `Ref` identities. Every reached definition,
including private callees, must pass the same typed entry checks. It preserves
unchanged facts and certificates, deduplicates cycles, and assigns deterministic
private machine names. Requested exports cannot use the `rt_` or
`nxe_private_` namespaces. Bounds are 32 roots, 128 definitions and 8192 AST
nodes per body; exhaustion refuses the whole request. Lowering still performs
its independent body, ownership, closed-call and machine-signature checks.
The internal `nxe_lower_closed` helpers are implementation plumbing, not an
external certificate-validation interface.

`check-closure.mjs API CAPTURE FRESH_OUT POLICY` consumes the independently
frozen `closure-manifest.json`: four positive exported roots, two canonical
roots with unsupported private dependencies, and nine explicit data mutations.
It asks Bend to derive the combined nine-definition closure and emits both QBE
and C. It does not execute emitted native workers. The original entry probe
also tests the generic wrapper's `closedLibraryAccepted: false` oracle field.

The native general command is `ABS_INPUT general SOURCE_ENTRY qbe|c|ir POLICY
live` and exports `nx_entry`. Initially the selected entry and all callees must
be reachable from checked `main`; an absent erased fact refuses. General mode
does not use the prepared Base cache. `native/prepare-general.py` requires a
complete actual closure qualification report and binds the current admission
module bytes to the exact checked API source before composing a fresh image.
The original fixed-contract native source remains separately frozen.
