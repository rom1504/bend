# Phase170 maintained-source integration audit

The maintained compiler now contains the selected Phase169 implementation
directly. Assembly reads ordinary maintained modules and `src/compiler.json`;
it does not replay experimental overrides. This document records the source
transport audit, before compiler or interface qualification.

## Exact boundary

The selected experimental source is
`selfhost/build/phase169/quality-native-source01/compiler.bend`,
1,538,604 bytes, SHA256
`db744d67dffc6cdbbe69eadfa42fa49e37ed6219cccccc0534e020c73f699e20`.
The full maintained parent was 3,085,157 bytes, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.

The integrated QBE profile is 3,149,379 bytes, SHA256
`5903812cda7f23f4e25dfbe88b8717ad1b9c5fbe9f342d52fe00e179317b5e9e`.
It retains all 8,265 original declarations and adds 144, for 8,409 declarations
across 218 modules. Its size differs from the experimental main closure because
maintained session, batch, JS/C and other APIs remain present. The experimental
147.764-second self-build observation is not a timing prediction for this source.

| Maintained owner | Added declarations | Purpose |
|---|---:|---|
| `src/back/qbe/early-demand.bend` |43|Demand model, generic adapter obligations and lowering|
| `src/back/qbe/early-observers.bend` |55|Observer admission, scalar eligibility reuse and protected ordinary composition|
| `src/back/qbe/early-emission.bend` |28|Checked public view, seeded imports, actual array/cold certificates and streaming|
| `src/host/qbe-early-entry.bend` |6|Qualified native request preparation, diagnostics and output|
| `src/check/publication-reuse.bend` |8|Publication provenance and conservative fallback|
| `src/back/qbe/borrowed-regions.bend` |4|Lazy scalar-worker admission helpers|

All 144 added declaration spans, including comments and whitespace, equal their
selected-source spans. The two replacements, `p128bs_eligible` and
`p143cb_resume_state`, also equal the selected spans exactly. The only further
original definition change is the authorized `p111_native_request` delegate to
`p169n_request`. The other **8,262 original declaration spans are byte-identical**.
No declarations were removed. Existing declaration order remains unchanged;
the additions retain their relative order from the qualified source.

The recipe explicitly refreshes its inventory. Of its 112 protected entries,
111 have unchanged source and pins. Only the authorized ordinary-native routing
entry changes its normalized pin:

- Before: `d5e221ea8f0219afb5832d8a156739ec6719f20af93218139dc48895fa8ab04a`.
- After: `00ca877012c17146f34795e4e2d6266d993a059c88a99b5c3a3842146b2b383d`.

This is an interface-routing change, not a modified verifier/proof body or a new
proof claim. The source assembler accepted all five profiles and
`git diff --check` passed. These are source/data checks only.

## Preserved interfaces and qualification obligations

`main` still calls `p111_native_args`. Its single-request argument validation,
session dispatch and batch dispatch are unchanged. Only the ordinary native
request enters the Phase169 pipeline. The qualified preparation preserves the
native runtime-refusal `compile: ` prefix and writes forwarders and cursor
chunks through one file, preserving output order and line endings.

Session/batch still use the existing frontend/backend, sealed `P134Planned`,
registry and render caches. Their same-mode cold/warm contract is unchanged;
ordinary/session byte identity has never been their contract. Their capability
binding still needs actual maintained session qualification on the new image.

Hosted QBE continues through `p134e_plan`; native C and JS retain their original
entries. The shared publication change can affect frontend execution in those
lanes, so their source/interface gates remain necessary. `p143cp_seed_ready`
is unchanged: importing the entire experimental publication file would have
introduced an additional unselected override.

The full retained source, source map, parent snapshot and pin audit are in
[maintained-source-integration01](../../selfhost/build/phase169/maintained-source-integration01/report.json).
The compact committed [source audit](source-integration.json) records the same
identities and ownership. The raw directory retains its original Phase169 name;
no historical receipt was relabelled or edited.

## Product identity instead of another timing campaign

The qualification broad45 and timed native45 contain **zero identical source
files**, despite sharing case names. The timed sources contain different wrappers.
Matching by name would therefore make an invalid runtime-evidence transfer.

Two separate checks are prepared:

1. [compare-products.py](../../selfhost/tests/phase170/compare-products.py)
   matches the forthcoming Phase170 qualification against Phase169
   `quality-qualification01` by exact source size/SHA256, verifies the actual
   whole QBE bytes and compares Base, preparation and machine policies.
2. [reemit-products.py](../../selfhost/tests/phase170/reemit-products.py)
   loads the 45 unique exact timed sources and products from Phase169
   `quality-six-native01` plus `quality-remaining-native01`. It uses the maintained
   `request.execute` with each frozen QBE as `expected`, serially under the
   root-owned guard. It verifies the same target runtime object, QBE/assembler/
   linker identities and flags before any request. It performs no machine build
   or program timing run.

Data-only tool checks found 45/45 identity matches when comparing the retained
qualification with itself, and correctly rejected the name-matched timed wrappers
with 0/45 source matches. Reemission plan-only admission accepted 45 unique timed
sources and all original machine policies; it launched no compiler. The original
45 emissions totalled 49.58 seconds, produced 24,545,199 QBE bytes, and peaked at
45,324 KiB RSS. These historical values inform a bounded execution budget; they
do not measure the integrated compiler.

After Phase170 native qualification:

```sh
taskset -c 0 python3 -B selfhost/tests/phase170/compare-products.py \
  --qualification selfhost/build/phase170/NATIVE_QUALIFICATION/report.json \
  --reference selfhost/build/phase169/quality-qualification01/report.json \
  --out selfhost/build/phase170/qualification-product-identity01.json
```

Run the following **inside one maintained outer process/disk guard**, using the
actual final N2 image binding and a fresh output directory. A 300-second whole
budget, 2 GiB RSS cap and 256 MiB artifact budget are adequate starting limits
for this bounded emission-only set; retain the normal available-memory and disk
reserve checks.

```sh
python3 -B selfhost/tests/phase170/reemit-products.py \
  --assets selfhost/manifests/assets-native.json \
  --image FINAL_N2_IMAGE --image-receipt FINAL_N2_BINDING \
  --host native --target qbe --stage ACTUAL_RECORDED_STAGE --mode cache \
  --reference selfhost/build/phase169/quality-six-native01/report.json \
  --reference selfhost/build/phase169/quality-remaining-native01/report.json \
  --out selfhost/build/phase170/timed-product-identity01 --seconds 60
```

If all timed QBE bytes and target machine policies match, the prior generated
program evidence applies to those same products; another broad timing campaign
would repeat existing code. This does not measure new compilation speed, prove
unrestricted conformance or establish fresh timing observations. A mismatch
remains a mismatch: neither tool normalizes emitted text or treats missing
coverage as a pass.
