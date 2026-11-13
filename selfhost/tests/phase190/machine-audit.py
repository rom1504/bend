#!/usr/bin/env python3
"""Read-only ELF inspection. Executes only nm/objdump, never inspected programs.

--regions is JSON: {role: {symbol: {name: [[start_offset, end_offset], ...]}}}.
Offsets are integers or 0x strings, relative to the symbol, end exclusive.
Regions describe explicit static instruction sets, not inferred execution counts.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


def identity(path):
    path = Path(path).resolve(strict=True)
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": digest.hexdigest()}


def run(argv):
    return subprocess.run(argv, check=True, text=True, capture_output=True,
                          env={**os.environ, "LC_ALL": "C"}, timeout=60).stdout


def number(value):
    return int(value, 0) if isinstance(value, str) else int(value)


def counts(instructions):
    result = dict.fromkeys([
        "instructions", "instruction_bytes", "frame_reference_instructions",
        "frame_reference_operands", "frame_memory_instructions",
        "frame_address_only_instructions", "stack_reference_instructions",
        "moves", "calls", "branches", "conditional_branches", "returns"], 0)
    for ins in instructions:
        mnemonic, operands = ins["mnemonic"], ins["operands"]
        frame = len(re.findall(r"\([^)]*%[er]bp\b[^)]*\)", operands))
        branch = mnemonic.startswith("j") or mnemonic.startswith("loop")
        result["instructions"] += 1
        result["instruction_bytes"] += ins["bytes"]
        result["frame_reference_instructions"] += bool(frame)
        result["frame_reference_operands"] += frame
        result["frame_memory_instructions"] += bool(frame) and not mnemonic.startswith("lea")
        result["frame_address_only_instructions"] += bool(frame) and mnemonic.startswith("lea")
        result["stack_reference_instructions"] += bool(re.search(r"\([^)]*%[er]sp\b", operands))
        result["moves"] += mnemonic.startswith("mov")
        result["calls"] += mnemonic.startswith("call")
        result["branches"] += branch
        result["conditional_branches"] += branch and mnemonic not in ("jmp", "jmpq", "jmpl")
        result["returns"] += mnemonic.startswith("ret")
    return result


def inspect(binary, symbols, regions, role, output, tool_paths):
    before = identity(binary)
    nm_command = [tool_paths["nm"], "-S", "--defined-only", before["path"]]
    nm_raw = run(nm_command)
    nm_file = output / (role + ".nm.txt")
    nm_file.write_text(nm_raw)
    table = {}
    for line in nm_raw.splitlines():
        fields = line.split()
        if len(fields) == 4:
            address, size, kind, name = fields
            if name in table and name in symbols:
                raise ValueError("ambiguous symbol: " + name)
            table[name] = (int(address, 16), int(size, 16), kind)
    result = {"artifact": before, "nm_command": nm_command,
              "nm_output": identity(nm_file), "functions": {}}
    for index, symbol in enumerate(symbols):
        if symbol not in table:
            raise ValueError("symbol missing or lacks size: " + symbol)
        address, size, kind = table[symbol]
        if kind.lower() != "t" or not size:
            raise ValueError("symbol is not nonempty text: " + symbol)
        command = [tool_paths["objdump"], "-d", "--insn-width=16",
                   "--disassemble=" + symbol, before["path"]]
        raw = run(command)
        raw_file = output / (role + "." + str(index) + ".asm")
        raw_file.write_text(raw)
        instructions = []
        for line in raw.splitlines():
            match = re.match(r"^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}\s+)+)\s*([a-z][a-z0-9.]*)\s*(.*?)\s*$", line)
            if match:
                pc = int(match[1], 16)
                if address <= pc < address + size:
                    instructions.append({"address": hex(pc), "offset": pc - address,
                                         "bytes": len(match[2].split()),
                                         "mnemonic": match[3], "operands": match[4]})
        if not instructions or sum(i["bytes"] for i in instructions) != size:
            raise ValueError("decoded bytes do not cover symbol exactly: " + symbol)
        boundaries = {i["offset"] for i in instructions} | {size}
        function = {"address": hex(address), "end_exclusive": hex(address + size),
                    "symbol_bytes": size, "whole_function_static": counts(instructions),
                    "objdump_command": command, "raw_disassembly": identity(raw_file),
                    "instructions": instructions, "regions": {}}
        for name, ranges in regions.get(symbol, {}).items():
            normalized = [[number(lo), number(hi)] for lo, hi in ranges]
            selected = []
            seen = set()
            for lo, hi in normalized:
                if lo not in boundaries or hi not in boundaries or lo >= hi:
                    raise ValueError("region range is not on instruction boundaries: " + name)
                for ins in instructions:
                    if lo <= ins["offset"] < hi:
                        if ins["offset"] in seen:
                            raise ValueError("overlapping region ranges: " + name)
                        seen.add(ins["offset"])
                        selected.append(ins)
            if not selected:
                raise ValueError("empty region: " + name)
            function["regions"][name] = {
                "offset_ranges_end_exclusive": normalized,
                "address_ranges_end_exclusive": [[hex(address + lo), hex(address + hi)] for lo, hi in normalized],
                "static": counts(selected)}
        result["functions"][symbol] = function
    if identity(binary) != before:
        raise ValueError("artifact changed during inspection")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--candidate")
    parser.add_argument("--symbol", action="append", required=True)
    parser.add_argument("--regions", type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    if len(set(args.symbol)) != len(args.symbol):
        parser.error("duplicate symbols")
    # Fail closed on output reuse, preserving all earlier audit evidence.
    args.out.mkdir(parents=True, exist_ok=False)
    regions = json.loads(args.regions.read_text()) if args.regions else {}
    paths, tools = {}, {}
    for name in ("nm", "objdump"):
        resolved = shutil.which(name)
        if not resolved:
            raise ValueError("missing inspection tool: " + name)
        paths[name] = str(Path(resolved).resolve())
        tools[name] = {**identity(resolved), "version": run([paths[name], "--version"]).splitlines()[0]}
    roles = {"baseline": args.baseline}
    if args.candidate:
        roles["candidate"] = args.candidate
    if set(regions) - set(roles):
        raise ValueError("regions contain uninspected roles")
    if any(set(value) - set(args.symbol) for value in regions.values()):
        raise ValueError("regions contain uninspected symbols")
    report = {"kind": "phase190-static-machine-audit", "version": 1,
              "scope": "Static x86 instruction counts; no target execution or dynamic frequency inference.",
              "definitions": {
                  "frame_reference": "Instruction with explicit rbp/ebp memory addressing; includes lea addresses, separately counted.",
                  "moves": "mnemonic starts with mov; includes extensions and movabs",
                  "branches": "mnemonic starts with j or loop; excludes calls and returns",
                  "regions": "User-selected static spans, end exclusive; a path/iteration claim requires independent control-flow reasoning.",
                  "memory_limits": "No implicit push/pop/call/ret accesses counted; frame references are not cache misses or DRAM accesses."},
              "script": identity(__file__), "python": identity(sys.executable),
              "tools": tools, "argv": sys.argv, "artifacts": {}, "deltas": {}}
    if args.regions:
        report["region_spec"] = identity(args.regions)
    for role, binary in roles.items():
        report["artifacts"][role] = inspect(binary, args.symbol, regions.get(role, {}), role, args.out, paths)
    if args.candidate:
        for symbol in args.symbol:
            baseline = report["artifacts"]["baseline"]["functions"][symbol]
            candidate = report["artifacts"]["candidate"]["functions"][symbol]
            delta = {"whole_function_static": {k: candidate["whole_function_static"][k] - v
                     for k, v in baseline["whole_function_static"].items()}, "regions": {}}
            for name in baseline["regions"].keys() & candidate["regions"].keys():
                delta["regions"][name] = {k: candidate["regions"][name]["static"][k] - v
                                           for k, v in baseline["regions"][name]["static"].items()}
            report["deltas"][symbol] = delta
    (args.out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({role: {symbol: {"whole_function_static": data["whole_function_static"],
                      "regions": data["regions"]} for symbol, data in artifact["functions"].items()}
                      for role, artifact in report["artifacts"].items()}, indent=2))


if __name__ == "__main__":
    main()
