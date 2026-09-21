#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {typedReport} from './typed-report.mjs';
const project=path.resolve(import.meta.dirname,'../..');
const file=path.resolve(process.argv[2]||path.join(project,'tests/conformance/prototype-baseline.json'));
const report=JSON.parse(fs.readFileSync(file,'utf8'));
const rows=report.results,inv=report.inventory;
const count=(lane,status,ns)=>rows.filter(r=>r.lane===lane&&r.status===status&&(!ns||r.namespace===ns)).length;
const positive=inv.tests.filter(t=>!t.negative).length,negative=inv.total-positive;
const text=report.identity.adapter!=='unchecked-prototype'?typedReport(report,file):`# Compatibility matrix

This is a measured **${report.identity.adapter}** baseline, not a claim that the
full compiler has been ported. The corpus contains **${inv.total} tests** across
**${Object.keys(inv.namespaces).length} namespaces**: ${positive} positive and
${negative} with an \`Error:\` expectation. All files were inventoried; no test
was removed to improve the result. A test in the \`check\` or \`proof\` namespace
can fail during parsing, so namespace membership alone proves no checker rule.

Pinned upstream: \`${inv.revision}\`.
Run: ${report.started}–${report.finished}; ${report.host.node} on
${report.host.platform}/${report.host.arch}; ${report.options.jobs} workers;
${report.options.timeout} ms per isolated probe. Full-suite verdict:
**${report.complete ? 'complete' : 'incomplete'}**.

## Measured lanes

| Lane | Pass | Fail | Timeout | Unsupported | Hardware-gated | Observation only |
|---|---:|---:|---:|---:|---:|---:|
${['parse','check','interpreter','js','native','metal','cuda'].map(l=>`| ${l} | ${count(l,'pass')} | ${count(l,'fail')} | ${count(l,'timeout')} | ${count(l,'unsupported')} | ${count(l,'hardware-gated')} | ${count(l,'observed')} |`).join('\n')}

Parse passes cover positive syntax only. Negative parse observations are excluded
from pass counts. There are **${report.summary.checkerRejections} demonstrated
checker rejections**. The **${report.summary.uncheckedExecutions} unchecked JS
execution passes** establish exact output for those programs, not type/proof
soundness, and do not satisfy their missing checker/interpreter/native lanes.
GPU syntax executed sequentially in JavaScript is not GPU coverage.

## Every namespace

| Namespace | Total | Positive | Error expectation | Positive parse pass | JS eligible | JS pass | JS nonpass |
|---|---:|---:|---:|---:|---:|---:|---:|
${Object.entries(inv.namespaces).map(([n,s])=>`| ${n} | ${s.total} | ${s.positive} | ${s.negative} | ${count('parse','pass',n)} | ${s.jsEligible} | ${count('js','pass',n)} | ${s.jsEligible-count('js','pass',n)} |`).join('\n')}

Compiled eligibility follows upstream's \`gates/test.ts\`: a positive fixture
imports Base, declares main and has a matching foreign C/JS twin if applicable.
Other positive programs still require checking and interpretation. Import and
foreign fixtures are preserved in their original directory trees. Native and GPU
lanes remain visible even when unavailable; missing implementations never pass.

## Port obligations

| Area | Upstream implementation | Required equivalence | Baseline limitation |
|---|---|---|---|
| Syntax and elaboration | bend.ts parser, binders, terms, bodies, flattening | All accepted/rejected forms, source locations, patterns, dependent syntax | ${count('parse','fail')} positive parse failures |
| Core representation | bend.ts terms, quantities, persistent maps, contexts, substitution | Capture avoidance, binder identity, graded uses, definitional equality | Prototype syntax AST does not implement the trusted core |
| Evaluation | bend.ts weak/strong normalization and comparison | Open terms, type values, neutral terms, readback | ${count('interpreter','unsupported')} required interpreter probes unsupported |
| Checking | bend.ts inference, checking, kind fitting, datatype validation | Dependent types, affine quantities, recursion descent, holes, proofs | All ${count('check','unsupported')} checker probes unsupported |
| Modules and laws | bend.ts book loader, main.ts proof rules | Namespaces, dependency order, foreign signatures, LAWS/PROOF handling | Module and foreign imports not implemented by prototype |
| Erasure and specialization | comp.ts term analysis, templates, layouts, ownership | Type-directed live arguments, closures, borrowing, specialized templates | Prototype executable erasure is incomplete |
| JS backend | comp.ts JS emitter and runtime | All eligible outputs, effects, numeric/array semantics, readback | ${count('js','fail')} failures and ${count('js','timeout')} timeout |
| Native CPU | comp.ts C emitter and shared runtime | Reference counting, scheduler, arrays, closures, native foreign ABI | ${count('native','unsupported')} native probes unsupported |
| Metal and CUDA | comp.ts device code and GPU runtime | Actual device compilation and execution, ownership, synchronization | ${count('metal','hardware-gated')+count('cuda','hardware-gated')} hardware-gated probes; no GPU implementation |
| Base and effects | base.bend, effs/*.c, effs/*.js | Complete library and backend-specific effect behavior | Runtime provides only a subset |
| CLI and tooling | main.ts | Checking/running/emitting, import loader, report rendering | Conformance adapter is separate from end-user CLI |
| Mechanized theory | bend.lean | Specification reference, not an executable compiler target | Not claimed ported or reverified |

## Source inventory

| Upstream source | Lines | Exported declarations |
|---|---:|---:|
${inv.sources.map(s=>`| ${s.file} | ${s.lines} | ${s.exports.length} |`).join('\n')}

The JSON inventory includes all exported names and source SHA-256 hashes,
**${inv.effects.length} backend effect files**, and **${inv.fixtures.length}
non-Bend support fixtures**. Benchmarks, demos, documentation generation and
cluster/performance gates are outside the 1,378-test compatibility corpus; test
success alone would not establish performance parity, hub/publishing behavior,
installation/release parity, or verification of the Lean development.

## Reproduce and extend

Run \`node tools/conformance/run.mjs\` with \`BEND_UPSTREAM\` pointing to the
pinned checkout. It intentionally exits nonzero for this incomplete baseline.
See \`tools/conformance/README.md\` for adapter contracts, separate frontend/core/
backend adapters, timeouts, hardware gating and selected development runs.
The full evidence is \`tests/conformance/${path.basename(file)}\`.

Compiler SHA-256: \`${report.identity.compilerSha256||'see adapter provenance'}\`.
Runtime SHA-256: \`${report.identity.runtimeSha256||'see adapter provenance'}\`.
`;
const output=path.join(project,'docs/COMPATIBILITY-MATRIX.md');
fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,text);
console.log(output);
