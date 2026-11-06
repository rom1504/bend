# Reproduce the Phase170 installation

Run from the repository root. Use fresh output directories, explicit asset
identities and the maintained disk/RSS guard for compiler or program execution.
The exact acquisition, qualification and publication commands are retained with
the receipt archive; this page explains their roles.

## Current source and installed artifacts

```sh
python3 -B selfhost/tools/build/release.py verify \
  --manifest selfhost/manifests/current.json

python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile qbe \
  --out selfhost/build/reproduce170-source/compiler.bend \
  --map selfhost/build/reproduce170-source/map.json
```

The canonical result must be 3,150,535 bytes with SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Ordinary later source edits intentionally change that identity and require a new
qualification; do not rewrite historical receipts to match them.

`current.json` binds native QBE N2, JS B2 and public native C N1. The public C
source has a separately verified thin CLI profile. Hosted QBE is a separate,
checked B1 API, not a relabeled native or B2 image. The operational asset maps
point to the installed QBE artifacts and retained qualification evidence.

## Acquisition and qualification sequence

1. Assemble current canonical source and independently check the B1 APIs.
2. Use an authenticated qualified native seed to build N1, N1 to build N2, and
   N2 to emit Q3. Compare complete QBE and machine products. Compare ELF loadable
   segments separately from nonloaded symbols; do not ignore executable changes.
3. Build genuine JS B2 using the selected-library self-emission path. Use that B2
   to freshly check the full source and emit B3; require exact B2/B3 API equality.
4. Derive the public CLI profile using the maintained tool, allowing exactly
   `main` and `p86_effect_read` replacements. Emit C with the documented native
   build bridge, then build the package with the unchanged Clang `-O2` policy.
5. Run final-image native QBE64, selected JS45 and public C45 gates. Run public
   JS/C behavior, frontend refusal and JS-hosted C controls. Qualify checked
   hosted QBE and hosted-session interfaces separately.
6. Reemit both the 45 correctness fixtures and the distinct 45 timed-wrapper
   sources, requiring complete Phase169 QBE identity and matching runtime/tools.
   This transfers the corresponding generated-code evidence; it is not a new
   timing observation.
7. Qualify positive native P140/2 session behavior with same-mode cold references
   and independent program outputs. Advertise only that tested capability.
8. Assemble and audit the explicit three-component release proposal, install with
   the existing selector-last transaction, update the operational asset selectors,
   verify installed bytes/source and run installed-command smoke checks.

The recipe is assembled by `selfhost/tests/phase170/promotion.py`; it calls the
unchanged release auditor and never installs on its own. Publication uses
`selfhost/tools/build/release.py install`. Keep the transaction's backup mapping,
previous selector and journal. The source migration, lexer repair and retained
failed attempts are explained in the [report](README.md).

## Metric boundaries

The 189.329-second full maintained-source native build uses authenticated prepared
Base (`cache`), a fresh process, one CPU 3 lane and streaming QBE construction.
It includes emission, QBE, assembly and linking; emission/QBE overlap. Independent
source checking and Base preparation are separate. It is neither a warm session
edit nor an upstream comparison. The 147.764-second Phase169 result uses a smaller
extracted source and must not replace the installed compiler's full-build number.

All qualification claims are finite. Source checking, self-reproduction, exact
products and independent output oracles establish different properties; none is
an end-to-end compiler-correctness theorem. Native error recovery, native object
units, additional GPU targets and universal conformance are not claimed here.
