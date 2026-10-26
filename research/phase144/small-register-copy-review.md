# Independent review: one/two-word register transfers

Source-only review found no semantic blocker to the optional specialization in
the existing x86-64 native ABI. No target execution or build was performed by
the reviewer. This is not a qualification or performance result.

| Artifact | SHA256 |
| --- | --- |
| `prepare-copy-v02.py` | `bac118b9180cc669c3ab77acef84b21d827377b8a16e77826faca7aa1f65802d` |
| `small-transfer02/runtime.c` | `597f1f24513ff571d5a65cc7cfb0bfc4e5adc4b7c9edb47f31cc6a87223a4d1b` |
| `copy-controls-v01.c` | `980886a901fcd7ab22dcb66cbb019ccb09b63226b214716c30f82f383398a55f` |

The actual candidate was reconstructed back to the exact serial-RFC parent:
removing the new macro definition and restoring the one replaced copy block
gives byte-identical original source. No other runtime logic changes.

For count1, an8-byte `memcpy` loads a local u64 before the destination store.
For count2, a16-byte `memcpy` fills a local two-element u64 array before either
destination store. This preserves the original `memmove` result when source
and destination overlap in either direction. It introduces neither `restrict`
nor a dereference of a potentially unaligned source. Other positive counts
retain the original `memmove`; count0 still reads no source bytes. The original
count/null checks precede all copying, and capability-dependent tail clearing
occurs afterward exactly as before. No ownership operation, ABI field or serial
worker-admission condition changes.

The proposed controls use a separate pre-call byte snapshot and compare the
entire state, including untouched header and tail bytes. They cover widths2,
26 and256, every admitted count, both clearing policies, external and overlapping
source positions, zero-count NULL, rejected positive-count NULL/oversize calls,
and protected-page source boundaries for exact read extent. These are meaningful
finite tests once executed, not a proof merely because they were prepared.

Byte-offset source casts exercise an extra empirical x86-64 property beyond the
compiler's aligned register-buffer ABI. They are not a portable C alignment
proof. Inspect actual machine instructions for exact8/16-byte, unaligned-safe
loads and preserve the distinction between the admitted ABI and these stronger
controls. Compare the disabled specialization's loaded code with the existing
runtime before interpreting timing; helper declarations can change compiler
layout even when source behavior is equivalent. Keep qualification and speed
claims separate, with the qualified serial runtime available as the control.
