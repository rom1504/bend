# Ordinary general recursive-continuation controls

`manifest02.json` freezes two source candidates and literal complete
stdout. The control author ran no compiler, API, native build or target. Root
first checks both with the existing Phase114 frontend preflight:

```
BUN selfhost/tools/performance/phase114/controls/frontend-preflight.mjs \
  CHECKED_API selfhost/tools/performance/phase114/controls/recursive-general/manifest02.json \
  selfhost/build/phase114/recursive-general-preflight02
```

Then `controls/prepare-jobs-v2.py --manifest ... --all` prepares the unchanged
checked-emission, build and complete-output observation route. Compare baseline
and general-recursion candidate against the same independent expected files.

The original source and `manifest01.json` remain frozen. Parent-run
`general-inspect01` checked and admitted the zero-capture source, but rejected
the other source because a match cannot scrutinize a local binder. Version 2
matches an explicit `Bool` parameter in `resume_at`; its caller still computes
the predicate after recursion. The manifest pins the original failed receipt.
All independent expected output bytes are unchanged; the corrected source
requires its own checked frontend and admission gate.

- `zero-capture-length` discards each owned head, recursively computes the tail
  length, then increments the returned scalar. Its continuation needs no head
  value. Empty, singleton, shared four-element and 257-element lists check exact
  counts, including allocated Unicode heads.
- `multiple-owned-captures` extracts two Strings and two independent U32 fields,
  recurses first, then calls a constructor-only helper that compares those scalar
  fields and conditionally retains/drops/repeats the owned fields. Source aliases
  survive two transformed observations and an observation of the original rows.
  Unsigned boundary values, both predicate branches and Unicode are included.

The independent first oracle is literal list cardinality. For the second,
`score > limit` returns `[left,right,left]` followed by the transformed tail;
the other branch returns `[right]` followed by that tail. The three shared rows
therefore produce `α|β🙂|α|α|tail|`. Neither expected output is calculated by
executing the candidate or repeating its lowering algorithm.

Source ordering alone does not prove emitted admission: inspect the actual
checked plans for capture counts, the post-recursive predicate and the selected
resume helper. A one-constructor Row may be flattened by the mature product
pass; the intended four live values still must survive the recursive call.
Complete output agreement remains useful if a shape conservatively falls back,
but cannot be reported as qualification of the general path without that
separate admission evidence. No memory/ABI failure probes are used.
