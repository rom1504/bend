# Phase96: what the upstream proof actually establishes

Offline source audit, 2026-10-15. No compiler, Lean invocation or target program
was run for this review. This is a source reading and law-design assessment,
not a fresh independent validation receipt.

## Source identity

The checkout's `bend2/bendtt.lean` and the pinned
`selfhost/.bootstrap/upstream-phase66/bend2/bendtt.lean` are byte-identical:

| Input | Identity |
| --- | --- |
| Pinned upstream revision | `059266225b77c8ca256ac6b25ee5c21449bab151` |
| Checkout revision at audit | `d8db7ff090efd4e1de00a5d55a8030993577f3f0` |
| Last commit changing this Lean file | `237c72261f3a19be7960a07060748f427fbd0433` |
| Both Lean files | 172,753 bytes; SHA256 `83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3` |
| Checkout `bend2/safe.ts` | 65,468 bytes; SHA256 `bf495d64c03caa7a2558aaae5e172cd7743b9aa5470c4d33ad86634e23d81ffc` |

Both complete Lean files were inspected. Neither contains `sorry`, `admit`,
an `axiom` declaration, `unsafe`, `implemented_by` or `native_decide`.
There are 17 `partial def` declarations, all in the parser (lines594–840).
`Classical` is used at lines1818,2882,3515. These lexical facts do **not**
establish an axiom-free transitive Lean dependency closure: `Std.Data.HashMap`,
Lean's logic/kernel and imported theorems remain dependencies. This review did
not run `#print axioms`. Phase94's retained build/replay evidence concerns the
unchanged kernel, and must not be relabelled as a new Phase96 check.

## Reusable theorem families

Line references below refer to the exact Lean file identified above.

| Actual construction or theorem | What it proves | Useful pattern for this compiler |
| --- | --- | --- |
| `Term.ren`, `Subst.up`, `Term.sub` (219,306,310); `ren_ren` (432), `sub_ren` (1739), `ren_sub` (1745), `sub_sub` (1752), `sub_var` (1759) | Renaming/substitution composition and identity for every constructor, with binder lifting | State transformations algebraically and include every binder case. Our named-ID representation requires its own freshness/shape conditions; these de Bruijn equations cannot simply be copied. |
| `Term.subk` (372), `subk_sub` (435), `@[csimp] sub_subz` (441) | The optimized depth-passing substitution equals the simple lifted-substitution specification; full function equality licenses the compiler simplification | Strongest immediate model: prove an actual helper equals a small independent specification for arbitrary inputs/accumulators, then connect that exact helper to production. |
| `ren_closed` (1773), `inst_sub` (1776), `unspine_spine` (1789), `zeta_drop` (1811) | Executable closedness implies semantic substitution stability; instantiation, spine reconstruction and context-zeta optimizations preserve specified meaning | Prove conditional fast-path laws and representation round trips. Specify observations carefully: spine normalization is not arbitrary raw-tree identity. |
| `Book.ok` (117), `table_at` (2391), `get_find` (2400), `index_find` (2403) | The HashMap is the table of its definition list; lookup returns the same **first** matching full definition and index as list search | Cache/index equivalence needs an invariant and full payload equality, with duplicate names, missing names and collisions. It is stronger than membership or result-count equality. |
| `Sees` (2042), `wnf_pars` (2046), `conv_sound` (2118), `fits_sound` (2214), `chk` (2333), `book_check` (2416) | Accepted executable reductions/checks imply the declarative relations, under explicit book/context assumptions | Keep executable-vs-spec bridge lemmas separate from the abstract algebra. A successful checked Boolean is evidence only when its bridge is established. |
| `par_sub` (1894), `confluent` (1940), `typed_sub` (2276), `eval_pars` (2571) | Substitution, reduction and typing interact correctly; operational steps are related to declarative reduction | Larger compiler preservation work needs a semantic relation between representations, not just same-backend output examples. |
| `canon_data` (2690), `uses_sub` (3166), `live_sub` (3244), `pos_ok` (3472), `desc_lex` (3504), `ev` (3812) | Copyable values are data; substitution preserves specified use/liveness conditions; structural descent and each evaluation step satisfy the termination measure | Encode the assumptions that authorize copying, reuse or recursion. A caller's assumption must be proved/preserved, not hidden in a helper's name. |
| `halts` (3876), `consistent` (3886) | Live closed terms in a live book are well-founded under formal `Eval`; no definition accepted by `Book.check` has a type convertible to empty enumeration | These are substantial end results with explicit premises, not a claim about arbitrary unsafe Bend source or generated C. |

