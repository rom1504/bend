# Retire the completed N2 QBE oracle

[storage-proposal09.json](storage-proposal09.json) selects exactly
`selfhost/build/phase173/owned-native-n2-08/program.ssa`: **100,278,749 bytes**,
**95.640625 MiB allocated**, one exclusive inode. Its freshly read SHA256 is
`a3ccea7189234d0b52b4b3669da93b616f52a2eb3e8b893c437d11efcf286068`.
The original writer completed successfully and its lifecycle remains sealed.
No target, compression, capture or apply ran during this review.

N3 already compared its complete QBE stream to this file and passed. The completed
`owned-generation-diff09` report also authenticates its full digest and confirms
N2/N3 QBE, assembly, object and loaded ELF equality; whole ELF files differ.
The completed native64 check reports 64 passes, zero failures or unsupported
cases. Preserve these reports and all binaries, sources, runtime and receipts.
The coordinator confirms no further local machine inspection needs the SSA.
Normal image execution reads the executable and receipt, not historical SSA.
Replaying the old `--expected-qbe` request or generation comparison requires
restoring this exact file first. These checks do not establish a correctness
theorem or authorize compiler promotion.

Use a **16 MiB archive cap**. N1's three-file archive was 26,018,303 bytes; N2's
assembly/object archive was 12,054,153 bytes. Their difference estimates a
**13.32 MiB** SSA archive. This is approximate: their SSA/machine products differ,
and gzip stream boundaries also matter. Expected recovery is **82.32 MiB**;
successful capture at the full cap still recovers **79.64 MiB**, before small
receipts/filesystem effects. Review-time headroom was 19.73 MiB above 5 GiB,
giving approximately 102.06 MiB afterward at the estimate. Remeasure actual space.

The bounded capture may exceed its cap and **fail safely with the SSA intact**.
Do not apply an incomplete plan or increase the cap automatically. Enforce
**5 GiB + 16 MiB before capture**, serialize with targets, and preserve the shared
lock. The frozen adapter itself checks only a 4 GiB floor.

Root can capture into a fresh path, separate from the prior N2 machine archive:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal09.json \
  --name p173-owned-native-n2-08-ir \
  --out selfhost/build-retention/phase169/p173-owned-native-n2-08-ir
```

After inspecting the exact verified plan, apply separately:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-owned-native-n2-08-ir/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-owned-native-n2-08-ir/applied
```

Keep the capsule, verified plan and journal for maintained exact restoration.
All unlisted files remain hot, especially `context-value-baseline09/program.ssa`,
active digest inputs, qualified chains, profiling assets and previous archives.
No historical storage search or recursive closure scan was needed for this
single explicitly retired consumer input.
