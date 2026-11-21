# Concurrent Agent Workflow (`selfhost/agy`)

This file documents the working methodology for the Antigravity agent operating in its own checkout (`/home/ai/bend2_agy`) concurrently with the Codex agent operating in `/home/ai/bend2/build/publish/bend` on `selfhost/bootstrap`.

## 1. Branch & Git Hygiene

- **Working branch**: `selfhost/agy` (branched off `selfhost/bootstrap`), with optional short-lived topic branches (e.g., `selfhost/agy-ray`, `selfhost/agy-selfbuild`) merged into `selfhost/agy`.
- **Never push directly to `selfhost/bootstrap`**: keep `selfhost/bootstrap` owned by the main Codex workflow so neither agent encounters non-fast-forward rejections or surprise merge conflicts.
- **Syncing & upstreaming**:
  - Periodically fetch and rebase/merge from `origin/selfhost/bootstrap`.
  - Land verified wins back into `selfhost/bootstrap` via clean, self-contained cherry-picks or PRs/merges once independently verified.
- **Small, self-contained commits**: keep compiler source diffs (`selfhost/src/...`) minimal and separate from experimental scripts/reports so individual optimizations can be reviewed or cherry-picked cleanly.

## 2. Collision-Free Directory & Naming Conventions

Codex increments sequential phase directories (`implementation/phase205`, `research/phase206`, ...) and updates `experiments/STEERING.md` and `experiments/ledger.md`. To prevent merge conflicts:

- **Experiment records & ledger**: store under `experiments/agy/` with `AGY-NNN-short-name.md` IDs and a branch-local `experiments/agy/ledger.md`.
- **Research scripts, prototypes & measurements**: store under `research/agy/`.
- **Build & benchmark outputs**: store under `selfhost/build/agy/` (ignored/ephemeral unless explicitly archived).
- **Shared files**: do not edit `experiments/STEERING.md`, `experiments/ledger.md`, or Codex's `phase*` directories on `selfhost/agy`. Only modify `selfhost/src/` when testing or landing a concrete compiler change.
- **Human-written upstream files**: never hand-edit `bend2/bend.ts` or alter historical pinned reference checkouts.

## 3. Shared Machine Hygiene (Disk & CPU)

Both workspaces share the same filesystem (`/`) and CPU (`Intel Xeon E3-1245 V2`, 4 physical cores / 8 hardware threads).

### Disk Space
- Codex's `selfhost/tools/build-retention/guard.py` enforces a **5 GiB free-space reserve floor** on `/` and aborts jobs if external writers push free space below the floor.
- Always run new compiler/benchmark jobs under `selfhost/tools/build-retention/guard.py` with an explicit `--disk-mib` budget and `--run-root` under `selfhost/build/agy/`.
- Never nest guards; keep the default 5 GiB reserve.
- Prune scratch/intermediate build directories under `selfhost/build/agy/` promptly after capturing verified receipts (and classify completed campaigns with `selfhost/tools/build-retention/close.py`). Never touch files or lock inodes outside this checkout.

### CPU & Timing Isolation
- Codex pins timed runs to **CPU 3** (`taskset -c 3`, physical core shared with its SMT sibling).
- Pin `selfhost/agy` timed runs to a **separate physical core** (default **CPU 2**, `taskset -c 2`) to avoid SMT contention with Codex's CPU 3 runs.
- Avoid launching heavy multi-core builds while Codex is actively running a timed benchmark, and note any concurrent host activity in timing receipts.

## 4. Experiment & Evidence Discipline

Follow the repository's evidence standards in `experiments/README.md`:

1. **Falsifiable hypothesis first**: state the target workload, invariant/soundness condition, expected mechanism, and falsification criterion in `experiments/agy/AGY-NNN-*.md`.
2. **Cheap discrimination before heavy builds**:
   - Inspect emitted x86/IR/profiles and count the actual hot opportunity.
   - Test boundary and adverse counterexamples early.
   - Screen with focused differential correctness checks before running broad suites or full self-rebuilds.
3. **Separate correctness, measurement, and promotion**:
   - Source checking, generated-program execution, byte-identical self-reproduction, and independent BendTT kernel proof are distinct claims; unsupported lanes never count as passes.
   - Freeze source/image/runtime/input identities before timing.
   - Run alternating baseline/treatment rounds on a pinned core; preserve regressions, dispersion flags, failures, and rejected attempts with their original status.
4. **Independent challenge before landing**: verify ownership, evaluation/error order, strictness/zero-count edge cases, ABI/register clobbers, and held-out transfer before proposing a merge into `selfhost/bootstrap`.
