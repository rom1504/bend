#!/usr/bin/env python3
"""Evaluate and SIGPROF-profile kmeans (size=13n) on CPU 2."""
import argparse, json, re, struct, subprocess, tempfile, time
from collections import Counter
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
PROF_C = ROOT / "research/agy/wave3_sc_algo/prof.c"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
LOCKED_NODE = str(ROOT / "research/agy/locked_node.sh")
BATCH_EMIT = str(ROOT / "research/agy/wave3_fuzz/batch_emit.mjs")


def decode_fid(sym):
    m = re.match(r"^(p111|p113d|p112w|p113i)_FID_([0-9_]+)_?$", sym)
    if not m:
        return sym
    prefix, nums = m.group(1), m.group(2).strip("_").split("_")
    name = "".join(chr(int(x)) for x in nums if x)
    return f"{prefix}({name})"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, default=ROOT / "selfhost/build/agy/wave5_r3/api.mjs")
    ap.add_argument("--size", type=int, default=13)
    ap.add_argument("--runs", type=int, default=1)
    ap.add_argument("--prof", action="store_true")
    args = ap.parse_args()

    with tempfile.TemporaryDirectory(prefix="w5r3_eval_") as td_s:
        td = Path(td_s)
        # Compile C reference at same size
        c_src = (ROOT / "research/agy/wave5_inputs/kmeans/main.c").read_text()
        c_src = c_src.replace("static uint32_t size(void) { return 19; }",
                              f"static uint32_t size(void) {{ return {args.size}; }}")
        c_tmp = td / "kmeans.c"; c_tmp.write_text(c_src)
        c_exe = td / "kmeans_c"
        subprocess.run([CC, "-O3", "-ffp-contract=off", str(c_tmp), "-lm", "-pthread", "-o", str(c_exe)], check=True)
        t0 = time.monotonic()
        rc_c = subprocess.run(["taskset", "-c", "2", str(c_exe)], capture_output=True, text=True, check=True)
        dt_c = time.monotonic() - t0
        c_out = rc_c.stdout.strip()
        print(f"C (size={args.size}n): out={c_out} time={dt_c:.4f}s", flush=True)

        # Emit Bend object
        b_src = (ROOT / "research/agy/wave5_inputs/kmeans/main.bend").read_text()
        b_src = b_src.replace("  19n\n", f"  {args.size}n\n")
        b_tmp = td / "kmeans.bend"; b_tmp.write_text(b_src)
        obj = td / "kmeans.o"
        mf = td / "mf.json"; mf.write_text(json.dumps([{"id": "km", "src": str(b_tmp), "out": str(obj)}]))
        t_em0 = time.monotonic()
        em = subprocess.run([LOCKED_NODE, "--stack-size=65536", BATCH_EMIT, str(args.api), str(mf)],
                            capture_output=True, text=True, check=True)
        t_em = time.monotonic() - t_em0
        em_res = json.loads(em.stdout)[0]
        print(f"Emit ({t_em:.2f}s): {em_res}", flush=True)
        if not em_res.get("ok"):
            return

        # Link clean binary (no prof)
        exe = td / "kmeans"
        subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)], check=True)
        times = []
        b_out = ""
        for _ in range(args.runs):
            t0 = time.monotonic()
            r = subprocess.run(["taskset", "-c", "2", str(exe)], capture_output=True, text=True, check=True)
            times.append(time.monotonic() - t0)
            b_out = r.stdout.strip()
        times.sort()
        med = times[len(times) // 2]
        match = (b_out == c_out)
        print(f"Bend (size={args.size}n): out={b_out} match={match} time={med:.4f}s ({med/dt_c:.2f}x C)", flush=True)

        # Symbol summary
        nm = subprocess.run(["nm", str(obj)], capture_output=True, text=True, check=True).stdout
        p113d_syms = []
        p111_k = 0
        for line in nm.splitlines():
            parts = line.split()
            if len(parts) >= 3 and parts[1] in ("T", "t"):
                d = decode_fid(parts[2])
                if d.startswith("p113d("):
                    p113d_syms.append(d[6:-1])
                elif d.startswith("p111($p111.k."):
                    p111_k += 1
        print(f"p113d funcs ({len(p113d_syms)}): {', '.join(sorted(p113d_syms))}")
        print(f"p111 $p111.k.* continuations: {p111_k}")

        if args.prof:
            prof_o = td / "prof.o"
            subprocess.run([CC, "-O2", "-c", str(PROF_C), "-o", str(prof_o)], check=True)
            exe_p = td / "kmeans_prof"
            subprocess.run([CC, "-no-pie", str(obj), str(RT), str(prof_o), "-pthread", "-lm", "-o", str(exe_p)], check=True)
            prof_out = td / "prof.bin"
            subprocess.run(["taskset", "-c", "2", str(exe_p)], env={"PROF_OUT": str(prof_out)},
                           capture_output=True, text=True, check=True)
            nm_p = subprocess.run(["nm", "-n", str(exe_p)], capture_output=True, text=True, check=True).stdout
            syms = []
            for line in nm_p.splitlines():
                parts = line.split()
                if len(parts) >= 3 and parts[1] in ("T", "t", "W", "w"):
                    syms.append((int(parts[0], 16), parts[2]))
            syms.sort()

            def resolve(pc):
                lo, hi = 0, len(syms) - 1
                ans = "<unknown>"
                while lo <= hi:
                    mid = (lo + hi) // 2
                    if syms[mid][0] <= pc:
                        ans = syms[mid][1]
                        lo = mid + 1
                    else:
                        hi = mid - 1
                return decode_fid(ans)

            data = prof_out.read_bytes()
            cnt = Counter()
            total = 0
            for i in range(0, len(data) - 15, 16):
                _, pc = struct.unpack_from("<QQ", data, i)
                cnt[resolve(pc)] += 1
                total += 1
            print(f"SIGPROF samples: {total}")
            for name, c in cnt.most_common(20):
                print(f"  {c:5d} ({100.0*c/max(total,1):5.1f}%)  {name}")


if __name__ == "__main__":
    main()
