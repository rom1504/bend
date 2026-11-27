#!/usr/bin/env python3
from __future__ import annotations
"""Differential checker conformance harness: bend5k vs pinned upstream bend2/main.ts.

Runs every case in check_conformance_corpus.json through:
  1. Pinned upstream checker: research/agy/locked_bun.sh --check-only
  2. bend5k --check-only
  3. bend5k -O2 <src> <out.o> (verifies invalid inputs do not emit a usable .o)

Reports all 4 core outcomes separately:
  - agree_accept
  - agree_reject
  - false_accept (invalid source accepted by bend5k)
  - false_reject (valid source rejected by bend5k)
AND tracks separately:
  - crashes, timeouts, unsupported_features, incomplete_proofs, compile_emitted_obj_on_invalid
"""
import argparse
import collections
import json
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_CORPUS = ROOT / "research/agy/bend5k/check_conformance_corpus.json"
DEFAULT_BEND5K = ROOT / "selfhost/build/agy/bend5k/bend5k_o2"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"


def run_cmd(cmd: list[str], timeout: int, cpu: int | None) -> dict:
    full = (["taskset", "-c", str(cpu)] + cmd) if cpu is not None else cmd
    t0 = time.perf_counter()
    try:
        r = subprocess.run(full, capture_output=True, text=True, timeout=timeout)
        ms = (time.perf_counter() - t0) * 1000.0
        return {
            "rc": r.returncode,
            "stdout": r.stdout,
            "stderr": r.stderr,
            "ms": round(ms, 2),
            "timeout": False,
            "crash": r.returncode < 0 or "memory fault" in r.stderr.lower() or "stack overflow" in r.stderr.lower(),
        }
    except subprocess.TimeoutExpired:
        ms = (time.perf_counter() - t0) * 1000.0
        return {
            "rc": -999,
            "stdout": "",
            "stderr": f"timeout>{timeout}s",
            "ms": round(ms, 2),
            "timeout": True,
            "crash": False,
        }


def classify_bend5k_err(stderr: str) -> str:
    s = stderr.strip().lower()
    if s.startswith("check:"):
        return "check"
    if s.startswith("compile: foreign provider"):
        return "foreign_policy"
    if "lex" in s or "unterminated" in s:
        return "lex"
    if "parse" in s or "expected" in s or "unexpected" in s:
        return "parse"
    return "other"


