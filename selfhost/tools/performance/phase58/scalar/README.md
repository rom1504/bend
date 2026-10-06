# Scalar residual/default reconstruction

This is an isolated, unexecuted compiler patch over the installed Phase56
source. Apply `scalar01.patch`; do **not** copy the complete constructor snapshot
onto another overlay (the literal-field experiment edits a different part of
that file). `source01.json` records before/after identities. No runtime, public
layout, ordered-expression, shared numeric-row scanner, or call-graph change.

Canonical native U32 row lowering attaches private facts to its two possible
residual arguments: a bit at position d and/or the Word suffix beginning at d.
Constructor lowering accepts only a full 32-position Word reconstruction from
literal Bool heads and same-origin, same-position residual fields. It combines
disjoint masks and emits `((origin & keep) | literal) >>> 0`. Constants are
actually reproduced; the final unconditional row need not prove its mask test.
Depth 32 returns an empty suffix mask explicitly, avoiding JavaScript shift-by-32
wraparound. Different origins, moved bits, unknown fields and incomplete widths
retain the old construction path.

The entire row is refused if any residual field retains an ordinary `JD_USE`,
including a use inside a closure. The compiler then renders the original row
with its original environment and views. This preserves object identity and
callback mutation of a demanded Word tail. Only inverse-only or unused binders
are eliminated; the original scalar scrutinee is still evaluated and held at the
same matcher boundary. All optimization facts originate from the checked native
U32/Word/Bool ownership proof. They are not inferred from generated JavaScript.

F32 residual rows are explicitly excluded. Existing whole native VIEW inverse
rules remain first, preserving their established NaN/signed-zero behavior.
The focused gate requires unchanged emitted F32 function bodies, valid floating
results, and matching cross-image bit observations; it does not invent a new
NaN payload contract or promise arbitrary boxed scalar/builtin monkeypatch
compatibility.

The extra code tries a candidate row once. If a surviving ordinary use prevents
scalarization, it renders the original row once. This adds compilation work and
must be measured separately from the removed generated-program allocations.

## Root-owned commands

Use the fresh open Phase58 checked baseline and candidate **attempt directories**
(the frozen emitter may populate its attempt-local cache), then the
pinned upstream checkout. Every acquisition gets a fresh output directory:

```sh
python3 selfhost/tools/performance/phase52/acquire-semantics-v2.py \
  --catalog selfhost/tools/performance/phase58/scalar/catalog-v1.json \
  --selection selfhost/build/phase58/checked-lookup01 --role direct \
  --out selfhost/build/phase58/scalar-baseline01
python3 selfhost/tools/performance/phase52/acquire-semantics-v2.py \
  --catalog selfhost/tools/performance/phase58/scalar/catalog-v1.json \
  --selection CANDIDATE_ATTEMPT_DIRECTORY --role direct \
  --out selfhost/build/phase58/scalar-candidate01
python3 selfhost/tools/performance/phase52/acquire-semantics-v2.py \
  --catalog selfhost/tools/performance/phase58/scalar/catalog-v1.json \
  --selection upstream:selfhost/.bootstrap/upstream-phase23 --role typescript \
  --out selfhost/build/phase58/scalar-typescript01
```

Run the controller under the normal serial resource guard, with default target
stack and a fresh report path:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/scalar/controls-v1.mjs \
  selfhost/build/phase58/scalar-baseline01/modules/scalar-residual.mjs \
  selfhost/build/phase58/scalar-candidate01/modules/scalar-residual.mjs \
  selfhost/build/phase58/scalar-typescript01/modules/scalar-residual.mjs \
  selfhost/build/phase58/scalar-controls01
```

The independent arithmetic gate covers all small inputs 0–259 and boundary
values through 2^32−1, changed prefix bits, a bit 31 suffix, moved bits/mixed
origins, aliases, mutation/throw/partial application, ignored fields, and F32
fallback. Three positive entry counters are a separate diagnostic derivative;
all value observations use original modules. The existing 34-case numeric suite
remains a separate selected-candidate gate.

## Private acquisition successor

The preferred Phase58 route stages both checked images and all caches privately:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/qualification/paired-fixtures.mjs \
  selfhost/build/phase58/checked-lookup01 selfhost/build/phase58/checked-scalar01 \
  selfhost/tools/performance/phase58/scalar/catalog-v1.json \
  selfhost/build/phase58/scalar-fixtures01
```

Use the independently acquired TypeScript module above with `controls-v2.mjs`,
passing `scalar-fixtures01/baseline/scalar-residual.mjs` and
`scalar-fixtures01/candidate/scalar-residual.mjs` as the two Bend modules.
Version 2 changes only the accepted acquisition receipt family and proves its
private copies against the original checked attempts. Version 1 remains intact.
