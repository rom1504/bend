# Phase48 experiment preservation

**Published and verified.** The closed campaign contains **18,935 files /
454,085,159 logical bytes**, stored as an **84,284,137-byte gzip stream**
in three ordered parts of at most 40 MiB. Every member was reopened and hashed;
the full source inventory was checked again. The reopened parts' concatenation
matches the original stream.

Stream SHA-256: `62aa86a48512a6ed13ff437f21e1bbdecce2004cd78e0ca4b32f453a11d21785`.

- [Evidence index](index.json): selected release, archive, portable bundles and prerequisites.
- [Selected qualification](selected-qualification.json): exact installed RNFA04,
  semantic gates, eight maintained suites, 81 backend agreements (69 execution
  passes / eight N/A / four shared failures), 42 CLI checks, 45 points / 669 samples,
  18 compiler requests and portable smoke.
- [Semantic qualification](semantic-qualification.json): byte-identical copy of
  the 28-entry source/image-bound gate receipt; scopes overlap.
- [Installed receipt](installed-release.json): byte-identical verified release join.
- [Source reconciliation](source-reconciliation.json): all 188 live source files
  match the selected snapshot; preimages preserve the deferred H/V proposals.
- [Writer closure](writers-closed.json): raw writes stopped at
  `2026-10-05T05:10:45.526361+00:00`.
- [Protected audit](protected-final.json): all 103 unrelated starting files
  unchanged and unstaged. Original inventory SHA-256
  `c5e803405d3c8267bd2f3741a638c77b4ce58c561cc5c829d0abac2ac8d67288`.
- [Archive manifest](raw/archive.json): every member size/hash.
- [Parts manifest](raw/parts.json): ordered sizes/hashes and concatenation verification.
- [Time accounting](../../../../../implementation/phase48/time-use.md): separate
  measured-process occupancy and elapsed work, with an explicit pre-publication cutoff.

The capsule includes every regular raw file: successful and failed attempts,
rejected or unselected prototypes, consumed tools, controls, exact generated
artifacts, profiles and timing leaves. Membership never promotes a failed
experiment. The unchanged [streaming archive producer](../../phase42/validation/archive-campaign-v1.py)
rejects symlinks, bounds inventory sizes and rehashes every member and input. Its
historical Phase42 schema remains unchanged; `rawRoot` identifies Phase48.
The [parts publisher](publish-archive-parts.py) preserves the original stream and
ignores only its reconstructed unsplit local copy.

## Recovery

The [portable benchmark](../README.md) runs without this raw capsule. To recover
historical experiments, first verify every part against `raw/parts.json`, then
reconstruct the exact ordered stream into a genuinely fresh path:

```sh
cat selfhost/tools/performance/phase48/evidence/raw/raw-campaign.tar.gz.part-000 \
    selfhost/tools/performance/phase48/evidence/raw/raw-campaign.tar.gz.part-001 \
    selfhost/tools/performance/phase48/evidence/raw/raw-campaign.tar.gz.part-002 \
  > /tmp/phase48-recovered-NEW.tar.gz
sha256sum /tmp/phase48-recovered-NEW.tar.gz
mkdir selfhost/build/phase48-recovered-NEW
tar -xzf /tmp/phase48-recovered-NEW.tar.gz \
  -C selfhost/build/phase48-recovered-NEW
```

Verify the concatenated size/hash before extraction; choose new paths to avoid
overwriting previous evidence. Check every extracted member against
`archive.json.files`. Names are relative to the raw root. Original absolute
execution paths remain in receipts; relocation does not make historical commands
portable or authorize editing their provenance.

Node v24.18.0, upstream `018751270e800bc222a93dad7f257083ee53a5f7`, repository
producers and earlier evidence remain prerequisites. The index binds the closed
[Phase45](../../phase45/evidence/README.md),
[Phase46](../../../../../implementation/phase46/README.md) and
[Phase47](../../phase47/evidence/README.md) archives. The complete historical raw
bytes are retained, not merely a recipe for recreating selected output.

No further raw writes are permitted in `selfhost/build/phase48`. Publication
receipts live outside that root. New work starts in a fresh successor directory.
