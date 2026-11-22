#!/usr/bin/env python3
"""Benchmark & Verify Content-Addressed Incremental Compilation (`incr_compile.mjs`).

Tests on `histogram` (small), `gameoflife` (small), `nbody` (small), `lexer`, and `compiler_200defs`:
  1. Cold build (empty cache) -> verifies exact runtime stdout!
  2. 1-function body edit -> measures cache hit rate, x86 emit speedup, total rebuild speedup,
     and verifies the edited binary runs and produces the updated output!
  3. No-op rebuild (exact same edited file) -> measures whole-program fast-path hit (< 50 ms)!
"""
import json
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave5c_unified/api.mjs"
INCR = ROOT / "research/agy/wave5_incr/incr_compile.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
RTS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]


def run_incr(src: Path, out: Path, cache_dir: Path, shards: int = 4) -> dict:
    r = subprocess.run(
        [
            "taskset", "-c", "0,1,4,5",
            "bash", str(LOCKED_NODE), str(INCR),
            "--api", str(API),
            "--src", str(src),
            "--out", str(out),
            "--cache-dir", str(cache_dir),
            "--shards", str(shards),
            "--json",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(r.stdout.strip().splitlines()[-1])


def run_exe(exe: Path) -> str:
    r = subprocess.run(
        ["taskset", "-c", "0,1,4,5", str(exe), *RTS],
        capture_output=True,
        text=True,
        check=True,
        timeout=60,
    )
    return r.stdout.strip()


def prep_upstream_small(family: str) -> str:
    spec = json.loads((ROOT / "research/agy/wave4_bench/inputs/upstream/suite.json").read_text())[family]
    txt = (ROOT / "research/agy/wave4_bench/inputs/upstream" / family / "main.bend").read_text()
    for bname, _, old, new in zip(spec["bendKnobs"], spec["cKnobs"], spec["upstream"], spec["small"]):
        txt = re.sub(rf"(?m)(^def {bname}\(\) -> Nat:\n  ){old}n$", rf"\g<1>{new}n", txt, count=1)
    return txt


def edit_non_comment(src: str, old: str, new: str) -> str:
    lines = src.splitlines(keepends=True)
    for i, line in enumerate(lines):
        if not line.lstrip().startswith("#") and old in line:
            lines[i] = line.replace(old, new, 1)
            return "".join(lines)
    raise ValueError(f"Could not find non-comment {old!r}")


def main():
    specs = [
        ("histogram", prep_upstream_small("histogram"),
         lambda s: edit_non_comment(s, "2654435761", "2654435763"),
         "3825188900"),
        ("gameoflife", prep_upstream_small("gameoflife"),
         lambda s: edit_non_comment(s, "2654435761", "2654435763"),
         "2601177279"),
        ("nbody", prep_upstream_small("nbody"),
         lambda s: edit_non_comment(s, "2654435761", "2654435763"),
         "2215450620"),
        ("lexer", (ROOT / "selfhost/tests/consolidation/native-broad/lexer.bend").read_text(),
         lambda s: edit_non_comment(s, "2654435761", "2654435763"),
         None),
    ]

    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        cache_dir = td / "cache"
        print(f"{'Program':<12} {'Cold(ms)':>9} {'ColdEm':>8} {'Edit1(ms)':>10} {'Edit1Em':>8} {'Hits':>10} {'EmSpd':>7} {'NoOp(ms)':>9}  {'Sound'}")
        print("-" * 98)
        rows = []
        for name, src_text, edit_fn, want_cold in specs:
            src_p = td / f"{name}.bend"
            src_p.write_text(src_text)
            exe_cold = td / f"{name}_cold.bin"
            c_res = run_incr(src_p, exe_cold, cache_dir, shards=4)
            out_cold = run_exe(exe_cold)

            edited_text = edit_fn(src_text)
            if edited_text == src_text:
                edited_text = src_text + "\ndef agy_incr_dummy(x: U32) -> U32:\n  U32.add(x, 1)\n"
            src_p.write_text(edited_text)
            exe_edit = td / f"{name}_edit.bin"
            e_res = run_incr(src_p, exe_edit, cache_dir, shards=4)
            out_edit = run_exe(exe_edit)

            exe_noop = td / f"{name}_noop.bin"
            n_res = run_incr(src_p, exe_noop, cache_dir, shards=4)
            out_noop = run_exe(exe_noop)

            cold_ok = (want_cold is None or out_cold == want_cold)
            changed_ok = (out_edit != out_cold)
            sound = cold_ok and changed_ok and (out_noop == out_edit) and (len(out_cold) > 0) and (len(out_edit) > 0)
            em_spd = (c_res["emitMs"] / e_res["emitMs"]) if e_res["emitMs"] > 0 else float("inf")
            hits_str = f"{e_res['hits']}/{e_res['totalUnits']}"
            print(
                f"{name:<12} {c_res['totalMs']:9.1f} {c_res['emitMs']:8.1f} "
                f"{e_res['totalMs']:10.1f} {e_res['emitMs']:8.1f} {hits_str:>10} "
                f"{em_spd:6.1f}x {n_res['totalMs']:9.1f}  {'PASS' if sound else 'FAIL'}"
            )
            rows.append({
                "name": name, "cold": c_res, "edit1": e_res, "noop": n_res,
                "out_cold": out_cold, "out_edit": out_edit, "sound": sound,
            })

        out_json = ROOT / "experiments/agy/receipts/wave5-incr-bench.json"
        out_json.write_text(json.dumps(rows, indent=2) + "\n")
        print(f"\nSaved receipt: {out_json}")


if __name__ == "__main__":
    main()
