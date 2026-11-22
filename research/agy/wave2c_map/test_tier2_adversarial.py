#!/usr/bin/env python3
"""Tier-2 Adversarial Differential Test Suite for Wave 2C-Map (AGY-W2C-1).

Tests `apply_map_fast.py` (prebuilt `/home/ai/bend2_agy/selfhost/build/agy/wave2c_map/api.mjs`)
against BOTH:
  1. Upstream Bend (`bun bend2/main.ts`)
  2. Phase 205 baseline (`selfhost/build/agy/api-base/api.mjs`)
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
CAND_API = ROOT / "selfhost/build/agy/wave2c_map/api.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
TMP = ROOT / "selfhost/build/agy/tier2_audit_w2c_map/adv_tmp"

HELPERS = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)

def s_hash(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{x}, t}: s_hash(t, U32.add(U32.mul(acc, 31), x))

def m_digest(xs: List<&2, Sigma<&2, &2, String, _ => U32>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: m_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), v))

def hash_map(m: Map<&2, U32>) -> U32:
  m_digest(Map.to_list(&2, U32, m), 2166136261)
"""

TESTS = {
    "1_map_static_and_shared_sibling_del": "import Base\n" + HELPERS + """
def static_branch() -> Map<&2, U32>:
  MNode{24n, MLeaf{"a", 10}, MLeaf{"b", 20}}

def use_shared_branch(+sub: Map<&2, U32>, +z: U32) -> U32:
  # Insert a fresh sibling next to a shared 0x82 subtree, then delete the fresh leaf!
  m = Map.set(&2, U32, sub, "zzz", U32.add(z, 99))
  m_del = Map.del(&2, U32, m, "zzz")
  m_upd = Map.set(&2, U32, sub, "a", U32.add(z, 777))
  m_del2 = Map.del(&2, U32, sub, "a")
  U32.xor(hash_map(sub), U32.add(hash_map(m_del), U32.add(U32.mul(hash_map(m_upd), 3), U32.mul(hash_map(m_del2), 5))))

def loop_static(n: Nat, +i: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      m1 = Map.set(&2, U32, static_branch(), "a", U32.add(i, 100))
      m2 = Map.del(&2, U32, static_branch(), "b")
      m3 = Map.set(&2, U32, static_branch(), "c", i)
      h = U32.xor(hash_map(m1), U32.add(hash_map(m2), hash_map(m3)))
      loop_static(p, U32.add(i, 1), U32.xor(U32.mul(acc, 16777619), h))

def main() -> IO(Unit):
  +z = dyn_zero()
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "a", U32.add(z, 1))
  m = Map.set(&2, U32, m, "b", U32.add(z, 2))
  m = Map.set(&2, U32, m, "c", U32.add(z, 3))
  +r1 = use_shared_branch(m, z)
  +r2 = loop_static(U32.to_nat(U32.add(z, 6)), 1, 0)
  IO.print(U32.show(U32.xor(r1, r2)))
""",
    "2_map_del_all_shapes_and_heap_vals": "import Base\n" + HELPERS + """
def ms_digest(xs: List<&2, Sigma<&2, &2, String, _ => String>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: ms_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), s_hash(v, 31)))

def main() -> IO(Unit):
  +z = dyn_zero()
  # Empty del, root leaf del -> MTip, 2-leaf collapse, 4-leaf interior collapse, missing del
  m = Map.new(&2, String)
  m = Map.del(&2, String, m, "empty_miss")
  m = Map.set(&2, String, m, "solo", String.append("val_", U32.show(z)))
  m = Map.del(&2, String, m, "solo")
  m = Map.set(&2, String, m, "k1", String.append("one_", U32.show(U32.add(z, 1))))
  m = Map.set(&2, String, m, "k2", String.append("two_", U32.show(U32.add(z, 2))))
  m = Map.del(&2, String, m, "k1")
  m = Map.set(&2, String, m, "k3", String.append("three_", U32.show(U32.add(z, 3))))
  m = Map.set(&2, String, m, "k4", String.append("four_", U32.show(U32.add(z, 4))))
  m = Map.set(&2, String, m, "k5", String.append("five_", U32.show(U32.add(z, 5))))
  m = Map.set(&2, String, m, "k3", String.append("three_upd_", U32.show(U32.add(z, 6))))
  m = Map.del(&2, String, m, "k4")
  m = Map.del(&2, String, m, "missing_key")
  m = Map.del(&2, String, m, "k2")
  IO.print(U32.show(ms_digest(Map.to_list(&2, String, m), 17)))
""",
    "3_map_key_len_63_64_65_and_unicode": "import Base\n" + HELPERS + """
def k63() -> String:
  "012345678901234567890123456789012345678901234567890123456789012"

def k64() -> String:
  "0123456789012345678901234567890123456789012345678901234567890123"

def k65a() -> String:
  "0123456789012345678901234567890123456789012345678901234567890123A"

def k65b() -> String:
  "0123456789012345678901234567890123456789012345678901234567890123B"

def get_u32(r: Map<&2, U32> & U32) -> U32:
  (m, v) = r
  U32.xor(hash_map(m), v)

def main() -> IO(Unit):
  +z = dyn_zero()
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "", U32.add(z, 1))
  m = Map.set(&2, U32, m, k63(), U32.add(z, 63))
  m = Map.set(&2, U32, m, k64(), U32.add(z, 64))
  m = Map.set(&2, U32, m, k65a(), U32.add(z, 65))
  m = Map.set(&2, U32, m, k65b(), U32.add(z, 66))
  m = Map.set(&2, U32, m, "αβγ", U32.add(z, 100))
  m = Map.set(&2, U32, m, "日本語", U32.add(z, 200))
  m = Map.set(&2, U32, m, "\\u{1f600}", U32.add(z, 300))
  m = Map.set(&2, U32, m, k64(), U32.add(z, 640))
  m = Map.del(&2, U32, m, k65a())
  m = Map.del(&2, U32, m, "αβγ")
  IO.print(U32.show(get_u32(Map.get(U32, 999, m, "\\u{1f600}"))))
""",
    "4_map_unsealed_heap_val_then_share": "import Base\n" + HELPERS + """
def ms_digest(xs: List<&2, Sigma<&2, &2, String, _ => String>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: ms_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), s_hash(v, 31)))

def share_map(+m: Map<&2, String>) -> U32:
  m1 = Map.set(&2, String, m, "k1", "replaced")
  m2 = Map.del(&2, String, m, "k2")
  U32.xor(ms_digest(Map.to_list(&2, String, m), 1),
    U32.add(ms_digest(Map.to_list(&2, String, m1), 3), ms_digest(Map.to_list(&2, String, m2), 7)))

def main() -> IO(Unit):
  +z = dyn_zero()
  # Freshly allocated 0x02 strings stored into Map, then Map is shared (+m)!
  m = Map.new(&2, String)
  m = Map.set(&2, String, m, "k1", String.append("fresh_a_", U32.show(U32.add(z, 11))))
  m = Map.set(&2, String, m, "k2", String.append("fresh_b_", U32.show(U32.add(z, 22))))
  m = Map.set(&2, String, m, "k3", String.append("fresh_c_", U32.show(U32.add(z, 33))))
  m = Map.set(&2, String, m, "k1", String.append("fresh_a2_", U32.show(U32.add(z, 44))))
  IO.print(U32.show(share_map(m)))
""",
    "5_map_heavy_churn_200_keys": "import Base\n" + HELPERS + """
def fill(n: Nat, +i: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n: m
    case 1n+p: fill(p, U32.add(i, 1), Map.set(&2, U32, m, String.append("key_", U32.show(i)), U32.mul(i, 17)))

def upd(n: Nat, +i: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n: m
    case 1n+p: upd(p, U32.add(i, 2), Map.set(&2, U32, m, String.append("key_", U32.show(i)), U32.add(i, 999)))

def drop_evens(n: Nat, +i: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n: m
    case 1n+p: drop_evens(p, U32.add(i, 2), Map.del(&2, U32, m, String.append("key_", U32.show(i))))

def main() -> IO(Unit):
  +z = dyn_zero()
  m = fill(U32.to_nat(U32.add(z, 200)), 0, Map.new(&2, U32))
  m = upd(U32.to_nat(U32.add(z, 100)), 0, m)
  m = drop_evens(U32.to_nat(U32.add(z, 100)), 0, m)
  IO.print(U32.show(hash_map(m)))
""",
}


