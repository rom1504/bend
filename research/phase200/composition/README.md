# Replaying the Phase200 maintained x86 source

The first composition adds the checked producer-retention declarations to the integrated Phase199 parent. The parent whole-source check accepted all declarations with zero unresolved holes. The maintained tree, reassembled without any virtual edits, matches its frozen a48b1532… compiler. The proposed source has SHA-256 c8b1b8a30d08e15e37d92cd6ed65ccc33b9bff484957e21ebeb903069ef106d7 and is 1,977,250 bytes. This is a source-assembly receipt. Its independent whole-source check and native image acquisition are separate, unexecuted stages. [Receipt](spill-only.json) · [Patch](spill-only.patch.gz).

The assembler checked every contributed declaration body against its successful API source. It also checked the per-case measurements against that API and the frozen integrated incumbent. The replacement stays in the existing ordinary-worker source location. Twenty-three new helper definitions follow the typed frame-spill declarations in the frame-forwarding module. The final declaration census allows exactly this replacement plus these additions; all existing declarations are present and the protected inventory passes.

To repeat the in-memory audit, run the following from the repository root. It authenticates the checked API and measurement receipts, assembles through the maintained source tool, and dry-runs the patch against the original tree with zero fuzz.

```sh
python3 -B research/phase200/composition/assemble.py
```

Once sufficient artifact storage is available, replay the committed patch into a fresh working tree. This requires the integrated Phase199 maintained tree, its compiled source snapshot and the portable patch and receipt. It recomputes both source hashes and does not require the large prior API artifact. The output is Bend source, with the same ordinary native interface as its parent.

```sh
python3 -B research/phase200/composition/replay.py \
  --record research/phase200/composition/spill-only.json \
  --out selfhost/build/phase199/p200-spill-maintained01
```

The optional ownership-tag rule has a different hook. Including it requires a separately checked API and completed focused measurements of its skipped immediate calls and runtime transfer. [Spill measurements](../spill/RESULTS.md) · [Complete-state stencil opportunity](stencil.md).

The [acquisition argv](acquisition-argv.json) freeze the source-only materialization, independent whole-source check and raw N1 build. The 1,977,250-byte spill-only source can be emitted without copying the maintained tree by overlaying the two changed modules in memory. The manifest is inherited byte-for-byte from the integrated parent's maintained tree. The full checker uses that manifest, the pinned Phase182 upstream and the upstream book/hole checks. Before N1 generation, run the source/receipt comparison in [validate.py](validate.py). The new N1 is built by the release Phase186 QBE N2 with Phase194 QBE assets and ordinary native cache mode. The streaming runner preserves the normal native x86 image binding and writes its native ELF to the candidate acquisition root.

The standard fallback argv are deliberately held outside the automatic sequence. Its previous integrated acquisition used 125.14 MiB of declared artifacts and the sampled filesystem decrease reached 139.10 MiB. The fallback reserves 144 MiB, before the separately required suite artifacts. It requires a new disk decision if the lower-disk stream parity fails.

Native program acquisition uses the unchanged Phase199 integrated asset manifest, linking the frozen ABI11102 original-plus-scan runtime. Broad timing relinks the same emitted objects against the live-plus-scan bundle. The two runtime provider identities are distinct and both come from the sealed Phase199 runtime-bundle01 receipt. The current portfolio comparison measures the native45 catalog against its frozen integrated reference and mature C products.
