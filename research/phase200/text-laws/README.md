# Sequence law for split/join fusion

`Sequence.lean` states the law over an arbitrary element type with decidable equality. Consequently it covers arbitrary U32 words, including invalid Unicode scalar values. It assumes neither nonempty replacement nor replacement free of the delimiter. Replacement is a single traversal, not recursively applied to the inserted separator.

**Status: proof source prepared, not yet checked by Lean. Finite controls prepared, not yet executed.** No compiler or machine equivalence is asserted. No physical job was launched while the lane was unavailable.

Let `R(x) = s` if `x=d`, and `[x]` otherwise. `split(d,[])=[[]]`; at a delimiter it inserts an empty leading chunk, otherwise it prepends the word to the first chunk. This ensures the result is always nonempty and preserves leading, trailing and consecutive empty chunks. It is the exact structural convention in the authored Unicode fixture's `ssplit`, `ssplit.pick`, and `ssplit.push` (the push-on-empty arm is unreachable for a split result).

The Lean representation stores the first chunk and the remaining chunks in a pair. `join(s,(head,tail)) = head ++ flatMap (s ++) tail`. Associativity of append makes this equal to the fixture's recursive `sjoin.go`; this correspondence is a mathematical representation argument, not checked Bend implementation equivalence.

The proof is induction on the input list:

* Empty input: joining its one empty chunk is empty, matching flatMap.
* Non-delimiter head `x`: prepending it to the first split chunk makes the joined sequence `x :: join(s,split(d,xs))`; induction gives `[x] ++ flatMap R xs`.
* Delimiter head: starting an empty chunk makes the joined sequence `s ++ join(s,split(d,xs))`, including when the suffix starts or ends with delimiters. Induction gives `R(d) ++ flatMap R xs`.

Therefore `join(s,split(d,xs)) = flatMap R xs` for every finite input. Since flatMap distributes over concatenation, the function is a monoid homomorphism: it maps empty to empty and concatenation to concatenation. Induction on repetition count gives `join(s,split(d,repeat(xs,n))) = repeat(join(s,split(d,xs)),n)`. No trimming or extra separator is introduced between repeated blocks, even if each block starts or ends with the delimiter. If a split API drops empty segments, the law is false; the staged controls include that mutation.

`controls.py` independently compares a forward imperative chunk scanner and joining loop with elementwise replacement. It covers lengths 0–6 over three words, five delimiter values, six replacements (empty, delimiter-containing and non-Unicode words), and repetitions 0,1,2,3,7. These are finite semantic controls, not a substitute for the generic theorem or an execution oracle for a generated worker.

When a lane is authorized, run the pinned Lean toolchain on `Sequence.lean` with a short wall cap and retain all three `#print axioms` results. Run `python3 -B research/phase200/text-laws/controls.py --out <fresh receipt.json>` separately. Do not mark either gate passed merely from this source file. Compiler selection additionally needs complete-use and immutable-source proofs, exact word comparison, ordering/ownership preservation, and generated-product comparisons against an independent implementation.

The prepared dispatch is `check-argv01.json`: shared CPU3 guard, five-second outer cap, eight MiB output allowance. `check.py` uses the installed Lean 4.32.0 executable with `-j1`, caps Lean at three seconds and both inner stages at 4.35 seconds total, and records real diagnostics even on refusal/timeout. A timeout is incomplete evidence, never a proof failure theorem or a pass. It requires all three axiom reports without `sorryAx`, and the exact finite check counts. The wrapper has been staged only; inspect the fresh `text-laws01/report.json` after dispatch for actual status.

## Attempt 01 and prepared correction

The actual first guarded invocation elaborated `join_split` and `join_split_append`, reporting only `propext` for each. The repetition portion failed because Lean reserves the token `repeat`. The original source, method and exact diagnostic are retained in `attempt01/`. The complete proof gate did not pass. The finite stage had not completed when the outer guard ended; no finite result is inferred.

`check-argv02.json` is a fresh five-second replay. The helper is renamed `repeatSeq`; the statements and derivation are unchanged. To fit the measured guard, finite v2 covers lengths 0–5 (10,920 base identities and 54,600 repetition identities). It retains all delimiter/replacement classes, explicit edge samples and the convention-changing mutant. Length 6 remains available through `controls.py --max-length 6` under a larger separately authorized budget. V2 is prepared, not executed at the time of this update.
