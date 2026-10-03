# Phase42 documentation finalization handoff

This is a static edit proposal for root's final installation step. It records no
installation or final performance completion. Keep existing public status until
the corresponding release, audit and current-bundle evidence is complete.
The selected compiler reference is checked16, API
`63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`.
The canonical results/status entry is [README.md](README.md). Detail pages
results.md, integration.md, compiler-cost.md, profile-findings.md and accounting.md
are planned; add direct public links only when those pages exist.

## Inventory of current-facing text

| File / original lines | Current text or link | Suggested change |
| --- | --- | --- |
| README.md:20–28 | Phase41 checked01 installed, 15/15, 227 bindings, 42 identical modules; phase41/current manifest | Replace the current-release block using the concise block below; retain Phase41 as historical previous release. |
| README.md:30–68 | Phase40 previous-installed release and current portable Phase40 loop | Keep historical results in implementation/phase40; remove this long current-facing summary or label it historical. Link Phase42 portable guide for current use. |
| selfhost/README.md:3–43 | Phase40 installed and old API630879... with Phase40 execution/cost/source totals | Replace the opening release summary; retain proof-trust and unsupported-platform limits. Do not carry Phase40 metrics into Phase42 text. |
| selfhost/README.md:59–70 | Phase40 current bundle45 points/1,336,751bytes/smoke20.36s | Replace with Phase42 guide and manifest only after publication. Archive size/smoke timing must come from the new bundle. |
| docs/BEND-IN-BEND.md:9–18 | Phase41 installed/API9900.../phase41/current | Replace current-release block; retain its original receipt as previous history. |
| docs/BEND-IN-BEND.md:20–26 | Phase40 previous installed/API630879... | Replace with short Phase41 previous-release link; preserve checked-B1 limitation. |
| docs/BEND-IN-BEND.md:136 | Phase40 backend rules described as current proof boundaries | Link PHASE42_GENERATED_JS.md for selected current architecture; label Phase40 rules historical. |
| docs/BEND-IN-BEND.md:141 | Portable Phase40 program loop | Switch current instructions to phase42/README.md. |
| docs/BEND-IN-BEND.md:293 | Phase40 release record described as current validation | Point to implementation/phase42/README.md for current status; retain Phase32 as historical. |
| docs/BEND-IN-BEND-PERFORMANCE.md:3–52 | Phase40 installed, Phase39 ratios, old current archive/command/smoke | Replace opening current summary and command as below. Historical numerical reports remain explicit historical comparisons. |
| phase42 portable guide:11–15,36 | Candidate not installed/current not published; live candidate variable | After actual publication, point to current/manifest.json and link the checked release/accounting evidence. Before that, preserve the present conditional language. |

No Phase41 current-release references occur in selfhost/README.md or the
performance guide: their openings are older Phase40 status and need independent
replacement. Do not indiscriminately replace phase40/phase41 historical links.

## Concise common opening text

The following text is valid while qualification is pending. Adjust link prefixes
for each file and, only after installation evidence, replace the second sentence
with the precise final installed-release status. Do not insert success counts
until they are taken from the final selected-image report.

> The selected compiler is **Phase42 checked16**; the
> [implementation report](README.md) records qualification and release status.
> Ordinary compilation executes the Bend implementation without a TypeScript
> fallback, on unchanged upstream pin0187512. See the
> [generated-JavaScript architecture](../../docs/PHASE42_GENERATED_JS.md) for
> guarded private graphs, owned layouts, List fusion and bounded structural
> execution, and the [portable benchmark guide](../../selfhost/tools/performance/phase42/README.md)
> for the maintained45-point catalog. Phase41 checked01 remains the retained
> previous comparison image; its [integration account](../phase41/integration.md)
> preserves that release's original evidence. This remains a checked B1 derivative,
> not a new self-emitted fixed point.

Use these exact destinations from each public file:

| Destination | README.md | selfhost/README.md | docs/*.md |
| --- | --- | --- | --- |
| Phase42 report | implementation/phase42/README.md | ../implementation/phase42/README.md | ../implementation/phase42/README.md |
| JS architecture | docs/PHASE42_GENERATED_JS.md | ../docs/PHASE42_GENERATED_JS.md | PHASE42_GENERATED_JS.md |
| Portable guide | selfhost/tools/performance/phase42/README.md | tools/performance/phase42/README.md | ../selfhost/tools/performance/phase42/README.md |
| New current manifest | selfhost/tools/performance/phase42/current/manifest.json | tools/performance/phase42/current/manifest.json | ../selfhost/tools/performance/phase42/current/manifest.json |
| Previous release | implementation/phase41/integration.md | ../implementation/phase41/integration.md | ../implementation/phase41/integration.md |

The new manifest target is conditional on root actually creating/verifying it.
Keep selfhost/dist/release.json as the authoritative installed identity, and keep
verify:release/CLI/build instructions unchanged. Preserve the host initialization
assumption in the performance guide's existing lower-level contract section.

## Current portable command proposal

For docs/BEND-IN-BEND-PERFORMANCE.md, replace the old Phase40 command with this
command only after the verified current archive exists:

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase42/baseline/manifest.json \
  --candidate selfhost/tools/performance/phase42/current/manifest.json \
  --node /absolute/path/to/node --cpu 3 \
  --rss-mib 2048 --available-mib 2048 \
  --budget 20 --set fast --out selfhost/build/my-phase42-screen-NEW
```

Document that outputs must be fresh, CPU must be available, and Node24+ is required;
exact diagnostic reproduction uses recorded Node24.18.0. This is a ceiling, not a
completion or wall-duration promise. Full 45 coverage requires three serial15-point
600-second batches: mandatory warmups alone exceed a single600-second ceiling.
Link the Phase42 guide's batching commands rather than duplicating them. Profiles
and static analysis remain separate from clean timing. The baseline packages
Phase41 checked01 and unchanged pinned TypeScript; do not substitute checked07
or an adjacent mechanism image as the release denominator.

In the Phase42 portable guide, after publication replace its candidate caveat
with the manifest/release evidence link and set
`PHASE42_CANDIDATE=selfhost/tools/performance/phase42/current/manifest.json`.
Retain live candidate preparation as the development alternative. Preserve all
budget/protocol, archive relocation, fresh-output and serial-job limitations.

## Architecture and historical sections

The new [JS architecture reference](../../docs/PHASE42_GENERATED_JS.md) is137 lines,
links actual selected source modules/functions, and has no selected15 reference.
All its local Markdown destinations were validated by filesystem reads. It links
only the existing implementation README for canonical results, with no nonexistent
final-report.md or uncreated result page.

Keep docs/BEND-IN-BEND.md's explicitly historical Phase40 measurements, limits,
and reproduction evidence. Its “What Phase40 changes” statements describe that
phase, including its absence of fusion, and should not become claims about current
Phase42. Add the new architecture link before this history. In the performance
guide, label the retained old introductory ratios as historical Phase40 if moved
below the new opening. Do not multiply ratios across phases, pool compiler cost
with generated execution, or turn sampled profiles into timing claims.
