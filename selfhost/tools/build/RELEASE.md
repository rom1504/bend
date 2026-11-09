# One current compiler binding

`release.py` separates promotion evidence from the operational selector.
`selfhost/manifests/current.json` has kind `bend-current-bindings`, version `1`.
Normal verification reads the maintained source recipe, installed/provider pins,
and the bytes of its small audit receipt. It does not follow that receipt's
historical build methods, source snapshots or bootstrap acquisition chain.

The release selected by [`current.json`](../../manifests/current.json) is
installed: the qualified QBE N2, genuine JS B2, and public C-emitting native N1.
The selector records their exact source/artifact identities and completed gates;
the [installation audit](../../dist/current-audit.json) records the promotion
decision. The [Phase182 report](../../../implementation/phase182/README.md)
records the latest promotion, exact current-source binding and rollback. Future
candidates must pass the same audit below.

## Operational document

The current document contains:

- `kind`, `version`, `complete: true`.
- `source`: `recipe` file pin, `root` (`selfhost`), `profile` (`qbe`), and canonical
  `identity` (`bytes`, `sha256`). The verifier reassembles the maintained modules
  through `source.py` and compares this exact identity.
- `components`: exactly `qbe`, `js`, `nativeCli`. Each contains `host`, `stage`,
  `protocol`, `sourceIdentity`, `image` pin, `capabilities`, and named `gates`.
- `files`: map of exact repository-relative installation paths under
  `selfhost/dist/` to pins whose `file` is that same relative path.
- `providers`: named explicit pins, either included in `files` or external pinned
  assets. Runtime/foreign/Base identities remain explicit.
- `gateStatus`: populated by installation after audit, recording qualification
  and the component gate names. It does not claim a mathematical proof.
- `provenance`: pin of `selfhost/dist/current-audit.json`, copied during installation.

The component contracts are fixed:

| Component | Host | Stage | Protocol | Image placement |
| --- | --- | --- | --- | --- |
| `qbe` | native | N2 | `qbe-source-v1` | Explicit installed QBE-emitting image |
| `js` | js | B2 | `hosted-api-v1` | `selfhost/dist/typed-api.mjs` |
| `nativeCli` | native | N1 | `native-public-cli-v1` | `selfhost/dist/native/bend` |

The JS source identity must equal the canonical identity. The QBE image's actual
compiled-source identity is retained even when a qualified equivalence permits
using it with the current canonical source. The public CLI
uses an independently bound thin profile, with the allowed main/effect-read
changes verified by its profile receipt. Native image files must be executable.
The native CLI is a public option parser, not the QBE or prepared C-request entry.

## Promotion document

A promotion proposal has kind `bend-release-promotion`, version `1`, and
`complete: true`. It contains:

- `bindings`: the intended operational document, before installer-added
  `provenance` and `gateStatus` fields.
- `files`: the same destination keys as `bindings.files`, but values are the
  actual qualified **source artifact** pins. Each must match the corresponding
  intended installed bytes. These may be explicitly acquired assets in a fresh
  worktree.
- `gates`: bounded map of named gate specifications described below.
- `jsFixedPoint`: name of the actual B3 self-emission gate.
- `nativeCliDerivation`: name of the canonical-source-to-public-CLI profile gate.

Every gate has `report` (a pinned complete JSON report), `role`, nonempty `claims`,
and optional `bindings`. `role` is one of `qualification`, `lineage`, `derivation`.
Reports with errors, changed inputs or incomplete status fail admission.
Qualification roles must have explicit true `passed`, `qualified` or
`nativeQualified` status; any present one of those status fields must be true.
Derivation records may correctly state `qualified: false`: they establish source
relationships, not behavioral qualification.

`claims` maps dotted report field names to exact scalar/structured values; JSON
types must also match. `bindings` maps dotted report field names to expected
`bytes`/`sha256` identities. For example, the qualified unchanged QBE image can
bind a preserved report's `n2` and `source` fields to the selected image and its
actual compiled source. Old paths inside a report do not need to exist: the independently
pinned report bytes and current acquired artifact identities are compared,
without reopening its historical input graph.

