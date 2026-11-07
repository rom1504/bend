# Context materializer: release old children before recursion

Status: experimental source overlay and bounded complete-loader workload
prepared; **no target execution or speed claim** by the implementation agent.
Two independent source reviewers found no semantic blocker. Both checked the
nonempty-built invariant before final child observation, exact empty/literal
behavior, special branches and all metadata. These reviews did not execute
targets or establish generated liveness. Root owns checking, native builds,
oracle readback and measurements after the current qualification.

## Hypothesis and selected ceiling

The real materializer currently carries both `term` and `ks(term)` through its
child loop. Keeping the original parent alive also keeps its old child list
alive while those same children are recursively transformed. This can cause
ownership work without increasing logical allocation counts, as the earlier
consuming pattern experiment demonstrated.

The latest retained profile observes `f_context_material_children` in 51/952
active-context samples inside a 30.522s diagnostic parse/load interval, plus
12 contexts in `material_done`. These are neither inclusive attribution nor
clean timing. They justify testing the real loader; they do not predict a
whole-request percentage or imply that the entire loader interval disappears.

The overlay replaces only `f_context_higher` and `f_context_lower`. Their
ordinary traversal entry calls `p173cm_enter`. Empty children retain the exact
existing `f_context_material_done(term,lower)` path. Otherwise `p173cm_split`
consumes the record into ordinary fields and passes an empty-child KTerm or
KLambda shell plus the owned original children to the existing loop.

The loop, deferred scheduling, early errors and final reduction are unchanged.
There is no runtime ABI, foreign effect, private parent token, uniqueness
assumption or new recursive traversal. This is an explicit source-level ceiling
for lifetime improvement; it is separate from the automatic QBE decomposition
prototype, whose present admission cannot cover this helper family.

## Equivalence argument and limits

For a nonempty original child list, the preserved shell has exactly the same
tag, name, ID, quantity, removed-name list, spans and lambda quantity-presence
bit. Its only changed field is `kids=[]`.

1. `f_context_material_deferred` observes only the tag and the loop's `rest` /
   `built` lists. Those inputs are unchanged.
2. Every successful or deliberately deferred child step conses onto `built`.
   Therefore an initially nonempty child list reaches its successful terminal
   state with a nonempty `built`. That branch reconstructs the original record
   variant using the complete reversed result before `material_done` observes
   children or performs application/lambda reduction.
3. A stopping child returns that same first error directly, without final
   reduction. Earlier release of obsolete data changes ownership cost, not
   child evaluation order or the error value.
4. Empty children keep the original term. KLiteral always has `ks=[]` regardless
   of its payload `kind`, so arbitrary literal kinds preserve the old behavior.
5. External root/child aliases remain valid through ordinary ownership. Metadata
   can share strings with descendants and those shares must remain; no raw
   pointer or assumed unique ownership bypasses that obligation.

The new helpers are acyclic; the original recursive loop and recursive higher /
lower calls remain. Native qualification still has to establish generated
stack behavior and liveness. In particular, source decomposition alone does
not prove that the generated code releases the original parent before child
recursion. The source argument is not a BendTT proof, and helper `law`
declarations are signatures, not semantic equivalence theorems.

**Cost risk:** a nonempty node now constructs a metadata shell and the final
parent, versus one final parent before. The empty-child test adds a temporary
`ks` observer. A valid result can therefore be slower or allocate more. Reject
it if complete loader timing does not improve, even if a particular ownership
counter falls. A cheaper later entry using `k_with_children(term,[])` is possible
but should not be added as another variant without evidence that this overhead
is the obstruction.

## Workloads and scope

`borrow-context-workload01.bend` calls the real complete `f_load_graph` on six
inputs: a normal definition, law/fill with arguments, a local binding/function
call, repeated imported aliases, a parser error, and a duplicate declaration.
It returns complete books, errors and imports. The independent oracle requires
the first four loads to succeed and the last two to fail.

Additional complete term values cover Lam/All/Let higher/lower deferral, first
error ordering, application/lambda reduction, FName lowering, an unresolved
operator, empty-node identity, arbitrary literal kinds and retained root/child
aliases. These complement the actual loader outputs rather than replace them.

`borrow-context-digest01.bend` runs 32 complete loads of varying source text with
24 nested calls to an ordinary identity function. It folds every KDef field,
every KTerm variant field, errors and imports into bounded output. This is a
timing workload, not a correctness proof. The source is generated in Bend; the
host transport contains no parser or optimization implementation.

Metadata-only dependency extraction found **307,776 bytes / 1,041 declarations**
for the full-value workload and **308,616 bytes / 1,047 declarations** for the
digest, versus the 3.15MB full compiler. Both use the whole helper closure of
the loader; no backend image is rebuilt to test this idea. The two exact
transplants add 1,313 source bytes, and an in-memory inverse check restored both
baseline sources exactly. These are source observations, not source-check or
execution results.

## Reproducible root-owned commands

