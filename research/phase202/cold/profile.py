"""Symbolize an exact non-PIE native compiler profile, including sample-order windows."""
import argparse
from bisect import bisect_right
from collections import Counter
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

def sha(path):
    with open(path, "rb") as f:
        digest = hashlib.sha256()
        for block in iter(lambda: f.read(1048576), b""):
            digest.update(block)
        return digest.hexdigest()

def demangle(name):
    m = re.fullmatch(r'p(?:111|113d)_FID_((?:[0-9]+_)+)', name)
    if m:
        return ''.join(chr(int(code)) for code in m[1][:-1].split('_'))
    return name

def group(name):
    for prefix in ("$direct.", "$p118borrow.read.", "$p128borrow.owned."):
        if name.startswith(prefix):
            name = name[len(prefix):]
    if name.startswith(("p125_rt_take", "p111_rt_take")):
        return "runtime field extraction"
    if name in {"term_drop","p201_term_drop_slow", "span_fade", "term_sink", "term_keep","p111_rt_sink","p111_rt_keep"}:
        return "reference counts and destruction"
    if name == "unresolved":
        return "unresolved"
    if name.startswith(("$p111.k.", "p111.k.")):
        return "unattributed continuation"
    if name.startswith(("x18","x19","x20")):
        return "named x86 functions"
    if name.startswith(("p88_string","index_hash","String.order","p88_index_hash","String.")):
        return "named string/hash functions"
    if name.startswith("p111_rt_"):
        return "native runtime helpers"
    return "other named functions"

def phase_markers(names, meta):
    # The sampling stream stores each thread separately. Secondary CPU time is
    # below one sampling period here, so all PCs are from the main thread.
    period = int(meta["period_us"]) / 1_000_000
    if int(meta["sampled_thread_cpu_ns"]) - int(meta["main_thread_cpu_ns"]) >= period * 1e9 or int(meta["overruns"]):
        return {}
    root = Path(__file__).resolve().parents[3] / "selfhost/build/phase198/progress-portfolio01/maintained/src"
    out = {}
    for label, pattern in [("front","front/*.bend"),("check","check/*.bend"),("sharedNative","back/native/*.bend"),("qbePlanning","back/qbe/*.bend"),("x86","back/x86/*.bend"),
                           ("objectEncoding","back/x86/object-encode.bend"),("elfWriter","back/x86/object-elf.bend")]:
        declared = set()
        for f in root.glob(pattern):
            declared.update(re.findall(r"(?m)^def ([\w.]+)\(", f.read_text()))
        seen = [(i, n) for i, n in enumerate(names) if n.split("$direct.")[-1] in declared or
                n.rsplit(".read.",1)[-1] in declared or n.rsplit(".owned.",1)[-1] in declared]
        if seen:
            out[label] = {"samples":len(seen), "firstApproxCpuSecond":round((seen[0][0]+1)*period,3),
                          "first":seen[0][1], "lastApproxCpuSecond":round((seen[-1][0]+1)*period,3), "last":seen[-1][1]}
    return out

def analyze(sample, image, expected):
    raw, pcs = sample.read_text().split("\nPCS\n")
    metadata, maps = raw.split("\nMAPS\n")
    meta = dict(line.split("\t", 1) for line in metadata.splitlines() if "\t" in line)
    addresses = [int(line, 16) for line in pcs.splitlines() if line != "END"]
    if len(addresses) != int(meta["samples"]) or meta["dropped"] != "0":
        raise ValueError("incomplete sample capture")
    if not any("00400000-" in line and "candidate-compiler" in line for line in maps.splitlines()):
        raise ValueError("expected a fixed-address compiler ELF")
    fd = os.memfd_create("profiled-compiler")
    try:
        with gzip.open(image, "rb") as src, os.fdopen(os.dup(fd), "wb") as dst:
            shutil.copyfileobj(src, dst)
        path = f"/proc/self/fd/{fd}"
        if sha(path) != expected:
            raise ValueError("producer identity mismatch")
        nm = subprocess.check_output(["nm","-nS",path], pass_fds=(fd,), text=True)
    finally:
        os.close(fd)
    symbols = []
    for line in nm.splitlines():
        row = line.split()
        if len(row) == 4 and row[2] in ("t","T"):
            symbols.append((int(row[0],16),int(row[1],16),demangle(row[3])))
    symbols.sort()
    start = [s[0] for s in symbols]
    names = []
    for pc in addresses:
        at = bisect_right(start, pc) - 1
        name = symbols[at][2] if at >= 0 and pc < start[at] + symbols[at][1] else "unresolved"
        names.append(name)
    n = len(names)
    return {"sampleSha256":sha(sample),"imageSha256":expected,"metadata":meta,
            "namedSourceMarkers":phase_markers(names,meta),
            "topLeaves":Counter(names).most_common(35),"groups":Counter(map(group,names)),
            "sampleOrderQuintiles":[Counter(names[n*i//5:n*(i+1)//5]).most_common(7) for i in range(5)],
            "groupQuintiles":[Counter(map(group,names[n*i//5:n*(i+1)//5])) for i in range(5)]}

if __name__ == "__main__":
    p=argparse.ArgumentParser()
    for arg in ["sample","image","receipt","output"]:
        p.add_argument(arg,type=Path)
    a=p.parse_args()
    expected=json.loads(a.receipt.read_text())["runs"][0]["producerSha256"]
    a.output.write_text(json.dumps(analyze(a.sample,a.image,expected),indent=2)+"\n")
