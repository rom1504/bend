# Frozen String fixture controls

`fixture-catalog-v4.json` pins source identities and independent bench(0,0) values.
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

Preparation command (supply a fresh output and the intended checked attempt):

```sh
python3 selfhost/tools/performance/programs/prepare.py \
 --attempt "$CHECKED_ATTEMPT" --role baseline \
 --catalog selfhost/tools/performance/phase43/strings/fixture-catalog-v4.json \
 --set full --out "$FRESH_PREPARATION_DIR" --node "$NODE" --cpu 3
```

Candidate preparation substitutes --role candidate and candidate CHECKED_ATTEMPT.
Each module is PREPARATION/modules/<source-stem>.mjs. v1 is preserved as a failed
consumed handoff; v2 adds the full standard preparation catalog schema.

V3 catalog uses fresh *-v3.bend filenames with duplicated seed arguments explicitly
quantity2 (+seed). Source originals consumed by failed baseline preparation remain
unchanged. Expected values and controls are unchanged.

V4 additionally uses +depth:Nat; its quantity propagates to predecessor p just as
working historical lexer batch(+d:Nat,+i:U32), with ordinary case1n+p.
