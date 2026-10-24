# Compact machine-gate evidence plan

Archive only after the native session, independent cold replay, machine comparison,
monolithic B build and bounded semantic gates have closed their writers. A failed
attempt stays failed; retain its receipt and diagnostics alongside the later run.

Use `selfhost/tools/performance/phase135/machine/archive-v01.py`, whose default
`selfhost/build/phase135/machine-*` roots already include the framed source
snapshots, smoke, native acquisition guard, full machine-session receipts, replay,
comparison and gate-plan/execution receipts. The tool also archives machine,
preparation and validation methods. It excludes `.ssa`, assembly, objects, ELF
images, frame payloads and hosted APIs. Exact product identities remain in the
receipts; successful producer and replay joins remain distinct from machine-only
success.

Add these explicit `--root` directories:

- `selfhost/build/phase135/monolithic-b-plan01`
- `selfhost/build/phase135/monolithic-b-guard01`
- `selfhost/build/phase111/p135-monolithic-b01`
- Every unique parent of `requests[].report` in the frozen machine gate plan
  (18 request directories under `selfhost/build/phase130`).
- Every unique parent of `ordinary[].report` in that plan (six ordinary build and
  output directories under `selfhost/build/phase111`).

Derive these last 24 paths from the actual frozen plan. Do not use a broad glob
across Phase130 or Phase111, and do not include generated source or machine output
merely because it shares a prefix. The metadata whitelist preserves request
reports, build reports, emitted diagnostics, ordinary stdout, and tool commands;
ordinary timing is a semantic smoke observation, not a generated-program runtime
benchmark.

Before accepting the archive, confirm its source/method inventory, reopened member
hashes, and unchanged original inputs. Keep source-path identity intact: the
original Lexer fixture is used for the native FIFO smoke; the actual historical
Phase132 compiler edit paths are used for the full A/B experiment. The edited
compiler's three request gates use independent edited-main QBE oracles.
