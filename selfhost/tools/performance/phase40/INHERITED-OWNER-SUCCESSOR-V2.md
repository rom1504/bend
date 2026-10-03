# Inherited owner closure v2

The consumed v1 closer/spec/mapping remain unchanged. V2 retains every v1 closure
assertion and pins two diagnostic successors: the repaired tail control (same
13/19/1 observations), and a unary helper-name decoder repair (all original unary
values, aliases, order, admissions, refusals and boundaries unchanged).

The unary failure occurred before any oracle: the old decoder treated the suffix
of a distinct `$R_<decimal>...$tree` helper as a numeric code point. The successor
recognizes only complete ordinary decimal helper names and leaves suffixed helpers
distinct. Static checked06 output retains the ordinary private unary worker in
each guarded root's primary branch; the structural helper appears in its fallback.
This repair changes diagnostic name parsing, not compiler output or admission.

Unary successor SHA:
`ae6ff69462e94956d452a5a7ff308a06ad21b80973dbd41f0cf3389b7643927e`.
Tail V2 SHA:
`abaffeaf752e9c5356ff139e5f9172a2fd6f7279b32007ead4072f5cb8603b1c`.
Both predecessor hashes are mandatory in the closer. The exact original failures
remain in `phase39-owners02/unary/report.json` and `inherited-component-tail03`.

Root-only serial controls, under the existing bounded Node resource settings:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase40/unary-compiled-controls-v1.mjs \
  selfhost/build/phase40/phase39-owners02/cohort-unary/unary \
  selfhost/build/phase40/inherited-unary-controls03

node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase40/component-inherited-tail-controls-v2.mjs \
  selfhost/build/phase40/inherited-component-derived03 \
  selfhost/build/phase40/inherited-component-tail04
```

The mapping expects bounded receipts respectively in
`run-inherited-unary-controls03/run.json` and
`run-inherited-component-tail04/run.json`. The successful component derivation and
original controls03 are reused unchanged. After the controls pass, supervise:

```sh
python3 selfhost/tools/performance/phase40/inherited-owner-close-v2.py \
  selfhost/build/phase40/checked06 \
  selfhost/build/phase40/inherited-owner-mapping04.json \
  selfhost/build/phase40/inherited-owner-close04/report.json
```

Python closer syntax and exact pins were checked. No target was executed by the
evidence owner; root validates the fresh control reports and closure.
