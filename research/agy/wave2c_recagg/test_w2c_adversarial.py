#!/usr/bin/env python3
"""
Adversarial & boundary differential test suite for Wave 2C passes:
- AGY-W2C-MAPFAST (Map.get + Map.set with owned 0x02, uniquely-owned 0x82 rc=1, and shared 0x82 rc>=2)
- AGY-W2C-LISTAPP (in-place owned TRMC List/String append with shared-prefix/shared-tail/renamed-ADT guards)
- AGY-W2C-ARRLIST (raw Array<U32> Array.to_list.go with non-empty acc, shared array, and boxed Array<String> bailout)

Compares native x86 output (cand API + runtime-agy.o) against upstream Bend (bun bend2/main.ts).
"""
import subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"

TESTS = {
    "map_shared_immutability": r'''import Base

def build(n: Nat, +u: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      +k = String.append("k", U32.show(u))
      build(p, U32.add(u, 1), Map.set(&2, U32, m, k, U32.mul(u, 10)))

def snd_u32(r: Map<&2, U32> & U32) -> U32:
  (m, v) = r
  v

def main() -> String:
  +m0 = build(12n, 1, Map.new(&2, U32))
  # Mutate m1..m3 while m0 stays live (shared rc >= 2!): m0 MUST NOT change!
  m1 = Map.set(&2, U32, m0, "k5", 9999)
  m2 = Map.set(&2, U32, m1, "k1", 8888)
  +m3 = Map.set(&2, U32, m2, "newkey", 7777)
  v0_5 = snd_u32(Map.get(U32, 0, m0, "k5"))
  v0_1 = snd_u32(Map.get(U32, 0, m0, "k1"))
  v0_n = snd_u32(Map.get(U32, 42, m0, "newkey"))
  v3_5 = snd_u32(Map.get(U32, 0, m3, "k5"))
  v3_1 = snd_u32(Map.get(U32, 0, m3, "k1"))
  v3_n = snd_u32(Map.get(U32, 0, m3, "newkey"))
  String.append(U32.show(v0_5), String.append(",",
    String.append(U32.show(v0_1), String.append(",",
    String.append(U32.show(v0_n), String.append("|",
    String.append(U32.show(v3_5), String.append(",",
    String.append(U32.show(v3_1), String.append(",", U32.show(v3_n)))))))))))
''',

    "map_unicode_prefix_wraparound": r'''import Base

def snd_u32(r: Map<&2, U32> & U32) -> U32:
  (m, v) = r
  v

def bump(k: String, d: U32, r: Map<&2, U32> & U32) -> Map<&2, U32>:
  (m, cur) = r
  Map.set(&2, U32, m, k, U32.add(cur, d))

def main() -> String:
  +m0 = Map.new(&2, U32)
  g0 = snd_u32(Map.get(U32, 77, m0, ""))
  m2 = Map.set(&2, U32, m0, "", 1)
  m3 = Map.set(&2, U32, m2, "a", 2)
  m4 = Map.set(&2, U32, m3, "ab", 3)
  m5 = Map.set(&2, U32, m4, "部門0", 4294967295)
  m6 = Map.set(&2, U32, m5, "部門10", 100)
  +m8 = bump("部門0", 5, Map.get(U32, 0, m6, "部門0"))
  v_emp = snd_u32(Map.get(U32, 99, m8, ""))
  v_a = snd_u32(Map.get(U32, 99, m8, "a"))
  v_ab = snd_u32(Map.get(U32, 99, m8, "ab"))
  v_u0 = snd_u32(Map.get(U32, 99, m8, "部門0"))
  v_u10 = snd_u32(Map.get(U32, 99, m8, "部門10"))
  v_miss = snd_u32(Map.get(U32, 99, m8, "部門1"))
  String.append(U32.show(g0), String.append(",",
    String.append(U32.show(v_emp), String.append(",",
    String.append(U32.show(v_a), String.append(",",
    String.append(U32.show(v_ab), String.append(",",
    String.append(U32.show(v_u0), String.append(",",
    String.append(U32.show(v_u10), String.append(",", U32.show(v_miss)))))))))))))
''',

    "map_boxed_string_values": r'''import Base

def snd_str(r: Map<&2, String> & String) -> String:
  (m, v) = r
  v

def main() -> String:
  m0 = Map.new(&2, String)
  m1 = Map.set(&2, String, m0, "k1", "alpha")
  m2 = Map.set(&2, String, m1, "k2", "beta")
  +m3 = Map.set(&2, String, m2, "k1", "ALPHA_NEW")
  s1 = snd_str(Map.get(String, "none", m3, "k1"))
  s2 = snd_str(Map.get(String, "none", m3, "k2"))
  s3 = snd_str(Map.get(String, "MISS", m3, "k3"))
  String.append(s1, String.append("|", String.append(s2, String.append("|", s3))))
''',

    "list_string_append_shared_and_renamed": r'''import Base

type MySeq is Data:
  MyNil{}
  MyCon{head: U32, tail: MySeq}

def my_app(a: MySeq, b: MySeq) -> MySeq:
  match a:
    case MyNil{}: b
    case MyCon{h, t}: MyCon{h, my_app(t, b)}

def my_sum(xs: MySeq, acc: U32) -> U32:
  match xs:
    case MyNil{}: acc
    case MyCon{h, t}: my_sum(t, U32.add(acc, h))

def main() -> String:
  # Shared String prefix: appending to s1 MUST NOT mutate s0!
  +s0 = String.append("hel", "lo")
  s1 = String.append(s0, "_world")
  s2 = String.append(s0, "_bend")
  # Shared tail inside owned prefix!
  +tail = String.append("T", "AIL")
  p1 = String.append(SCon{'A', SCon{'B', tail}}, "_1")
  p2 = String.append(SCon{'X', SCon{'Y', tail}}, "_2")
  # Empty cases
  e1 = String.append("", "rhs")
  e2 = String.append("lhs", "")
  # User-defined renamed list ADT (both owned and shared!)
  +q0 = my_app(MyCon{1, MyCon{2, MyNil{}}}, MyCon{3, MyNil{}})
  q1 = my_app(q0, MyCon{10, MyNil{}})
  q2 = my_app(q0, MyCon{20, MyNil{}})
  String.append(s0, String.append("|",
    String.append(s1, String.append("|",
    String.append(s2, String.append("|",
    String.append(p1, String.append("|",
    String.append(p2, String.append("|",
    String.append(e1, String.append("|",
    String.append(e2, String.append("|",
    String.append(U32.show(my_sum(q0, 0)), String.append(",",
    String.append(U32.show(my_sum(q1, 0)), String.append(",",
    U32.show(my_sum(q2, 0))))))))))))))))))))
''',

    "array_tolist_edges": r'''import Base

def sum_list(xs: List<U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: sum_list(t, U32.add(acc, h))

def fill_idx(n: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p:
      fill_idx(p, U32.add(i, 1), Array.set(U32, a, i, U32.add(i, 1)))

def take2_str(xs: List<String>) -> String:
  match xs:
    case Con{h1, Con{h2, Nil{}}}: String.append(h1, h2)
    case _: "bad"

def main() -> String:
  # 1-element raw Array<U32>
  a1 = Array.set(U32, Array.new(U32, 0n, 0), 0, 42)
  l1 = Array.to_list(U32, a1)
  # 16-element raw Array<U32> with non-empty acc and empty acc
  a16a = fill_idx(16n, 0, Array.new(U32, 4n, 0))
  l16a = Array.to_list.go(U32, a16a, Con{1000, Nil{}})
  a16b = fill_idx(16n, 0, Array.new(U32, 4n, 0))
  l16b = Array.to_list(U32, a16b)
  # Boxed Array<String> (non-U32 -> must bail cleanly to slow path!)
  as2 = Array.set(String, Array.new(String, 1n, "x"), 1, "y")
  ls2 = Array.to_list(String, as2)
  s_out = take2_str(ls2)
  String.append(U32.show(sum_list(l1, 0)), String.append(",",
    String.append(U32.show(sum_list(l16a, 0)), String.append(",",
    String.append(U32.show(sum_list(l16b, 0)), String.append("|", s_out))))))
'''
}

def main():
    api = Path(sys.argv[1])
    ok = 0
    with tempfile.TemporaryDirectory(prefix="w2c_adv_") as td:
        td = Path(td)
        for name, code in TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(code)
            # Upstream reference
            ref = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                                 capture_output=True, text=True, check=True)
            ref_out = ref.stdout.strip()
            # Candidate native x86
            obj = td / f"{name}.o"
            exe = td / f"{name}.exe"
            subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                           capture_output=True, text=True, check=True)
            subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                           capture_output=True, text=True, check=True)
            cand = subprocess.run([str(exe)], capture_output=True, text=True, check=True)
            cand_out = cand.stdout.strip()
            if cand_out == ref_out:
                print(f"PASS  {name:38s}  out={cand_out}")
                ok += 1
            else:
                print(f"FAIL  {name:38s}\n  ref ={ref_out}\n  cand={cand_out}")
                sys.exit(1)
    print(f"\nALL {ok}/{len(TESTS)} ADVERSARIAL DIFFERENTIAL TESTS PASSED!")

if __name__ == "__main__":
    main()
