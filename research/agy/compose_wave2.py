#!/usr/bin/env python3
"""Compose ALL Tier-2-cleared Wave 2 passes cleanly on top of Wave 1 unified/compiler.bend.

Usage: python3 -B research/agy/compose_wave2.py <out_compiler.bend>
"""
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BASE_COMPILER = ROOT / "selfhost/build/agy/unified/compiler.bend"

STEPS = [
    ("Track-D (W2D Lexer Deforest + Interval)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_lexrec/apply_lex_deforest.py"), str(i), str(o)]),
    ("Track-A (2A+2B+2C Ray/F32/XMM/ASR)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2c_ray/apply_all_track_a_2c.py"), str(i), str(o)]),
    ("Track-B1 (AGY-W2B-1 Perceus Reuse + Take)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_bst/apply_reuse.py"), "--reuse", "--take", "--src", str(i), "--dst", str(o)]),
    ("Track-B2 (AGY-W2B-2 Multi-Pass p114h)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_bst/apply_p114h_mp.py"), "--src", str(i), "--dst", str(o)]),
    ("Track-B3 (AGY-W2B-3 BST Zipper)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_bst_b/apply_bst_zipper.py"), "--src", str(i), "--dst", str(o)]),
    ("Track-C1 (AGY-W2-ROREC Borrowed Native Rec)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_editsym/apply_rorec.py"), str(i), str(o)]),
    ("Track-B4 (AGY-W2B-4 Native Bitonic Flow)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_bst_b/apply_flow_native.py"), "--src", str(i), "--dst", str(o)]),
    ("Track-C2 (AGY-W2-DPLOOP 1D Stencil Fast Path)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_editsym/apply_dp_loop.py"), str(i), str(o)]),
    ("Track-C3 (AGY-W2B-F32LOOP XMM Recurrence)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_editsym_b/apply_f32_loop.py"), str(i), str(o)]),
    ("Track-C4 (AGY-W2B-DEADARR Dead Array Scan)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2_editsym_b/apply_dead_arr_scan.py"), str(i), str(o)]),
    ("Wave2C-1 (AGY-W2C-MAPFAST Map.get/Map.set)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2c_recagg/apply_map_fast.py"), str(i), str(o)]),
    ("Wave2C-2 (AGY-W2C-LISTAPP + ARRLIST)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2c_recagg/apply_list_arr.py"), str(i), str(o)]),
    ("Wave2C-3 (AGY-W2C-1 Map.set/del/get Radix Trie)",
     lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave2c_map/apply_map_fast.py"), "--src", str(i), "--dst", str(o)]),
]


def main():
    out = Path(sys.argv[1])
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        cur = BASE_COMPILER
        for idx, (label, mk_cmd) in enumerate(STEPS):
            nxt = out if idx == len(STEPS) - 1 else Path(td) / f"step_{idx:02d}.bend"
            cmd = mk_cmd(cur, nxt)
            print(f"[{idx+1:2d}/{len(STEPS)}] {label} ...", flush=True)
            subprocess.run(cmd, check=True)
            cur = nxt
    print(f"\nComposed Wave 2 unified compiler: {out} ({out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
