# Phase126 native checkpoint

The selected source32 is **native-qualified**, with no installed selection change.
Hosted emission and N1 self-emission produce exactly99,526,466 QBE bytes, SHA256
`7aa7d259bdaf445713ee07f5b076a1435dd3a7387a4443506dca838e2c946804`.
N1 and N2 each pass focused19; N2 passes all45 one-shot programs.

[Machine-readable evidence](native-results.json) pins the plan, authenticated
aggregate and actual comparison. The completed first four jobs are reused after
a storage refusal; the report does not pretend they ran twice.

| Completed obligation | Seconds |
| --- | ---: |
| authenticate-plan | 0.52 |
| full-hosted-integrated-emission | 845.57 |
| n1-build | 13.89 |
| n1-focused19 | 26.16 |
| storage-after-n1 | 2.02 |
| native-self-emission-only | 511.06 |
| storage-before-n2 | 2.82 |
| n2-build | 14.34 |
| exact-hosted-native-qbe | 2.87 |
| dedup-completed-machine-artifacts | 2.87 |
| n2-focused19 | 23.18 |
| n2-original-full45 | 126.56 |

The two outer guards use **26.27 active minutes**;
maximum process-tree RSS is **5.502 GiB** under the6GiB cap.
The first guard ends at its storage checkpoint after successful emission, N1
build and focused checks. Its failed status does not mean those14.8 minutes were
discarded. The resume retains that receipt and all completed product identities.
The storage interruption and read-only analysis time are additional campaign
wall time, not compiler execution.

The actual hosted emission takes845.57s and native self-emission511.06s. These
compile a larger compiler source than Phase125; they measure acquisition cost,
not a fixed-source N1/N2 throughput improvement. The full compiler QBE grows
93,049,182→99,526,466 bytes (+6.96%). Native request timing is a separate gate.

After the original reserve refused, exact duplicate historical test snapshots
were hardlinked only after SHA256, byte, ownership, mode, device and mtime checks.
The first six recovered11,550,720 bytes; a later bounded set recovered418,938,880.
All file paths and contents remain. Completed QBE and machine artifacts are also
deduplicated only after their independent equality checks. The post-N1 restart
uses actual staged storage needs while retaining CPU3,6GiB RSS,16GiB available,
128MiB per-file limits and the same semantic gates. See the
[storage and resume audit](../../selfhost/tools/performance/phase126/native/README-resume.md).

This checkpoint does not claim ELF identity, N2→N3 self-emission, GPU/parallel
qualification, full-language proof or recursive research acceleration. Native
one-shot45 correctness and hosted-emitted timed batch45 runtime remain distinct.
