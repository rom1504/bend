#!/usr/bin/env python3
"""Offline, loss-aware ELF leaf analysis for Bend native CPU captures.

No target is executed. Symbol readers inspect the exact mapped executable and
available shared objects; inference for zero-sized QBE symbols is explicit.
"""
import argparse
import bisect
import collections
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
DEPENDENCY = ROOT / "selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py"
_spec = importlib.util.spec_from_file_location("bend_cpu_elf_helpers", DEPENDENCY)
ELF = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ELF)

# These are physical helper buckets, not inclusive semantic cost attribution.
DEFAULT_GROUPS = {
    "reclamation": r"^(term_drop|span_fade|blk_free|free)([.@]|$)",
    "allocation": r"^(heap_alloc|blk_new|malloc|calloc|realloc)([.@]|$)",
    "ownership_and_products": r"^(term_keep|rfc_|p\d+_(?:p\d+_)?rt_(?:keep|take|ctor|extend)|root_take)",
    "memory_copy": r"^(memcpy|memmove|memset|blk_copy|__mem)",
    "scheduler": r"^(WL_|task_|pool_|work_|p111_run)",
    "generated_bend": r"_FID_",
}


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return {"file": str(path), "bytes": path.stat().st_size, "sha256": digest.hexdigest()}


def decode_name(name):
    def decode(match):
        try:
            value = "".join(chr(int(n)) for n in match[0].rstrip("_").split("_"))
            return value if all(c.isprintable() for c in value) else match[0]
        except (ValueError, OverflowError):
            return match[0]
    return re.sub(r"(?<=_FID_)(?:[0-9]+_)+|(?<![0-9])(?:[0-9]+_){3,}", decode, name)


def parse_capture(path):
    """Keep poor-quality captures analyzable; reject structural corruption."""
    lines = Path(path).read_text().splitlines()
    if not lines or lines[0] != "BEND_MAIN_CPU_SAMPLES_V1" or lines[-1] != "END":
        raise ValueError("Incomplete or unknown sampler output")
    maps_at, pcs_at = lines.index("MAPS"), lines.index("PCS")
    if not 0 < maps_at < pcs_at:
        raise ValueError("Invalid sampler section order")
    header = {}
    for line in lines[1:maps_at]:
        key, value = line.split("\t", 1)
        if key in header:
            raise ValueError("Duplicate capture header: " + key)
        header[key] = int(value) if re.fullmatch(r"[0-9]+", value) else value
    required = ("exe", "pid", "tid", "final_tid", "period_us", "capacity",
                "main_thread_cpu_ns", "samples", "dropped", "overruns", "handler_intact")
    if any(key not in header for key in required):
        raise ValueError("Missing required capture metadata")
    if any(not isinstance(header[key], int) or header[key] < 0 for key in required[1:]):
        raise ValueError("Invalid numeric capture metadata")
    if not header["period_us"] or header["samples"] > header["capacity"]:
        raise ValueError("Invalid sampling period or capacity")
    maps = []
    for line in lines[maps_at + 1:pcs_at]:
        fields = line.split(maxsplit=5)
        start, end = (int(item, 16) for item in fields[0].split("-"))
        if start >= end:
            raise ValueError("Invalid mapping interval")
        maps.append({"start": start, "end": end, "permissions": fields[1],
                     "offset": int(fields[2], 16), "device": fields[3],
                     "inode": int(fields[4]), "path": fields[5] if len(fields) > 5 else ""})
    pcs = [int(line, 16) for line in lines[pcs_at + 1:-1]]
    if len(pcs) != header["samples"]:
        raise ValueError("Sample count does not match capture")
    return header, maps, collections.Counter(pcs)


def capture_quality(header):
    coverage = ELF.coverage_summary(header)
    reasons = list(coverage["limitations"])
    intact = bool(header["handler_intact"])
    main_exit = header["pid"] == header["tid"] == header["final_tid"]
    if not intact:
        reasons.append("Sampler signal handler changed")
    if not main_exit:
        reasons.append("Shutdown did not run on the sampled main thread")
    zero_loss = header["dropped"] == 0 and header["overruns"] == 0
    if not zero_loss:
        reasons.append("Lost samples or timer overruns")
    cpu_ns = header.get("sampled_thread_cpu_ns", header["main_thread_cpu_ns"])
    expected = cpu_ns / (header["period_us"] * 1000)
    delivery = header["samples"] / expected if expected > 0 else None
    # At least ten periods avoids treating timer startup rounding as delivery failure.
    delivery_ok = expected < 10 or (delivery is not None and 0.8 <= delivery <= 1.2)
    if not delivery_ok:
        reasons.append("Delivered sample count differs materially from sampled-clock periods")
    usable = (coverage["usable_for_process_cpu_attribution"] and zero_loss and
              intact and main_exit and delivery_ok)
    return {**coverage, "zero_loss": zero_loss, "handler_intact": intact,
            "main_thread_shutdown": main_exit, "expected_clock_periods": expected,
            "delivered_per_expected_period": delivery, "delivery_plausible": delivery_ok,
            "usable_for_process_cpu_attribution": usable, "limitations": reasons}


