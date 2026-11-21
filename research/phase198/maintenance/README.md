# Optional x86-only maintained policy block

This unapplied proposal reconstructs the checked `portfolio03` source **byte-for-byte**: 1,934,272 bytes, SHA256 `732735cf661f45a5bb12e930e1aa1e90fe5a263eda74103958434c295acd9830`. All five other maintained profiles preserve their complete source bytes and serialized maps relative to the qualified Phase197 composition (`phase198/selected-source01`). Every generated map span is verified against its module bytes and line offsets. No live maintained files are changed.

## Corrected checked source checkpoint

The latest [progress-portfolio01 checkpoint](checkpoints/progress-portfolio01/summary.json) preserves corrected source SHA256 `72061fa57c75993b59eaf42e18c6b923eebea640c352d0f7b9cd1d27ce7be91d` (1,947,566 bytes), its independent zero-hole source check, and its composition audit. This publishes reconstructible source while native qualification proceeds separately; it does not change the installed compiler.

```sh
python3 research/phase198/maintenance/replay.py \
  --recipe research/phase198/maintenance/checkpoints/progress-portfolio01/replay.json \
  --out research/phase198/maintenance/replay-output-progress
```

The earlier orbit checkpoint below remains immutable and is not relabeled as the corrected source.

## Checked orbit source checkpoint

The later [orbit-portfolio03 checkpoint](checkpoints/orbit-portfolio03/summary.json) reconstructs source SHA256 `b2c9aade19ae7a205ec61bb9358ae68b31f9d25de2eb6256c56e093fccc4edff` (1,942,906 bytes), with its successful zero-hole independent source-check receipt. It remains a source-only checkpoint: native qualification and installed selection are separate.

```sh
python3 research/phase198/maintenance/replay.py \
  --recipe research/phase198/maintenance/checkpoints/orbit-portfolio03/replay.json \
  --out research/phase198/maintenance/replay-output-orbit
```

See [candidate operation and installation boundaries](CANDIDATE.md) for using an actual published image without replacing the installed compiler. `prepare-checkpoint.py` creates the same compact checkpoint for a future explicitly frozen and checked portfolio.

## Replay from a clean checkout

Only Python 3 and `patch` are needed. From the repository root, select a fresh output path:

```sh
python3 research/phase198/maintenance/replay.py \
  --out research/phase198/maintenance/replay-output01
```

The replay authenticates the tracked qualification archive, extracts its baseline into the fresh directory, applies the 19 KB compressed portfolio delta, reconstructs the proposed source tool, runs **29 metadata tests**, and proves exact source/map identities and all five unaffected profiles. It also authenticates the retained successful, zero-hole portfolio source-check receipt against the exact reconstructed source. It executes no Bend compiler or target and does not rerun or transfer native qualification.

`summary.json` records the expected outcome; `replay.json` pins every transport input, changed module before/after, complete resulting source/map and unchanged profile identities. `portfolio-evidence.json.gz` retains the original composition audit and full source-check receipt. The baseline is reused from the existing tracked `research/phase198/qualification/native-replay01.tar.gz`; no duplicate baseline/source tree is committed. Output includes `report.json`, `tests.log`, and `proof/{compiler.bend,map.json,maintained}`. Generated trees, the proposed full tool copy, and intermediate proof directories are ignored.

## Proposed interface

The existing additive profile modules prohibit replacing a canonical definition. Copying/renaming its shared caller closure would be much larger. `source-policy.patch` adds this optional field to the x86 profile:

```json
"policyBlock": {
  "replace": "p121f_selected",
  "module": "src/back/x86/semantic-policy.bend"
}
```

The original shared `src/back/qbe/construction-elimination.bend` remains unchanged. The policy file contains the exact staged 29 helpers and replacement definition; assembly inserts that block at the original definition's position before closure selection. This preserves staged framing, reachable declaration order, and final bytes. The remaining portfolio changes use ordinary x86-only modules. The full canonical profile set, order and protection dictionary remain in use.

`make-tool.py` reconstructs an isolated `source-proposed.py` from the pinned live transport tool and minimal patch; it never applies the patch to the live tool. `prove.py` accepts explicit `--baseline`, `--stage`, and fresh `--out` paths for a later portfolio. Its current extraction intentionally admits only the existing fusion helper namespace and one contiguous block; changed scope needs a new audited recipe and evidence pins.

## Boundaries and tests

- Only the `x86` profile with `native-x86-source-v1` may select a block, using exactly `replace` and `module` fields.
- The target must be one unique existing `def`, without a law pair; `main` and protected declarations are refused.
- The entire original standalone single-line header must match, including `@unsafe`, names, quantities, argument types and result type. Multiline/inline-body signatures are refused; source transport does not become a Bend parser.
- The block has a separate confined module owner. Existing canonical/additive/entry modules cannot be reused. Missing/duplicate replacements, duplicate helpers and shadows of canonical/additive declarations or constructors are refused, even when closure pruning would hide them.
- Original inventory and protection checks still run. Map rows truthfully name the policy file. Helpers remain subject to ordinary independent checking and qualification.

All 23 new narrow-policy regressions and six existing maintained-profile tests pass. Controls cover malformed/null selectors, quantities/signatures, protected definitions, constructor and additive shadows, path escape, exact map origins, and existing closure/law behavior. An initial metadata-only attempt falsely counted constructor uses in defs as declarations; the final scan considers only type declarations.

The existing source CLI hashes emitted bytes/maps; hosted acquisition pins the assembled source; release binding reassembles the x86 profile and checks its identity. Packaging an x86 maintained tree must include its explicit policy file, just as it includes additive x86 modules. No QBE-only enumerator needs that file.

This is a maintenance proposal, not a live application or release. The final qualified portfolio may use the same mechanism after exact reconstruction and independent qualification evidence are updated. Without adopting it, the separate `portfolio03` single-profile experimental tree remains usable; its manifest must not replace the canonical multi-profile manifest.
