# Phase144: separating native shipping source from API and test source

The ordinary native compiler does contain a substantial amount of source outside
its CLI dependency closure. That is a **packaging opportunity**, not evidence
that the JS/C implementations or their tests can be deleted. The narrowest safe
organizational step is moving isolated controls to a separately checked test
composition; its likely benefit is modest. A separate native source profile is
the more ambitious experiment.

This census began as a read-only audit at HEAD `e60af39`. The subsequently
authorized profile preparation is described below; no compiler or native target
ran in this agent's work. The exact Phase143 qualified source is
`selfhost/build/phase143/integrated-source03/compiler.bend`, SHA256
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
It contains 63,983 physical lines, 46,498 nonblank/noncomment code lines,
7,981 declarations and 2,959,385 bytes. There are 6,939 definitions, 359 types,
and **683 laws paired with definitions of the same name**. The import/header
accounts for one code line outside declaration totals.

## Audited scopes

The [census JSON](shipping-source-census.json) records exact counts, root sets,
source identity, declaration-family accounting and methodological limits.

| Retained contract | Retained code lines | Excluded code lines | Fraction of source code outside closure |
|---|---:|---:|---:|
| Native `main`, protected verifiers and 11 proof-connected declarations | 27,973 | 18,524 | 39.84% |
| Same native contract, additionally retaining **every law** in the monolith | 36,481 | 10,016 | 21.54% |
| All 108 published typed-driver API roots, native CLI, protected/proof roots | 40,825 | 5,672 | 12.20% |
| Same published contract, additionally retaining every law | 40,882 | 5,615 | 12.08% |

The native CLI includes the existing ordinary live/cache request, Phase140 session
and batch branches at source lines 40461–40487. This audit does not silently remove
incremental modes to make a smaller number. The corresponding published API
profile retains direct/legacy JS, C/native preparation and all existing fallback
interfaces exposed by `selfhost/tools/typed-driver.mjs`.

Within the published-contract exclusions, at least **519 control-only definitions,
3,403 code lines / 4,399 physical lines / 237,364 bytes** form an explicit test
separation pool: **7.32% of code / 8.02% of bytes**. Roots combine finite-control
protocols, `*_control_report` functions and unchanged exact control provenance from
Phase141 census04. Production reachability wins over test classification. For
example, `p140v_header` is also needed by the active metadata path and is retained.
The remaining approximately 2.2k lines outside the all-public/all-law closure are
an audit pool, not established dead code.

Original-module name attribution identifies 10,391 code lines under JS modules,
of which **1,128 remain reachable from native main**, and 4,873 under native/C
modules, of which **2,528 remain reachable**. Labels such as “JS” and “C” are not
deletion criteria: their shared layout, scalar, effect and ownership knowledge is
used by QBE. The attribution uses original declaration identities, not potentially
stale module comments beside overridden bodies.

## What these counts do and do not establish

The graph uses references in complete declaration signatures and bodies, including
first-class/static-template arguments; it maps constructors back to defining types.
All declarations with the same name participate together, so a `law` cannot be
silently overwritten by its later `def`. Existing `@unsafe` annotations, source
order, imports and definitions have not been rewritten. The established Phase141
read-only lexer masks comments, strings and character literals; the complete root
and source fingerprints are preserved in the JSON.

This is a conservative lexical closure, **not a checked dead-code theorem**.
Binder collisions can add spurious edges: the local parameter `main` in
`f_load_graph` reaches global `main` in this approximation. Quoted-name foreign
contracts, implicit elaboration requirements and historical external API clients
need separate auditing before removal. The body catalogue used by source checking
and optimization can change even when a removed function has no execution edge.
The smaller compiler's own QBE, symbol identities and layout therefore need not be
byte-identical to the old image; external compiled programs and semantic gates are
the appropriate comparison.

## Cost interpretation

Using the coordinator's approximately **117s cold frontend** solely as a linear
size model gives:

| Source composition experiment | Modeled frontend saving | Modeled whole-request reduction at 296.541s |
|---|---:|---:|
| Separate the explicit control pool | 8.6s | 2.9% |
| Audit all exclusions while retaining public APIs and every law | 14.1s | 4.8% |
| Separate native profile while retaining every law | 25.2s | 8.5% |
| Native profile with reachable laws plus existing mandatory proof roots | 46.6s | 15.7% |

These are **assumptions, not measured gains or hard bounds**. Parsing may track
bytes more closely than lines; checking costs depend on terms, global book size,
specialization and declarations. Removing cold helpers might also reduce some
whole-book preparation, but no measured attribution supports adding that benefit.
The generated executable already filters reachable definitions, so source
separation does not imply equally smaller machine code or faster generated
programs. Test-only separation is unlikely to be the next 2× compiler gain.

## Avoid repeating the prior simplification campaign

[Phase141's deletion budget](../phase141/deletion-budget.md) already identified
2,413–3,430 control-only lines and explicitly distinguished test packaging from
retiring implementation complexity. Its parser-SCC and static-comparator
consolidations are already reflected in this source. The
[10k decision](../phase141/ten-k-decision.md) found no justified large active
backend deletion. This census adds the exact current source/profile split; it
does not rediscover a new optimizer architecture or justify generic callback
walkers rejected in earlier work.

The smallest informative next experiment is a **native source composition**,
starting with the all-laws variant if proof-surface preservation is preferred.
Keep the full API/test composition and every historical fixture intact. Produce
an ordered declaration manifest with duplicate law/definition blocks and attached
annotations; do not use `C.blocks` as an emitter. Independently check the reduced
source before building anything. If it checks, compare complete external-request
products and measure parser/checker time against the full-source profile. Only
after useful savings should ordinary native reproduction and the existing
focused/full qualification gates be repeated. Session/batch behavior needs its
own retained-mode gate; it is not covered by ordinary native qualification.

## Authorized source-only follow-up

The new [profile preparer](../../selfhost/tools/performance/phase144/source-profile/prepare-v01.py)
produced `selfhost/build/phase144/native-profile-source01/compiler.bend`, SHA256
`6414e0ed268f92a50bfb4876f50998a7df393b5639ff938a836744940a46038a`.
It contains **38,226 physical / 27,974 code lines and 1,641,979 bytes**, retaining
4,889 declaration blocks, including 553 laws, with no function overrides or new
definitions. Its manifest pins explicit roots, ordered retained/excluded block
hashes, every protected/proof declaration and the unchanged full parent source.

This source is **unchecked and unqualified** at preparation time. The method
independently checks declaration discovery outside masked literals, exact original
source reconstruction, annotation attachment and lexical closure. It does not
substitute these checks for the Bend checker. An optional `--all-laws` profile
retains all 683 laws for a stricter proof-surface experiment. The full original
API/test source remains unchanged. Root-owned source checking and complete-product
gates determine whether either profile is usable; there is no measured gain yet.


## 2026-10-26 consolidation update

The unchecked source01 state above is historical. The later profile02 passed
independent source checking, three complete hosted-product comparisons, native
acquisition (approximately268s guarded wall), three native ordinary requests and
the retained two-/four-revision session/batch smoke gates. This is a packaging
workflow screen, not full qualification or a same-source compiler-speed gain.
Its acquisition used a different source and producer from the earlier full-image
acquisition, so subtracting those times would not isolate source-size savings.
The line-based2.9–15.7% projections remain unmeasured assumptions. The latest
source01 full-input frontend diagnostic is94.833s, not the117s historical input
to that model. See [workflow scope](../../selfhost/tools/performance/phase144/source-profile/README.md)
and [consolidated findings](../../implementation/phase144/profiler-and-cost-findings.md).
