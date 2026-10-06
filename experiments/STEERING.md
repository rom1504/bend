# Active Phase54: backend cleanup and direct bootstrap qualification

The user authorized the cleanup recommendation. Installed release remains the
qualified Phase53 ordered02 described below; no Phase54 promotion yet.
[Design](../design/phase54/backend-cleanup-and-direct-bootstrap.md),
[report](../implementation/phase54/README.md), and
[backend boundaries](../docs/self_hosted/backend-boundaries.md).

Shared helpers moved unchanged:27 common semantic queries and7 shared JS text
helpers. The helper-only checked build passes36 frontend witnesses and produces
exactly the installed Phase53 API bytes. Two maintained compiler-image commands
now explicitly select legacy; six host-only routing controls pass.

The new compact SCC analysis has independent static review; checked graph facts,
resource policy and larger source qualification remain separate gates. The
existing no-G loader may support direct compiler images without an ABI rewrite;
restricted exports/transport precede full compiler emission and self-reproduction.
Legacy compatibility and native C remain required until their users migrate.
No speculative universal IR, LLVM or assembly emitter is being added.

Keep the103 inherited files untouched, historical producers immutable and heavy
targets serialCPU3/1GiBheap/2GiBRSS/4GiBfloor. Root controls execution, installation,
commits and pushes. No PR comments. Final Phase54 evidence will use one closed raw
archive; all failures remain recorded. Do not rerun full timing if output is exact.

# Current compiler: Phase53 ordered02

The user authorized fixing the semantic mismatch, making direct JavaScript the
default, and optimizing further. **Ordered02 is installed.** Semantic/compatibility gates, all45/669 benchmark
observations, release integrity and legacy42/default24 interface checks pass.
Portable replay passes three cases/27 samples. Final evidence is bound by the
[publication index](../selfhost/tools/performance/phase53/publication.json).
No PR comment is authorized.

[Design](../design/phase53/default-direct-and-ordered-expressions.md),
[report](../implementation/phase53/README.md),
[qualification](../implementation/phase53/qualification.md),
[direct guide](../selfhost/docs/direct-javascript.md),
[measurement plan](../selfhost/tools/performance/phase53/PLAN.md), and
[publication recipe](../selfhost/tools/performance/phase53/publication-plan.md).
Preserve all 103 unrelated starting files and all closed historical evidence.

Selected checked attempt: `selfhost/build/phase53/checked-ordered02`.
API: `3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`.
Source: `1b54ede1643a131c1bb7c7b995900da7947b6f21aac71141f50a0f5c8d15899d`.
Direct runtime: `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.
Legacy runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.

## Selected behavior

Direct output is the workspace default for emitted programs/libraries and
`--run`; `--direct-js` remains an alias. `--legacy-js` and explicit API
`backend:'js'` preserve the old descriptor interface. Pure interpretation and
native target selection retain their routes. Private compiler-image workers and
legacy-structure tests now select their required backend explicitly.

Fresh typed-array storage fixes cold NaN payload transport. The original oracle
remains40: selected output40 passes, pinned TS1 fails. New callback controls
exposed a separate prior ordering gap. Ordered prefixes and pending values follow
pinned `js_call`: collect child prefixes first, then hold pending operands at
intrinsic boundaries. Closures, constructors, lets, partial calls and genuine
overapplication are covered. No TypeScript fallback or emitted-JS rewrite.

Selected source has 26,151 physical /21,523 code Bend lines: +361/+288 versus
Phase52. Only existing core.bend changes; the other100 old modules remain exact.
Two new modules compose ordered expressions/values. The direct backend now has
11 modules. The 512-definition cap is conservative and precedes exact emitted
pruning; compiler-sized direct self-emission remains unqualified.

## Completed gates and publication

- Original independent source suite:96/96 candidate,95/96 TS and differential;
  only the reference's NaN source defect differs.
- Numeric/cold controls:34/34 candidate,28/34 TS. The six reference failures are
  original/renamed NaN-table calls in fresh processes, not unhealthy processes.
- Composition18 and genuine-overapplication2 pass both roles.
- Direct JS census agrees26/26 (18 runtime passes,four rejections,four N/A).
- Maintained compatibility8 passes after four test calls explicitly select legacy.
  The initial default-routing test failure remains preserved.
- Causal screen8/72 passes: corrected01/TS1.207400 → ordered02/TS1.130115,
  speedup1.068387. Prewritten≥1.05 and no>10% regression gate met. Morning and
  closures regress5.01%/3.78%; no spread/drift flags. Full45 is separate.

The complete final campaign uses original direct06 and pinned TS, never historical
timings. All45 points/23 sources/669 samples pass. Equal-point time improves
1.129266× →1.069599× TS, a1.055785× speedup; equal-source improves1.135543× →
1.078076×, a1.053305× speedup. Fifteen points beat TS,34/45 are within±10%.
Twelve regressions remain, none above3.4%; all six role/point timing flags remain.
The worst TS ratio is grid4 at1.911888×, so this is not per-program parity.

Installation, both integrity checks, legacy42/default24, prior-history byte
preservation, and the installed direct generic-row acquisition/oracle pass.
Six sandbox Clang spawn refusals in the first legacy gate remain preserved;
the unchanged authorized retry passes42. The last timing batch had one launch-only
approval timeout and a successful retry, with no repeated completed samples.
Final portable replay passes3/3 cases and27/27 samples. At the explicit
00:09:58 UTC accounting cutoff, elapsed time is80.13 minutes and observed process
occupancy35.12 minutes; the remainder is mixed work, not a waiting estimate.
All135 portable mappings are verified. Compact replay bundles and one closed raw
archive preserve the full campaign, including failures, under
`selfhost/tools/performance/phase53/`. The publication index binds the evidence.

## Follow-on experiments

1. Five scalar Nat→F32 scene helpers still use branches where TS uses short
   constant tables. Preserve source NaN bits and observable demand; the pinned
   reference's bare-NaN folding is not a correct template to copy wholesale.
2. Acyclic helpers retain redundant loop/block structure. Retain the singleton
   self-edge fact and test ordinary function bodies using a cheap saved-output
   ablation before committing to an emitter change. No speed effect is proved.
3. Use linear graph algorithms and explicit budgets before scaling to compiler
   inputs. Do not simply raise512 or add a silent legacy fallback.

Finite F32 literals are already specialized. Mandelbrot uses U32 fixed-point,
and inspected ray/Mandel modules have no generated f32_from_bits calls. Do not
repeat that nonexistent literal optimization. The four-module shape census finds
202 removed primitive calls, not a dynamic attribution or V8 mechanism proof.

Use one target owner, CPU3,1GiB heap,2GiB tree RSS,4GiB available-memory floor.
Keep compilation/compression away from clean timing. Small checked builds/screens
serve iteration; full45 is an integration gate. Close the raw campaign only after
all writers stop. Publish one raw archive and compact replay bundles, not another
13,930-file duplicate review packet. Broader language/native/GPU conformance,
compiler-throughput parity and a new self-emitted fixed point remain separate.
