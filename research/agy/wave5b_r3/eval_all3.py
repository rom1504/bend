#!/usr/bin/env python3
"""Evaluate, SIGPROF-profile, and optionally disassemble kmeans (13n), bfs (15n), merkle (18n) on CPU 2."""
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


def prep_bench(name, td):
    if name == "kmeans":
        c_src = (ROOT / "research/agy/wave5_inputs/kmeans/main.c").read_text()
        c_src = c_src.replace("static uint32_t size(void) { return 19; }", "static uint32_t size(void) { return 13; }")
        b_src = (ROOT / "research/agy/wave5_inputs/kmeans/main.bend").read_text()
        b_src = b_src.replace("  19n\n", "  13n\n")
    elif name == "bfs":
        c_src = (ROOT / "research/agy/wave5_inputs/bfs/main.c").read_text()
        c_src = c_src.replace("#define DEPTH 19", "#define DEPTH 15")
        b_src = (ROOT / "research/agy/wave5_inputs/bfs/main.bend").read_text()
        b_src = b_src.replace("  19n\n", "  15n\n")
    elif name == "merkle":
        c_src = (ROOT / "research/agy/wave5_inputs/merkle/main.c").read_text()
        c_src = c_src.replace("#define SIZE 22", "#define SIZE 18")
        b_src = (ROOT / "research/agy/wave5_inputs/merkle/main.bend").read_text()
        b_src = b_src.replace("build!(22n, 0)", "build!(18n, 0)").replace("pgen!(22n, 1337, 0)", "pgen!(18n, 1337, 0)")
    else:
        raise ValueError(name)
    c_p = td / f"{name}.c"; c_p.write_text(c_src)
    b_p = td / f"{name}.bend"; b_p.write_text(b_src)
    return c_p, b_p


def run_one(name, api, runs, prof, dump_dir, td):
    c_p, b_p = prep_bench(name, td)
    c_exe = td / f"{name}_c"
    subprocess.run([CC, "-O3", "-ffp-contract=off", str(c_p), "-lm", "-pthread", "-o", str(c_exe)], check=True)
    c_times = []
    c_out = ""
    for _ in range(runs):
        t0 = time.monotonic()
        r = subprocess.run(["taskset", "-c", "2", str(c_exe)], capture_output=True, text=True, check=True)
        c_times.append(time.monotonic() - t0)
        c_out = r.stdout.strip()
    c_times.sort()
    dt_c = c_times[len(c_times) // 2]

    obj = td / f"{name}.o"
    mf = td / f"{name}_mf.json"
    mf.write_text(json.dumps([{"id": name, "src": str(b_p), "out": str(obj)}]))
    t_em0 = time.monotonic()
    em = subprocess.run([LOCKED_NODE, "--stack-size=65536", BATCH_EMIT, str(api), str(mf)],
                        capture_output=True, text=True, check=True)
    t_em = time.monotonic() - t_em0
    em_res = json.loads(em.stdout)[0]
    if not em_res.get("ok"):
        print(f"=== {name} === EMIT FAILED: {em_res}", flush=True)
        return

    exe = td / f"{name}_b"
    subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)], check=True)
    b_times = []
    b_out = ""
    for _ in range(runs):
        t0 = time.monotonic()
        r = subprocess.run(["taskset", "-c", "2", str(exe)], capture_output=True, text=True, check=True)
        b_times.append(time.monotonic() - t0)
        b_out = r.stdout.strip()
    b_times.sort()
    dt_b = b_times[len(b_times) // 2]
    match = (b_out == c_out)

    nm = subprocess.run(["nm", str(obj)], capture_output=True, text=True, check=True).stdout
    p113d_syms, p111_k = [], 0
    for line in nm.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t"):
            d = decode_fid(parts[2])
            if d.startswith("p113d("):
                p113d_syms.append(d[6:-1])
            elif d.startswith("p111($p111.k."):
                p111_k += 1

    print(f"=== {name} === C={dt_c*1000:.1f}ms  Bend={dt_b*1000:.1f}ms ({dt_b/dt_c:.2f}x C)  out={b_out} match={match}  emit={t_em:.2f}s  p113d={len(p113d_syms)}  p111.k={p111_k}", flush=True)

    if dump_dir:
        dump_dir.mkdir(parents=True, exist_ok=True)
        dis = subprocess.run(["objdump", "-d", str(obj)], capture_output=True, text=True, check=True).stdout
        (dump_dir / f"{name}.s").write_text(dis)
        (dump_dir / f"{name}.nm").write_text("\n".join(
            f"{l}  # {decode_fid(l.split()[2])}" if len(l.split()) >= 3 else l
            for l in nm.splitlines()
        ) + "\n")

    if prof:
        prof_o = td / "prof.o"
        if not prof_o.exists():
            subprocess.run([CC, "-O2", "-c", str(PROF_C), "-o", str(prof_o)], check=True)
        exe_p = td / f"{name}_prof"
        subprocess.run([CC, "-no-pie", str(obj), str(RT), str(prof_o), "-pthread", "-lm", "-o", str(exe_p)], check=True)
        prof_out = td / f"{name}_prof.bin"
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
        print(f"  SIGPROF ({total} samples):", flush=True)
        for sname, c in cnt.most_common(12):
            print(f"    {c:5d} ({100.0*c/max(total,1):5.1f}%)  {sname}", flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, default=ROOT / "selfhost/build/agy/wave5a_unified/api.mjs")
    ap.add_argument("--benches", nargs="+", default=["kmeans", "bfs", "merkle"])
    ap.add_argument("--runs", type=int, default=1)
    ap.add_argument("--prof", action="store_true")
    ap.add_argument("--dump-dir", type=Path, default=None)
    args = ap.parse_args()
    with tempfile.TemporaryDirectory(prefix="w5br3_") as td_s:
        td = Path(td_s)
        for b in args.benches:
            run_one(b, args.api, args.runs, args.prof, args.dump_dir, td)


if __name__ == "__main__":
    main()