def main() -> int:
    ap = argparse.ArgumentParser(description="Differential checker conformance runner")
    ap.add_argument("--bend5k", type=Path, default=DEFAULT_BEND5K)
    ap.add_argument("--corpus", type=Path, default=DEFAULT_CORPUS)
    ap.add_argument("--cpu", type=int, default=2)
    ap.add_argument("--timeout", type=int, default=30)
    ap.add_argument("--suite", choices=("frozen60", "v2_parametric", "all"), default="frozen60")
    ap.add_argument("--json-out", type=Path, default=None)
    ap.add_argument("--label", type=str, default="run")
    args = ap.parse_args()

    corpus = json.loads(args.corpus.read_text(encoding="utf-8"))
    if args.suite == "frozen60":
        cases = corpus["cases"]
    elif args.suite == "v2_parametric":
        cases = corpus.get("v2_parametric_cases", [])
    else:
        cases = list(corpus["cases"]) + list(corpus.get("v2_parametric_cases", []))

    outcomes = collections.Counter()
    by_category = collections.defaultdict(collections.Counter)
    crashes = []
    timeouts = []
    unsupported_features = []
    incomplete_proofs = []
    compile_emitted_obj_on_invalid = []
    b5k_check_ms = []
    up_check_ms = []
    details = []

    with tempfile.TemporaryDirectory(prefix="b5k_chk_conf_") as tmpdir:
        tmp = Path(tmpdir)
        for c in cases:
            cid = c["id"]
            cat = c.get("category", "unknown")
            grp = c.get("group", "unknown")
            if "file" in c:
                src = ROOT / c["file"]
            else:
                src = tmp / f"{cid}.bend"
                src.write_text(c["code"], encoding="utf-8")

            up = run_cmd(["bash", str(LOCKED_BUN), "--check-only", str(src)], args.timeout, args.cpu)
            b5k_chk = run_cmd([str(args.bend5k), "--check-only", str(src)], args.timeout, args.cpu)

            obj = tmp / f"{cid}.o"
            if obj.exists():
                obj.unlink()
            b5k_o2 = run_cmd([str(args.bend5k), "-O2", str(src), str(obj)], args.timeout, args.cpu)
            obj_emitted = obj.exists() and obj.stat().st_size > 0
            if obj.exists():
                obj.unlink()

            up_status = "timeout" if up["timeout"] else ("crash" if up["crash"] else ("accept" if up["rc"] == 0 else "reject"))
            b5k_status = "timeout" if b5k_chk["timeout"] else ("crash" if b5k_chk["crash"] else ("accept" if b5k_chk["rc"] == 0 else "reject"))
            b5k_err_kind = classify_bend5k_err(b5k_chk["stderr"]) if b5k_status == "reject" else ""

            if not b5k_chk["timeout"] and not b5k_chk["crash"]:
                b5k_check_ms.append(b5k_chk["ms"])
            if not up["timeout"] and not up["crash"]:
                up_check_ms.append(up["ms"])

            if b5k_chk["crash"] or b5k_o2["crash"]:
                crashes.append(cid)
            if b5k_chk["timeout"] or b5k_o2["timeout"] or up["timeout"]:
                timeouts.append(cid)

            # Determine core outcome
            if up_status in ("accept", "reject") and b5k_status in ("accept", "reject"):
                if up_status == "accept" and b5k_status == "accept":
                    outcome = "agree_accept"
                elif up_status == "reject" and b5k_status == "reject":
                    outcome = "agree_reject"
                elif up_status == "reject" and b5k_status == "accept":
                    outcome = "false_accept"
                else:
                    outcome = "false_reject"
            else:
                outcome = f"infra_{up_status}_{b5k_status}"

            outcomes[outcome] += 1
            by_category[cat][outcome] += 1

            # Track unsupported features separately (valid upstream rejected due to parse/lex/foreign policy)
            if outcome == "false_reject" and b5k_err_kind in ("parse", "lex", "foreign_policy"):
                unsupported_features.append({"id": cid, "kind": b5k_err_kind, "err": b5k_chk["stderr"].strip()[:160]})

            # Track incomplete proofs separately (bend5k accepted a proof/dependent/grade case without BendTT)
            if b5k_status == "accept" and cat in ("proof_or_dependent", "dependent_proof", "grade_system"):
                incomplete_proofs.append({
                    "id": cid,
                    "upstream": up_status,
                    "b5k_stdout": b5k_chk["stdout"].strip()[:120],
                })

            # Track invalid source producing a usable .o under -O2
            if up_status == "reject" and (b5k_o2["rc"] == 0 or obj_emitted):
                compile_emitted_obj_on_invalid.append({
                    "id": cid,
                    "rc": b5k_o2["rc"],
                    "obj_emitted": obj_emitted,
                })

            row = {
                "id": cid,
                "group": grp,
                "category": cat,
                "outcome": outcome,
                "upstream_status": up_status,
                "bend5k_check_status": b5k_status,
                "bend5k_check_stdout": b5k_chk["stdout"].strip()[:160],
                "bend5k_check_stderr": b5k_chk["stderr"].strip()[:200],
                "bend5k_err_kind": b5k_err_kind,
                "bend5k_o2_rc": b5k_o2["rc"],
                "bend5k_o2_obj_emitted": obj_emitted,
                "upstream_ms": up["ms"],
                "bend5k_check_ms": b5k_chk["ms"],
                "bend5k_o2_ms": b5k_o2["ms"],
            }
            details.append(row)
            flag = ""
            if outcome == "false_accept":
                flag = "  <-- FALSE ACCEPT"
            elif outcome == "false_reject":
                flag = f"  <-- FALSE REJECT ({b5k_err_kind})"
            print(
                f"{outcome:14s} {cid:34s} up={up_status:6s} b5k={b5k_status:6s} "
                f"o2_obj={str(obj_emitted):5s} {b5k_chk['ms']:6.1f}ms{flag}",
                flush=True,
            )

    summary = {
        "label": args.label,
        "bend5k": str(args.bend5k),
        "corpus": str(args.corpus),
        "total_cases": len(cases),
        "outcomes": {
            "agree_accept": outcomes["agree_accept"],
            "agree_reject": outcomes["agree_reject"],
            "false_accept": outcomes["false_accept"],
            "false_reject": outcomes["false_reject"],
            "other": sum(v for k, v in outcomes.items() if k not in ("agree_accept", "agree_reject", "false_accept", "false_reject")),
        },
        "by_category": {k: dict(v) for k, v in sorted(by_category.items())},
        "crashes": crashes,
        "timeouts": timeouts,
        "unsupported_features_count": len(unsupported_features),
        "unsupported_features": unsupported_features,
        "incomplete_proofs_count": len(incomplete_proofs),
        "incomplete_proofs": incomplete_proofs,
        "compile_emitted_obj_on_invalid_count": len(compile_emitted_obj_on_invalid),
        "compile_emitted_obj_on_invalid": compile_emitted_obj_on_invalid,
        "latency_ms": {
            "bend5k_check_median": round(statistics.median(b5k_check_ms), 2) if b5k_check_ms else 0.0,
            "bend5k_check_mean": round(statistics.mean(b5k_check_ms), 2) if b5k_check_ms else 0.0,
            "bend5k_check_total": round(sum(b5k_check_ms), 2),
            "upstream_check_median": round(statistics.median(up_check_ms), 2) if up_check_ms else 0.0,
        },
        "cases": details,
    }

    print("\n=== CHECKER CONFORMANCE SUMMARY ===", flush=True)
    print(f"Label                         : {args.label}", flush=True)
    print(f"Total cases                   : {len(cases)}", flush=True)
    print(f"  1. agree_accept             : {outcomes['agree_accept']}", flush=True)
    print(f"  2. agree_reject             : {outcomes['agree_reject']}", flush=True)
    print(f"  3. false_accept (invalid OK): {outcomes['false_accept']}", flush=True)
    print(f"  4. false_reject (valid ERR) : {outcomes['false_reject']}", flush=True)
    print(f"Crashes                       : {len(crashes)}", flush=True)
    print(f"Timeouts                      : {len(timeouts)}", flush=True)
    print(f"Unsupported features          : {len(unsupported_features)}", flush=True)
    print(f"Incomplete proofs             : {len(incomplete_proofs)}", flush=True)
    print(f"Invalid emitted .o (-O2)      : {len(compile_emitted_obj_on_invalid)}", flush=True)
    print(f"bend5k --check-only median    : {summary['latency_ms']['bend5k_check_median']} ms (total {summary['latency_ms']['bend5k_check_total']} ms)", flush=True)

    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
