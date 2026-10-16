# Owning observer result projection: bounded generated-C experiment

This is a separate follow-up to the frozen +425-line Phase102 candidate. It
changes neither the Bend compiler nor the installed image. Root owns all C
builds and executions. Only offline source transformations and shape controls
have run at initial preparation.

The structural pattern is an owning observer adapter returning
`Tuple(Tuple(root0, root1), scalar)`, followed immediately by the generated
second-field projection. It currently occurs once in each saved final app C.
Two temporary Tuple allocation sites remain even though the consumer discards
the roots. The prototype introduces a private three-Term owned product, then
disposes both roots at the projection boundary and returns the scalar. Public
functions and results retain their original one-Term ABI.

`prepare.py` requires exact whole-function templates after renaming only generated
function, local and label identifiers. It follows at most four trivial owning
forwarders. It does not select String, application, or source-function names.
`patterns.json` contains the normalized structures; `pattern-provenance.json`
records the actual source spans used to establish those patterns. The present
scope is deliberately two nested ordinary Tuple constructors with two roots,
not arbitrary C or a complete product-demand optimizer.

The adapter retains its existing observer call and error checks. Its internal
constructor blocks instead write owned fields into the private product. The
caller retains its argument order and intermediate error check. A replacement
projection retains the projection worker's cancellation poll and sinks both
discarded owned roots once. No root is borrowed across a new caller boundary;
aliases retain the original owning-input requirement. Existing adapter, alias,
projection and scheduler functions remain for every other use.

Refuse additional effects/operations, a different constructor/projection shape,
unknown or recursive alias paths, nonmatching argument flow, and narrowed Tuple
fields. Unmatched functions and complete unmatched programs are byte-identical.
The transformation verifies an exact inverse of all edited source spans. Fresh
private names cannot collide with an earlier prototype. Root must use the same
controlled compiler flags, without external Tuple field-narrowing defines.

The sink simplification assumes the existing owning immutable-constructor ABI:
allocating, sealing, taking and discarding fresh private Tuple shells may be
replaced by disposal of their fields. Shared/static/dynamic roots and overlapping
aliases need execution controls. Allocation failure timing is not preserved;
this optimization removes allocations. No runtime atomic protocol changes.

Offline evidence is `selfhost/build/phase102/projection-offline01/`: all three
saved app C files transform, with one selected caller/two Tuple sites each;
arbitrary worker renaming still admits; added effects in the adapter, projector
or caller refuse with exact unchanged fallback. These are shape tests, not C
compilation, semantic success or speed measurements.

To prepare a catalog consumable by the existing saved-app runner:

```sh
python3 -B selfhost/tools/performance/phase102/projection/prepare.py \
  --catalog selfhost/build/phase102/FINAL-CATALOG/catalog.json \
  --out selfhost/build/phase102/NEW-projection-catalog
```

Then use the generated `NEW-projection-catalog/prepare.py` as the existing
`phase102/run.py --transform` input. The full compiler remains frozen while
this follow-up is tested. First compare complete app outputs and focused owning
observer controls, including shared/unique/static roots, equal/prefix/mismatch
comparisons, U32/Unicode values, retained aliases and one/four workers. Compare
against the exact final candidate as well as upstream; only a measured useful
gain warrants a Bend-level product/projection certificate.