The exact end claims are in lines1665–1693. `Claim.sound` requires
`Book.check bk = .ok ()`; `Claim.halts` requires `Book.Live`, `Term.Closed`
and `Term.Live`. `Claim.consistent` excludes a checked definition whose type
is convertible to `Enu []`. `Term.conv` is fuelled (982; `FUEL` at157),
and `conv_sound` proves acceptance soundness, not completeness. A failed
conversion/check is not thereby a proof that the declarative proposition is
false.

## Independent checking and its boundary

`Book.check` checks types, bodies, closedness and live affine/descent conditions
([Lean1402–1420](../../bend2/bendtt.lean#L1402)). Its command-line entry parses
text and reports exact success/failure ([1424](../../bend2/bendtt.lean#L1424)).
The consistency development is about these formal terms and judgments.
It does not prove `.bend` elaboration faithful, C/JS generation correct,
reference counting safe, or an unsafe callback terminating/pure.

The elaborator introduces another boundary:

* `safe_book` propagates failures and removes out-of-scope definitions
  ([safe.ts225](../../bend2/safe.ts#L225)). `safe_emit` still writes the
  remaining text and returns an out-of-scope list (1556); `safe_check` requires
  that list empty **and** kernel success (1564). A successfully checked subset
  is insufficient. Audit the expected helper/theorem inventory as well.
* `item_emit` rejects an `@unsafe` definition
  ([351](../../bend2/safe.ts#L351)). `def_emit` elaborates an actual body when
  present, but can model a bodyless declaration (371); `model` constructs a
  typed consistency witness (464). Every claimed actual helper needs its
  ordinary body in the emitted book. A model of a foreign implementation does
  not prove that implementation agrees with its model.
* Arbitrary template parameters can become opaque constants, reused by
  parameter position/type ([246](../../bend2/safe.ts#L246), key at266).
  Their models are checked with transparent definitions; ordinary proofs
  cannot unfold those constants (`Def.check`, Lean1402). This supports generic
  laws conditional on typed pure total parameters. It does not discharge the
  connection to production's unsafe callbacks, nor any unstated predicate
  property such as reflexivity or uniqueness.
* `kernel_bin` accepts a `BENDTT` executable override directly
  ([1480](../../bend2/safe.ts#L1480)); otherwise it selects/builds Lean4.34.0
  using a source/version cache. Pin the executable/toolchain/module actually
  used, elaborated text, sources and raw receipt. Checking a path's name or a
  success string from an unauthenticated wrapper is insufficient.

The practical Phase94 pattern remains appropriate: authenticate the unchanged
kernel and official toolchain, check the positive book and an independently
false equality, require complete emission with no out-of-scope items, and
retain both frontend and kernel receipts. A source-mutant frontend rejection
and an independently false kernel rejection are different controls; count them
separately.

## Law priorities for the first-order compiler

| Priority and production connection | Adequate law / observations | Essential counterexamples |
| --- | --- | --- |
| Ordered builders: `back/native/text.bend` (`nt_reverse`, `nt_append`, `nt_text_finish`) | Reverse-with-arbitrary-tail equals simple reverse then append; append associativity/units; chunk finishing equals ordered string concatenation. Full elements/text and nonempty initial accumulator matter. | Reverse twice incorrectly, drop/duplicate an element, append tail on the wrong side, swap two unequal chunks, mishandle empty chunks/separator/initial accumulator. |
| Environment filtering: the Phase94 generic helper and its unsafe adapter | Full ordered output plus complete arbitrary drop accumulator equals a simple filter/fold reference. Live/dead, duplicate payloads, and a noncommutative accumulator expose wrong sequencing. | Retain dead, drop live, reverse retained order, omit a dropped binding, reset the seed; production adapter uses the wrong liveness predicate. |
| Exact-name membership/index: `core/term.bend:278,321`, `core/index.bend:71,126,259` | Lookup equals a simple first-match list oracle on a valid constructed index, preserving the entire `KDef`; membership equals reference disjunction without an assumed special input order. | Missing name, duplicate name with distinct payloads, exact hash collision, empty key, Unicode, zero/nonzero branch masks. Constant membership and last-match lookup must fail. |
| Conditional substitution reuse: `core/term.bend:359,427` | `core_subst_stable(t) = True` implies full `subst(t,id,v) = t`; compare ordinary substitution with an independent constructor-by-constructor reference. | Var anywhere; reducible App; wrong App arity/name/id/quantity/removed data; specialized lambda/literal; preserve source ranges and all payload fields. False stability is permitted to be conservative. |
| Environment substitution: `check/env-substitution.bend:23–65`, admission in `check/env-telescope.bend:15` | Under the actual admission conditions, batched substitution equals sequential oldest-first substitution, including inserted values affected only by later bindings. Test failed admission and eager fallback separately. | Repeated IDs, replacements containing later IDs, binder/Var shapes, beta-producing replacement, 0/1/many bindings, wrong reverse order, rejected safe-path guard. |
| Checker/cache facts and native representation | Soundness direction of each accepted fact, exact fallback/refusal behavior, complete metadata/diagnostic observations; reusable cache requires a source/world invariant. | Stale source/world, same tag with changed payload, first diagnostic changed, partial result retained after failure, zero-work/constant observer. |

An important production distinction: `subst` invokes `core_rebuild`, which can
canonicalize an `App` or beta-reduce its lambda even when the substituted ID is
absent. Therefore “absent ID implies unchanged arbitrary `KTerm`” is not a valid
raw-tree law. `core_subst_stable` deliberately restricts the fast path. The
upstream's de Bruijn substitution algebra is useful design guidance, not a
proof of this different representation and normalization behavior.

Small safe algebra implementations and their actual reference/helper equality
can be independently proved for all typed inputs. Current `@unsafe` production
helpers can be exercised with generated full-value comparisons and exact
extraction/source binding, but those finite tests are not universal proofs.
Moving a helper into the safe fragment would require proving its recursion,
affinity and representation assumptions; a copied safe model alone does not
accomplish that migration. No optimization or production edit is implied by
adding these laws.

## Adequacy audit for the Phase96 suite

For each proposed law, retain: its quantifiers and premises; actual helper and
independent specification; emitted helper/theorem inventory; positive result;
which semantic mutant it rejects and at which checking stage; and the exact
production connection or the statement that none exists yet.

Count laws by useful semantic obligations, not by the number of reflexive
equations. Identity, associativity or idempotence alone often admit a constant
or wrong-order implementation. Pair them with reference equivalence and
distinguishing examples. A mutant should remain well-typed with the same
interface and fail the intended semantic assertion; parser/type/out-of-scope
failure is weaker evidence and must be labelled. Preconditions need both
inhabited positive cases and near-miss boundary cases to prevent vacuity.

For production controls, compare full independently serialized values rather
than only tags, lengths, counts or checksums. Exercise all representation
variants and preserved aliases; require expected-output identity and maintain
independent oracle code. Freeze and hash the method, extracted source, generated
inputs, outputs and receipts before targets run. A finite generated corpus,
however large, remains finite coverage; a universal proof of a safe algebra
does not automatically cover its unsafe production adapter.
