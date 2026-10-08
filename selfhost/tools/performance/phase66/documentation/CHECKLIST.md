# Phase66 active documentation migration

This directory owns reviewable documentation patches, not live production edits.
The root agent applies the full `documentation-v3.patch` only while every
`beforeSha256` still matches its named live file. Its JSON manifest records all
11 exact before/after identities. The patch describes the active source and
links the current phase report for installed status; it does not declare a
qualified or installed Phase66 release.

The separate bootstrap owner supplies `docs/PHASE5_DEVELOPMENT.md` through
`../bootstrap/documentation/phase5-development.patch`. The root README, steering
and ledger remain root-owned. Neither patch changes a compiler or generated API.

## Covered active surfaces

| Surface | Required migration |
| --- | --- |
| `selfhost/README.md` | New active pin and current report pointer; preserve Phase65 ratios as dated historical evidence. |
| `selfhost/CONFORMANCE.md` | New fixture inventory; distinguish frontend, runtime-unit, real network and full backend gates; explicit legacy refusals. |
| `selfhost/docs/ARCHITECTURE.md` | Raw namespace identity versus display, iterative host queue, descriptor/request ABI and actual image-profile roles. |
| `selfhost/docs/direct-javascript.md` | 35 providers, effect-tagged requests, deferred missing-registration error, public display names, queued ADT/Array conversion and narrower legacy support. |
| `docs/BEND-IN-BEND.md` | Operational upstream checkout/pin, guarded profile7 contract, current release pointer and dated old image hashes. |
| `docs/self_hosted/prepared-base-artifacts.md` | New mandatory Base identity; optional new-Base permission requires independent qualification; explicit preparation versus ordinary demand. |
| `docs/self_hosted/compiler-image-generation.md` | Separate checked parent, selected derivative, genuine B2 and installed package; preserve old timings/roots/hashes. |
| `docs/self_hosted/compiler-request-pipeline.md` | Updated field-plan consumers and removed recursive-tail helpers; retain frame4/world and old measurements with dates. |
| `docs/self_hosted/README.md` | Current phase index; historical Phase64 and Phase45 snapshots retain their scopes. |
| `docs/self_hosted/backend-boundaries.md` | Current interface/status pointers and direct/legacy effect capability separation. |
| `docs/self_hosted/compiler-allocation.md` | Constructor-literal optimization remains; obsolete host-clone rule is explicitly historical. |

## Before promotion

- Join the final selected raw/derived B1, source, Base, direct/legacy/native
  runtime and provider identities to actual closed receipts. Do not make an
  attempt02 profile/control observation an unbound attempt03 result.
- Preserve profile7's exact limits: native string equality and literal choices,
  without the old array-argument branch rewrite. Keep the six historical replay
  profiles; the bootstrap owner owns their detailed workflow documentation.
- Reconcile optional annotation permission with its actual selected source and
  closed new-Base producer/whole-product/whole-module/owned-route/custom-Base
  controls. The initial migration denied new-Base optional products. Version3 records
  their completed checked03 qualification and enabled exact99ac43… permission,
  bound to driver e093483d…. Any later change needs a fresh patch and closed
  evidence; do not overwrite staged artifacts or the historical old-Base grant.
- Report all five axes independently: generated-program runtime, B1 latency,
  genuine-B2 latency, conformance denominators and source/contract complexity.
  Historical old-TypeScript ratios stay tied to their own campaigns.
- Retain the four explicit legacy timed-send refusals and asynchronous TCP
  unknown-suffix refusal. The closed 34-control runtime gate includes three real
  loopbacks but does not qualify source emission or every network behavior.
- Publish full conformance and reproduction outcomes, including unchanged or
  new gaps, resource exclusions and original failed receipts. Complete release
  verification and installed/relocated CLI gates before saying installed.
- Rerun `implementation/phase66/simplicity-audit-v2.py` on the final immutable
  checked attempt and genuine-B2 receipt. Attempt02/03 censuses are checkpoints,
  not substitutes for the final selected-source audit.
- Check links at their intended repository destinations after the documentation
  bundle is applied. Preserve historical snapshots and their upstream pins.

## Preparation and review lineage

`prepare-v1.py` made the first complete staged patch; independent review verified
all 11 hashes and reconstructed every unified diff. `prepare-v2.py` derives a
full replacement patch from those frozen originals, correcting two wording
issues: optional preparation does not annotate a user's selected definitions,
and the old Phase61 direct-image chain is historical. The original failed link
scan (a JavaScript call mistaken for a Markdown link) and its partial isolated
documents remain under `failed-preparation01/`; no live document was changed.
`prepare-v3.py` binds the closed new-Base owned/custom controls and applied host
permission before deriving the successor documentation; versions1/2 stay frozen.

All preparation and review are source/data work on CPU0. No compiler, generated
program, benchmark, Git operation or PR comment is executed by this lane.
