#!/usr/bin/env python3
"""Extract exact QBE FIDs and conditional lexical lowered-definition owners.

This is not a call graph or logical stack. Grouping is valid under the recorded
emitter contract; QBE alone cannot prove which source/compiler produced it.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
CONTRACT_FILES = [
    "selfhost/tools/performance/phase111/segment/lower-book.bend",
    "selfhost/tools/performance/phase111/segment/lower-control.bend",
    "selfhost/tools/performance/phase111/segment/lower-helpers.bend",
    "selfhost/tools/performance/phase111/qbe/program.bend",
    "selfhost/tools/performance/phase111/qbe/emit.bend",
    "selfhost/tools/performance/phase113/direct-emit/program.bend",
    "selfhost/src/back/native/bridge.bend",
    "selfhost/src/back/native/direct.bend",
    "selfhost/src/back/native/text.bend",
]
TABLE_NAME = "p111_segments"
DESCRIPTOR_NAME = "p111_program"
SYMBOL = r"[A-Za-z_.$][A-Za-z0-9_.$]*"
FUNCTION = re.compile(r"^\s*(?:export\s+)?function\s+(?:[A-Za-z0-9_:]+\s+)?\$(" + SYMBOL + r")\s*\(")
DATA = re.compile(r"^\s*(?:export\s+)?data\s+\$(p111_segments|p111_program)\s*=.*?\{")


def pin(path):
    path = Path(path).resolve()
    sha = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            sha.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=sha.hexdigest())


def decoded_symbol(symbol):
    match = re.fullmatch(r"[A-Za-z0-9_]+_FID_((?:[0-9]+_)+)", symbol)
    if not match:
        return None
    try:
        codes = [int(code) for code in match[1].rstrip("_").split("_")]
        if any(code > 0x10FFFF or 0xD800 <= code <= 0xDFFF for code in codes):
            return None
        name = "".join(chr(code) for code in codes)
        return name if name and all(char.isprintable() for char in name) else None
    except ValueError:
        return None


def read_qbe(path):
    """Stream bodies; retain only declarations and the two ABI data blocks."""
    functions, blocks = {}, {}
    active, body = None, []
    with Path(path).open() as stream:
        for number, line in enumerate(stream, 1):
            if active is not None:
                body.append(line)
            else:
                function = FUNCTION.match(line)
                if function:
                    name = function[1]
                    if name in functions:
                        raise ValueError("Duplicate function definition: " + name)
                    functions[name] = number
                data = DATA.match(line)
                if data:
                    active = data[1]
                    if active in blocks:
                        raise ValueError("Duplicate ABI data block: " + active)
                    body = [line[data.end():]]
            if active is not None and "}" in line:
                joined = "".join(body)
                content, tail = joined.split("}", 1)
                if tail.strip():
                    raise ValueError("Unsupported text following ABI data block")
                blocks[active] = content
                active, body = None, []
    if active is not None:
        raise ValueError("Unterminated ABI data block")
    if set(blocks) != {TABLE_NAME, DESCRIPTOR_NAME}:
        raise ValueError("Missing P111 descriptor or segment table")
    return functions, blocks


def descriptor(block):
    fields = [field.strip() for field in block.split(",")]
    if len(fields) != 24 or not all(re.fullmatch(r"l (?:[0-9]+|\$" + SYMBOL + r")", f) for f in fields):
        raise ValueError("Unsupported P111 descriptor layout")
    values = [field[2:] for field in fields]
    if values[:2] != ["11101", "192"] or values[12] != "$p111_segments":
        raise ValueError("Unsupported P111 descriptor ABI or table reference")
    if not values[2].isdigit() or not values[4].isdigit():
        raise ValueError("Nonliteral descriptor segment count or entry FID")
    count, main = int(values[2]), int(values[4])
    if count > 65532 or (count and main >= count):
        raise ValueError("Descriptor FIDs exceed supported bounds")
    if any(not values[i].isdigit() for i in (6,7,11)):
        raise ValueError('Nonliteral runtime transport descriptor')
    return dict(magic=11101, bytes=192, segment_count=count, main_fid=main,
                register_width=int(values[6]), result_width=int(values[7]),
                capabilities=int(values[11]))


def group_fids(fids):
    """Check whole contiguous groups before assigning any anonymous ownership."""
    groups, pending = [], []
    owner = None

    def finish():
        if not pending:
            return
        errors = []
        direct_count = 0
        for row in pending:
            name = row["decoded"]
            if row["role"] == "direct_segment":
                direct_count += 1
                if name[len("$direct."):] != owner:
                    errors.append("Direct entry disagrees with named factory")
            elif row["role"] == "unsupported":
                errors.append("Unknown segment naming form")
        if direct_count > 1:
            errors.append("More than one direct entry in a factory group")
        if owner is None:
            errors.append("No preceding named factory")
        valid = not errors
        for row in pending:
            row["lowered_owner"] = owner if valid else None
            row["owner_basis"] = "contiguous_lowering_group" if valid else "unknown"
        groups.append(dict(lowered_owner=owner, first_fid=pending[0]["fid"],
                           last_fid=pending[-1]["fid"], count=len(pending),
                           valid_under_emitter_contract=valid, errors=sorted(set(errors))))

    for row in fids:
        name = row["decoded"]
        factory = name is not None and (not name.startswith("$") or name.startswith("$native."))
        if factory:
            finish()
            pending = []
            owner = name
            row["role"] = "native_factory" if name.startswith("$native.") else "named_factory"
        elif name is not None and name.startswith("$direct."):
            row["role"] = "direct_segment"
        elif name is not None and re.fullmatch(r"\$p111\.k\.[0-9]+", name):
            row["role"] = "anonymous_lowered_segment"
        else:
            row["role"] = "unsupported"
        pending.append(row)
    finish()
    return groups


def parse_qbe_owners(qbe_path):
    qbe_path = Path(qbe_path).resolve()
    functions, blocks = read_qbe(qbe_path)
    abi = descriptor(blocks[DESCRIPTOR_NAME])
    fields = [field.strip() for field in blocks[TABLE_NAME].split(",")]
    if abi["segment_count"] == 0 and fields == ["b 0"]:
        fields = []
    symbols = []
    for field in fields:
        match = re.fullmatch(r"l \$(" + SYMBOL + r")", field)
        if not match:
            raise ValueError("Nonliteral segment-table relocation")
        symbols.append(match[1])
    if len(symbols) != abi["segment_count"] or len(set(symbols)) != len(symbols):
        raise ValueError("Segment count mismatch or duplicate table symbol")
    missing = set(symbols) - functions.keys()
    if missing:
        raise ValueError("Table references missing QBE function: " + sorted(missing)[0])
    fids = [dict(fid=i, symbol=symbol, decoded=decoded_symbol(symbol)) for i, symbol in enumerate(symbols)]
    if any(not row["symbol"].startswith("p111_FID_") for row in fids):
        raise ValueError("Unsupported public segment symbol convention")
    names = [row["decoded"] for row in fids if row["decoded"] is not None]
    if len(set(names)) != len(names):
        raise ValueError("Ambiguous duplicate decoded segment identity")
    groups = group_fids(fids)
    by_name = {row["decoded"]: row for row in fids if row["decoded"] is not None}
    rows = []
    for symbol, line in functions.items():
        name = decoded_symbol(symbol)
        public = by_name.get(name)
        # Named private wrappers and anonymous workers share the exact decoded
        # segment identity. Composite product/observer/region names stay unknown.
        owner = public["lowered_owner"] if public else None
        rows.append(dict(symbol=symbol, decoded=name, qbe_line=line,
                         fid=public["fid"] if public and symbol == public["symbol"] else None,
                         lowered_owner=owner,
                         owner_basis=("exact_public_symbol" if public and symbol == public["symbol"] else
                                      "exact_decoded_segment_identity") if owner is not None else "unknown"))
    stats = collections.Counter(row["owner_basis"] for row in rows)
    return {
        "schema": "bend-qbe-lowered-owners-v1", "descriptor": abi,
        "identities": {"qbe": pin(qbe_path), "analyzer": pin(__file__),
                       "emitter_contract_sources": [pin(ROOT / path) for path in CONTRACT_FILES]},
        "functions": rows, "fids": fids, "groups": groups,
        "coverage": dict(functions=len(rows), owned_functions=sum(r["lowered_owner"] is not None for r in rows),
                         fids=len(fids), owned_fids=sum(r["lowered_owner"] is not None for r in fids),
                         valid_groups=sum(g["valid_under_emitter_contract"] for g in groups),
                         invalid_groups=sum(not g["valid_under_emitter_contract"] for g in groups),
                         function_basis_counts=dict(stats)),
        "producer_provenance_verified": False,
        "rules": [
            "FID is its exact zero-based relocation index in the descriptor's segment table; ELF address order is never used.",
            "Under p111_compile_step/defs, each named factory precedes all segments generated while lowering that definition; reverse-accumulation restores group order.",
            "Nested lambdas and continuations use $p111.k.* and remain in that lexical group, even when runtime calls escape or resume elsewhere.",
            "The optional $direct.NAME entry must agree exactly with its factory; $native.NAME is a distinct lowered identity.",
            "p111q_ids/table and p113e_public_chunks preserve segment order; private definitions do not change dispatch FIDs.",
            "Unsupported forms invalidate the whole current group. Private symbols attach only by exact decoded segment identity; composite origins are unknown.",
        ],
        "limitations": [
            "QBE identity and structural checks are exact; lexical ownership additionally assumes the recorded emitter contract and separately verified producer lineage.",
            "Current repository module hashes document the contract; they do not prove that these modules produced an arbitrary input QBE file.",
            "This is lowered-definition ownership, not dynamic logical ancestry, original inline origin, allocation origin, or source-line provenance.",
            "Inlining can place another source definition's work inside this owner; private product/observer/region functions may have composite origins and remain unknown.",
            "Runtime FIDs outside the descriptor segment count are not program definitions and must be interpreted from the separately pinned runtime ABI.",
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--qbe", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Refusing to overwrite owner map")
    report = parse_qbe_owners(args.qbe)
    with args.output.open("x") as stream:
        json.dump(report, stream, indent=2)
        stream.write("\n")
    print(json.dumps(report["coverage"], indent=2))


if __name__ == "__main__":
    main()
