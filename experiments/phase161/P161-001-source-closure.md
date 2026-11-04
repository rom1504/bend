# P161-001 — does 45% less source materially reduce acquisition work?

Hypothesis: a target-main source closure removes meaningful parse/check work
while preserving the same runtime compiler. Prior exposure:3,085,157→1,697,879
source bytes,8,265→5,007 rows, no mapped runtime owners lost, independent source
check passes. This is not yet an output-equivalence or performance result.

Keep the same Phase156 QBE executable and original `old` request route. Run
closure then full input, fresh processes, same live Base, CPU3, exact runtime and
write protocol. Compare complete output to independently qualified118,227,421
QBE bytes. A changed output is preserved and reconciled, not relabeled a pass.
Measure whole-child CPU/wall/RSS and subsequent machine cost only where necessary.

If closure output is exact, the compiler executable product can be reused under
the frozen machine policy; its execution speed has not changed. Savings then
come from input preparation or compiler work, not a faster compiler algorithm.
Use paired stage evidence to locate them. If the saving is small, prioritize
the surviving representation/optimization work rather than more line removal.
