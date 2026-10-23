# Phase129: what the selected compiler actually proves

Static audit at `a4ecad0e2e33944814fbad0b53705c2460e60f8a`, 2026-10-23.
No compiler, benchmark, Lean kernel or generated program was executed. This
document reports source inspection and retained evidence, not new qualification.

The useful next step is a small source-connected contract for one reusable
analysis or borrowing boundary. The current compiler has substantial executable
verification, but its optimization plans do not carry mathematical proofs.
Erasing proof terms can avoid proof execution; it cannot eliminate analysis of
the unknown program being compiled.

## 1. Exact selection and evidence

The authoritative selection is [Phase128 candidate.json](../../implementation/phase128/candidate.json),
following the [frontier](../../experiments/STEERING.md). The selected
[compiler.bend](../../selfhost/build/phase128/native-source02/compiler.bend) has
2,609,331 bytes, 56,904 physical lines and SHA256
`6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d`.
This audit recomputed that identity. Its retained source archive is
[compiler-source02.bend.gz](../../implementation/phase128/compiler-source02.bend.gz).

The [source manifest](../../selfhost/build/phase128/native-source02/manifest.json)
deliberately says `sourceChecked=false`, `targetsRun=false`, and
`nativeQualified=false`: source assembly alone establishes none of them.
The later [checked API receipt](../../selfhost/build/phase111/p128-native-api02/report.json)
binds this exact source to upstream checking, and the candidate binds its later
native admission and qualification. Do not treat an earlier preparation manifest
as the final qualification verdict, or an unselected historical module as the
effective implementation.

The final selection retains exact hosted → N1 → N2 QBE reproduction, focused19
on both native images, ordinary45 on N2, 100 finite predicates and 545 independent
field-ABI checks. Those are retained experimental evidence, not universal
compiler preservation. Installed production selection remains unchanged.

Lexical inventory of this assembled source, excluding imported Base:

| Item | Count | Interpretation |
| --- | ---: | --- |
| `def` declarations | 6,159 | Includes controls and historical helpers still assembled |
| Leading `@unsafe` annotations | 6,020 | About 97.74% of the definition count; a syntactic count, not a dependency-closure proof |
| `law` declarations | 680 | Every name also has a `def`; none of these law signature blocks contains an equality proposition |
| Own `type` declarations | 267 | No parameterized own datatype declaration in this source; ordinary records/enums dominate |

The 680 `law`s are forward signatures such as `noa_eval : ... NO_Analysis` and
`noa_equal : ... Bool`, not 680 theorem statements. Imported Base and the separate
proof packages must be assessed separately from these counts.

## 2. Dependent types, unsafe code and erasure

Bend supports dependent function types, equality propositions and proof rewrites.
The compiler parses, checks and erases those language features, and uses generic
functions and quantity annotations itself. That does not make its internal AST
or native IR intrinsically well-typed.

The actual `KTerm` stores tags, names, U32 IDs, quantities and child lists in
ordinary constructors. `KDef` stores a `typ: KTerm` alongside an unrelated
`value: KTerm`. Neither datatype indexes the value by its checked type. Likewise:

- `NO_Plan` holds a schema, analysis and error String.
- `NO_Schema` holds parameter/root/specification lists and an error String.
- `P128BRHelper` holds owner, parameter/root lists, result name and reader name.
- `P113ACertificate` holds two Bools, `scalar` and `unshared`.

These are valuable semantic records, but a constructor can represent an invalid
combination. Their production path must establish invariants through executable
analysis and checks. See selected source lines 41, 47, 703, 737, 47510 and 55492;
the tracked [borrow context](../../selfhost/tools/performance/phase128/borrow/next/context.bend)
and [layout graph](../../selfhost/tools/performance/phase128/borrow/next/layouts.bend)
show the corresponding Phase128 additions.

