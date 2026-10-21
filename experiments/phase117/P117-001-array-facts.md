# P117-001 — use existing scalar-array facts at access sites

Status: designed; candidate correctness and measurements pending.

Hypothesis: after checked scalar/unshared admission, scalar payload reference
operations are identities. Removing their repeated dynamic tests can reduce hot
loop cost while retaining runtime representation guards. Falsified by a lawful
scalar representation requiring those operations, output differences, or no useful
runtime gain after exact machine inspection. Fold128 and edit distance are the
initial diagnostic pair; other array and unrelated programs test transfer.

Parent and method: [design](../../design/phase117/array-facts-and-scalar-code.md).
Outcomes will be recorded in [report](../../implementation/phase117/README.md).

## Outcome

Selected scalar/layout/origin/versioning composition passes the original45; geomean5.308→4.240×upstream. The facts-only step was useful but smaller. See Phase117 report/results for ablations and compiler-cost tradeoff.

[Complete report](../../implementation/phase117/README.md) retains exact receipts and limits.
