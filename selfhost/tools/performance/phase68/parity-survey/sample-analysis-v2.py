#!/usr/bin/env python3
"""Symbolize main-thread samples; enforce identical baseline/debug .text first."""
import argparse
import collections
import hashlib
import json
import pathlib
import re
import subprocess
import tempfile


def command(*args):
    return subprocess.check_output(args, text=True)


def sha(path):
    return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()


def text_sha(path):
    with tempfile.TemporaryDirectory(prefix="bend-sample-text-") as directory:
        output = pathlib.Path(directory) / "text.bin"
        subprocess.run(["objcopy", "--dump-section", f".text={output}",
                        str(path), str(pathlib.Path(directory) / "copy.elf")], check=True)
        return sha(output), output.stat().st_size


def parse(path):
    lines = pathlib.Path(path).read_text().splitlines()
    if not lines or lines[0] != "BEND_MAIN_CPU_SAMPLES_V1" or lines[-1] != "END":
        raise ValueError("Incomplete or unknown sampler output")
    maps_at, pcs_at = lines.index("MAPS"), lines.index("PCS")
    header = dict(line.split("\t", 1) for line in lines[1:maps_at])
    for key in ("pid", "tid", "period_us", "capacity", "signal", "final_tid",
                "main_thread_cpu_ns", "wall_ns", "samples", "dropped", "overruns",
                "handler_intact"):
        header[key] = int(header[key])
    for key in ("process_cpu_ns", "sampled_thread_cpu_ns", "max_threads", "thread_capacity",
                "threads_allocated", "threads_ready", "threads_ended", "thread_overflow",
                "thread_clock_failures", "timer_disarm_failures"):
        if key in header:
            header[key] = int(header[key])
    if header["tid"] != header["final_tid"] or header["tid"] != header["pid"]:
        raise ValueError("Exit did not run on the sampled main thread")
    if not header["handler_intact"] or header["dropped"]:
        raise ValueError("Handler changed or sample capacity exhausted")
    maps = []
    for line in lines[maps_at + 1:pcs_at]:
        fields = line.split(maxsplit=5)
        start, end = (int(item, 16) for item in fields[0].split("-"))
        maps.append({"start": start, "end": end, "permissions": fields[1],
                     "offset": int(fields[2], 16),
                     "path": fields[5] if len(fields) > 5 else ""})
    pcs = [int(line, 16) for line in lines[pcs_at + 1:-1]]
    if len(pcs) != header["samples"] or not pcs:
        raise ValueError("Sample count mismatch or empty profile")
    return header, maps, collections.Counter(pcs)


def load_segments(path):
    segments = []
    for line in command("readelf", "-W", "-l", str(path)).splitlines():
        fields = line.split()
        if fields and fields[0] == "LOAD":
            segments.append(tuple(int(fields[i], 16) for i in (1, 2, 4)))
    if not segments:
        raise ValueError(f"No ELF load segments in {path}")
    return segments


def text_layout(path):
    for line in command("readelf", "-W", "-S", str(path)).splitlines():
        found = re.match(r"\s*\[\s*\d+\]\s+\.text\s+\S+\s+([0-9a-fA-F]+)\s+"
                         r"([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s", line)
        if found:
            return tuple(int(value, 16) for value in found.groups())
    raise ValueError(f"No ELF .text section layout in {path}")


def virtual_address(pc, mapping, segments):
    offset = pc - mapping["start"] + mapping["offset"]
    for file_offset, address, file_size in segments:
        if file_offset <= offset < file_offset + file_size:
            return address + offset - file_offset
    return None


def symbolize(path, addresses):
    result = {}
    addresses = sorted(addresses)
    for start in range(0, len(addresses), 1000):
        chunk = addresses[start:start + 1000]
        lines = command("addr2line", "-a", "-f", "-C", "-i", "-e", str(path),
                        *(hex(address) for address in chunk)).splitlines()
        active, values = None, []
        for line in lines + ["0x0"]:
            if re.fullmatch(r"0x[0-9a-fA-F]+", line):
                if active is not None:
                    if len(values) % 2:
                        raise ValueError("Malformed addr2line frame output")
                    result[active] = [{"function": values[i], "location": values[i + 1]}
                                      for i in range(0, len(values), 2)]
                active, values = int(line, 16), []
            else:
                values.append(line)
    return result


