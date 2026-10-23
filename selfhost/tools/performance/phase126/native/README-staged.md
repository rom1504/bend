Selected32 staged native plan
=============================

Launch only the `rootGuardCommand` in `selfhost/build/phase126/native32-staged-plan01.json`. Its permanent ABI receipt is `native32-abi01.json`. The unstaged parent plan is retained as derivation evidence; do not launch both plans into the shared artifact paths.

The staged plan retains all eight original qualification obligations in twelve serial jobs. It uses the unchanged native runner's existing emission-only mode and the unchanged Phase123 aligned builder. After N1 focused19, a disk checkpoint measures actual N1 artifacts and requires enough free space for the larger of the 128 MiB native stdout cap or the measured machine artifacts plus 8 MiB, then 96 MiB for remaining suites and 32 MiB slack. Insufficient space stops before native self-emission and preserves completed artifacts.

After native emission closes, the second checkpoint authenticates the actual N1 image and the same source/Base/cache/selection/admission request. It requires raw hosted/native QBE SHA256 and byte equality, then atomically hardlinks the native SSA path to the hosted file. The paths, bytes and original reports remain valid. Only then does the independent aligned N2 build run.

`comparison-staged.py` retains the original complete hosted stages, checked source/API/runtime gates, aligned machine build stages, actual image/runtime/product lineage, exact raw stdout and source equality. Its sole build-binding change is explicit: the native emission receipt says `build: not-requested`; the separately complete N2 receipt must bind the native product as both input and actual QBE command argument. The prebuild comparison receipt is also required and pinned. It does not claim that the emission-only receipt built N2.

After this full comparison passes, equal completed N1/N2 assembly and object files are hardlinked after SHA256, byte and metadata checks. N2 focused19 and full45 then run unchanged. Unequal machine files remain intact; no ELF equality or compiler fixed-point claim is made.

The old native06 products occupied 93,049,182 bytes of QBE and 104,212,115 bytes of assembly/object/binary. Staging would free the duplicate QBE before N2 build, and the equal assembly/object afterward. These are historical sizing observations, not guaranteed future output sizes. The new checkpoints record actual counts and free bytes.

`staging-review01.json` pins the adapter review and selected plan. Preparation and review were data-only; root owns all compiler/target execution. The 4200-second bound retains CPU3, 6 GiB RSS, 16 GiB available and 128 MiB per-file limits.
