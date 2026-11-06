# Native extraction of the combined quality treatment

[`quality-native-extraction.json`](quality-native-extraction.json) binds the
combined cold API source and the fresh native source. All4,541 native
declarations, keyed by kind and name, occur byte-identically in the combined
API source. The native closure excludes the new finite control declarations;
its sole extraction root is `main`. This is source identity evidence, not a
new executable, source-check receipt or native qualification.

The [preparer](tools/prepare-quality-native.py) pins and reuses the exact cold
preparer and every preceding source adapter. Its only change to the final
metadata-extractor invocation is replacing the API export list with `main`.
The final derivation records the effective command as well as the precursor
command before export selection. It runs no compiler or native target.

```sh
taskset -c 0 python3 -B experiments/phase169/tools/prepare-quality-native.py \
  --publication --admission --lazy --single-verify --native-protocol \
  --ordinary-composition --cold-constructors \
  --out selfhost/build/phase169/quality-native-source01
```

Prepared source:

- File: `selfhost/build/phase169/quality-native-source01/compiler.bend`
- SHA256: `db744d67dffc6cdbbe69eadfa42fa49e37ed6219cccccc0534e020c73f699e20`
- Size:1,538,604bytes,40,339lines and4,541 declarations.
- Growth over the protocol-fixed native source `ed10e79d…`:29,015bytes
  (1.922%),746lines and84 declarations.
- All62 metadata input pins verify. Protected canonical declarations remain
  unchanged. Production sources and installed selectors are unchanged.

The native entry still uses the existing six-string `qbe-source-v1` request
protocol. The selected source includes the native diagnostic-prefix repair,
the actual array certificate and namespace checks, protected ordinary
composition, and same-request cold-constructor derivation. There is no runtime
or machine-code replacement in this source recipe.

The [false-certificate audit](composition-result.md) predicts unchanged full
compiler QBE: File effects make the existing scalar permission false, so the
extra inlining and cold metadata paths are skipped and rendering uses the
original mode1 route. Added certificate traversal still costs work. After the
combined generated-program quality screen passes, the root should acquire
the native candidate, compare complete canonical-source QBE and measure the
same full request. That equality and timing have not run during preparation.

The cold source review found no new authority shortcut: full borrowed/direct
verification and enabled array/transport namespace gates run first; actual
`p118c_plan(request)` then rederives validity, error and cold names before the
unchanged `p118c_apply_plan` changes only constructor hot flags. Unshared-array
permission is correctly independent of cold permission. Synthetic plan
controls test helper mechanics; real cold-positive programs remain required.
