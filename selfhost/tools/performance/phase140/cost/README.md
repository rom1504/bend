# Bounded cost inventory

This metadata-only tool reads exactly the two guard scopes:

- `selfhost/build/phase111/p140-*/process.json`
- `selfhost/build/phase140/*/process.json`

It counts terminal success and failure records, excludes pending/later records,
computes interval unions, and retains exact receipt pins. It also reports the
explicit source03/15/17/18 candidate acquisition/build/source inventory and a
fixed list of native pair/batch observations. Source18 maps to acquire04/N1d.
No compiler, native executable, benchmark or subprocess is invoked.

Run only after the coordinator selects the final accounting cutoff:

```sh
python3 -B selfhost/tools/performance/phase140/cost/inventory.py \
  --out-prefix implementation/phase140/cost-final
```

For a deterministic earlier snapshot, supply `--cutoff` with an explicit UTC
ISO timestamp. The default campaign start is2026-10-25T18:12:15Z and can be
changed using `--start`. Outputs are fresh `.json` and `.md`; existing files are
never overwritten. Keep `cost-review.md` and `cost-review-data.json` unchanged.

The metadata smoke at `selfhost/build/phase140/cost-tool-smoke01/inventory.json`
reproduces the20:34:33.311173 snapshot exactly:93 terminal guards,29 failures,
4142.815482549835 guard seconds,4077.5296926498413 interval-union seconds.
Later records are explicitly excluded when reconstructing that cutoff.

Bounds:512 guard receipts,128 selected modules per candidate,8MiB maximum per
source/metadata file. No recursive directory scan, generated-QBE read, ELF
rehash, broad history traversal or target execution. Final output contains
nested stage/build timers only as explanations; they are not added to enclosing
guard totals. The tool does not measure agent thinking, token use, quota or
unrecorded idle time. See the earlier cost review for interpretation.
