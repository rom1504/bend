# P128-001: borrowed scalar observations and helper composition

Status: integrated source native-qualified; see final results below. The initial
checkpoint paragraphs retain their original limited scope.

Hypothesis: the consuming traversal of compiler names performs ownership work
that is unnecessary while a caller retains its owning roots. A scalar result
cannot carry borrowed storage outside that lifetime.

The existing NO analysis already accepts `p88_string_eq_go`, but its root-return
adapter excludes the Bool result. The checked scalar adapter admits nonowning
results, holds roots through private-reader execution, and retains the original
owning fallback behind a conservative runtime ownership guard. The transformation
contains no benchmark-name recognition.

Independent controls cover roots, aliases, descendants, result/argument/state
contracts and original verifier obligations. The second experiment composes
private readers via source-derived summaries; it never passes borrowed data to
an ordinary owning helper. Original-position fallback insertion retains direct
dependencies, with complete final verification from an empty ready set.

See [checkpoint01](../../implementation/phase128/checkpoint01.md) for measured
results and limitations. The extracted computation nearly doubles in speed;
this is not yet a native compiler or broad-suite claim. Held-out transfer,
analysis overhead and native self-reproduction decide promotion.

## Final status

The scalar capability now composes verified helper calls and concrete nested
layouts. An exact thin-wrapper equation restores calls bypassed by earlier
inlining. Together with the later field template, the frozen kernel improves
1.490729 → 0.368798s (4.04×), with independent owning fallback and transfer checks.
The integrated source is native-qualified. Compiler requests improve 21.16%
versus Phase126; broad program runtime improves4.72%, so the kernel ratio must
not be generalized to compiler throughput. See the [final Phase128 report](../../implementation/phase128/README.md).
