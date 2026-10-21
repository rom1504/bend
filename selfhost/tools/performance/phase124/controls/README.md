# Phase124 independent ready-call/local-resume controls

Prepared offline at repository HEAD`c530016`. No Bend compiler, generated program
or machine build was executed. Source validity and optimization activation remain
pending. Files and complete independently calculated outputs are frozen in
`manifest01.json`; `cases.json` follows the existing Phase118 case format.

| Case | Intended private owner | Required call/resume shape | Bounded deep input |
| --- | --- | --- | --- |
| `p124-list-resume01` | `$direct.parcel.collect` | Owned list helper; recurse on rest; resume with both lists; concat |4096 nested list nodes |
| `p124-tree-resume01` | `$direct.archive.collect` | Owned payload helper; left recursive call; right recursive call; combine in original preorder |2048 skew branch levels |

The helper transforms reverse each payload and apply exact wrapped U32 affine
arithmetic. They are tail recursive; concat is ordinary constructor-tail recursion.
All helpers and owners return one ordinary owning Term. No dynamic closure,
effect, custom primitive, mutual owner recursion or unsafe source is required.
Empty payloads, singleton/empty containers, unequal branch structure and UINT_MAX
are included. Both programs retain the original container outside the owner and
print its complete contents after printing the complete transformed result. Thus
neither output checksums nor candidate-generated expectations can hide changed
ordering or a damaged alias.

`prepare.py` calculates the expected outputs from mathematical map/reverse and
preorder definitions, using iterative Python loops and U32 masking. It executes no
compiler. Outputs are48,487 and60,267bytes (eight lines each); their stdout and
JSON forms are pinned. The Python code only builds fixture oracles and manifests;
it is not a compiler or optimizer. To reproduce frozen expectations:

```sh
python3 selfhost/tools/performance/phase124/controls/prepare.py
```

For the parent's existing isolated emission workflow, set
`P118_CASE_MANIFEST=selfhost/tools/performance/phase124/controls/cases.json` and
select the two case names above. Then use the ordinary complete-output functional
gate. Compare a frozen parent and the proposed producer against the same oracle.
Check admission/emitted worker selection separately: successful fallback output
does not validate the new transformation. Preserve rejected source versions and
add a new version if parsing/checking fails.

The deep cases are ordinary bounded inputs, with no stack-limit alteration or
intentional failure probe. Passing them is finite evidence, not proof of stack
safety: inspect emitted control flow and the authenticated helper call graph to
establish that owner depth uses the explicit continuation stack.
