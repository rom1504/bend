# Laws for the experimental native IR constant folder

The package constrains the actual safe `nx_fold_bin` helper in
[`../ir/optimize.bend`](../ir/optimize.bend), using its real
[`NxExpr`](../ir/model.bend) datatype. It does not substitute a toy folder.
The frozen [reference](reference.bend) defines eight pure U32 operations through
the checked Base `Word(32)` implementation. Arithmetic wraps modulo 2^32;
comparisons produce exactly 0 or 1 and `ult` uses unsigned order.

[laws.bend](laws.bend) states twelve universal full-result contracts: eight
literal operations and preservation of U64, mixed-type, unknown-operation and
call-containing inputs. These are complete `NxExpr` equalities, so the laws
also constrain result types, operand order and retained fallback trees.
One support lemma proves that the independent Bool-to-word functions agree for
both Bool constructors; equality and unsigned-order contracts use congruence
with this lemma. There are thirteen named laws including that support.
The U64-literal contract concerns the IR's current U32 literal payload; it is
not a proof about unrestricted U64 arithmetic.

## Actual source connection

`prepare.mjs` snapshots the complete model and the verbatim safe optimizer
prefix before its first `@unsafe` declaration. It adds only `import Base`.
It does not remove an unsafe annotation or insert a replacement helper.
The manifest binds both original files, frozen laws/reference and every output.
It also checks the exact recursive-pass call site that invokes `nx_fold_bin`.
This call-site check is source correspondence, not a proof of the traversal.

The recursive `nx_simplify` pass, statement sequencing, C and CLIF emitters,
foreign runtime, allocation/free, aliasing and machine code remain outside the
formal scope. In particular, no owned-region or reference-counting claim is made.
The backend's explicitly masked shifts are outside this arithmetic package;
they must not be confused with Base's repeated-shift `U32.shln` behavior.

## Serial root-owned checks

Preparation is data-only. Use fresh paths and first finish changes to the model
and helper so that the source hashes identify the actual candidate being tested:

```sh
selfhost/build/phase66/bun-toolchain01/bun \
  selfhost/tools/performance/phase106/laws/prepare.mjs \
  --out selfhost/build/phase106/law-source01

python3 -B selfhost/tools/laws/phase98/check.py \
  --source selfhost/build/phase106/law-source01/baseline/laws.bend \
  --out selfhost/build/phase98/phase106-law-check01
```

The accepted repaired run uses `law-source02` and `phase106-law-check02`.
It contains twelve public contracts plus one support lemma; see the results
linked below before choosing fresh replay paths.

The existing checker reauthenticates pinned tools, snapshots imports, checks
safe Bend, emits BendTT, runs the independent Lean kernel, checks that every law
has a nonopaque body, and rejects an independent false kernel equality. Its
existing output-root restriction is intentional; hence the Phase98 build path.
The manifest's `targetsRun: false` describes preparation, even after a separate
checker has run. The checker report records proof acceptance.

Four prepared mutations replace addition with subtraction, reverse subtraction,
replace unsigned comparison with equality, or discard literal-type guards.
For each mutation directory, run the checker first on `candidate.bend` with
`--source-only` and require success. Then check the unchanged `laws.bend` with
`--source-only` and require an expected/observed proof mismatch identifying
the intended law. Use fresh output directories for each step. A syntax error,
resource stop, missing import or an unadmitted helper is not a successful
semantic mutation detection. These negatives establish source-check rejection;
they do not claim independent kernel rejection of a candidate that could not
be elaborated. The positive package has its separate independent-kernel check.

The serial runner enforces this protocol, verifies the accepted positive
closure and all prepared inputs, and retains each checker report and raw log:

```sh
selfhost/build/phase66/bun-toolchain01/bun \
  selfhost/tools/performance/phase106/laws/check-mutations.mjs \
  --prepared selfhost/build/phase106/law-source02 \
  --accepted selfhost/build/phase98/phase106-law-check02/report.json \
  --out selfhost/build/phase98/phase106-law-mutants-new
```

Run only in the coordinator's exclusive target slot. The original successful
four-mutation execution is `phase106-law-mutants02`; do not overwrite it.

## Connecting laws to actual backend execution

[cases.json](cases.json) supplies thirty explicit U32 boundary observations:
overflow, underflow, multiplication wrap, high bits, complementary masks,
comparison equality and signed/unsigned distinguishing pairs. Its literal
expected results are independent of both emitters.

[`bridge.bend`](bridge.bend) constructs one `NxProgram` with both forms and the
usual two-U32 `main(n, seed)` ABI. Inputs `n=0..29` select literal operands;
`n=30..59` select corresponding operations on locals made by XORing each
operand with the runtime `seed`. At `seed=0` the frozen expectations apply,
while the dynamic code cannot assume that seed at compilation time. The
preparer checks the exact ordered Bend/JSON input correspondence and validates
literal expected results independently with BigInt arithmetic.

The completed `controls04` run tests raw/folded IR through the actual Bend C
printer plus Clang and through the CLIF consumer. The four products pass
**600 exact arithmetic outputs**: thirty literal and thirty dynamic inputs at
seed zero, plus ninety dynamic inputs using seeds 17, 2147483648 and 4294967295.
The independent interpreter also passes all 150 inputs on each IR variant,
giving **300 interpreter observations**. Four wrong expected-output controls
are rejected, one per native product.

The literal AST checks are explicit: all thirty raw expressions remain binary
operations with the expected operator, and all thirty folded expressions are
the exact expected `u32` constant. Thus this gate checks activation as well as
output equality. The report binds the producer-native02/artifacts02 identities
and verifies inputs remain unchanged. See the
[completed results](../../../../../implementation/phase106/laws-notes.md#completed-backend-bridge).

No universal backend theorem follows from this finite matrix. Do not use the
fold evaluator as the sole oracle: a shared wrong arithmetic definition could
otherwise make both paths agree incorrectly. The frozen expectations and the
independent interpreter remain separate from both emitters.

Results, rejected attempts and the exact accepted source identities belong in
[`implementation/phase106/laws-notes.md`](../../../../../implementation/phase106/laws-notes.md).
