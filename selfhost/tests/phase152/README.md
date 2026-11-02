# Phase152 controls and replay

The implementation is now in the maintained compiler modules:

- `src/back/native/closed-match.bend`: prepared nullary correspondence and selector reuse.
- `src/back/qbe/signatures.bend`: authenticated nonowning value classification.
- `src/front/lexer.bend`: preferred scalar lexer.
- `src/host/prepared-base.bend` and `src/back/qbe/fused-regions.bend`: compact dispatch tables.

`prepared-constants-controls.bend` is a finite compiler-data test module. Append
it to an explicitly refreshed maintained source recipe and acquire a checked API
exporting `p152c_controls` and `p152c_controls_ok`. There are66 rows:19 incumbent
selector controls plus47 new image, correspondence, refusal and ownership rows.
The malformed data is never executed as a generated native program. These are
not universal correctness proofs. Frozen source assemblies and API receipts are
identified in the [phase report](../../../implementation/phase152/README.md).

The standalone optimization overlay and promoted Phase150/151 component copies
are historical experimental inputs. Recover their exact bytes from commit
`75bc607` or the Phase152 evidence capsule. Historical reference/candidate probes
must use their frozen source assemblies, rather than substituting today's
maintained lexer or dispatch functions for their former reference definitions.

`compiler-api.json` is the minimal general checked QBE API for early compiler
experiments. A six-root API supports actual QBE emission and small native
witnesses without first building another complete native compiler.

`native45-acquire.json` binds both actual native images and the unchanged45-point
catalog. The [screen guide](native45-screen.md) describes acquisition and fresh
paired timing separately. Re-freeze a benchmark manifest after a consumed method
changes; never amend frozen observations or redefine input points to obtain a
better score. Increasing repetition scale is a declared resolution adjustment,
not a new program/input point.
