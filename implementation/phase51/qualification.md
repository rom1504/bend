# Phase51 qualification and retained failures

The selected candidate is `checked-candidate01`, a checked B1 derivative with
API `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061`
and runtime `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
The upstream pin is unchanged. Build plus focused strict validation took 53.48s,
with zero exact differences. No new self-emitted fixed point is claimed.

## Checks on actual checked output

- String proof controls: 11 observations on each of Unicode, Map churn and
  records. Full values, event order, error identity, argument getter mutation,
  reentry, dependency/code/call getters, host changes and restoration agree.
  Admitted ordinary entries make one String check instead of two.
- Application controls: 27 observations, including repeated accessor reads,
  IO late capture, argument ownership, partial/overapplication, trampoline
  behavior and exact-entry permission. These pass on the actual Evening output.
- Existing exact-entry suite: six host-hook observations.
- Nullary demand suite: six values, 39 boundaries, nine metadata observations
  and six activation observations.
- Array view suite: 24 values and 39 boundaries. Array tree suite: 159 values
  and 11 boundaries. Their original historical ordinary-path baselines remain;
  the current compiler is not silently substituted for those oracles.
- All eight maintained suites pass, including 37 IR checks, 1,129 primitive
  guard cases, 25 related observations and constructor-provenance controls.

These inventories overlap. They are not a count of additional unique language
tests. Earlier prototype executions remain distinct from checked-output tests.
All 24 emitted libraries match the prior RNFA04 body except the expected token
argument at 28 contextual sites in 13 libraries, plus the shared runtime changes.

## Backend census and native retry

The resolved census has exact historical agreement on **81 outcomes: 69 execution
passes, eight N/A and four shared failures**. Sixty outcomes come from the first
run; 21 native outcomes come from a targeted retry. This is explicitly joined
evidence, not a claim that the first run passed all 81 outcomes.

The first run's 17 otherwise executable native cases failed in both roles because
the sandbox refused the pinned Clang process (`EPERM`). Their equal diagnostics
did not qualify them as passing: the historical census gate correctly failed.
Only that native batch was rerun with execution permission and the same bounded
resources. All 21 native outcomes then matched their historical expectations.

`semantic-qualification01.json` records the resolution without altering the
failed `qualification02` receipt. The join checks the same historical observation
fields as the frozen backend runner, selected image identities and all consumed
inputs. No frontend inventory or full native/GPU conformance is renewed here.

## Other failures preserved

1. The first isolated-source preparation had an incorrect repository parent
   index. It stopped before creating source output; the corrected producer made
   the candidate used thereafter.
2. The first actual-output dispatch binding used an unescaped JavaScript
   replacement string containing dollars. The controller rejected the binding
   before any semantic observation. A new receipt producer escapes literal
   dollars; original receipts, producer and controller remain unchanged.
3. The first semantic queue inherited CPU0 affinity, while its child guard
   requires CPU3. Preparation refused before executing a target. The unchanged
   queue was rerun with an unpinned parent; children select CPU3 themselves.

These are setup/evidence failures, not compiler counterexamples. The batched
String guard and larger dispatcher variants are separate rejected or unselected
performance experiments, retained in their respective reports.

All generated-code and compiler execution used CPU3, pinned Node24.18.0,
a 1GiB heap, a polled 2GiB process-tree RSS ceiling and a 4GiB memory floor.
Targets ran serially. Build peak tree RSS was about 1.37GiB. Installation,
CLI checks and portable replay are reported separately in the phase summary.
