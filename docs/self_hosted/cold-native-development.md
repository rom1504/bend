# Cold native compiler development

[Phase143](../../implementation/phase143/README.md) is the latest explicitly
qualified ordinary-native checkpoint. It preserves Phase140–142 incremental
experiments and the selected Phase137 fallback. It does not install or silently
select a new compiler.

Use the exact source/image/runtime/Base identities in
[candidate.json](../../implementation/phase143/candidate.json). The native N2
image is `selfhost/build/phase111/p143-integrated-n2/program`; its independently
checked source is `selfhost/build/phase143/integrated-source03/compiler.bend`.
The existing ordinary native entry consumes source, Base and the authenticated
compact carrier. `phase130/native-request.py` handles its precise argv contract
and complete output verification.

Cold here means a fresh native process without source-specific semantic, edit or
machine-object state. A prebuilt compiler/runtime and immutable prepared Base
are named inputs. Acquisition is separate; OS caches are not flushed. Time the
whole compiler request, QBE, assembly and linking. Do not substitute an
incremental session's cold-seed stage or an old JS-target emission time.

The measured same-source request falls374.7→296.5s. Complete target operations
fall390.3→311.8s; including supervision and verification gives394.0→315.3s.
Peak compiler RSS stays about1.07GB. The150s and smaller milestones remain open.
Three small-input native pairs per family find no material latency regression.
Generated QBE is identical on the full compiler input and all frozen native
products; this is not a new broad runtime benchmark or a compiler theorem.

Start experiments with the finite controls and real-request screens in the
[Phase143 tool guide](../../selfhost/tools/performance/phase143/README.md).
One CPU3 target lane,3GiB tree RSS cap and16GiB available floor prevent accidental
parallel acquisition/OOM. Host observers must not become alternate compilers.
The paired small-request runner creates its own per-job guards: do not nest an
outer execution guard around it.

For profiling, reuse the generic profiler and retained machine object. The
[ordinary profile](../../research/phase143/cold-profile.md) distinguishes physical
leaves from active Bend owners. The new
[milestone probe](../../research/phase143/milestone-pilot.md) relinks a small
diagnostic runtime to the same object and checks exact, unique ordered entries.
Missing or repeated markers invalidate attribution. Sampled/diagnostic clocks
are not clean speed measurements. Keep full output checks and independent final
verification enabled.

The new checker is used only when a suffix contains at least256 eligible
childless definitions. This is an empirically conservative profitability gate;
semantic legality and fallbacks remain separate. Small requests take the original
checker. A source-level optimization should preserve that distinction instead
of adding another cache from hit counts alone.
