# Phase185 experiment progress

The frozen parent is1d8b56e. Installed images remain the Phase183 qualified selection. Small checked-emitter experiments are not native self-reproduction qualification.

## Measured screens

- Initial array-only x86 and late-template reuse were negative for scalar kernels. Exact outputs pass. Array profile840/841 samples places essentially all observed CPU in the fast body; the fallback is not a supported explanation.
- Stable copy removal plus immediate selection: local-pair2.45×, local-fold2.71×, scalar-region2.23× faster than retained assembly; generic-row1.26×. These are four timed pilot cases, not the full45.
- Boolean dispatch and result facts: tree5.15% faster, ray3.94%, map0.32%, fold0.04%; scalar0.75% slower in this short screen. No broad aggregate claim.
- Source and finite machine controls passed for Boolean/facts, immediate selection, stable copy and cold constructor first prototype.

## Rejected or corrected attempts

- Adaptive runtime screen initially reused QBE-sized repetition counts for much slower assembly products. Initial pilots spent12–16s each and the campaign exhausted its90s deadline after three cases. Preserve array-runtime01 as incomplete; completed per-case rows are diagnostic, no campaign aggregate. New runs begin at at most16 repetitions.
- New fact-control fixtures needed parser-safe Con/Nil patterns, parameter-scrutinizing helpers and an annotated list binding. Failed source acquisitions bf-api01–03 are retained. Production Boolean/fact candidate accepted in bf-api04.
- Cold constructor renderer had a match-binder-order source error, corrected before execution. copy-ctor-api01 retained failed; api02 and its machine controls pass.
- Unconditional existing-facts reuse in x86 was rejected by static audit: scalar N111Return is not the direct optimizer's termination form. Current candidate conservatively skips that pass for bodies containing scalar Returns; dedicated public-return controls were added.
- Existing profiler plan directories cannot be guard artifact roots. One attempted dispatch was refused before targets. Fresh-root wrapper now plans and executes within the guarded directory; array-profile02 passes.

## Evidence roots

`selfhost/build/phase185/{baseline-profile01,array-runtime01,late-runtime01,array-profile02,bf-controls01,bf-qbe-runtime01,copy-ctor-controls01,copy-x86-runtime01}`. Every complete runtime row uses exact source/output identities and adaptive rotated uninstrumented batches. Timing and diagnostic profiles remain separate.
