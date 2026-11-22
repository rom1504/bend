#!/usr/bin/env python3
"""Verify Wave 2C (AGY-W2C-1 Certified In-Place Radix-Trie Map.set & Map.del):
5 comprehensive adversarial upstream differential tests + 19/19 focused19.
"""
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
UPSTREAM = ROOT / "bend2/main.ts"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

DIGEST_HELPERS = """
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

ADVERSARIAL_TESTS = {
    "map_rfc_shared": "import Base\n" + DIGEST_HELPERS + """
def use_shared(+m: Map<&2, U32>) -> U32:
  m1 = Map.set(&2, U32, m, "alpha", 999)
  m2 = Map.set(&2, U32, m, "zeta", 777)
  m3 = Map.del(&2, U32, m, "beta")
  h0 = hash_map(m)
  h1 = hash_map(m1)
  h2 = hash_map(m2)
  h3 = hash_map(m3)
  U32.xor(h0, U32.add(h1, U32.add(U32.mul(h2, 7), U32.mul(h3, 13))))

def main() -> IO(Unit):
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "alpha", 1)
  m = Map.set(&2, U32, m, "beta", 2)
  m = Map.set(&2, U32, m, "gamma", 3)
  IO.print(U32.show(use_shared(m)))
""",
    "map_static_root": "import Base\n" + DIGEST_HELPERS + """
def static_m() -> Map<&2, U32>:
  MLeaf{"init", 42}

def loop(n: Nat, +i: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      m1 = Map.set(&2, U32, static_m(), U32.show(i), i)
      m2 = Map.del(&2, U32, m1, "init")
      loop(p, U32.add(i, 1), U32.add(U32.mul(acc, 17), hash_map(m2)))

def main() -> IO(Unit):
  IO.print(U32.show(loop(8n, 1, 0)))
""",
    "map_edge_keys": "import Base\n" + DIGEST_HELPERS + """
def shared_key(+k: String, m: Map<&2, U32>) -> Map<&2, U32>:
  m = Map.set(&2, U32, m, k, 111)
  m = Map.set(&2, U32, m, k, 222)
  m

def main() -> IO(Unit):
  # Empty map del, root leaf del -> MTip, empty string "", prefix chains, shared keys, miss del
  m = Map.del(&2, U32, Map.new(&2, U32), "nope")
  m = Map.set(&2, U32, m, "only", 5)
  m = Map.del(&2, U32, m, "only")
  m = Map.set(&2, U32, m, "", 10)
  m = Map.set(&2, U32, m, "a", 20)
  m = Map.set(&2, U32, m, "ab", 30)
  m = Map.set(&2, U32, m, "abc", 40)
  m = Map.set(&2, U32, m, "a", 25)
  m = Map.set(&2, U32, m, "", 15)
  m = shared_key("dupkey", m)
  m = Map.del(&2, U32, m, "ab")
  m = Map.del(&2, U32, m, "missing")
  m = Map.del(&2, U32, m, "")
  IO.print(U32.show(hash_map(m)))
""",
    "map_long_key_bailout": "import Base\n" + DIGEST_HELPERS + """
def long_k1() -> String:
  "0123456789012345678901234567890123456789012345678901234567890123456789_A"

def long_k2() -> String:
  "0123456789012345678901234567890123456789012345678901234567890123456789_B"

def main() -> IO(Unit):
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "short", 1)
  m = Map.set(&2, U32, m, long_k1(), 100)
  m = Map.set(&2, U32, m, long_k2(), 200)
  m = Map.set(&2, U32, m, long_k1(), 150)
  m = Map.del(&2, U32, m, long_k2())
  IO.print(U32.show(hash_map(m)))
""",
    "map_heap_values": "import Base\n" + """
def s_hash(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{x}, t}: s_hash(t, U32.add(U32.mul(acc, 31), x))

