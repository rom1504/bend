#!/usr/bin/env python3
"""Tier-2 Adversarial & Boundary Differential Test Suite for Wave 2C-RecAgg:
  - AGY-W2C-LISTAPP: static String/List literal corruption check
  - AGY-W2C-MAPFAST: static Map mutation check
  - AGY-W2C-MAPFAST: unsealed 0x02 value stored into 0x82 MLeaf -> shared double-free!
  - AGY-W2C-MAPFAST: long keys (> 33 chars, pos >= 1100), empty key "", Unicode keys

Requires bit-exact stdout across:
  1. Upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Wave 2C-RecAgg candidate hosted x86 API (arg 1)
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
BASE_API = ROOT / "selfhost/build/agy/api-base/api.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
TMP_ROOT = ROOT / "selfhost/build/agy/tier2_audit_w2c_recagg/adv_tmp"

CASES = [
    # ------------------------------------------------------------------
    # 1. AGY-W2C-LISTAPP: Static String & List literal in-place mutation check!
    # ------------------------------------------------------------------
    (
        "listapp_static_string_corruption",
        r'''import Base

def static_pref() -> String:
  SCon{Chr{97}, SCon{Chr{98}, SNil{}}}

def static_list() -> List<&2, U32>:
  Con{1, Con{2, Nil{}}}

def sum_l(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: sum_l(t, U32.add(acc, h))

def app_loop(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      s = String.append(static_pref(), "1")
      l = List.append(&2, U32, static_list(), Con{10, Nil{}})
      app_loop(p, U32.add(acc, U32.add(U32.from_nat(String.length(s)), sum_l(l, 0))))

def main() -> IO(Unit):
  IO.print(U32.show(app_loop(5n, 0)))
''',
    ),
    # ------------------------------------------------------------------
    # 2. AGY-W2C-MAPFAST: Static Map in-place mutation check!
    # ------------------------------------------------------------------
    (
        "mapset_static_map_corruption",
        r'''import Base

def static_map() -> Map<&2, U32>:
  MLeaf{"k", 10}

def get_val(r: Map<&2, U32> & U32) -> U32:
  (m, v) = r
  v

def map_loop(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      m1 = Map.set(&2, U32, static_map(), "k", 999)
      v_orig = get_val(Map.get(U32, 0, static_map(), "k"))
      v_m1 = get_val(Map.get(U32, 0, m1, "k"))
      map_loop(p, U32.add(acc, U32.add(v_orig, v_m1)))

def main() -> IO(Unit):
  IO.print(U32.show(map_loop(3n, 0)))
''',
    ),
    # ------------------------------------------------------------------
    # 3. AGY-W2C-MAPFAST: Unsealed 0x02 value stored into 0x82 MLeaf, then shared!
    # ------------------------------------------------------------------
    (
        "mapset_unsealed_val_into_shared_map",
        r'''import Base

def mk_str(n: Nat, +c: U32) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p: SCon{Chr{c}, mk_str(p, U32.add(c, 1))}

def churn(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      s = mk_str(8n, 65)
      churn(p, U32.add(acc, U32.from_nat(String.length(s))))

def get_s(r: Map<&2, String> & String) -> String:
  (m, v) = r
  v

def main() -> IO(Unit):
  m0 = Map.set(&2, String, MTip{}, "k", mk_str(4n, 65))
  +m1 = Map.set(&2, String, m0, "k", mk_str(6n, 97))
  v1 = get_s(Map.get(String, "MISS", m1, "k"))
  c = churn(64n, 0)
  v2 = get_s(Map.get(String, "MISS", m1, "k"))
  IO.print(v1 ++ "|" ++ v2 ++ "|" ++ U32.show(c))
''',
    ),
    # ------------------------------------------------------------------
    # 4. AGY-W2C-MAPFAST: Long keys (> 33 chars, pos >= 1100), empty key "", Unicode keys
    # ------------------------------------------------------------------
    (
        "map_long_keys_and_shared_child",
        r'''import Base

def get_u(r: Map<&2, U32> & U32) -> U32:
  (m, v) = r
  v

def main() -> IO(Unit):
  +k1 : String = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1"
  +k2 : String = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2"
  +k3 : String = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa10"
  m0 : Map<&2, U32> = MTip{}
  m1 = Map.set(&2, U32, m0, k1, 101)
  m2 = Map.set(&2, U32, m1, k2, 202)
  m3 = Map.set(&2, U32, m2, k3, 303)
  m4 = Map.set(&2, U32, m3, "", 404)
  m5 = Map.set(&2, U32, m4, "αβγδεζηθικλμνξοπρστυφχψω1", 505)
  +m6 = Map.set(&2, U32, m5, "αβγδεζηθικλμνξοπρστυφχψω2", 606)
  m7 = Map.set(&2, U32, m6, k2, 9999)
  v1 = get_u(Map.get(U32, 0, m6, k1))
  v2 = get_u(Map.get(U32, 0, m6, k2))
  v3 = get_u(Map.get(U32, 0, m6, k3))
  v4 = get_u(Map.get(U32, 0, m6, ""))
  v5 = get_u(Map.get(U32, 0, m6, "αβγδεζηθικλμνξοπρστυφχψω2"))
  w2 = get_u(Map.get(U32, 0, m7, k2))
  IO.print(U32.show(v1) ++ "," ++ U32.show(v2) ++ "," ++ U32.show(v3) ++ "," ++ U32.show(v4) ++ "," ++ U32.show(v5) ++ "|" ++ U32.show(w2))
''',
    ),
]


def run_upstream(src: Path) -> str:
    r = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                       capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        return f"UP_ERR({r.returncode}): {r.stderr.strip()[:200]}"
    return r.stdout.strip()


def run_x86(api: Path, src: Path, tag: str) -> str:
    obj = TMP_ROOT / f"{tag}.o"
    exe = TMP_ROOT / f"{tag}.exe"
    try:
        r = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                           capture_output=True, text=True, timeout=90)
        if r.returncode != 0:
            return f"EMIT_ERR({r.returncode}): {r.stderr.strip()[:200]}"
        r2 = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                            capture_output=True, text=True, timeout=30)
        if r2.returncode != 0:
            return f"LINK_ERR({r2.returncode}): {r2.stderr.strip()[:200]}"
        r3 = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
        if r3.returncode != 0:
            return f"RUN_ERR({r3.returncode}): {r3.stderr.strip()[:200]}"
        return r3.stdout.strip()
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    cand_api = Path(sys.argv[1])
    TMP_ROOT.mkdir(parents=True, exist_ok=True)
    failures = []
    for name, code in CASES:
        src = TMP_ROOT / f"{name}.bend"
        src.write_text(code)
        up = run_upstream(src)
        p205 = run_x86(BASE_API, src, f"{name}.p205")
        cand = run_x86(cand_api, src, f"{name}.cand")
        ok = (up == p205 == cand) and not up.startswith("UP_ERR")
        status = "PASS" if ok else "FAIL"
        print(f"[{name}] {status}", flush=True)
        print(f"  upstream : {up}", flush=True)
        print(f"  phase205 : {p205}", flush=True)
        print(f"  w2c_rec  : {cand}", flush=True)
        if not ok:
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL AUDIT FAILED ({len(failures)}/{len(CASES)} failures)!")
        sys.exit(1)
    print(f"\nALL {len(CASES)} TIER-2 ADVERSARIAL DIFFERENTIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