def run_upstream(src: Path) -> str:
    r = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                       capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        return f"UP_ERR({r.returncode}): {r.stderr.strip()[:200]}"
    return r.stdout


def run_x86(api: Path, rt: Path, src: Path, tag: str) -> str:
    obj = TMP / f"{tag}.o"
    exe = TMP / f"{tag}.exe"
    try:
        em = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                            capture_output=True, text=True, timeout=60)
        if em.returncode != 0:
            return f"EMIT_ERR({em.returncode}): {em.stderr.strip()[:200]}"
        lk = subprocess.run([CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
                            capture_output=True, text=True, timeout=30)
        if lk.returncode != 0:
            return f"LINK_ERR({lk.returncode}): {lk.stderr.strip()[:200]}"
        run = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
        if run.returncode != 0:
            return f"RUN_ERR({run.returncode}): {run.stderr.strip()[:200]}"
        if run.stderr:
            return f"STDERR: {run.stderr.strip()[:200]}"
        return run.stdout
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    TMP.mkdir(parents=True, exist_ok=True)
    failures = []
    for name, code in TESTS.items():
        src = TMP / f"{name}.bend"
        src.write_text(code)
        up = run_upstream(src)
        p205 = run_x86(BASE_API, P205_RT, src, f"{name}.p205")
        cand = run_x86(CAND_API, AGY_RT, src, f"{name}.cand")
        ok = (up == p205 == cand) and not up.startswith("UP_ERR")
        status = "PASS" if ok else "FAIL"
        print(f"{status:4s} {name:40s} up={up.strip()!r}", flush=True)
        if not ok:
            print(f"     p205={p205.strip()!r}", flush=True)
            print(f"     cand={cand.strip()!r}", flush=True)
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL SUITE FAILED: {len(failures)}/{len(TESTS)} failures!")
        sys.exit(1)
    print(f"\nTIER-2 ADVERSARIAL SUITE PASSED: {len(TESTS)}/{len(TESTS)} (upstream == Phase205 == Wave 2C-Map)!")


if __name__ == "__main__":
    main()
