# Frozen String fixture controls

`fixture-catalog-v1.json` pins source identities and independent bench(0,0) values.
Prepare each source using the original checked16 compiler and the actual candidate
compiler with the repository checked preparation workflow. Preserve the .mjs.json
receipt beside each resulting module; the instrumenter verifies the receipt and
all compiler/source hashes. Run from repository root, with fresh output paths:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
"$NODE" selfhost/tools/performance/phase43/strings/source-instrument-v4.mjs \
 "$BASE_MODULE" "$CANDIDATE_MODULE" "$FRESH_DIAGNOSTIC_DIR"
"$NODE" selfhost/tools/performance/phase43/strings/fixture-controls-v2.mjs \
 "$FRESH_DIAGNOSTIC_DIR/original.mjs" "$FRESH_DIAGNOSTIC_DIR/full.mjs" \
 "$CONTROL_KIND" "$FRESH_REPORT_DIR"
```

CONTROL_KIND is renamed for either typed-components source, negative-literal0 for
the computed nullary source. Root supplies bounded execution and serial CPU jobs.
The instrumenter discovers actual functions and entry scopes with AST traversal;
its lexer adapters are never called by fixture-controls. Activation checks require
the complete outer graph entry, rather than counting isolated inner workers.
Negative-literal0 may activate count.chars independently, but bench/rows must stay
generic. The renamed controls exercise aliases, custom String fields, nested
SCon/Chr patterns, exact nullary literals, astral code points, and renamed graph
identities. Type-control malformed-header tests remain a separate compiler proof
refusal diagnostic; these fixture sources are valid Bend.