The pinned upstream [language definition](../../selfhost/.bootstrap/upstream-phase66/bend2/bend.ts#L230)
states that `@unsafe` opts out of structural descent, permits reusable binder
domains at any kind, and permits live calls to unfilled or later definitions.
It is **not merely a termination annotation**. Ordinary checking still checks
the body under those relaxed rules; the safe-language metatheoretic claims do
not cover a book using unsafe definitions.

The checked-API [bootstrap method](../../selfhost/tools/stage0-library.mjs)
runs `book_valid`, rejects unresolved holes, and invokes upstream JS emission
with ownership checking. It does not invoke BendTT. The pinned
[BendTT elaborator](../../selfhost/.bootstrap/upstream-phase66/bend2/safe.ts#L351)
explicitly rejects a dependency marked `@unsafe`; a bodyless/foreign item may
instead be represented by an opaque checked model. A model's validity does not
verify the foreign implementation.

Erasure exists in the selected compiler. `nc_erase_args` drops quantity-zero
arguments, `nc_erase_annotated` replaces equality-typed values by `Rfl`, and native
lowering maps proof/type values to inert values and selects the computational
body of a rewrite. See selected lines 31932–31988, 42439 and 44611, and tracked
[erase.bend](../../selfhost/src/back/native/erase.bend). These are executable
compiler rules, themselves largely unsafe; there is no selected end-to-end
erasure-correctness theorem.

A proof that an analysis algorithm is sound can be erased from the compiler
executable. A freshly supplied program's AST, computed summary, runtime ABI
identity, and admission tests remain computational data. Turning their fields
into erased parameters does not compute or validate them for free.

## 3. What “verified plan” means here

The actual selected borrowing path combines several independently useful gates:

1. `p128bs_eligible` / `p128br_eligible` require a successful observer plan,
   exact scalar result identity, one or two retained roots, absent generated
   names, residual admission and successful lowering. These are Bool/String
   checks over ordinary data, not equality proof terms.
2. `p128br_arguments` checks nominal argument types and requires each borrowed
   root's origin to lie below a held caller root. Scalar helper summaries are
   seeded from admitted leaf readers, not accepted just because a record has
   the right name. The finite concrete layout graph permits one exact type
   instantiation per nominal owner and refuses conflicts.
3. `p128br_project_residual` replaces an admitted `NO_ReadCall` by a scalar
   placeholder for the existing residual checker. That preserves its structural
   checks; the projection is **not a proof that the call equals zero**.
4. `p118b_verify_functions`, `p113e_functions` and the final
   `p126bp_complete` check the assembled result. Direct-call verification checks
   argument/result arities, defined values, local types, ABI and topological
   readiness. The ready set grows only after each function verifies. This
   rejects missing/cyclic direct calls; it does not prove a borrowed callee
   preserves heap ownership or equals the replaced computation.
5. The late `p128bf_match` field template runs after the original import has
   passed these checks. It rechecks exact import shape, constructor arity,
   width2–8, local-buffer family and freshness, then emits raw loads with a
   guarded original-helper fallback. Its concrete heap semantics are an
   additional trusted lowering boundary.

Relevant selected-source entries are at lines 45033, 45093, 51475, 54672, 55338,
55529, 55538, 55643 and 56717. The tracked
[field template](../../selfhost/tools/performance/phase128/borrow/field-read/template.bend)
and [field audit](../../implementation/phase128/borrow-field-template-audit.md)
spell out the last boundary. “Certified” in that experiment's name means its
checked admission, source/ABI binding and controls; it is not currently a
BendTT-checked template-preservation theorem.

The runtime premises include valid heap Terms, a live ancestor during all
borrowed reads, no borrowed owned-data escape, unchanged runtime descriptor
identity, fail-stop errors and the selected sequential CPU ABI. The template's
ordinary RFC loads do not establish correctness for concurrent/device runtimes.
The 545 ABI observations include independent expected values and fallback
spies; they do not quantify over arbitrary heaps or prove production failure
semantics. The [borrowing guide](../../docs/self_hosted/borrowed-native-queries.md)
and Phase128 audits retain these restrictions.

Shared preparation has a similarly precise boundary. `p128raw_lower_request`
constructs one request-local prepared state and raw candidate list, then reuses
them through later lowering and closure. It retains final verification. The
selected `P128RawLowering` is an ordinary pair, not a proof that every consumer
uses the same semantic world. Complete QBE equality on retained Map/RLE/tree
experiments supports the refactor, but is a finite observational result.

## 4. What the Phase94–98 proofs actually established

| Evidence | Established statement | Important excluded bridge |
| --- | --- | --- |
| [Phase94 environment pilot](../../implementation/phase94/README.md) | Exact safe fused helper equals filter→append→partition, including ordered payloads and arbitrary accumulator, for typed pure total callbacks; independently checked BendTT closure | Unsafe adapters, validity of callback facts, machine ownership and full compiler preservation; the candidate was not promoted |
| [Phase95 membership change](../../implementation/phase95/README.md) | Finite independent semantic/performance evidence for real `has_name` replacement | No independent theorem about its unsafe recursive implementation |
| [Phase96 inventory](../../implementation/phase96/proof-inventory-review.md) | 31 public universal contracts and seven supports, including actual extracted KTerm helper bodies; separately 226 finite production cases | Not all included helpers are fully specified; metadata “Semantics” is not program operational semantics |
| [Phase97 ownership model](../../implementation/phase97/semantic-pilot.md) | Four public laws and three supports prove Keep→Read→Drop elimination in arbitrary surrounding finite operation sequences, including faults, final counts and read traces | Single immutable abstract cell and unbounded Nat counts; no concrete handle/heap, nested child escape, bounded refcount or concurrency bridge |
| [Phase98 source-connected proofs](../../implementation/phase98/proofs.md) | String equality, ordered selectors, tag/scalar observations, permission guards and a redirect-list transformation, with actual helper bodies and independent kernel receipts | Native reference counting, unsafe callers, host authentication and complete backend correctness |

The deduplicated [catalog06](../../selfhost/proofs/phase98/catalog06.json)
contains 51 public names and 50 support names across Phase96–98. This is a
historical catalog spanning different and sometimes unpromoted implementations,
not 101 theorems newly checked against Phase128. Repeated proof runs and finite
predicates do not increase its distinct-law count.

An important positive source finding: this audit compared current selected
declarations against the accepted Phase98 origin-source extraction manifests.
After removing comments, blank lines and a leading unsafe annotation, the
following exact helper bodies still match:

- Tag package: `KTerm`, `p88_string_eq_go`, `p98_eq_finish`, `p88_string_eq`,
  `tg`, `p98_tag_eq_read`, `p98_tag_eq_finish`, `p98_tag_eq`.
- Permission package: the same three comparator helpers plus
  `no_effect_provider_member` and `no_effect_foreign_allowed`.

The historical accepted receipts are
[origin-tag-proof-check01](../../selfhost/build/phase98/origin-tag-proof-check01/report.json)
and [origin-membership-proof-check01](../../selfhost/build/phase98/origin-membership-proof-check01/report.json).
This is static identity evidence for the listed helpers, **not** a new check of
the complete Phase128 proof dependency closure or current compiler. Use the
[current-source extraction guide](../../selfhost/proofs/phase98/RUNNING.md) to
produce a fresh source-bound receipt before making that claim.

The proof distinction is material. A `law` without a body is a specification or
assumption, not a demonstrated theorem. A filled equality body checked in the
safe fragment is a source-level proof. Independent BendTT checking requires the
actual helper and theorem bodies, complete in-scope emission, authenticated
kernel/toolchain and accepted receipts. Opaque generic parameters remain
explicit premises. Neither kernel acceptance nor same-source self-reproduction
establishes that QBE, native runtime or generated machine code implements that
semantics. The pinned [upstream proof audit](../phase96/upstream-proof-method.md)
describes those boundaries; newer upstream kernel claims must be distinguished
from the actual Phase66 pin used here.

## 5. Smallest valuable proof-carrying contract

Start with a **borrowed-field admission contract**, not all of `NO_Plan`.
It constrains an existing small trusted lowering boundary and can be falsified
without another compiler image. The next performance change should still be
selected from refreshed profiles; the contract itself is not a speed claim.

Proposed interface, schematic rather than checked Bend syntax:

```text
admit_field_read(statement, constructor_descriptor, verified_buffer, site)
    -> Refused | BorrowFieldPlan

BorrowFieldPlan:
    original statement identity
    symbolic constructor + numeric ID + exact arity
    source Term + scratch destination + result local + fresh site
    width witness in {2,3,4,5,6,7,8}
    erased proof: accepted plan agrees with the independent import-shape spec
```

Make the finite metadata/shape checker and its statement safe. Prove the exact
selected acceptance computation agrees with a separately written specification,
or prove its acceptance implication if intentionally conservative. Keep the
runtime-computed witness and actual checks. The consumer should use that
validated plan rather than reconstructing unrelated facts from nominal names.
Bind the extracted original body, checker and statement to the selected source
manifest. If making the current helper safe requires a changed implementation,
first prove equality of the safe replacement to a precise reference and record
the missing production bridge honestly; merely copying its intended behavior
into a safe model is insufficient.

Minimum obligations are exact argument/result widths and argument order,
state identity, constructor/arity agreement, buffer size/origin, bounded
count, result/input alias preservation and reserved-local freshness. The
existing structural verifier establishes some premises; a theorem about the
admission checker must not silently assume that every caller invoked it.

This first proof would **not** prove raw-load equivalence. A later extension can
give the field operation an explicit sequential immutable heap semantics and
prove successful fast-path equality, unchanged heap/ownership and exact buffer
writes. It must model live-root reachability, RFC decoding, valid address ranges,
scratch separation and the fallback's failure behavior. These cannot be erased
from the theorem's premises or inferred from matching a constructor tag.

Cheap falsifiers, using existing finite controls and ABI fixtures:

- Correct name with wrong constructor arity, high literal word, type width,
  state name, buffer origin or overflowing freshness must refuse.
- Count1/packed and nullary cases must retain the original route.
- Wrong tag/CID must reach fallback before dereference, including a null-heap
  spy fixture; exact output/status and canaries matter.
- Aliased result/input, RFC counts1/2/max, nonzero high RFC header and every
  width2–8 must retain exact payloads and status.
- A well-typed mutant weakening the descriptor check must first pass helper
  admission and then fail the unchanged contract. A syntax rejection is not
  detection of that semantic fault.
- An equivalent refactor should still satisfy the same public statement;
  support-proof repair and authoring time must be recorded separately.

Do one actual-source extraction and independent check, with a false-equality
kernel control, before investing in a general certificate framework. Retained
Phase98 small packages occupied roughly1.7–2.7s of guarded target time; this
does not predict new proof-authoring effort or guarantee this package's cost.

## 6. Alternative if usage queries dominate the refreshed profile

A safe **0/1/many usage-summary algebra** may offer a better performance payoff
than the field contract. Actual selected `nq_uses` at line33963 is not ordinary
occurrence counting: exactly two-arm `Mat` takes maximum, ordinary child
sequencing takes saturating sum, and `NWPattern` has separate rules. Prove
summary lookup equals this specified query for every supported tree and ID,
including branch composition and duplicate IDs. Unknown forms retain the
existing query. Require the summary's immutable source identity and invalidate
it after a rewrite; matching a source hash alone does not prove its contents.

The safe compiled subset should expose only its validated usage facts to the
optimization. An erased theorem can justify consuming those facts without
rechecking every query, but summary construction and the concrete KTerm-to-safe
representation bridge still cost time. Retaining the full final verifier and
same-QBE comparison makes this a bounded preparation optimization, rather than
a wholesale IR rewrite. Do not weaken a universal statement to a separate
model without measuring and qualifying that bridge.

Choose between these two contracts by measured exposure and total experiment
cost. Existing helper proofs are reusable; there is no evidence here that
proving the entire compiler, adding blanket proof fields, or rerunning unchanged
self-compilation would accelerate optimization research.
