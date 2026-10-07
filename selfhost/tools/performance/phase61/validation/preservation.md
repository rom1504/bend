# Phase61 preservation and publication

Run these data-only operations outside measured timing. They do not execute
compiler targets. Root owns installation decisions and final writer closure.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/prepare-preservation.py \
  --out selfhost/build/phase61/preservation-method01
taskset -c 0 python3 -B selfhost/build/phase61/preservation-method01/publication/capture-installed.py
taskset -c 0 python3 -B selfhost/build/phase61/preservation-method01/publication/preservation.py \
  --installed unchanged --out selfhost/build/phase61/preservation-start.json
```

Capture preserves exactly the seven `installed-start.json` files in a fresh
`prior-release` directory and verifies source/copy identities. Run it once before
any replacement. Audits reuse the root's `closed-inventories.json` references to
published Phase58,59,60 archive metadata. They stream-hash all closed files,
reject symlinks, compare exact relative file sets and verify archive identities.
Protected103 and staged status remain mandatory. They do not assert that the
authorized live compiler source has remained equal to the old source.

Before installation, rerun `--installed unchanged` to a fresh receipt. After the
standard release installer and CLI gates, use `--installed selected --attempt
selfhost/build/phase61/checked-WINNER` with a fresh output. That branch binds the
actual installed source/API/Base/runtimes, checked parent, bootstrap and exact
derivation receipt to the genuine selected attempt. The old seven copies remain
verified. A failed audit stays retained; no retry overwrites it.

```sh
taskset -c 0 python3 -B selfhost/build/phase61/preservation-method01/publication/preservation.py \
  --installed selected --attempt selfhost/build/phase61/checked-WINNER \
  --out selfhost/build/phase61/preservation-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase51/check-protected.py \
  selfhost/build/phase61/protected-final.json
```

Only after every target, report, accounting and raw writer stops, root writes
`writers-closed.json` with `complete:true`, `writersClosed:true`, the absolute
Phase61 `rawRoot`, and actual selected `attempt`/`api` file/hash rows. Successful
audits do not certify later writer activity. After closure all archive and
publication outputs stay outside raw; no raw launcher logs are appended.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase61 --out selfhost/tools/performance/phase61/artifacts/raw \
  --writers-closed selfhost/build/phase61/writers-closed.json \
  --protected-final selfhost/build/phase61/protected-final.json
taskset -c 0 python3 -B selfhost/build/phase61/preservation-method01/publication/publish-parts.py \
  --archive-dir selfhost/tools/performance/phase61/artifacts/raw
```

The unchanged archive method SHA256 is
`4d393286e9a3e26892ff52bb242f53f1ea3211a82caeee3ef79a52b4597cfaa6`.
It streams deterministic tar/gzip in bounded memory, reopens and verifies every
member, and verifies final raw stability. Limits remain 2 GiB per file, 64 GiB
total and 500,000 members. The publication successor changes only phase paths
and labels: below 100,000,000 bytes retain one archive; otherwise create ordered
48 MiB parts, verify their concatenation hash and ignore the full local archive.
Archive publication itself is neither compiler qualification nor installation.
