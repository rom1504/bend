# Lazy chooser branch-swap laws

These three small candidate laws state, for every result type `A`, total Boolean
`b`, and supplied thunk values `yes, no : Unit -> A`:

```text
choose(A, Bool.not(b), yes, no) == choose(A, b, no, yes)
```

The proof splits on the two Boolean constructors; both sides then reduce to the
same thunk application. `A`, `yes` and `no` are erased proof parameters. Only the
Boolean is inspected at proof execution. There is no `@unsafe`, axiom, unfilled
law, foreign declaration or assumed equality in either proof module.

`production-v01.bend` copies the actual `kc`, `nt_choose` and `f_choose`
declarations from the frozen Phase144 integrated source
`992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b`.
Only their leading `@unsafe` annotations are removed. The source bridge records
the exact source and module identities; types, quantities and executable bodies
are unchanged. Removing the annotation does not itself establish safety: the
new safe declarations and the laws must pass checking.

Root can reuse the existing authenticated proof checker, after releasing any
quiet native timing window:

```sh
python3 -B selfhost/tools/performance/phase131/laws/check.py \
  --source selfhost/tools/performance/phase144/predicate/laws/laws-v01.bend \
  --out selfhost/build/phase131/p144-chooser-laws01
```

That existing tool snapshots the source closure, checks Bend, emits BendTT,
checks every law is present and nonopaque, runs the retained Lean BendTT kernel,
and runs its independent unequal-label negative control. Its existing inner
guard uses CPU4, 2GiB and a 16GiB available-memory floor; the coordinator should
schedule it, rather than run it concurrently with controlled native timing.
The current files have not yet been checked or executed by this agent.

`reject-unswapped-v01.bend` is an optional **static** negative control: it removes
the negation without swapping branches and asserts `True == False`. An ordinary
`--check-only` invocation should reject it. It is not a failure-runtime probe.

The theorem is a returned-value contract. It does not prove the operational
behavior of generated code, reference counting, allocation failures, foreign
effects, or arbitrary thunk-producing expressions. In particular, moving two
effectful expressions into opposite argument positions requires a separate
evaluation-order argument. The current `p131i_insert` experiment uses syntactic
lambda arms and a pure scalar predicate, evaluates that predicate once, and
preserves ownership annotations; its exact source bridge and dynamic controls
remain separate obligations. The 87-site syntax census is not automatically
authorized by these laws.