Each component's named gates must include an independent qualification bound to
its image, and a lineage gate binding both its image and source. A qualification
report may itself supply that lineage. Every supplied gate is checked; omitted,
failed or incomplete evidence is never treated as a pass.

Additional mandatory checks cannot be disabled by the proposal's claims:

- JS requires a `bend-js-self-emission` report for actual B3, with
  `freshSelfCheck`, `typeAccepted`, and `byteEquality` all true. Its generator must
  equal the selected B2, B3 bytes must equal B2, and the checked source must equal
  the canonical source.
- The public CLI profile must be `bend-public-cli-source-profile`, have
  `allOtherBodiesIdentical: true`, change exactly `main` and `p86_effect_read`,
  bind the canonical identity, and bind the selected CLI source identity.
- The CLI additionally needs its independent behavior gate bound to its actual
  packaged image. The source-profile report alone cannot qualify it.

For the bounded canonical-source change from the JS definition-analysis capacity
4096 to 4352, an optional `qbe.canonicalEquivalence` records
`kind: whole-qbe-byte-identity`, `canonicalSourceIdentity`, `qualifiedQbeIdentity`,
`requestGate` and `qualificationGate`. The separate narrow validator in
`release_bridge.py` requires the preserved qualified N2 source/image/fixed-point
report and an actual clean N2 request compiling the new canonical source. That
request must have compared the entire emitted QBE product with the qualified
reference, byte for byte; expected/product/stdout identities must all agree.
The selected N2's `sourceIdentity` continues to name its original source. The
bridge applies to its QBE capability and does not qualify a JS image or relabel
the old image as freshly rebuilt.

Commit small gate reports or explicitly acquire their exact bytes alongside
qualified images for a fresh checkout. This does not require restoring the
original workspace's historical compiler implementations. The initial QBE
qualification can be inherited only through an explicit exact image/source
identity bridge; a newer filename does not establish that relationship.

The incomplete staging proposal was retired after successful promotion.
Actual B2/B3 self-emission, selected-B2 and final public-C 45-program gates,
public CLI integrity/behavior, and installed launcher controls passed. The
[completed evidence index](../../../implementation/repository-consolidation/qualification-evidence.json)
identifies the exact retained audit, qualification and installed-verification
reports in the
[receipt archive](../../../implementation/repository-consolidation/qualification-evidence.tar.gz).
The [fresh-worktree report](../../../implementation/repository-consolidation/fresh-worktree.json)
records verification with explicitly supplied qualified assets. Historical
failures remain retained; the build-only C pilot does not replace qualification
of the installed public image.

## Commands and transaction behavior

```sh
python3 -B selfhost/tools/build/release.py audit \
  --manifest /absolute/promotion.json \
  --out selfhost/build/consolidation/promotion-audit-fresh.json

python3 -B selfhost/tools/build/release.py install \
  --manifest /absolute/promotion.json \
  --out selfhost/build/consolidation/install-transaction-fresh

python3 -B selfhost/tools/build/release.py verify \
  --manifest selfhost/manifests/current.json
```

`audit` performs no installation. `install` audits again, admits bounded staging
and rollback bytes plus the 5 GiB reserve, stages exact artifact bytes/modes, and
backs up every existing destination. It rechecks the promotion evidence before
publication. Each destination is atomically replaced and journaled; the single
`current.json` selector is published last. Failure restores already replaced
destinations and the previous selector. Initially absent destinations are removed
during rollback. Backup files and the transaction report remain available.

An abrupt machine/process kill cannot run Python exception cleanup. The recorded
backup map and mutation journal permit recovery; do not rerun into the same output
directory or erase its backups. Installation does not remove unrelated historical
distribution files or silently rewrite compatibility selectors. Stable launchers
must consume the one current binding.

The bounded controls create only temporary fixture workspaces:

```sh
python3 -B selfhost/tools/build/test_release.py
```

They cover failed gates, wrong generation labels, missing actual self-check,
selector-last installation, operational verification with all gate/proposal files
removed, and rollback after an injected partial-install failure. No real compiler
is built, executed or promoted by these tests.
