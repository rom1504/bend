#!/usr/bin/env python3
"""Join ordered physical samples, bounded callers and optional dispatch IDs.

Offline only. These are one-frame physical edges and active dispatch contexts,
never reconstructed logical stacks or allocation-source attribution.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

import analyze

UNKNOWN = 2**32 - 1


def checked_pin(identity):
    actual = analyze.pin(identity["file"])
    if actual["sha256"] != identity["sha256"] or actual["bytes"] != identity["bytes"]:
        raise ValueError("Artifact identity changed: " + identity["file"])
    return actual


def vector(text, magic, marker, required):
    lines = text.splitlines()
    if not lines or lines[0] != magic or lines[-1] != "END" or lines.count(marker) != 1:
        raise ValueError("Incomplete or unknown sidecar format")
    at = lines.index(marker)
    header = {}
    for line in lines[1:at]:
        cells = line.split("\t")
        if len(cells) != 2 or cells[0] in header:
            raise ValueError("Malformed or duplicate sidecar header")
        header[cells[0]] = cells[1]
    if set(header) != set(required):
        raise ValueError("Unexpected sidecar headers")
    if not re.fullmatch(r"[0-9]+", header["samples"]):
        raise ValueError("Invalid sidecar sample count")
    header["samples"] = int(header["samples"])
    rows = lines[at + 1:-1]
    if len(rows) != header["samples"]:
        raise ValueError("Sidecar sample count mismatch")
    return header, rows


def parse_callers(text):
    header, lines = vector(text, "BEND_PHYSICAL_CALLERS_V1", "ROWS",
                           {"unwind_id", "object_sha256", "samples"})
    if any(not re.fullmatch(r"[0-9a-f]{64}", header[k]) for k in ("unwind_id", "object_sha256")):
        raise ValueError("Invalid caller table identity")
    rows = []
    for line in lines:
        match = re.fullmatch(r"([0-9]+)\t([0-9a-fA-F]+)", line)
        if not match:
            raise ValueError("Malformed caller row")
        rule, address = int(match[1]), int(match[2], 16)
        if rule > UNKNOWN or address >= 2**64 or ((rule == UNKNOWN) != (address == 0)):
            raise ValueError("Invalid unknown caller sentinel or address")
        rows.append((rule, address))
    return header, rows


def parse_contexts(text):
    header, lines = vector(text, "BEND_DISPATCH_SAMPLES_V1", "IDS",
                           {"context_available", "samples"})
    if header["context_available"] not in ("0", "1"):
        raise ValueError("Invalid context availability")
    available = header["context_available"] == "1"
    fids = []
    for line in lines:
        if not re.fullmatch(r"[0-9]+", line) or int(line) > UNKNOWN:
            raise ValueError("Invalid dispatch ID")
        fid = int(line)
        if not available and fid != UNKNOWN:
            raise ValueError("Unavailable context contains a dispatch ID")
        fids.append(fid)
    return {**header, "context_available": available}, fids


def validate_table(table, caller_header):
    if table.get("schema") != "bend-bounded-physical-unwind-v1":
        raise ValueError("Unsupported unwind table schema")
    rows = table["rows"]
    if not rows:
        raise ValueError("Empty unwind table")
    for row in rows:
        if set(row) != {"start", "end", "cfa", "ra"} or any(type(v) is not int for v in row.values()):
            raise ValueError("Malformed unwind rule")
        if not 0 <= row["start"] < row["end"] < 2**64:
            raise ValueError("Invalid unwind interval")
        if any(not -(2**63) < value < 2**63 for value in (row["cfa"], row["ra"], row["cfa"] + row["ra"])):
            raise ValueError("Unrepresentable unwind offset")
    if any(a["end"] > b["start"] for a, b in zip(rows, rows[1:])):
        raise ValueError("Overlapping or unsorted unwind rows")
    identity = {"objectSha256": table["object"]["sha256"], "rows": rows}
    digest = hashlib.sha256(json.dumps(identity, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    if table["id"] != digest or caller_header["unwind_id"] != digest:
        raise ValueError("Caller unwind ID mismatch")
    if caller_header["object_sha256"] != table["object"]["sha256"]:
        raise ValueError("Caller unwind object mismatch")


def validate_applied_rule(index, leaf, table):
    if index == UNKNOWN:
        return
    if not 0 <= index < len(table["rows"]):
        raise ValueError("Caller rule index outside table")
    if leaf.get("objectSha256") != table["object"]["sha256"]:
        raise ValueError("Applied CFI rule has wrong leaf object")
    pc = leaf.get("elfAddress")
    row = table["rows"][index]
    if pc is None or not row["start"] <= pc < row["end"]:
        raise ValueError("Applied CFI row does not cover original leaf PC")


class Resolver:
    def __init__(self, maps, identities):
        self.maps, self.objects, self.errors = maps, {}, {}
        self.pins = {Path(p["file"]).resolve(): p for p in identities}

    def resolve(self, pc):
        mapping = next((m for m in self.maps if m["start"] <= pc < m["end"]), None)
        result = {"pc": hex(pc), "object": mapping["path"] if mapping else None,
                  "elfAddress": None, "symbol": None, "decoded": None,
                  "rangeBasis": None, "objectSha256": None}
        if not mapping or "x" not in mapping["permissions"]:
            return result
        path = mapping["path"]
        if path not in self.objects and path not in self.errors:
            valid, reason = analyze.mapping_identity(mapping)
            if valid:
                try:
                    pin = analyze.pin(path)
                    expected = self.pins.get(Path(path).resolve())
                    if expected is None or expected["sha256"] != pin["sha256"]:
                        raise ValueError("Object lacks matching capture-analysis hash")
                    segments, symbols = analyze.load_object(path)
                    self.objects[path] = segments, symbols, pin
                except (OSError, ValueError, subprocess.SubprocessError) as error:
                    self.errors[path] = str(error)
            else:
                self.errors[path] = reason
        if path not in self.objects:
            result["error"] = self.errors[path]
            return result
        segments, symbols, pin = self.objects[path]
        address = analyze.ELF.virtual_address(pc, mapping, segments)
        result.update(elfAddress=address, objectSha256=pin["sha256"])
        symbol = symbols.resolve(address) if address is not None else None
        if symbol:
            result.update(symbol=symbol["name"], decoded=analyze.decode_name(symbol["name"]),
                          rangeBasis=symbol["range_basis"], offset=symbol["offset"])
        return result


def bind_owners(owner_map, binary):
    """Validate exact dispatch order against linked ELF pointers, not ELF order."""
    if owner_map.get("schema") != "bend-qbe-lowered-owners-v1":
        raise ValueError("Unknown owner map schema")
    checked_pin(owner_map["identities"]["qbe"])
    segments = analyze.ELF.load_segments(binary)
    symbols = {}
    for line in subprocess.check_output(["readelf", "-W", "-s", str(binary)], text=True).splitlines():
        fields = line.split()
        if len(fields) >= 8 and fields[0].rstrip(":").isdigit() and fields[6].isdigit():
            name, value = fields[7], int(fields[1], 16)
            if name in symbols and symbols[name] != value:
                raise ValueError("Ambiguous ELF symbol: " + name)
            symbols[name] = value
    relocs = {}
    relocation_text = subprocess.check_output(["readelf", "-W", "-r", str(binary)], text=True)
    if ".relr" in relocation_text:
        raise ValueError("Packed ELF relocations are not supported for owner binding")
    for line in relocation_text.splitlines():
        fields = line.split()
        if len(fields) >= 3 and re.fullmatch(r"[0-9a-fA-F]+", fields[0]) and fields[2].startswith("R_"):
            offset = int(fields[0], 16)
            if offset in relocs:
                raise ValueError("Duplicate ELF relocation")
            relocs[offset] = fields
    with Path(binary).open("rb") as stream:
        elf = stream.read(64)
        if (len(elf) < 64 or elf[:6] != b"\x7fELF\x02\x01" or
            struct.unpack_from("<H", elf, 18)[0] != 62 or
            struct.unpack_from("<H", elf, 16)[0] not in (2, 3)):
            raise ValueError("Owner binding requires little-endian x86-64 ELF")
        def word(address):
            if address in relocs:
                fields = relocs[address]
                if fields[2] != "R_X86_64_RELATIVE" or len(fields) != 4:
                    raise ValueError("Unsupported segment-table relocation")
                return int(fields[3], 16)
            for offset, virtual, size in segments:
                if virtual <= address and address + 8 <= virtual + size:
                    stream.seek(offset + address - virtual)
                    return struct.unpack("<Q", stream.read(8))[0]
            raise ValueError("Descriptor/table extends outside ELF file data")
        desc = symbols["p111_program"]
        table = symbols["p111_segments"]
        abi = owner_map["descriptor"]
        expected = {0: 11101, 8: 192, 16: abi["segment_count"], 32: abi["main_fid"], 96: table}
        if any(word(desc + offset) != value for offset, value in expected.items()):
            raise ValueError("ELF descriptor does not match owner map")
        fids = owner_map["fids"]
        if len(fids) != abi["segment_count"] or any(row["fid"] != i for i, row in enumerate(fids)):
            raise ValueError("Owner FIDs are not the exact descriptor sequence")
        for i, row in enumerate(fids):
            if row["symbol"] not in symbols or word(table + 8 * i) != symbols[row["symbol"]]:
                raise ValueError("ELF segment-table owner binding mismatch at FID %d" % i)
    functions = {row["symbol"]: row for row in owner_map["functions"] if row["symbol"] in symbols}
    if len(functions) != sum(row["symbol"] in symbols for row in owner_map["functions"]):
        raise ValueError("Duplicate owner-map function")
    linked_fids = [{**row, "elfAddress": symbols[row["symbol"]]} for row in fids]
    return functions, linked_fids, {"kind": "exact-ELF-segment-table-pointers", "checkedFids": len(fids),
                              "checkedFunctionSymbols": len(functions),
                              "elfType": struct.unpack_from("<H", elf, 16)[0],
                              "producerProvenanceVerified": False,
                              "lexicalOwnerConditionalOnEmitterContract": True}


def receipt_binding(analysis_path, identities):
    candidate = analysis_path.parent.parent / "report.json"
    if not candidate.is_file():
        return {"verified": False, "reason": "No enclosing run receipt; vector pairing is structural only"}
    document = json.loads(candidate.read_text())
    matches = [r for r in document.get("rows", []) if r.get("analysis", {}).get("file") == str(analysis_path)]
    if not matches:
        return {"verified": False, "reason": "Enclosing receipt does not identify this analysis"}
    if len(matches) != 1:
        raise ValueError("Ambiguous capture receipt")
    row = matches[0]
    for key, identity in identities.items():
        wanted = "profile" if key == "capture" else key
        expected = row.get(wanted)
        if not expected or expected["sha256"] != identity["sha256"] or expected["file"] != identity["file"]:
            raise ValueError("Sidecar/capture receipt identity mismatch: " + key)
    return {"verified": True, "receipt": analyze.pin(candidate), "workload": row.get("workload"),
            "variant": row.get("variant"), "round": row.get("round"), "correct": row.get("correct")}


def attribute(analysis_path, callers_path, table_path, contexts_path=None, owners_path=None):
    analysis_path, callers_path, table_path = (Path(p).resolve() for p in (analysis_path, callers_path, table_path))
    analysis = json.loads(analysis_path.read_text())
    capture = checked_pin(analysis["identities"]["capture"])
    binary = checked_pin(analysis["identities"]["binary"])
    header, maps, counts = analyze.parse_capture(capture["file"])
    if header != analysis["header"] or maps != analysis["maps"]:
        raise ValueError("Analysis metadata does not match raw capture")
    expected_counts = {int(row["pc"], 16): row["samples"] for row in analysis["pcs"]}
    if len(expected_counts) != len(analysis["pcs"]) or dict(counts) != expected_counts:
        raise ValueError("Analysis PC histogram does not match raw capture")
    lines = Path(capture["file"]).read_text().splitlines()
    pcs = [int(line, 16) for line in lines[lines.index("PCS") + 1:-1]]
    caller_header, callers = parse_callers(callers_path.read_text())
    table = json.loads(table_path.read_text())
    validate_table(table, caller_header)
    checked_pin(table["object"])
    if caller_header["samples"] != len(pcs):
        raise ValueError("Caller/capture sample count mismatch")
    identities = {"analysis": analyze.pin(analysis_path), "callers": analyze.pin(callers_path),
                  "capture": capture}
    context_header, contexts = None, [UNKNOWN] * len(pcs)
    if contexts_path:
        contexts_path = Path(contexts_path).resolve()
        context_header, contexts = parse_contexts(contexts_path.read_text())
        if len(contexts) != len(pcs):
            raise ValueError("Context/capture sample count mismatch")
        identities["contexts"] = analyze.pin(contexts_path)
    pairing = receipt_binding(analysis_path, identities)
    identities.update(table=analyze.pin(table_path), binary=binary, tool=analyze.pin(__file__),
                      dependencies=[analyze.pin(analyze.__file__), analyze.pin(analyze.DEPENDENCY)])
    resolver = Resolver(maps, analysis["identities"]["mapped_objects"])
    functions, fids, binding = {}, [], None
    if owners_path:
        owners_path = Path(owners_path).resolve()
        functions, fids, binding = bind_owners(json.loads(owners_path.read_text()), binary["file"])
        identities["owners"] = analyze.pin(owners_path)

    def ownership(resolved):
        row = functions.get(resolved.get("symbol")) if resolved.get("objectSha256") == binary["sha256"] else None
        return {"loweredOwner": row.get("lowered_owner"), "ownerBasis": row.get("owner_basis")} if row else {}

    events, matrix, contexts_matrix, context_leaves = [], collections.Counter(), collections.Counter(), collections.Counter()
    cache = {}
    totals = collections.Counter({key: 0 for key in ("eligibleLeafSamples", "recoveredCallerSamples",
                                  "symbolizedCallerSamples", "inferredCallerSymbolSamples", "knownDispatchSamples")})
    def resolve(pc):
        if pc not in cache:
            value = resolver.resolve(pc)
            cache[pc] = {**value, **ownership(value)}
        return cache[pc]
    for number, (pc, (rule, address), fid) in enumerate(zip(pcs, callers, contexts)):
        leaf = resolve(pc)
        eligible = leaf.get("objectSha256") == table["object"]["sha256"] and any(
            r["start"] <= leaf["elfAddress"] < r["end"] for r in table["rows"] if leaf["elfAddress"] is not None)
        totals["eligibleLeafSamples"] += bool(eligible)
        validate_applied_rule(rule, leaf, table)
        caller = resolve(address - 1) if rule != UNKNOWN else None
        totals["recoveredCallerSamples"] += caller is not None
        totals["symbolizedCallerSamples"] += caller is not None and caller["symbol"] is not None
        totals["inferredCallerSymbolSamples"] += caller is not None and caller["rangeBasis"] == "next_symbol_inferred"
        context = None
        if contexts_path:
            context = {"fid": None if fid == UNKNOWN else fid, "kind": "unknown"}
            if fid != UNKNOWN:
                context["kind"] = "active_dispatch"
                totals["knownDispatchSamples"] += 1
                if fids and fid < len(fids):
                    context.update(symbol=fids[fid]["symbol"], loweredOwner=fids[fid]["lowered_owner"],
                                   ownerBasis=fids[fid]["owner_basis"])
                elif fids:
                    context["kind"] = "runtime_or_out_of_program_fid"
                contexts_matrix[(fid, context.get("symbol"), context.get("loweredOwner"))] += 1
            else:
                contexts_matrix[(None, None, None)] += 1
            context_leaves[(context.get("fid"), context.get("loweredOwner"),
                            leaf["object"], leaf["symbol"], leaf.get("loweredOwner"))] += 1
        event = {"sample": number, "leaf": leaf, "unwindRule": None if rule == UNKNOWN else rule,
                 "returnAddress": hex(address) if address else None, "caller": caller}
        if contexts_path:
            event["dispatchContext"] = context
        events.append(event)
        key = (leaf["object"], leaf["symbol"], None if rule == UNKNOWN else rule,
               caller["object"] if caller else None, caller["symbol"] if caller else None,
               caller.get("loweredOwner") if caller else None)
        matrix[key] += 1
    total = len(pcs)
    totals["allSamples"] = total
    totals["unknownCallerSamples"] = total - totals["recoveredCallerSamples"]
    totals["eligibleWithoutCallerSamples"] = totals["eligibleLeafSamples"] - totals["recoveredCallerSamples"]
    quality = analyze.capture_quality(header)
    result = {"schema": "bend-physical-attribution-v1", "identities": identities,
              "pairing": pairing, "unwindId": table["id"], "ownerBinding": binding,
              "coverage": dict(totals), "quality": quality, "contextHeader": context_header,
              "matrix": [{"leafObject": key[0], "leafSymbol": key[1], "unwindRule": key[2],
                          "callerObject": key[3], "callerSymbol": key[4], "callerLoweredOwner": key[5],
                          "samples": count, "fractionOfAllSamples": count / total if total else 0.0}
                         for key, count in matrix.most_common()],
              "dispatchContexts": [{"fid": key[0], "symbol": key[1], "loweredOwner": key[2],
                                    "samples": count, "fractionOfAllSamples": count / total if total else 0.0}
                                   for key, count in contexts_matrix.most_common()],
              "contextLeafMatrix": [{"fid": key[0], "dispatchLoweredOwner": key[1],
                                     "leafObject": key[2], "leafSymbol": key[3], "leafLoweredOwner": key[4],
                                     "samples": count, "fractionOfAllSamples": count / total if total else 0.0}
                                    for key, count in context_leaves.most_common()],
              "objectErrors": resolver.errors,
              "limitations": ["All samples remain in denominators, including unsupported or unknown callers.",
                               "One physical caller only; returnaddress-1 selects the preceding call instruction's symbol.",
                               "CFI coverage and object identity are checked; raw stack memory is not retained or re-read.",
                               "Tail-erased callers and logical source ancestry cannot be reconstructed.",
                               "Active dispatch is a separate context; synchronous private calls retain the outer dispatch.",
                               "Lowered ownership assumes the recorded emitter contract; linked FID validation does not prove compiler lineage.",
                               "Short or lossy captures remain inspectable, with their original quality restrictions.",
                               "The sidecar format lacks a raw-capture hash; a matching runner receipt strengthens pairing."]}
    return result, events


def aggregate_events(document, fids, binding):
    if document.get("schema") != "bend-native-dispatch-events-v1":
        raise ValueError("Unknown runtime-event schema")
    if document.get("context_kind") != "active-dispatch-not-logical-ancestry":
        raise ValueError("Unsupported runtime-event attribution semantics")
    count = document["segment_count"]
    runtime_count = document["runtime_segment_count"]
    if count != len(fids) or document["unknown_fid"] != UNKNOWN or runtime_count != 4:
        raise ValueError("Runtime event descriptor disagrees with linked owner map")
    names = document["counter_names"]
    if not names or len(set(names)) != len(names) or any(not isinstance(n, str) or not n for n in names):
        raise ValueError("Invalid or duplicate runtime-event counter names")
    grouped, totals, seen, biases = {}, collections.Counter(), set(), set()
    for row in document["rows"]:
        fid, values = row["fid"], row["counts"]
        if type(fid) is not int or fid in seen or not (0 <= fid < count + runtime_count or fid == UNKNOWN):
            raise ValueError("Invalid or duplicate runtime-event FID")
        seen.add(fid)
        if len(values) != len(names) or any(type(n) is not int or not 0 <= n < 2**64 for n in values):
            raise ValueError("Invalid runtime-event count vector")
        address = int(row["segment_address"], 16)
        if fid < count:
            if not 0 < address < 2**64:
                raise ValueError("Invalid runtime-event segment address")
            biases.add(address - fids[fid]["elfAddress"])
            owner = fids[fid].get("lowered_owner")
            kind = "lowered_owner" if owner is not None else "unowned_program_segment"
        else:
            if address != 0:
                raise ValueError("Non-program event has a segment address")
            owner = None if fid == UNKNOWN else "runtime FID %d" % fid
            kind = "outside_dispatch" if fid == UNKNOWN else "runtime_segment"
        key = owner, kind
        group = grouped.setdefault(key, {"fids": [], "counts": collections.Counter()})
        group["fids"].append(fid)
        for name, value in zip(names, values):
            group["counts"][name] += value
            totals[name] += value
    if len(biases) > 1 or (binding["elfType"] == 2 and biases and biases != {0}):
        raise ValueError("Runtime-event addresses do not match linked segment table")
    if biases and next(iter(biases)) % 4096:
        raise ValueError("Runtime-event load bias is not page aligned")
    good = (document.get("complete") is True and document.get("counts_enabled") is True and
            document.get("counter_overflow") is False and document.get("invalid_context_events") == 0)
    groups = [{"owner": key[0], "kind": key[1], "observedFids": value["fids"],
               "counts": dict(value["counts"])} for key, value in grouped.items()]
    top = {name: [{"owner": group["owner"], "kind": group["kind"], "count": group["counts"][name],
                   "fractionOfAllEvents": group["counts"][name] / totals[name] if totals[name] else 0.0}
                  for group in sorted(groups, key=lambda g: g["counts"][name], reverse=True)[:25]
                  if group["counts"][name]] for name in names}
    return {"totals": dict(totals), "owners": groups, "topOwnersPerCounter": top,
            "coverage": {"observedFids": len(seen), "descriptorFids": count,
                         "observedOwnerGroups": len(groups), "eventAddressLoadBias": next(iter(biases)) if biases else None},
            "quality": {"usableCounts": good, **{key: document.get(key) for key in
                        ("complete", "counts_enabled", "counter_overflow", "invalid_context_events", "global_context_scope")}}}


def attribute_events(events_path, binary_path, owners_path):
    events_path, binary_path, owners_path = (Path(p).resolve() for p in (events_path, binary_path, owners_path))
    identities = {"events": analyze.pin(events_path), "binary": analyze.pin(binary_path),
                  "owners": analyze.pin(owners_path), "tool": analyze.pin(__file__),
                  "dependencies": [analyze.pin(analyze.__file__), analyze.pin(analyze.DEPENDENCY)]}
    document = json.loads(events_path.read_text())
    _, fids, binding = bind_owners(json.loads(owners_path.read_text()), binary_path)
    result = aggregate_events(document, fids, binding)
    receipt_path = events_path.parent.parent / "report.json"
    pairing = {"verified": False, "reason": "No matching external event receipt"}
    if receipt_path.is_file():
        receipt = json.loads(receipt_path.read_text())
        rows = [row for row in receipt.get("rows", []) if row.get("events", {}).get("file") == str(events_path)]
        if rows:
            row = rows[0]
            if (len(rows) != 1 or row["events"]["sha256"] != identities["events"]["sha256"] or
                Path(row["command"][0]).resolve() != binary_path):
                raise ValueError("Event receipt pairing mismatch")
            binary_pins = [p for p in receipt.get("inputs", []) if p.get("file") == str(binary_path)]
            if not binary_pins or any(p["sha256"] != identities["binary"]["sha256"] for p in binary_pins):
                raise ValueError("Event receipt does not authenticate the binary")
            pairing = {"verified": True, "receipt": analyze.pin(receipt_path), "workload": row.get("workload"),
                       "variant": row.get("variant"), "correct": row.get("correct")}
    return {"schema": "bend-runtime-owner-attribution-v1", "identities": identities,
            "ownerBinding": binding, "pairing": pairing, **result,
            "limitations": document.get("limitations", []) + [
                "Counts are attributed to active dispatch execution context, not object creation or logical ancestry.",
                "Synchronous private calls retain the outer dispatch; inlined operations can bypass hooks.",
                "Each counter has its own all-event denominator; unknown and runtime FIDs are retained.",
                "Linked segment pointers/FIDs are exact; lexical owners still depend on the emitter contract.",
                "Counts are diagnostic event volumes, not CPU-time shares or demonstrated optimization savings."]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("analysis", "callers", "table", "events", "binary"):
        parser.add_argument("--" + name, type=Path)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--contexts", type=Path)
    parser.add_argument("--owners", type=Path)
    args = parser.parse_args()
    try:
        if args.out.exists():
            raise ValueError("Output directory must be fresh")
        if args.events:
            if not args.binary or not args.owners or any((args.analysis, args.callers, args.table, args.contexts)):
                raise ValueError("Event mode requires --events --binary --owners, without sample arguments")
            report = attribute_events(args.events, args.binary, args.owners)
            events = None
        else:
            if not all((args.analysis, args.callers, args.table)) or args.binary:
                raise ValueError("Sample mode requires --analysis --callers --table")
            report, events = attribute(args.analysis, args.callers, args.table, args.contexts, args.owners)
        args.out.mkdir(parents=True)
        if events is not None:
            event_path = args.out / "events.jsonl"
            with event_path.open("x") as stream:
                for event in events:
                    stream.write(json.dumps(event, separators=(",", ":")) + "\n")
            report["identities"]["events"] = analyze.pin(event_path)
        (args.out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps({"report": str(args.out / "report.json"), "coverage": report["coverage"],
                          "receiptVerified": report["pairing"]["verified"]}))
    except (ValueError, OSError, KeyError, subprocess.SubprocessError) as error:
        parser.exit(2, "attribute: %s\n" % error)


if __name__ == "__main__":
    main()
