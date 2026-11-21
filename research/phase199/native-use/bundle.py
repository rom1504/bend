"""Combine checked runtime components using a pinned ELF relocatable link."""

import argparse
import hashlib
import json
import os
import struct
import subprocess
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
LEAF = "p199_rt_u32_scan4"
LD = Path("/usr/bin/x86_64-linux-gnu-ld.bfd")
LD_SHA = "a65e1f0b0030ee1e322775b7f5bf6bf65ebf25a00a72409b459d2e3913e776ce"
LIVE = ROOT / "research/phase198/runtime-broad/evidence/progress-live-equivalence.json"
SCAN = ROOT / "research/phase199/scan-runtime/evidence/report.json"
ASSETS = ROOT / "selfhost/build/phase194/assets.json"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    file = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)
    return dict(file=file, bytes=len(data), sha256=sha(data))


def verify(record):
    path = ROOT / record.get("file", record.get("path"))
    current = pin(path)
    assert (current["bytes"], current["sha256"]) == (record["bytes"], record["sha256"]), path
    return path


def read(path):
    return json.loads(path.read_text())


def symbols(path):
    """Describe externally linkable definitions and imports by name and ABI attributes."""
    data = path.read_bytes()
    assert data[:7] == b"\x7fELF\x02\x01\x01" and struct.unpack_from("<HH", data, 16) == (1, 62)
    offset = struct.unpack_from("<Q", data, 40)[0]
    size, count, _ = struct.unpack_from("<HHH", data, 58)
    sections = [struct.unpack_from("<IIQQQQIIQQ", data, offset+i*size) for i in range(count)]
    symtab = next(section for section in sections if section[1] == 2)
    strings = sections[symtab[6]]
    pool = data[strings[4]:strings[4]+strings[5]]
    defined, undefined = {}, {}
    for i in range(symtab[5]//symtab[9]):
        start = symtab[4] + i * symtab[9]
        name_at, info, other, shndx, address, length = struct.unpack_from("<IBBHQQ", data, start)
        if info >> 4 == 0:
            continue
        name = pool[name_at:pool.index(b"\0", name_at)].decode()
        row = dict(binding=info >> 4, type=info & 15, visibility=other & 3, bytes=length)
        if shndx == 0:
            undefined[name] = row
            continue
        assert shndx < len(sections), (name, shndx)
        section = sections[shndx]
        assert address+length <= section[5], (path, name)
        row["sectionType"] = section[1]
        if section[1] != 8:  # SHT_NOBITS carries no file contents.
            begin = section[4] + address
            row["sha256"] = sha(data[begin:begin+length])
        assert name not in defined
        defined[name] = row
    return defined, undefined


def package(out):
    assert os.sched_getaffinity(0) == {3} and not out.exists()
    out.mkdir(parents=True)
    assert pin(LD)["sha256"] == LD_SHA
    assert pin(LIVE)["sha256"] == "3d106627ca8c8b67e6318e88ce3261519ab8010c9b71100c6d7b2f4fe3fa70f9"
    assert pin(SCAN)["sha256"] == "ef3b2cade07077ce724e90341fc1af1b24e8813d13d8f1b025e1d14b16979710"
    assert pin(ASSETS)["sha256"] == "767986fb99bd450f7f83e9abd4a05361c7c3fd502a6a724717eb77abc1f76597"
    live_record, scan_record, assets = read(LIVE), read(SCAN), read(ASSETS)
    assert live_record["complete"] and scan_record["complete"] and scan_record["independentPythonFullStateChecks"] == 9
    leaf = verify(scan_record["helperObject"])
    live = verify(live_record["liveRuntime"])
    original = verify(assets["assets"]["qbe-runtime"])
    leaf_defs, leaf_imports = symbols(leaf)
    assert set(leaf_defs) == {LEAF} and not leaf_imports
    assert leaf_defs[LEAF]["binding"] == 1 and leaf_defs[LEAF]["type"] == 2
    inputs = [pin(p) for p in (LD, LIVE, SCAN, ASSETS, leaf, live, original, Path(__file__))]
    expected_abi = {"p111_rt_main", "p111_rt_jump", "p111_rt_op", "p125_rt_take2"}
    report = dict(kind="phase199-scan-runtime-bundle", complete=False, runtimeABI=11102,
                  runtimeArgumentConvention="bend-rts-v1", inputs=inputs, leafSymbol=LEAF, variants={})
    result = out/"report.json"
    for name, runtime in (("live", live), ("original", original)):
        original_defs, original_imports = symbols(runtime)
        assert expected_abi <= original_defs.keys() and LEAF not in original_defs and LEAF not in original_imports
        output = out / ("runtime-" + name + "-scan.o")
        command = [str(LD), "-m", "elf_x86_64", "-r", "-o", str(output), str(runtime), str(leaf)]
        proc = subprocess.run(command, capture_output=True, timeout=2)
        (out / (name + ".stderr")).write_bytes(proc.stderr)
        assert proc.returncode == 0 and not proc.stdout and not proc.stderr, (proc.returncode, proc.stderr)
        combined, imports = symbols(output)
        assert combined == {**original_defs, **leaf_defs} and imports == original_imports, name
        report["variants"][name] = dict(runtime=pin(runtime), bundle=pin(output), command=command,
                                        preservedExports=len(original_defs), preservedImports=len(imports),
                                        checkedDefinedSymbols=combined, checkedUndefinedSymbols=imports)
        result.write_text(json.dumps(report, indent=2)+"\n")
    for item in inputs:
        verify(item)
    report["complete"] = True
    result.write_text(json.dumps(report, indent=2)+"\n")
    print([(name, row["bundle"], row["preservedExports"], row["preservedImports"])
           for name, row in report["variants"].items()])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    package(parser.parse_args().out)
