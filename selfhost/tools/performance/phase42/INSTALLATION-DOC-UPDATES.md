# Phase42 installation documentation handoff

This is an update checklist and prose template, not an installation claim.
Leave the repository root README unchanged until the final checked candidate,
installation audit and portable bundle identities are supplied by the release
owner. The Phase42 run guide already supports retained-reference replay and live
checked candidates without requiring installation.

After those artifacts exist, update the consolidated compiler guide and root
README in their existing style with the following verified facts:

- Final checked attempt/source identity and installed API/runtime identity.
- Release verification, postinstallation audit and applicable CLI relocation gates,
  with exact observed coverage and links to their retained reports.
- Portable `phase42/current/manifest.json` availability and its final source binding;
  preserve `phase42/baseline/manifest.json` as Phase41 checked01 plus pinned TS.
- Selected retained optimization scope, exact refused/deferred/rejected proposals,
  complete paired timing coverage, and remaining TypeScript gaps by family.
- Source complexity and generated-JavaScript byte deltas from the accounting report,
  using consistent baseline counts; do not substitute syntax counts for runtime gains.

Suggested short prose, replacing every bracketed field from final receipts:

> Phase42 [final checked identity] is installed. [Exact verification/audit counts]
> pass; the upstream TypeScript pin remains
> `018751270e800bc222a93dad7f257083ee53a5f7`. The portable Phase42 current bundle
> retains the installed compiler's checked emissions. See [final results link] for
> complete paired coverage, per-family ratios and remaining limitations, and the
> Phase42 portable performance guide for replay against Phase41 and pinned TS.

In `phase42/README.md`, replace the provisional current-bundle paragraph with the
verified availability and installed identity, and change the default
`PHASE42_CANDIDATE` example to `selfhost/tools/performance/phase42/current/manifest.json`.
Keep the live acquisition command and the three serial full-catalog batches.
Retain observed failures and rejected prototypes in the implementation account;
installation does not turn diagnostic prototypes into selected compiler behavior.

Link the final design/implementation indexes and results from the repository's
existing navigation. Record any unfinished semantic or performance gate explicitly.
Do not describe catalog-wide parity, a universal speedup, or complete language
conformance unless the corresponding final evidence establishes that scope.