Run from the repository root. Every target command belongs under the existing
single-lane `job.py` resource guard. Use fresh names if any directory exists.
The pinned assets already bind Bun, upstream, the qualified compiler, runtime
and QBE toolchain. Do not introduce a different producer between the pair.

Extract the full-value baseline, then apply the two exact named transplants:

```sh
python3 -B selfhost/tests/phase173/prepare-workload.py \
  --module selfhost/tests/phase173/borrow-context-workload01.bend \
  --module selfhost/tests/phase173/borrow-context-main01.bend \
  --out selfhost/build/phase173/context-value-source01

python3 -B selfhost/tests/phase173/prepare-variant-v2.py \
  --source selfhost/build/phase173/context-value-source01/compiler.bend \
  --module selfhost/tests/phase173/borrow-consuming-context01.bend \
  --prelude selfhost/tests/phase173/borrow-consuming-context-prelude01.bend \
  --replace f_context_higher \
  --out selfhost/build/phase173/context-value-higher01

python3 -B selfhost/tests/phase173/prepare-variant.py \
  --source selfhost/build/phase173/context-value-higher01/compiler.bend \
  --module selfhost/tests/phase173/borrow-consuming-context-lower01.bend \
  --replace f_context_lower \
  --out selfhost/build/phase173/context-value-candidate01
```

The existing helpers authenticate exact original/replacement bytes, declared
new helpers and inverse restoration. Both candidate definitions remain in
their original lexical positions; helper laws precede first use.

Acquire the baseline's independently checked upstream API and observe its
complete result (use the same acquisition for the candidate as a separate
source-check gate, changing source and fresh output name):

```sh
python3 -B selfhost/tests/phase173/job.py context-oracle-api01 120 64 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase173/context-value-source01/compiler.bend \
  --exports selfhost/tests/phase173/borrow-oracle-exports.json \
  --engine selfhost/.assets/bin/bun \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --out selfhost/build/phase173/context-oracle-api01

python3 -B selfhost/tests/phase173/job.py context-oracle-value01 30 16 \
  selfhost/.assets/bin/bun selfhost/tests/phase173/borrow-context-oracle01.mjs \
  --kind context --receipt selfhost/build/phase173/context-oracle-api01/report.json \
  --out selfhost/build/phase173/context-oracle-value01
```

The separate oracle adapter retains the frozen original transport and adds
fixed KDef/FResult/P173CMReport schemas. It authenticates exact source declaration
field order, checked upstream acquisition and complete output before producing
`oracle.bend`. The independent semantic value comes from unchanged Bend run by
upstream. Constant native readback adds a representation check, not a second
independent compiler proof.

Build the constant, full baseline and full candidate with the same qualified
producer. Example for the baseline (substitute the corresponding oracle or
candidate source and fresh job/output name for the other two):

```sh
python3 -B selfhost/tests/phase173/job.py context-value-base-machine01 120 96 \
  python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json --image-key qbe-n2 \
  --host native --target qbe --stage N2 --mode cache --retain-ir \
  --source selfhost/build/phase173/context-value-source01/compiler.bend \
  --out selfhost/build/phase173/context-value-base-machine01
```

Read back the constant and compare both actual workloads against its complete
stdout, preserving empty stderr and identical runtime/toolchain:

```sh
python3 -B selfhost/tests/phase173/job.py context-oracle-output01 30 16 \
  python3 -B selfhost/tests/phase173/native-pair.py --rounds 1 \
  --baseline selfhost/build/phase173/context-oracle-machine01/report.json \
  --candidate selfhost/build/phase173/context-oracle-machine01/report.json \
  --out selfhost/build/phase173/context-oracle-output01

python3 -B selfhost/tests/phase173/job.py context-value-pair01 30 16 \
  python3 -B selfhost/tests/phase173/native-pair.py --rounds 1 \
  --baseline selfhost/build/phase173/context-value-base-machine01/report.json \
  --candidate selfhost/build/phase173/context-value-candidate-machine01/report.json \
  --expected selfhost/build/phase173/context-oracle-output01/0-baseline.stdout \
  --out selfhost/build/phase173/context-value-pair01
```

For the digest, run `prepare-workload.py` with these modules in order:
`borrow-context-workload01.bend`, `borrow-compiler-digest-support.bend`,
`borrow-context-digest01.bend` (omit the full-value main). Repeat the exact two
transplants, upstream acquisition and observation using `--kind context-digest`,
then same-producer native builds. Use four balanced timing pairs only after
independent full-value and digest gates pass. If all native runs are below
30ms, increase the literal repeat count in a new snapshot, re-observe its
independent digest, and retain the rejected short measurement.

The next useful evidence is complete loader latency plus a separate event pair
for keeps, sinks, take/drop work, dispatch and allocations. Do not infer a win
from lower ownership counts alone, or estimate full self-build savings by
multiplying an unmeasured inclusive profile share. A full compiler image is
justified only after this smaller real-computation test is positive.