def ms_digest(xs: List<&2, Sigma<&2, &2, String, _ => String>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: ms_digest(t, U32.xor(s_hash(k, acc), s_hash(v, 17)))

def get_str3(r2: Map<&2, String> & String, v1: String) -> U32:
  (m2, v2) = r2
  U32.xor(ms_digest(Map.to_list(&2, String, m2), 1), U32.add(s_hash(v1, 3), s_hash(v2, 7)))

def get_str2(r1: Map<&2, String> & String) -> U32:
  (m1, v1) = r1
  get_str3(Map.get(String, "def2", m1, "missing"), v1)

def main() -> IO(Unit):
  m = Map.new(&2, String)
  m = Map.set(&2, String, m, "k1", "hello")
  m = Map.set(&2, String, m, "k2", "world")
  m = Map.set(&2, String, m, "k3", "bend")
  m = Map.set(&2, String, m, "k1", "updated_val")
  m = Map.del(&2, String, m, "k2")
  IO.print(U32.show(get_str2(Map.get(String, "def1", m, "k1"))))
""",
    "map_get_shared_unicode": "import Base\n" + DIGEST_HELPERS + """
def step4(r4: Map<&2, U32> & U32, m3: Map<&2, U32>, v1: U32, v2: U32, v3: U32) -> U32:
  (m4, v4) = r4
  U32.add(v1, U32.add(U32.mul(v2, 3), U32.add(U32.mul(v3, 5), U32.add(U32.mul(v4, 7), U32.xor(hash_map(m3), hash_map(m4))))))

def step3(r3: Map<&2, U32> & U32, m: Map<&2, U32>, v1: U32, v2: U32) -> U32:
  (m3, v3) = r3
  step4(Map.get(U32, 666, m, ""), m3, v1, v2, v3)

def step2(r2: Map<&2, U32> & U32, m: Map<&2, U32>, v1: U32) -> U32:
  (m2, v2) = r2
  step3(Map.get(U32, 777, m2, "missing"), m, v1, v2)

def step1(r1: Map<&2, U32> & U32, m: Map<&2, U32>) -> U32:
  (m1, v1) = r1
  step2(Map.get(U32, 888, m1, "部門10"), m, v1)

def probe_shared(+m: Map<&2, U32>) -> U32:
  step1(Map.get(U32, 999, m, "部門0"), m)

def run_with_v0(r0: Map<&2, U32> & U32) -> U32:
  (m, v0) = r0
  m = Map.set(&2, U32, m, "部門0", 100)
  m = Map.set(&2, U32, m, "部門1", 200)
  m = Map.set(&2, U32, m, "部門10", 300)
  m = Map.set(&2, U32, m, "", 400)
  U32.add(v0, probe_shared(m))

def main() -> IO(Unit):
  IO.print(U32.show(run_with_v0(Map.get(U32, 123, Map.new(&2, U32), "empty"))))
""",
}

def run_cmd(cmd, timeout=60):
    return subprocess.run(list(map(str, cmd)), capture_output=True, text=True, timeout=timeout)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, required=True)
    ap.add_argument("--rt", type=Path, default=RT_OBJ)
    a = ap.parse_args()

    failed = []
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        print(f"=== Wave 2C Adversarial Upstream Differential Tests ({len(ADVERSARIAL_TESTS)}) ===")
        for name, src_text in ADVERSARIAL_TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(src_text.lstrip())
            up = run_cmd([BUN, UPSTREAM, src])
            if up.returncode != 0:
                print(f"  [FAIL] {name}: upstream failed: {up.stderr.strip()}")
                failed.append(name)
                continue
            obj = td / f"{name}.o"
            binp = td / f"{name}.bin"
            c1 = run_cmd([BUN, EMIT_OBJ, a.api, src, obj])
            if c1.returncode != 0:
                print(f"  [FAIL] {name}: emit_obj failed: {c1.stderr.strip()[:200]}")
                failed.append(name)
                continue
            c2 = run_cmd([CC, "-O2", "-no-pie", obj, a.rt, "-o", binp, "-lm", "-pthread"])
            if c2.returncode != 0:
                print(f"  [FAIL] {name}: link failed: {c2.stderr.strip()[:200]}")
                failed.append(name)
                continue
            ev = run_cmd([binp])
            if ev.returncode != 0 or ev.stdout != up.stdout:
                print(f"  [FAIL] {name}: mismatch! upstream={up.stdout!r} cand={ev.stdout!r} rc={ev.returncode}")
                failed.append(name)
            else:
                print(f"  [PASS] {name}: {ev.stdout.strip()!r}")

        cat = json.loads(QUAL_CAT.read_text())
        focused = [c for c in cat["cases"] if c["suite"] == "focused"]
        print(f"\n=== focused19 ({len(focused)} cases) ===")
        for c in focused:
            cid = c["id"]
            src = ROOT / c["source"]["file"]
            exp = c["expect"]
            obj = td / f"{c['name']}.o"
            binp = td / f"{c['name']}.bin"
            c1 = run_cmd([BUN, EMIT_OBJ, a.api, src, obj])
            if exp["stage"] != "execute":
                if c1.returncode != 0:
                    print(f"  [PASS] {cid} (expected refusal)")
                else:
                    print(f"  [FAIL] {cid}: expected refusal, but compiled!")
                    failed.append(cid)
                continue
            if c1.returncode != 0:
                print(f"  [FAIL] {cid}: emit_obj failed: {c1.stderr.strip()[:200]}")
                failed.append(cid)
                continue
            c2 = run_cmd([CC, "-O2", "-no-pie", obj, a.rt, "-o", binp, "-lm", "-pthread"])
            if c2.returncode != 0:
                print(f"  [FAIL] {cid}: link failed: {c2.stderr.strip()[:200]}")
                failed.append(cid)
                continue
            ev = run_cmd([binp])
            if ev.returncode != exp["exitCode"] or ev.stdout != exp["stdout"] or ev.stderr != exp["stderr"]:
                print(f"  [FAIL] {cid}: rc={ev.returncode} stdout={ev.stdout!r} exp={exp['stdout']!r}")
                failed.append(cid)
            else:
                print(f"  [PASS] {cid}")

    total = len(ADVERSARIAL_TESTS) + len(focused)
    print(f"\nSUMMARY: {total - len(failed)} / {total} PASS")
    if failed:
        print("FAILED:", failed)
        sys.exit(1)

if __name__ == "__main__":
    main()
