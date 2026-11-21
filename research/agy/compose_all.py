#!/usr/bin/env python3
"""Compose all verified AGY compiler passes cleanly onto p205-compiler.bend:
  - AGY-001: Binary-fork Nat-depth U32.add linearization (bf_linearize.bend)
  - AGY-005b: Fueled-loop absorbing-state early-exit (absorbing.bend)
  - AGY-005a: Bounded pure closed-term evaluator / CTFE (ctfe.bend)
  - AGY-005-sqrt: sqrt-preserving F32 regions (apply_sqrt.py)
  - AGY-004: Dominating CSE + immediate cmpq $id (x86_reg/apply.py --branch-cse)
  - AGY-003: Parallel call-arg scheduling + bounded cold ctor{1..4} inlining (x86_ctor/apply.py --mode=args_ctor)
"""
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BASE = ROOT / "selfhost/build/agy/bootstrap/p205-compiler.bend"


def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match for {old[:80]!r}, got {n}")
    return s.replace(old, new, 1)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "selfhost/build/agy/unified/compiler.bend"
    out.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        # 1. Start from p205-compiler.bend, chain CTFE -> Absorbing -> BF-Linearize before p86_plan_annotated
        src = BASE.read_text()
        ctfe_src = (ROOT / "research/agy/big_wins/ctfe.bend").read_text()
        abs_src = (ROOT / "research/agy/absorbing/absorbing.bend").read_text()
        bf_src = (ROOT / "research/agy/bf_linearize.bend").read_text()

        # Chain: p86_plan_annotated -> agy_bf_plan -> agy_abs_plan -> agy_ctfe_plan -> p205_ready
        old_tail = "p205_ready(ctx1,stops,verdict,defs1,p205u_decls(ctx1,defs1,missing(),False{}))"
        old_orig = "p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{}))"

        # In absorbing.bend, replace both p205_ready tails with agy_ctfe_plan
        abs_chained = abs_src.replace(old_tail, "agy_ctfe_plan(ctx1,stops,verdict,defs1)").replace(
            old_orig, "agy_ctfe_plan(context,stops,verdict,annotated)"
        )
        assert "agy_ctfe_plan(" in abs_chained

        # In bf_linearize.bend, replace both p205_ready tails with agy_abs_plan
        bf_chained = bf_src.replace(old_tail, "agy_abs_plan(ctx1,stops,verdict,defs1)").replace(
            old_orig, "agy_abs_plan(context,stops,verdict,annotated)"
        )
        assert "agy_abs_plan(" in bf_chained

        anchor = "@unsafe\ndef p86_plan_annotated("
        old_call = "u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{}))"
        src = once(src, old_call, "u => agy_bf_plan(context,stops,verdict,annotated)", "hook p86_plan_annotated")
        src = once(src, anchor, ctfe_src + "\n\n" + abs_chained + "\n\n" + bf_chained + "\n\n" + anchor, "insert KTerm passes")

        step1 = td / "step1_kterm.bend"
        step1.write_text(src)

        # 2. Apply sqrt-regions (AGY-005-sqrt)
        step2 = td / "step2_sqrt.bend"
        subprocess.run(["python3", "-B", str(ROOT / "research/agy/big_wins/apply_sqrt.py"), str(step1), str(step2)], check=True)

        # 3. Apply AGY-004 (--branch-cse)
        step3 = td / "step3_reg.bend"
        subprocess.run(["python3", "-B", str(ROOT / "research/agy/x86_reg/apply.py"), "--base", str(step2), "--out", str(step3), "--branch-cse"], check=True)

        # 4. Apply AGY-003 (--mode=args_ctor)
        subprocess.run(["python3", "-B", str(ROOT / "research/agy/x86_ctor/apply.py"), "--src", str(step3), "--dst", str(out), "--mode=args_ctor"], check=True)

    print(f"Composed unified compiler: {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
