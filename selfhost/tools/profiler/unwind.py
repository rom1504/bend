#!/usr/bin/env python3
"""Prepare bounded, one-frame x86-64 unwind rules from ELF .eh_frame CFI.

This is an offline metadata reader, not an unwinder or a stack scanner. Only
constant CFA=rsp+offset, RA=memory[CFA+offset] rules are admitted. The sampler
must authenticate the mapped object and check the interrupted stack bounds.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


class CFIError(ValueError):
    pass


def integer(value):
    if isinstance(value, bool) or not isinstance(value, (str, int)):
        raise CFIError("address/offset must be an integer or integer string")
    return int(value, 0) if isinstance(value, str) else int(value)


def requested_ranges(document):
    key = "physicalUnwindRows" if "physicalUnwindRows" in document else "ranges"
    ranges = []
    for item in document.get(key, []):
        start, end = integer(item["start"]), integer(item["end"])
        if not 0 <= start < end < 2**64:
            raise CFIError("invalid requested interval")
        entry = {"start": start, "end": end}
        if key == "physicalUnwindRows":
            if item.get("cfaRegister") != "rsp":
                raise CFIError("requested physical rule is not rsp-relative")
            entry["expected"] = (integer(item["cfaOffset"]),
                                 integer(item["returnAddressOffset"]))
        ranges.append(entry)
    ranges.sort(key=lambda x: x["start"])
    if not ranges:
        raise CFIError("no requested ranges")
    if any(a["end"] > b["start"] for a, b in zip(ranges, ranges[1:])):
        raise CFIError("overlapping requested ranges")
    return ranges


def parse_frames(text):
    """Read GNU readelf frames-interp output; never infer missing CFI."""
    cies, fdes = {}, []
    section, active, columns = None, None, None
    for line in text.splitlines():
        section_match = re.match(r"Contents of the (\S+) section:", line)
        if section_match:
            section, active, columns = section_match[1], None, None
            continue
        if section != ".eh_frame":
            continue
        cie = re.match(r'^([0-9a-fA-F]+)\s+\S+\s+\S+\s+CIE\s+"([^"]*)".*\bra=(\d+)\s*$', line)
        fde = re.match(r"^([0-9a-fA-F]+)\s+\S+\s+\S+\s+FDE\s+cie=([0-9a-fA-F]+)\s+pc=([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)\s*$", line)
        if cie:
            offset = int(cie[1], 16)
            if offset in cies:
                raise CFIError("duplicate .eh_frame CIE offset")
            active = {"offset": offset, "augmentation": cie[2],
                      "returnRegister": int(cie[3]), "rows": [], "errors": []}
            cies[offset] = active
            columns = None
        elif fde:
            active = {"offset": int(fde[1], 16), "cie": int(fde[2], 16),
                      "start": int(fde[3], 16), "end": int(fde[4], 16),
                      "rows": [], "errors": []}
            fdes.append(active)
            columns = None
        elif active is not None and line.strip().startswith("LOC "):
            columns = line.split()
            if len(set(columns)) != len(columns) or not {"LOC", "CFA", "ra"} <= set(columns):
                active["errors"].append("malformed interpreted column header")
        elif active is not None and line.strip():
            cells = line.split()
            if columns and re.fullmatch(r"[0-9a-fA-F]+", cells[0]):
                if len(cells) != len(columns):
                    active["errors"].append("malformed interpreted row")
                    continue
                row = dict(zip(columns, cells))
                active["rows"].append({"pc": int(row["LOC"], 16),
                                       "CFA": row.get("CFA"), "ra": row.get("ra")})
            elif "ZERO terminator" not in line:
                active["errors"].append("unrecognized interpreted CFI: " + line.strip())
    return cies, fdes


def rule(row):
    cfa = re.fullmatch(r"rsp([+-]\d+)", row.get("CFA") or "")
    ra = re.fullmatch(r"c([+-]\d+)", row.get("ra") or "")
    if not cfa or not ra:
        return None, "unsupported CFA/RA rule: %s / %s" % (row.get("CFA"), row.get("ra"))
    offsets = int(cfa[1]), int(ra[1])
    if any(not -(2**63) < x < 2**63 for x in (*offsets, sum(offsets))):
        return None, "unrepresentable unwind offset"
    return offsets, None


def fde_intervals(fde, cies):
    def rejected(reason):
        return [{"start": fde["start"], "end": fde["end"], "reason": reason}]
    cie = cies.get(fde["cie"])
    if not cie:
        return rejected("missing CIE")
    if cie["errors"] or fde["errors"]:
        return rejected("; ".join(cie["errors"] + fde["errors"]))
    if cie["returnRegister"] != 16:
        return rejected("CIE return register is not x86-64 RIP (16)")
    if "S" in cie["augmentation"]:
        return rejected("signal-frame CIE is not an ordinary caller")
    if len(cie["rows"]) != 1 or cie["rows"][0]["pc"] != 0:
        return rejected("unsupported CIE initial-state table")
    rows = fde["rows"]
    if (fde["end"] <= fde["start"] or
        any(not fde["start"] <= row["pc"] <= fde["end"] for row in rows) or
        any(a["pc"] >= b["pc"] for a, b in zip(rows, rows[1:]))):
        return rejected("invalid FDE row boundaries")
    if not rows or rows[0]["pc"] > fde["start"]:
        rows = [{**cie["rows"][0], "pc": fde["start"]}] + rows
    result = []
    for i, row in enumerate(rows):
        end = rows[i + 1]["pc"] if i + 1 < len(rows) else fde["end"]
        if row["pc"] == end:
            continue
        offsets, reason = rule(row)
        interval = {"start": row["pc"], "end": end}
        if reason:
            interval["reason"] = reason
        else:
            interval.update(cfa=offsets[0], ra=offsets[1])
        result.append(interval)
    return result


def prepare_rows(text, ranges, allow_partial=False):
    cies, fdes = parse_frames(text)
    admitted, skipped, coverage = [], [], []
    for request in ranges:
        lo, hi = request["start"], request["end"]
        matches = [fde for fde in fdes if fde["start"] < hi and fde["end"] > lo]
        intervals = []
        for fde in matches:
            coverage.append({"requestedStart": lo, "requestedEnd": hi,
                             "fdeOffset": fde["offset"], "cieOffset": fde["cie"],
                             "start": fde["start"], "end": fde["end"]})
            intervals.extend(fde_intervals(fde, cies))
        boundaries = sorted({lo, hi} | {max(lo, min(hi, part[k]))
                                       for part in intervals for k in ("start", "end")})
        for start, end in zip(boundaries, boundaries[1:]):
            parts = [part for part in intervals if part["start"] <= start < part["end"]]
            reason = None
            if not parts:
                reason = "no .eh_frame FDE coverage"
            elif len(parts) != 1:
                reason = "ambiguous overlapping FDE coverage"
            elif "reason" in parts[0]:
                reason = parts[0]["reason"]
            elif "expected" in request and request["expected"] != (parts[0]["cfa"], parts[0]["ra"]):
                reason = "CFI disagrees with requested physical rule"
            if reason:
                skipped.append({"start": start, "end": end, "reason": reason})
            else:
                admitted.append({"start": start, "end": end,
                                 "cfa": parts[0]["cfa"], "ra": parts[0]["ra"]})
    if skipped and not allow_partial:
        raise CFIError("requested coverage rejected: " + json.dumps(skipped))
    if not admitted:
        raise CFIError("no supported unwind intervals")
    return {"rows": admitted, "skipped": skipped, "fdeCoverage": coverage,
            "complete": not skipped,
            "requestedBytes": sum(r["end"] - r["start"] for r in ranges),
            "coveredBytes": sum(r["end"] - r["start"] for r in admitted)}


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def header(table):
    obj = table["object"]
    lines = ["/* Generated from authenticated ELF CFI; no stack scanning. */",
             "#ifndef BEND_PROFILER_UNWIND_TABLE_H", "#define BEND_PROFILER_UNWIND_TABLE_H",
             "#include <stdint.h>",
             "typedef struct { uintptr_t start, end; intptr_t cfa, ra; } BendUnwindRow;",
             "#define BEND_UNWIND_OBJECT_PATH " + json.dumps(obj["file"], ensure_ascii=True),
             "#define BEND_UNWIND_OBJECT_DEVICE UINT64_C(%d)" % obj["device"],
             "#define BEND_UNWIND_OBJECT_INODE UINT64_C(%d)" % obj["inode"],
             "#define BEND_UNWIND_OBJECT_SHA256 " + json.dumps(obj["sha256"]),
             "#define BEND_UNWIND_ID " + json.dumps(table["id"]),
             "#define BEND_UNWIND_ROW_COUNT %d" % len(table["rows"]),
             "static const BendUnwindRow BEND_UNWIND_ROWS[] = {"]
    for row in table["rows"]:
        lines.append("  {UINT64_C(0x%x), UINT64_C(0x%x), %d, %d}," %
                     (row["start"], row["end"], row["cfa"], row["ra"]))
    return "\n".join(lines + ["};", "#endif", ""])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--object", required=True, type=Path)
    parser.add_argument("--ranges", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--allow-partial", action="store_true",
                        help="explicitly record unsupported intervals; never guess their rules")
    args = parser.parse_args()
    try:
        if args.out.exists():
            raise CFIError("output directory must be fresh")
        obj = args.object.resolve(strict=True)
        ranges_path = args.ranges.resolve(strict=True)
        stat = obj.stat()
        digest, ranges_digest = sha256(obj), sha256(ranges_path)
        document = json.loads(ranges_path.read_text())
        expected = document.get("object", {}).get("sha256")
        if expected and expected != digest:
            raise CFIError("range metadata object SHA256 mismatch")
        ranges = requested_ranges(document)
        readelf = shutil.which("readelf")
        if not readelf:
            raise CFIError("GNU readelf is required")
        env = {**os.environ, "LC_ALL": "C"}
        def inspect(*options):
            result = subprocess.run([readelf, *options, str(obj)], env=env,
                                    text=True, capture_output=True, check=True, timeout=30)
            if result.stderr.strip():
                raise CFIError("readelf diagnostic: " + result.stderr.strip())
            return result.stdout
        elf_header = inspect("-h")
        if not (re.search(r"Class:\s+ELF64\s", elf_header) and
                re.search(r"Data:\s+2's complement, little endian", elf_header) and
                re.search(r"Machine:\s+Advanced Micro Devices X86-64", elf_header)):
            raise CFIError("only little-endian ELF64 x86-64 is supported")
        frames = inspect("-W", "--debug-dump=frames-interp")
        table = prepare_rows(frames, ranges, args.allow_partial)
        current = obj.stat()
        if ((current.st_dev, current.st_ino, current.st_size, current.st_mtime_ns) !=
            (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns) or sha256(obj) != digest or
            sha256(ranges_path) != ranges_digest):
            raise CFIError("input changed during metadata preparation")
        identity = {"objectSha256": digest, "rows": table["rows"]}
        table.update(schema="bend-bounded-physical-unwind-v1",
                     id=hashlib.sha256(json.dumps(identity, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
                     object={"file": str(obj), "sha256": digest, "bytes": stat.st_size,
                             "device": stat.st_dev, "inode": stat.st_ino},
                     request={"file": str(ranges_path), "sha256": ranges_digest, "ranges": ranges},
                     method={"reader": str(Path(readelf).resolve()), "readerSha256": sha256(Path(readelf)),
                             "framesSha256": hashlib.sha256(frames.encode()).hexdigest(),
                             "command": [readelf, "-W", "--debug-dump=frames-interp", str(obj)],
                             "section": ".eh_frame", "architecture": "x86-64",
                             "rule": "CFA=rsp+cfa; physical RA=memory[CFA+ra]"},
                     limitations=["Exactly one physical return address; no tail-call ancestry.",
                                  "Consumer must authenticate object mapping and enforce stack bounds.",
                                  "Unsupported rules and uncovered padding never yield unwind rows."])
        # Preserve just selected FDEs plus referenced CIEs, not a large global dump.
        selected_fdes = {row["fdeOffset"] for row in table["fdeCoverage"]}
        selected_cies = {row["cieOffset"] for row in table["fdeCoverage"]}
        evidence = ["Contents of the .eh_frame section:\n"]
        eh_frames = frames.split("Contents of the .eh_frame section:", 1)[1]
        eh_frames = eh_frames.split("Contents of the ", 1)[0]
        for block in re.split(r"\n\s*\n", eh_frames):
            first = block.strip().splitlines()[0] if block.strip() else ""
            match = re.match(r"([0-9a-fA-F]+)\s+\S+\s+\S+\s+(CIE|FDE)\b", first)
            if match and int(match[1], 16) in (selected_cies if match[2] == "CIE" else selected_fdes):
                evidence.append(block.strip() + "\n")
        selected_frames = "\n".join(evidence)
        table["method"]["selectedFramesSha256"] = hashlib.sha256(selected_frames.encode()).hexdigest()
        args.out.mkdir(parents=True)
        (args.out / "table.json").write_text(json.dumps(table, indent=2) + "\n")
        (args.out / "unwind-table.h").write_text(header(table))
        (args.out / "frames-interp.txt").write_text(selected_frames)
        print(json.dumps({"table": str(args.out / "table.json"), "id": table["id"],
                          "rows": len(table["rows"]), "complete": table["complete"],
                          "coveredBytes": table["coveredBytes"], "requestedBytes": table["requestedBytes"]}))
    except (CFIError, OSError, KeyError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(2, "unwind: %s\n" % error)


if __name__ == "__main__":
    main()