def parse_sections(text):
    sections = {}
    pattern = r"\s*\[\s*(\d+)\]\s+(\S+)\s+\S+\s+([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)\s+\S+\s+(\S+)"
    for line in text.splitlines():
        match = re.match(pattern, line)
        if match and "X" in match[5]:
            sections[int(match[1])] = {"name": match[2], "start": int(match[3], 16),
                                       "end": int(match[3], 16) + int(match[4], 16)}
    return sections


def parse_symbols(text, sections):
    symbols = {}
    for line in text.splitlines():
        fields = line.split()
        if len(fields) < 8 or not fields[0].rstrip(":").isdigit():
            continue
        if fields[3] not in ("FUNC", "NOTYPE", "IFUNC") or not fields[6].isdigit():
            continue
        section = int(fields[6])
        if section not in sections:
            continue
        start, size, name = int(fields[1], 16), int(fields[2], 0), fields[7]
        if not sections[section]["start"] <= start < sections[section]["end"]:
            continue
        # Duplicate dynsym/symtab entries are common, and versioned aliases are retained.
        symbols[(section, start, size, name)] = {
            "start": start, "size": size, "name": name, "section": section}
    return list(symbols.values())


class SymbolIndex:
    def __init__(self, symbols, sections):
        self.sections = sections
        self.tables = {}
        for section in sections:
            at = collections.defaultdict(list)
            for symbol in symbols:
                if symbol["section"] == section:
                    at[symbol["start"]].append(symbol)
            self.tables[section] = (sorted(at), at)

    def resolve(self, address):
        for section, bounds in self.sections.items():
            if not bounds["start"] <= address < bounds["end"]:
                continue
            keys, at = self.tables[section]
            index = bisect.bisect_right(keys, address) - 1
            if index < 0:
                return None
            aliases = at[keys[index]]
            sized = [s for s in aliases if s["size"] and
                     address < min(s["start"] + s["size"], bounds["end"])]
            if sized:
                chosen = sorted(sized, key=lambda s: (s["size"], s["name"]))[0]
                kind = "elf_size"
            else:
                unsized = [s for s in aliases if not s["size"]]
                # Never stretch the last unsized symbol through arbitrary section padding.
                if (any(s["size"] for s in aliases) or not unsized or
                        (index + 1 == len(keys) and address != keys[index])):
                    return None
                chosen = sorted(unsized, key=lambda s: s["name"])[0]
                kind = "next_symbol_inferred" if index + 1 < len(keys) else "exact_entry_only"
            return {**chosen, "offset": address - chosen["start"], "range_basis": kind,
                    "aliases": sorted(set(s["name"] for s in aliases))}
        return None


def load_object(path):
    sections = parse_sections(subprocess.check_output(["readelf", "-W", "-S", str(path)], text=True))
    symbols = parse_symbols(subprocess.check_output(["readelf", "-W", "-s", str(path)], text=True), sections)
    return ELF.load_segments(path), SymbolIndex(symbols, sections)


def mapping_identity(mapping):
    path = Path(mapping["path"])
    if not path.is_absolute() or not path.is_file():
        return False, "Mapped object is unavailable (anonymous, deleted, or missing)"
    stat = path.stat()
    dev = f"{os.major(stat.st_dev):x}:{os.minor(stat.st_dev):x}"
    expected_dev = ":".join(f"{int(part, 16):x}" for part in mapping["device"].split(":"))
    if stat.st_ino != mapping["inode"] or dev != expected_dev:
        return False, "Mapped device/inode no longer matches the file"
    return True, None


