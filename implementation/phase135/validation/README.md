# Phase135 full compiler edit: validation evidence

The existing native session successfully compiled both complete compiler
revisions, retained optimization state and reproduced both independently frozen
107 MB QBE products exactly. This establishes full-workload correctness and
bounded observed memory for this edit. The completed equal-image ordinary B
baseline shows **no net cache speed benefit**: warm B took 374.922 seconds,
versus 364.183 seconds for the ordinary cache-free request process.

## Completed full session

[Result](full01/full-session01/report.json),
[frozen plan](full01/full-session-plan01/plan.json),
[resource guard](full01/full-session-guard01/process.json), and
[compact archive](full01/archive.json).

| Observation | A: initial compiler | B: edited compiler, retained cache |
|---|---:|---:|
| Complete request interval | 362.510 s | 374.922 s |
| Prior inline hits | 0 | 1,387 |
| Inline misses | 1,507 | 120 |
| Prior range hits | 0 | 1,387 |
| Same-request range hits | 556 | 7 |
| Range misses | 951 | 113 |
| Complete QBE bytes | 107,059,385 | 107,059,557 |
| Independent product identity | Exact | Exact |

B reuses 92.0% of the private inline units. This is a count of admitted units,
not a claim to eliminate 92% of compilation. Parsing/checking, preparation,
other lowering, key comparisons, independent final verification and rendering
remain. No source or runtime code was changed to obtain this observation.

Shared preparation took 0.318 seconds. Complete native process wall time was
737.793 seconds and process CPU was 737.428 seconds. Peak child RSS was
1,035.9 MiB; the outer process-tree guard observed approximately 1.105 GB, below
its 4 GiB ceiling, while maintaining the 16 GiB available-memory floor. Total
supervised wall time, including identity checks and report handling, was
741.526 seconds.

The source edit is exactly the previously checked Phase132 change: the compiler's
`p111q_main` emits local `%answer` instead of `%result` at two locations. Every
other source byte and total source length are preserved. Both actual historical
source paths were retained; no path or generated-QBE normalization was used.
The [design contract](../../../design/phase135/edit-contract.md) explains why
the one-declaration edit is known to cause nonlocal pool/binding churn.

The two source versions are the historical Phase131 compiler and its Phase132
edit, compiled by the fixed experimental Phase134 session image. This is a real
full compiler workload, but not a claim that the latest source now has a fully
incremental self-hosting loop. The experimental image is separate from the
qualified/installed core.

## Performance interpretation and same-image baseline

A and B differ in source, retained Base/cache state, allocation history and
ordering. Therefore B's 374.922 seconds versus A's 362.510 seconds is **not a fair
cache-versus-no-cache ratio**. It is a warning against equating hit rate with
speed, not proof of either gain or regression from cache adoption.

The completed ordinary-B measurement uses the **same executable**, same actual B
source path, runtime, carrier and independent full-QBE oracle. It calls the
original ordinary entry, whose shared compiler declarations and six-argument CLI
arm were checked unchanged. The result is independently byte-exact.

| Observation | Same-image ordinary B | Session warm B |
|---|---:|---:|
| Native wall time | 364.183 s, complete process | 374.922 s, B request interval |
| Native CPU time | 363.933 s | Not measured separately from A |
| Native peak RSS | 949.2 MiB | Not measured separately from A |
| Full QBE identity | Exact | Exact |

Warm B is 10.739 seconds, or 2.949%, longer in this single comparison. Its
interval excludes shared preparation and process startup/teardown, whereas
the ordinary measurement includes those costs. These differing boundaries do
not justify a precise causal cache-regression estimate, but they certainly
provide **no evidence of a net speed win**. No full uncached A+B session or
balanced full-source repeats were measured.

The ordinary measurement's outer guard took 369.653 seconds and peaked at
979.8 MiB for the full process tree. See its [native result](baseline01/p135-session-ordinary-b01/report.json),
[frozen plan](baseline01/ordinary-baseline-plan01/plan.json),
[resource guard](baseline01/ordinary-baseline-guard01/process.json), and
[12-file, 55,765-byte archive](baseline01/archive.json).

No whole-loop net gain, upstream ratio, machine-build saving, generated-program
runtime improvement or recursive acceleration is claimed from this single run.
The already-paid experimental compiler acquisition remains a separate Phase134
cost; the current full session itself costs more than twelve minutes.

## Reproducibility and next gates

The compact archive stores 18 receipt/method/contract files totaling 98,863 bytes.
It excludes both 107 MB generated outputs, APIs, assembly and binaries while
retaining their exact identities. It also verifies that the already tracked
Phase131 source gzip plus the two small before/after declaration files reconstruct
the edited source exactly. The archive does not silently duplicate or substitute
the original source or oracle.

The coming framed-machine experiment uses a separate bounded gate plan:
monolithic edited B versus independently cold and reused partitioned edited B;
exact current payload, successful producer status and cold/reused ELF equality;
then the historical three request oracles in two interleaved orders and six
ordinary program outputs. Identical generated QBE under the same downstream
tool/runtime policy supports code-quality preservation, not a fresh runtime
speed claim. That machine experiment is not part of the completed result above.

The [machine archive plan](machine-archive-plan.md) lists the bounded external
Phase130 request and Phase111 build evidence to retain after those gates finish.
