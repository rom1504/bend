# Phase69 implementation checkpoint

Work in progress; installed release remains Phase67. All runtime numbers below
are fresh paired, uninstrumented saved executables under the pinned Clang recipe.
Diagnostics modify saved C only; they do not count as compiler improvements.
Final combined measurement and native/raw/B2 qualification remain pending.

## reachable-comparison01

18 qualified timing observations. Raw: `selfhost/build/phase69/reachable-comparison01/report.json`.

```json
[
  {
    "case": "tree",
    "mediansMs": {
      "baseline23": 664,
      "candidate": 560,
      "upstream": 273
    },
    "candidateOverUpstream": 2.051282051282051,
    "baseline23OverCandidate": 1.1857142857142857
  },
  {
    "case": "lexer",
    "mediansMs": {
      "baseline23": 613,
      "candidate": 544,
      "upstream": 245
    },
    "candidateOverUpstream": 2.220408163265306,
    "baseline23OverCandidate": 1.1268382352941178
  }
]
```

## closure-comparison02

9 qualified timing observations. Raw: `selfhost/build/phase69/closure-comparison02/report.json`.

```json
[
  {
    "case": "closures",
    "mediansMs": {
      "baseline23": 747,
      "candidate": 536,
      "upstream": 564
    },
    "candidateOverUpstream": 0.950354609929078,
    "baseline23OverCandidate": 1.3936567164179106
  }
]
```

## product-transport-diagnostic01

25 qualified timing observations. Raw: `selfhost/build/phase69/product-transport-diagnostic01/report.json`.

```json
{
  "selfhost": 611,
  "loop": 595,
  "static-mode": 482,
  "combined": 432,
  "upstream": 246
}
```

## node-reuse-diagnostic01

36 qualified timing observations. Raw: `selfhost/build/phase69/node-reuse-diagnostic01/report.json`.

```json
{
  "selfhost": 668.0,
  "mode": 570.0,
  "reuse": 556.5,
  "cold": 459.5,
  "combined": 426.5,
  "upstream": 274.0
}
```

## map-island-diagnostic02

9 qualified timing observations. Raw: `selfhost/build/phase69/map-island-diagnostic02/report.json`.

```json
{
  "selfhost": 722,
  "island": 677,
  "upstream": 430
}
```

## Decisions so far

Reachable-bang metadata and known closure factories were integrated into checked
B1 builds01/02. The broader static-image, cold-constructor and tiny-combinator
candidate is still being built and qualified. Static images use the existing
runtime ABI; cold constructors reuse the existing checked no-sharing proof.

The lexer scalar-state loop gave only10.4% additional gain on the static/mode
base. The Map scheduler product island gave6.2%, despite eliminating many
allocation calls. Both remain diagnostic prototypes; a broad ownership/ABI
change is deferred until a stronger benefit justifies its complexity.

Tree cold stores gave19.4% less time versus mode-only; storage reuse adds7.2%
on top. Native worker scalar types are the next independent discriminator.

Independent review rejected closure V3 before execution because ordinary core
substitution could erase demanded work. V4 uses syntax-only substitution and
includes a separately documented nd_beta correctness prerequisite. Final raw
first-error controls remain required.

## Preserved setup failures

- Static build03 omitted its module from compiler.json (manifest alone was
  insufficient); build04 found computed match scrutinees; build05 found an
  earlier parameter matched after a later parameter. All fixed with module
  registration and ordinary helper parameters; no semantic gate was bypassed.
- Combined builds06/07 exposed two missing affine `+rest` binders in V4.
- Map island01 compiled but failed its first runtime oracle. Reviewer found
  `WL_OPEN` shadowed input registers; successor02 preserves them and passes
  three controls (threads1/4) and nine timing intervals.
- Custom source controls02 failed reference setup because four external fixture
  IDs collided with pinned inventory IDs. Namespace-only selection-v2 preserves
  exact source/goldens; no test expectation changed.

No PR comment was posted. Production selection, raw evidence capsules and final
measurements will be linked from the final report.

## Combined checked build08

B1 checked build and36 frontend witnesses pass; all six acquired programs pass
independent outputs. Six-family clean54-observation campaign gives geometric
mean **1.0829× upstream**.

| Family | compiler23 ms | candidate08 ms | upstream ms | candidate/upstream |
|---|---:|---:|---:|---:|
| numeric | 249 | 249 | 251 | 0.992× |
| array | 169 | 169 | 169 | 1.000× |
| closures | 736 | 171 | 567 | 0.302× |
| tree | 708 | 455 | 274 | 1.661× |
| map | 728 | 717 | 432 | 1.660× |
| lexer | 616 | 483 | 247 | 1.955× |

The equal-family average does not establish every-family parity: tree/Map/lexer
remain1.66/1.66/1.96×. Compiler23's ratio in this fresh campaign differs from its
historical1.724×; compare roles within the same campaign, not across campaigns.

`combined08-raw02` passes all original12 and14 new raw cases (26 rows): raw
cache preservation, forged static rejection, dead/live bangs, capture hygiene,
unused demanded arguments, repeated/dropped combinator fallback and first-error
controls. Runtime controls use threads1/4. No per-role oracle exemption was
needed. The nd_beta syntax-only prerequisite is protective for the new
specialization; these controls do not demonstrate an independently observable
compiler23 defect.

`combined08-js-closure` verifies all2992 reachable frontend/JS functions and
runtime/public wrappers unchanged. New source controls02 pass25/32 for both
compilers; seven new fixture declarations are ill-typed and are being repaired
in new files without changing goldens. The preceding controls attempt failed
because Node's default piped stdin reports EPERM in the sandbox despite child
status0. A `/bin/true` reproduction isolates that environment failure; the
unchanged second run uses approved execution with the same resource guard.

Typed scalar signatures, a separate saved-C diagnostic, give tree medians
cold459.5→typed397ms (upstream274.5), with six controls and16 clean intervals.
A small general implementation using the existing N_Param representation is
next. No production typed-worker change is included in build08.