def analyze_capture(samples_path, binary_path, *, groups=None, clean_cpu_seconds=None):
    """Analyze a capture without executing target code; preserve bad-quality evidence."""
    samples_path, binary_path = Path(samples_path).resolve(), Path(binary_path).resolve()
    header, maps, pcs = parse_capture(samples_path)
    if Path(header["exe"]).resolve() != binary_path:
        raise ValueError("Capture executable does not match --binary")
    if clean_cpu_seconds is not None and (not math.isfinite(clean_cpu_seconds) or clean_cpu_seconds < 0):
        raise ValueError("Clean CPU seconds must be finite and nonnegative")
    rules = DEFAULT_GROUPS if groups is None else groups
    compiled_groups = [(name, re.compile(pattern)) for name, pattern in rules.items()]
    quality = capture_quality(header)
    objects, object_errors, rows = {}, {}, []
    counts, group_counts, category_counts, library_counts = (collections.Counter() for _ in range(4))
    total = header["samples"]
    for pc, count in sorted(pcs.items()):
        mapping = next((m for m in maps if m["start"] <= pc < m["end"]), None)
        row = {"pc": hex(pc), "samples": count, "mapping": mapping["path"] if mapping else None,
               "category": "unmapped", "symbol": None, "elf_address": None}
        if mapping:
            path = mapping["path"]
            row["category"] = "executable_unresolved" if path == header["exe"] else "library_unresolved"
            if path not in objects and path not in object_errors:
                valid, reason = mapping_identity(mapping)
                if valid:
                    try:
                        segments, index = load_object(path)
                        objects[path] = (segments, index, pin(path))
                    except (OSError, ValueError, subprocess.CalledProcessError) as error:
                        object_errors[path] = str(error)
                else:
                    object_errors[path] = reason
            if path in objects and "x" in mapping["permissions"]:
                segments, index, _ = objects[path]
                address = ELF.virtual_address(pc, mapping, segments)
                if address is not None:
                    row["elf_address"] = hex(address)
                    symbol = index.resolve(address)
                    if symbol:
                        row.update(symbol=symbol["name"], decoded=decode_name(symbol["name"]),
                                   offset=symbol["offset"], range_basis=symbol["range_basis"],
                                   aliases=symbol["aliases"], category="executable" if path == header["exe"] else "library")
            if path != header["exe"]:
                library_counts[path] += count
        name = row["symbol"] or "[" + row["category"] + "]"
        key = (row["mapping"], name)
        counts[key] += count
        group = "unresolved" if row["symbol"] is None else next(
            (label for label, pattern in compiled_groups if pattern.search(row["decoded"])), "other")
        row["group"] = group
        group_counts[group] += count
        category_counts[row["category"]] += count
        rows.append(row)

    def measures(count):
        fraction = count / total if total else 0.0
        result = {"samples": count, "fraction": fraction, "percent": fraction * 100}
        if clean_cpu_seconds is not None and quality["usable_for_process_cpu_attribution"]:
            result["estimated_clean_cpu_seconds"] = fraction * clean_cpu_seconds
        return result

    functions = [{"name": name, "decoded": decode_name(name), "object": path, **measures(n)}
                 for (path, name), n in counts.most_common()]
    ranked = lambda counter: [{"name": name, **measures(n)} for name, n in counter.most_common()]
    resolved = category_counts["executable"] + category_counts["library"]
    quality["resolved_sample_fraction"] = resolved / total if total else 0.0
    quality["unknown_samples"] = total - resolved
    inferred = sum(r["samples"] for r in rows if r.get("range_basis") == "next_symbol_inferred")
    quality["inferred_symbol_range_samples"] = inferred
    quality["resolved_symbol_coverage_is_not_logical_attribution"] = True
    return {
        "schema": "bend-native-profile-v1", "header": header, "quality": quality,
        "coverage": quality, "usable": quality["usable_for_process_cpu_attribution"],
        "zeroLoss": quality["zero_loss"], "top_functions": functions,
        "groups": ranked(group_counts), "group_rules": rules,
        "categories": ranked(category_counts), "libraries": ranked(library_counts),
        "pcs": rows, "maps": maps, "object_errors": object_errors,
        "identities": {"capture": pin(samples_path), "binary": pin(binary_path),
                       "analyzer": pin(__file__), "dependencies": [pin(DEPENDENCY)],
                       "mapped_objects": [value[2] for value in objects.values()]},
        "clean_cpu_seconds": clean_cpu_seconds,
        "absolute_cost_method": "Approximate: physical sample fraction times independently measured clean process CPU; only emitted for usable captures.",
        "limitations": [
            "Physical instruction leaves, not inclusive stacks, logical callers, or allocation counts.",
            "Decoded generated names are symbol identities, not verified source-file/line mappings.",
            "Zero-sized symbols infer extent only up to the next symbol in the same executable section; padding may be attributed. Last unsized symbols resolve only at entry.",
            "Library symbols can be absent or hidden; unresolved samples remain in every denominator.",
            "Mapped device/inode is checked and current files are hashed; in-place mutation since capture is not ruled out without runner identity pins.",
            "Fixed-period sampling can alias; compare periods and repeats. Instrumented clocks are diagnostic, never clean performance.",
            "Runtime groups classify physical helper names only and do not identify which source computation caused their work.",
            "Raw sample order remains in the hashed capture file; pcs is a lossless address histogram, not a timeline.",
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--samples", type=Path, required=True)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--groups", type=Path, help="Ordered JSON object mapping group names to regexes on decoded symbols")
    parser.add_argument("--clean-cpu-seconds", type=float)
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Refusing to overwrite analysis output")
    groups = json.loads(args.groups.read_text()) if args.groups else None
    result = analyze_capture(args.samples, args.binary, groups=groups, clean_cpu_seconds=args.clean_cpu_seconds)
    if args.groups:
        result["identities"]["group_file"] = pin(args.groups)
    with args.output.open("x") as stream:
        json.dump(result, stream, indent=2)
        stream.write("\n")
    print(json.dumps({"samples": result["header"]["samples"], "quality": result["quality"],
                      "top_functions": result["top_functions"][:15]}, indent=2))


if __name__ == "__main__":
    main()
