# Phase190 supplementary evidence

This packer freezes a separate, metadata-only supplement. It does not modify
`../evidence/`, run a compiler or target, or infer qualification from a successful
process. The raw reports retain their original scopes, failures, timings, source
identities and tool identities. Raw oracle stdout/stderr are retained verbatim.
The failed `broad-runtime01-guard` receipt is intentionally included.

From the repository root, inspect the explicit selection and pending inputs:

```sh
python3 -B implementation/phase190/qualification-evidence/pack.py
```

After the pending native generation, acquisition, runtime and comparison jobs
finish and the desired guards have been closed, create the supplement once:

```sh
python3 -B implementation/phase190/qualification-evidence/pack.py --pack
python3 -B implementation/phase190/qualification-evidence/pack.py --verify
```

The default selection is the `ROOTS`, companion guard roots, and `EXTRA` constants
in `pack.py`. Add a specifically named phase190 receipt root with
`--include-root NAME` if necessary; unrestricted recursive phase190 discovery is
not used. Authenticated close-receipt links from selected retention records are
included automatically. Missing required reports or still-running guards block
packing; failed but finished guards remain evidence. Default planning writes
nothing. Existing archive/inventory outputs are never overwritten.

For an exact replay, while the original receipt files remain available:

```sh
python3 -B implementation/phase190/qualification-evidence/pack.py --pack \
  --selection implementation/phase190/qualification-evidence/inventory.json \
  --out /tmp/phase190-qualification-repacked01
python3 -B implementation/phase190/qualification-evidence/pack.py --verify \
  --out /tmp/phase190-qualification-repacked01
```

`inventory.json` records the packer hash, archive hash, and every original/member
path, byte count and SHA-256. Tar metadata and gzip timestamps are fixed, so an
unchanged selection reproduces the same archive bytes. Verification does not
extract or execute anything. Archive and inventory together have a default 4 MiB
budget, checked before writing; source evidence changing during packing rejects
the snapshot.

Compiler source, API modules, binaries, objects and `source-map.json` are omitted.
The selected source identity survives in the independent source-check and native
request/build receipts. Nested runtime JSON is omitted because the root runtime
report retains each observation; raw stdout/stderr remain included. Static
assembly and the local-pair interpretation are included as bounded evidence,
not dynamic counts or causal proof of the heldout regression. The first capsule
is neither included again nor superseded. This is portable evidence for the
specific reported runs, not a standalone toolchain or a claim that every finite
lane establishes full conformance, independent kernel proof, or promotion.
