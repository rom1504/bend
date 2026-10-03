# Hook-preserving String comparison SCC: feasibility boundary

Read-only follow-up to the saved native-worker ablation. No source/runtime patch,
compiler build or target execution is performed. The emitted control inspected
is the exact Phase41 portable Map module retained in `ablation01/baseline.mjs`.

Retaining String splitting and reconstruction is necessary, but it does not by
itself make a defunctionalized worker safe under arbitrary host callbacks.
Callbacks can change G dependencies, function invocation protocols and force
protocols midway through a comparison. Entry-only graph/descriptor facts do not
justify skipping later calls. A callback can also inspect the JavaScript call
stack and return a different code point: a loop necessarily changes that stack.
Thus unrestricted host equivalence still requires generic fallback when hooks
are observable, or an explicit host-observer contract. There is no blanket
callback-free String fact established by preserving the method names.

## Actual source order

The original source's first curried String argument is matched before the
second argument is applied. Its known SCon branch uses `project`, not
`fields('SCon',...)`. `project('SCon',s)` calls `codePointAt(0)` **twice**, then
`slice(width)` once; width uses the second code-point result. An alternating
codePointAt override can therefore change head and tail independently.

| Phase | Original operations / capture point | What a loop must retain |
| --- | --- | --- |
| Match left | `fields('SNil',left)`, otherwise `project('SCon',left)` | Exact empty/marker test; two code-point reads plus slice |
| Match right | Same order for right, after left split | No eager right split when a prior left action throws |
| Either empty | Construct tuple/tag; rebuild only the nonempty head with SCon | One fromCodePoint; **no** Chr scalar validation in this branch |
| Both nonempty | Select/apply `String.cmp.fin(t1,t2)` **before** invoking Char.cmp | Preserve selected fin version even if Char.cmp subsequently changes G.fin |
| Compare heads | Select Char.cmp; project Chr left/right; force nested tuple | Chr constructors validate left then right, then current U32.cmp is looked up/called |
| Finish LT/GT | Match pair and tag; construct SCon left then right | Two fromCodePoint calls; fresh complete tuple, original order |
| Finish EQ | Select/apply `String.cmp.rec(h1b,h2b)` **before** selecting recursive String.cmp | Save rec's selected version, not merely its source name |
| Descend | Invoke current String.cmp on tails | Recheck this recursive edge; a hook may have replaced G.root |
| Unwind | Pass the complete suffix result through saved rec continuation | Rebuild left then right per frame; innermost frame first |

For a clean comparison demanding `q` nonempty head pairs and reaching a mismatch,
source splitting performs four codePointAt reads and two slices per pair; each
pair's full Char result performs two scalar checks. Source rebuilding performs
two fromCodePoint calls per reconstructed pair. Empty/prefix termination can add
one split/rebuild for a surviving head. Existing native compareText reads each
demanded code point once, performs no slices or fromCodePoint reconstruction, and
returns the original operands. The native ablation therefore measures combined
dispatch/operation headroom; it does not isolate a source-equivalent SCC loop.

## Why a naive loop fails

1. A codePointAt callback replaces `G['Char.cmp']`. Source looks up the replacement
   later in the same comparison. Inlined numeric comparison from an entry snapshot
   would use stale semantics even if it performed both code-point reads.
2. A Char.cmp callback replaces `G['String.cmp.fin']`. Source has already selected
   and partially applied the previous fin descriptor. Resuming by looking up fin
   again would incorrectly use the replacement; restarting the root duplicates
   code-point/slice callbacks.
3. A fromCodePoint callback replaces `Array.prototype.push/pop` or
   `Function.prototype.call`. Source's next `force`/`callOwned` steps observe those
   replacements. An eager `ctor` loop that removes build forcing can skip calls
   even while its own String reconstruction counts match.
4. A callback throws or reenters a public alias. A live pure `regionProof` cannot
   cover unowned observation. Suspending only on `bad` is insufficient for a
   native method which calls out or throws directly.
5. A callback returns data derived from Error().stack. Removing original JS call
   frames changes the returned data. No finite list of retained intrinsic calls
   solves unrestricted stack-sensitive callback equivalence.

## Smallest concrete safe next step

The reliable near-term mechanism is **bounded source SCC contification with
guarded generic resume**, keeping String observers as residual operations. It
does not admit the SCC as pure. Typed source/arity/closure facts can be shared,
but callback-free host permission remains a distinct fact. Use existing typed
terms plus explicit worker frames; do not introduce another general optimizer IR.

Each private control segment runs only while its selected source descriptors and
the exact dispatch/forcing protocol it would skip are still owned. A potentially
observable operation is a barrier. The plan records its exact source occurrence,
arguments, evaluation count and the generic continuation selected **before** it.
The barrier invokes the ordinary runtime operation, with any inherited purity
proof suspended for that observer window. It must not publish a String-purity
proof. After the operation, an exact-state resume either continues an owned
segment or executes the original generic continuation with the already computed
values. Never restart the root or repeat an observer.

An illustrative frame carries only:

```text
source label + selected descriptor/continuation version
head values / tail values at their original demand point
saved generic rec continuation + next frame
```

The minimal evaluation strategy retains generic Char.cmp as one residual call
and retains the original build/force expression for each unwind. This preserves
its own callback/error ordering without separately proving a numeric replacement
or eager tuple layout. In clean protocol segments it can remove the SCC's helper
matchers and recursive dispatcher frames. It may save less than the native
ablation and may be unprofitable after dynamic checks.

Required control skeleton (not implementation-ready code):

```text
enter with plain source strings and an exactly selected canonical root
split left/right using the original fields/project source operations
capture the ordinary fin continuation at its original lookup point
run the ordinary complete Char.cmp observer/residual
resume the captured fin version; if it is not privately owned, call it generically
on EQ, capture the ordinary rec continuation before selecting the recursive root
if the new root/dispatch is still owned, save rec frame and descend
otherwise call that exact root generically and resume through saved rec frames
unwind with the original nested build/force expressions, left then right
```

Implementing `resume captured fin version` cannot be replaced by a Boolean
“still pure” check. Intermediate partial functions, protocol mutations, malformed
hook return values and original forcing points all require a concrete resumption
representation. Caller proof restoration after observer reentry also needs a
fresh ownership check; a previous source graph membership set is insufficient.
For arbitrary changed String hooks, keep the original whole-source path to
preserve stack-sensitive observer behavior. For an owned clean method, executing
the original operation retains counts/order while allowing adjacent control
segments to simplify. This is narrower than treating every String method as pure.

## Cheap falsifiers before a source proposal

- Record an ordered event log for alternating codePointAt results, both slice
  calls and all fromCodePoint reconstructions; compare complete tuples/errors.
- During left splitting, replace Char.cmp, fin and the recursive root in separate
  controls. Verify the exact version selected at each lookup point.
- During Char.cmp, replace fin: the captured previous fin must finish this step.
  During recursive comparison, replace rec: a previously captured rec must unwind.
- During reconstruction, alter Function.prototype.call and Array.prototype
  push/pop; require original generic resume with zero duplicated observer events.
- Throw and reenter a retained public alias at each observer; verify no String
  purity proof is open and no saved caller permission survives invalidation.
- Supply a stack-sensitive code-point hook. A fast worker must refuse entry;
  preserving only hook counts is not an adequate oracle.

First implement an exact saved-JS source control only after defining these
resumption rules. A handcrafted loop calling project/ctor with an entry guard is
not yet that control. The queued native experiment remains a headroom probe;
its failure or success cannot establish SCC feasibility or host safety.
