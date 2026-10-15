# Phase98 frozen evidence

The final seal preserves **7,988 files** as **4,008 unique content blobs**. Original
paths and modes remain independent. Raw evidence totals 1,178,157,908 bytes; unique
content totals 527,467,750 bytes. The verified two-part ZIP stores 89,036,455 bytes.
All blobs were reopened and hashed. A separate full verify and missing-only
restore both succeeded with zero missing entries.

[Receipt](receipt.json) · [Manifest](manifest.json) ·
[Phase report](../../../../../../implementation/phase98/README.md).

Receipt SHA256: `1c2b28eccc57d75730ad5678df403cddbb7b51a4e35bd2a99c9ee61d5b70d297`.

The separate `phase98-preselection02` and `phase98-assets02` request capsules
are authenticated external dependencies. Earlier-phase histories/toolchains are
not silently folded into this campaign archive. Restore requires the recorded
canonical checkout root; changed existing bytes and modes are refused.

From the repository root:

```sh
python3 -B selfhost/tools/performance/phase98/evidence.py restore selfhost/tools/performance/phase98/artifacts/evidence01/receipt.json --verify-only
python3 -B selfhost/tools/performance/phase98/evidence.py restore selfhost/tools/performance/phase98/artifacts/evidence01/receipt.json
```

No compiler or program is run by these archive operations. Final target accounting
records 970 complete guard intervals and 90.95 minutes of union occupancy. It is
wall occupancy, not CPU, token or quota accounting. Interrupted records remain
explicit rather than receiving invented durations. No PR comment was posted.

This package directory is excluded from its own content manifest. Its receipt,
parts, manifest and this index are versioned directly in Git.
