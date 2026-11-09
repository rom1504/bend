# Phase183 — assembly as a maintained compiler target

Authorized objective: migrate the Bend-written AMD64 SysV assembly backend to
upstream 2.0.40 and make it a first-class installed compiler target alongside
JS, C and QBE. Baseline `4aa31ac`; upstream remains `9a4223d`. This is target
integration and qualification, not a new performance-parity campaign.

## Contracts and implementation

1. Add a maintained `x86` source profile from the same module tree. Its explicit
   additive backend modules and conservative declaration closure must preserve
   exact declaration bodies. Independent source checking remains mandatory.
   Existing QBE, native-C and JS profiles must remain byte-identical.
2. Use `native-x86-source-v1` and `--target x86` in the ordinary request/build
   tools. The Bend entry accepts source/Base, live or authenticated-cache mode,
   carrier and stamp. Runtime invocation comes from each actual image/provider.
   Emission is GNU assembly; assembler/linker construction has no QBE machine
   stage. No host-language compiler or generated-QBE parser is introduced.
3. Integrate finite qualification, native benchmark acquisition/execution,
   assembly inspection and profiler source ownership. Keep historical formats
   readable and benchmark definitions/oracles unchanged. Runtime ABI11102 is
   explicit; it is not inferred from the backend name.
4. Add an installed assembly component with its own profile source identity,
   checked lineage, independent execution gates and native reproduction.
   Existing JS/C/QBE component identities and qualification remain intact.
   Expose an unambiguous public assembly command; never emit an ELF silently
   under a requested assembly filename.
5. Document x86-64 SysV, sequential CPU/runtime/foreign limits, entry points,
   qualification and measured costs. The historical roughly2× execution deficit
   is not magically resolved by integration; do not rebrand it as parity.

## Gates and execution order

- Metadata first: unchanged three source profiles, closed extension inventory,
  negative image/protocol/runtime/asset controls and native target routing.
- Independent current-upstream source check; acquire the x86 compiler using the
  qualified Phase182 native QBE compiler and current Base/runtime assets.
- Reuse17 machine ABI and10 namespace controls with current checked authorities.
  Run focused native source/output and current-runtime controls before broad work.
- Run the unchanged current64 catalog (focused19 plus ordinary45) through the
  new maintained x86 route. Unsupported and failed cases cannot count as passes.
- Actual same-source seed→N1→N2 native assembly reproduction, including complete
  emitted assembly/object comparison and independent execution on the successor.
  Whole ELF identity and loaded-section identity remain separate observations.
- Exercise installed source/asset verification and public commands from a fresh
  bounded checkout. Preserve the old qualified compiler until admission succeeds.
- Record generated-program behavior, compiler emission/build clocks, native
  self-compilation, memory, disk and agent/metadata effort separately. At least a
  small real compiler workload compares QBE-built and assembly-built execution
  on identical source and requests; broad runtime ratios require a separate run.

## Cost and resource discipline

One root-owned CPU3 execution lane; bounded agents handle independent modules,
metadata and audits. Every target job has the existing process/disk guard and
5GiB reserve. Freeze code before target measurements. Small gates precede full
native acquisition; retain failed attempts. Current disk headroom is tight:
first deduplicate byte-identical immutable Phase182 IR/assembly/object files,
retaining every path and exact bytes with a comparison journal. Keep installed
images, runtime assets, rollback and scientific evidence. No age-based deletion.

Commit the design, implementation and final evidence. A source profile, a working
image, finite qualification and installed promotion are different milestones;
report unfinished scope honestly rather than calling experimental output first
class prematurely.
