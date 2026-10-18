# Ordinary-call extension controls

`manifest.json` freezes the actual compiler `nt_append`/`nt_reverse` declarations
including `@unsafe`, their original file/declaration hashes, an independent
whole-source stdout, and twelve new graph observations at **19:10:55 UTC**.
Six training graphs and six held-outs are new to this ordinary-call experiment;
they do not reset the held-out status of any earlier Phase110 ABI data.

The runtime entry is `nx_list_append(ctx, xs, ys)`, with one owning claim for
each argument. The body must come from the checked actual source closure;
the C harness implements no append algorithm. It uses `nx_rt_keep` to prepare
same-root or shared-tail arguments, updates a root if keep returns a redirect,
and retains independent aliases into either argument. Expected values are the
mathematical concatenation `xs + ys`, derived without running any worker.

Prepared root-run inputs:

```text
selfhost/build/phase110/controls-calls-training01
selfhost/build/phase110/controls-calls-heldout01
```

Each contains `harness.c`, `cases.inc.c`, `abi.h`, exact `expected.jsonl` and a
source-bound preparation manifest. Regenerate a fresh directory with
`prepare.py --split training --out selfhost/build/phase110/controls-calls-training02`.
The existing fifteen `../append.expected.jsonl` cases remain useful additional
regressions. The new deep cases contain 65,536/65,537 list nodes and physically
shared accumulator roots/suffixes, not merely equal but independent strings.

`call-shapes.bend` and `shapes-manifest.json` separately freeze five ordinary
source shapes and two lowerer refusals at **19:12:44 UTC**. They exercise a
one-argument callee, an ordinary call within a constructor, nested argument calls,
keep across calls, repeated owning arguments, and dropping a dead input before
a call. Catalogue/credit mutations are declared interface checks; their list
length must never be reported as an executed test count. Dynamic/partial calls
remain refusals. Root's later checked/target receipts determine actual outcomes.
