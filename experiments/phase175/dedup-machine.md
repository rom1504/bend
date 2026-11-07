# Exact deduplication of closed Phase175 generated products

The adapter `dedup-machine.py` prepares a separate verification receipt and, only
when explicitly invoked with `apply`, journals atomic hardlink replacement of
identical generated products. Preparation performed static syntax checking only:
**no real-product verification, replacement or compiler execution was run**.

Final adapter SHA256:
`a2738aa1057f0614ca74b11bab3359d379c9634b4ed0bed990a7a00e79db7dc5`.

## Existing implementation reused

Phase146's `dedup-native-v01.py` at commit `8bd91d2` already used separate
verify/apply receipts, literal comparison, durable intents and atomic hardlink
replacement for N1/N2 assembly and objects. Cleanup retired that one-campaign
implementation; its completed receipts remain under `selfhost/build/phase146`.
The current profiler deduplicator supports exact profiler stdout/stderr, not
modern native build reports, so calling it directly would require misrepresenting
these artifacts as profiling results.

The small adapter uses the maintained `archive-v02.py` execution lock, stable
pinning and durable receipt writer plus `build/common.py` literal comparison.
It adapts the original journaled replacement sequence to current build and
request receipts. It does not modify those maintained tools.

## Admission and limits

Both writers must be complete, successful and sealed, with `process.json` and
`retention.json` in each sibling `<build>-guard` directory. Native producers must
have successful compiler/QBE and assemble/link exits. Request-only producers
must have a successful child and an independently expected, byte-exact product.
No hashing or replacement should overlap target execution; the shared lock
refuses concurrent ownership.

Only explicit report fields are accepted: `assembly` (`program.s`), `object`
(`program.o`), `retainedIR` or request `product` (both `program.ssa` in the current
QBE tools). Paths must be direct leaves of their declared build roots, with no
symlinks, xattrs, special permissions, different owners or cross-device links.
The right-hand duplicate must be under Phase175. Both original receipt hashes
and literal bytes must match. Unknown inode aliases are refused. Exactly two
already-linked paths are supported, allowing an interrupted two-file campaign
to be reverified with a fresh receipt.

At least 5 GiB plus 1 MiB receipt allowance must be free. Dedup itself needs no
archive or large copy. Recovery is the duplicate's allocated blocks, less small
new journals; it is not the sum of file lengths. Every original artifact path,
byte identity, permission and report remains valid. **Inode, mtime and ctime are
shared. Both paths must remain immutable; all future builds use fresh roots.**
Any earlier inode-bound pruning plan for these leaves becomes stale and must not
be reused. No executable, runtime, source, API or installed selector is eligible.

This is storage maintenance, not evidence of semantic correctness or native
fixed-point qualification. The compiler qualification remains independently
required. The adapter does not infer equality from generations or common source.

## Native N1/N2 assembly and objects

Run only after both writer guards close:

```sh
python3 -B experiments/phase175/dedup-machine.py verify \
  --left-report selfhost/build/phase175/full-native-n1/report.json \
  --right-report selfhost/build/phase175/full-native-n2/report.json \
  --out selfhost/build/phase175/dedup-native-verify01.json

python3 -B experiments/phase175/dedup-machine.py apply \
  --left-report selfhost/build/phase175/full-native-n1/report.json \
  --right-report selfhost/build/phase175/full-native-n2/report.json \
  --verified selfhost/build/phase175/dedup-native-verify01.json \
  --out selfhost/build/phase175/dedup-native-apply01.json
```

Both fields are selected by default. Apply requires the exact unchanged verified
metadata and method identities, writes a durable intent before any replacement,
then journals each replacement. It reauthenticates original reports and both
products afterward. If interrupted, inspect the intent/journal and run fresh
verification before another explicitly reviewed apply; do not blindly reuse the
old verification receipt.

## Q3 request product versus N1 retained IR

`request.py` uses `program.ssa` for QBE, despite the product being QBE text.
After Q3 has actually executed, independently compared its expected bytes and
closed its guard, use the same command shape with:

```text
--left-report selfhost/build/phase175/full-native-n1/report.json
--right-report selfhost/build/phase175/full-native-q3/report.json
--pair retainedIR:product
```

Use fresh `dedup-q3-verify01.json` and `dedup-q3-apply01.json` receipts. The N1 IR
has not been included in assembly/object dedup, so it initially has one link.
This could recover roughly one emitted IR's allocation; report the measured
value, not a fixed assumed 94 MiB.

For a future cold fixed-source build, an existing Phase174 fixed-baseline
**completed modern build report** may be the left keeper and the new Phase175
build the right duplicate. First compare their report hashes cheaply. If only
one product matches, explicitly select `--pair object:object` or
`--pair assembly:assembly`. Hash mismatch rejects the attempt. A keeper already
shared with an additional third path is deliberately refused; handling a wider
alias group needs another explicit review rather than silently broadening scope.

## Recovering independent storage

All data remains at both original paths, so executing, inspecting and relinking
requires no archive restore. If independent writable storage is later required,
allocate enough room for a complete copy, take the shared lock, authenticate both
current products, copy the duplicate to a fresh exclusive temporary inode,
verify its exact bytes/mode, and atomically replace only that duplicate. Record
an intent and journal as in the original Phase146 `split` operation. This adapter
does not expose split because current builds must use fresh directories and no
in-place rewriting is planned.
