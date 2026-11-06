# Phase170: integrate and install the qualified fast compiler

The user authorized promoting Phase169 into the maintained compiler, with working
interfaces and a retained rollback. This phase is integration and qualification,
not another optimization campaign.

## Findings before integration

HEAD starts at `858d738fd155a0919696bdffab6e8a81bb47820e`.
Phase169's qualified image compiles an extracted ordinary-request source. Its
147.764-second self-build is not a promise for the larger maintained compiler
with session and public interfaces restored. Its same-source full canonical
build was 185.190 seconds versus 244.461 seconds for the reference.

The installed selector already fails verification: its maintained source recipe
pin is stale. The installed QBE component also predates the Phase152 research
reference. The public native launcher emits C; QBE is a separate component.
Simply copying the Phase169 executable would leave these contracts inconsistent.

## Implementation

Import the 144 live added declarations from the qualified Phase169 source into
the maintained modules. Preserve their checked bodies. Replace the two live
shared implementations (`p128bs_eligible`, `p143cb_resume_state`) and route only
ordinary native QBE requests through the qualified path. Keep the maintained
argument dispatcher and its existing session/batch implementation. Keep the
hosted JS/C API and existing hosted QBE interface.

Do not replay experiment overlays during normal builds. Refresh the maintained
source inventory; preserve all protected proof/verifier declarations. The
ordinary request entry is itself inventory-protected: update only its pin for
the explicitly authorized routing change, recording the old and new identities;
the other 111 protected declarations remain exact. Do not
claim the smaller experimental source is the full canonical source.

## Gates and installation

1. Assemble the maintained canonical source; independently check it. Audit the
   exact declaration delta and protected bodies.
2. Build actual native N1/N2 from this source using the qualified Phase169
   producer. Check self-reproduction and ordinary native correctness. Exercise
   the retained interfaces separately; a build success is not a session gate.
3. Build genuine JS B2/B3 from the same frozen canonical source, with a fresh
   source check and exact B3/B2 equality. Changes shared with JS/C require this;
   old binaries must not be relabeled as current.
4. Derive the public C CLI profile using the existing two permitted body
   replacements, acquire its build-only native bridge, emit C, and construct
   the public package with the unchanged Clang policy. Run independent public
   behavior and target qualification controls.
5. Bind exact sources, images, providers, lineage and independent qualification
   reports in the existing release transaction. Audit first, install selector
   last, retain old files for rollback, and verify installed launchers.

Preserve generated-program evidence. Compare candidate emissions with qualified
Phase169 products where meaningful, and run execution gates on actual native
products. Reuse qualified runtime/toolchain identities. Distinguish finite
tests, source checking, self-reproduction and mathematical proof.

## Resource and cost discipline

Use one guarded CPU3 target lane. Keep the five-GiB disk reserve, bounded RSS,
fresh outputs, independent oracles, and close every run. Reclaim only the eight
previously authenticated Phase169 pairs of assembly/object files after fresh
selective archive verification. Preserve sources, IR, images and evidence.

Freeze source and acquisition inputs before bootstrap. Rebuild JS and the public
C package because their installed source bindings are stale; do not change the
release contract to bypass this work. Long machine construction can run while
documentation and receipt audits proceed. Record actual integration cost and
any failed gates. Commit and push the maintained implementation, reproducible
evidence and an honest installation report.