def coverage_summary(header):
    scope = header.get("sampler_scope", "main_thread")
    if scope not in ("main_thread", "all_created_threads"):
        raise ValueError(f"Unknown sampler scope: {scope}")
    process_cpu = header.get("process_cpu_ns", 0)
    main_fraction = header["main_thread_cpu_ns"] / process_cpu if process_cpu > 0 else None
    all_threads = scope == "all_created_threads"
    cpu = header.get("sampled_thread_cpu_ns", 0) if all_threads else header["main_thread_cpu_ns"]
    sampled_fraction = cpu / process_cpu if process_cpu > 0 else None
    reasons = []
    lifecycle = True
    if all_threads:
        required = ("sampled_thread_cpu_ns", "threads_allocated", "threads_ready",
                    "threads_ended", "thread_overflow", "thread_clock_failures", "timer_disarm_failures")
        missing = [key for key in required if key not in header]
        if missing:
            raise ValueError(f"Incomplete all-thread sampler metadata: {missing}")
        if header["threads_allocated"] != header["threads_ready"] or header["threads_ready"] < 1:
            lifecycle = False
            reasons.append("Some allocated thread slots were never ready")
        for key in ("thread_overflow", "thread_clock_failures", "timer_disarm_failures"):
            if header[key]:
                lifecycle = False
                reasons.append(f"{key}={header[key]}")
    enough_samples = header["samples"] >= 500
    if not enough_samples:
        reasons.append("Fewer than 500 delivered samples")
    near_complete = sampled_fraction is not None and sampled_fraction >= 0.95
    if sampled_fraction is None:
        reasons.append("Process CPU time was not recorded")
    elif not near_complete:
        reasons.append("Sampled thread clocks cover less than 95% of process CPU")
    return {
        "scope": scope, "main_thread_cpu_fraction": main_fraction,
        "sampled_thread_cpu_fraction": sampled_fraction,
        "minimum_process_cpu_fraction": 0.95, "minimum_samples": 500,
        "enough_samples": enough_samples, "thread_lifecycle_complete": lifecycle,
        "near_complete_process_cpu_coverage": near_complete and lifecycle,
        "usable_for_process_cpu_attribution": near_complete and lifecycle and enough_samples,
        "limitations": reasons,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--samples", required=True, type=pathlib.Path)
    parser.add_argument("--baseline", required=True, type=pathlib.Path,
                        help="Uninstrumented executable used for clean timings")
    parser.add_argument("--debug", required=True, type=pathlib.Path,
                        help="Equivalent executable rebuilt with -g, or baseline with DWARF")
    parser.add_argument("--output", required=True, type=pathlib.Path)
    args = parser.parse_args()
    if args.output.exists():
        raise ValueError("Refusing to overwrite analysis output")
    header, maps, pcs = parse(args.samples)
    baseline_text, baseline_size = text_sha(args.baseline)
    debug_text, debug_size = text_sha(args.debug)
    sampled_path = pathlib.Path(header["exe"])
    sampled_text, sampled_size = text_sha(sampled_path)
    if not (baseline_text == debug_text == sampled_text):
        raise ValueError("Sampled, baseline and debug .text sections differ")
    if text_layout(sampled_path) != text_layout(args.debug):
        raise ValueError("Sampled/debug .text address or file layout differs")
    segments = load_segments(args.debug)
    rows, addresses = [], set()
    for pc, count in pcs.items():
        mapping = next((entry for entry in maps if entry["start"] <= pc < entry["end"]), None)
        row = {"pc": hex(pc), "samples": count, "mapping": mapping["path"] if mapping else None}
        if mapping and mapping["path"] == header["exe"]:
            address = virtual_address(pc, mapping, segments)
            row["category"] = "executable"
            if address is not None:
                addresses.add(address)
                row["elf_address"] = hex(address)
            else:
                row["category"] = "executable_unresolved"
        else:
            row["category"] = "shared_or_other_mapping" if mapping else "unmapped"
        rows.append(row)
    symbols = symbolize(args.debug, addresses)
    functions, outer_functions, locations, categories, libraries = (collections.Counter() for _ in range(5))
    for row in rows:
        count = row["samples"]
        categories[row["category"]] += count
        if "elf_address" in row:
            row["frames"] = symbols[int(row["elf_address"], 16)]
            if row["frames"]:
                inner, outer = row["frames"][0], row["frames"][-1]
                functions[inner["function"]] += count
                outer_functions[outer["function"]] += count
                locations[inner["function"] + " @ " + inner["location"]] += count
        elif row["mapping"]:
            libraries[row["mapping"]] += count
    total = header["samples"]
    def ranked(counter):
        return [{"name": key, "samples": count, "percent_all_samples": 100 * count / total}
                for key, count in counter.most_common()]
    coverage = coverage_summary(header)
    scope_limitation = (
        "Intercepted pthreads plus main; bounded lifetime thread slots; assess process CPU coverage."
        if coverage["scope"] == "all_created_threads" else
        "Main thread only; assess main/process CPU coverage before whole-program attribution.")
    result = {
        "schema": "bend-cpu-analysis-v2", "header": header, "coverage": coverage,
        "identities": {"samples_sha256": sha(args.samples),
                       "baseline": str(args.baseline.resolve()), "baseline_sha256": sha(args.baseline),
                       "debug": str(args.debug.resolve()), "debug_sha256": sha(args.debug),
                       "sampled_executable": str(sampled_path), "sampled_sha256": sha(sampled_path),
                       "text_sha256": baseline_text, "text_bytes": baseline_size,
                       "debug_text_bytes": debug_size, "sampled_text_bytes": sampled_size},
        "categories": ranked(categories), "leaf_functions": ranked(functions),
        "outer_functions": ranked(outer_functions), "leaf_locations": ranked(locations),
        "shared_or_other_mappings": ranked(libraries),
        "samples": sorted(rows, key=lambda row: (-row["samples"], row["pc"])),
        "limitations": [scope_limitation,
                        "Startup and shutdown included; per-thread windows have small timing offsets; not a stack profile.",
                        "Inline DWARF ancestry is lexical, not a dynamic call stack.",
                        "Fixed-period timer sampling can alias; compare another period/repeat.",
                        "Runtime overhead and signal interruptions make profiled timings diagnostic only.",
                        "ELF .text equality binds machine code, not data/runtime environment equality.",
                        "Shared libraries are counted separately; executable symbols alone are resolved."]}
    with args.output.open("x") as output:
        json.dump(result, output, indent=2)
        output.write("\n")
    print(json.dumps({"samples": total, "main_cpu_ms": header["main_thread_cpu_ns"] / 1e6,
                      "coverage": coverage, "overruns": header["overruns"],
                      "leaf_functions": ranked(functions)[:15]}, indent=2))


if __name__ == "__main__":
    main()
