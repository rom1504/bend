#!/usr/bin/env python3
"""Extract exact QBE/assembly FIDs and conditional lexical definition owners.

This is not a call graph or logical stack. Grouping is valid under the recorded
emitter contract; emitted text alone cannot prove its source/compiler provenance.
"""
import argparse
import bisect
import collections
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
TABLE_NAME = "p111_segments"
DESCRIPTOR_NAME = "p111_program"
SYMBOL = r"[A-Za-z_.$][A-Za-z0-9_.$]*"
FUNCTION = re.compile(r"^\s*(?:export\s+)?function\s+(?:[A-Za-z0-9_:]+\s+)?\$(" + SYMBOL + r")\s*\(")
DATA = re.compile(r"^\s*(?:export\s+)?data\s+\$(p111_segments|p111_program)\s*=.*?\{")
ASSEMBLY_FORMAT = 'gnu-x86-64-assembly'
NATIVE_SCHEMA = 'bend-native-lowered-owners-v1'


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


def read_assembly(path):
    """Stream the maintained GNU emitter's typed functions and literal ABI data."""
    functions, blocks, declarations, labels = {}, {}, set(), set()
    active, kind, started, body = None, None, False, []
    with Path(path).open() as stream:
        for number, line in enumerate(stream, 1):
            text = line.strip()
            if not text or text.startswith('#'):
                continue
            declaration = re.fullmatch(r'\.type\s+('+SYMBOL+r'),\s*@(function|object)', text)
            if declaration:
                if active is not None:
                    raise ValueError('Unterminated assembly definition: '+active)
                active, kind = declaration.groups()
                if active in declarations:
                    raise ValueError('Duplicate assembly definition: '+active)
                declarations.add(active); started, body = False, []
                continue
            label = re.fullmatch('('+SYMBOL+'):', text)
            if label:
                name = label[1]
                if name in labels:
                    raise ValueError('Duplicate assembly label: '+name)
                labels.add(name)
            if active is None:
                if label and label[1] in (TABLE_NAME,DESCRIPTOR_NAME):
                    raise ValueError('Untyped assembly ABI object')
                continue
            if not started:
                if text != active+':':
                    raise ValueError('Assembly type must precede its exact label: '+active)
                if kind == 'function':functions[active] = number
                elif active in (TABLE_NAME,DESCRIPTOR_NAME):blocks[active] = None
                started = True
                continue
            if text.startswith('.size'):
                if not re.fullmatch(r'\.size\s+'+re.escape(active)+r',\s*\.\s*-\s*'+re.escape(active),text):
                    raise ValueError('Assembly size does not close its definition: '+active)
                if active in blocks:blocks[active] = ', '.join(body)
                active = None
                continue
            if active in blocks:
                literal = re.fullmatch(r'\.quad\s+([0-9]+)',text)
                relocation = re.fullmatch(r'\.quad\s+('+SYMBOL+r')(?:\+0)?',text)
                if literal:body.append('l '+literal[1])
                elif relocation:body.append('l $'+relocation[1])
                elif text == '.byte 0' and active == TABLE_NAME:body.append('b 0')
                else:raise ValueError('Unsupported assembly ABI data: '+text)
    if active is not None:raise ValueError('Unterminated assembly definition: '+active)
    if set(blocks) != {TABLE_NAME,DESCRIPTOR_NAME}:
        raise ValueError('Missing assembly P111 descriptor or segment table')
    return functions, blocks


def descriptor(block):
    fields = [field.strip() for field in block.split(",")]
    if len(fields) != 24 or not all(re.fullmatch(r"l (?:[0-9]+|\$" + SYMBOL + r")", f) for f in fields):
        raise ValueError("Unsupported P111 descriptor layout")
    values = [field[2:] for field in fields]
    if values[0] not in ('11101','11102') or values[1] != "192" or values[12] != "$p111_segments":
        raise ValueError("Unsupported P111 descriptor ABI or table reference")
    if not values[2].isdigit() or not values[4].isdigit():
        raise ValueError("Nonliteral descriptor segment count or entry FID")
    count, main = int(values[2]), int(values[4])
    if count > 65532 or (count and main >= count):
        raise ValueError("Descriptor FIDs exceed supported bounds")
    if any(not values[i].isdigit() for i in (6,7,11)):
        raise ValueError('Nonliteral runtime transport descriptor')
    return dict(magic=int(values[0]), bytes=192, segment_count=count, main_fid=main,
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


def parse_owners(source_path, emitter_sources=(), source_format='qbe'):
    source_path = Path(source_path).resolve()
    identity = pin(source_path)
    if source_format not in ('qbe',ASSEMBLY_FORMAT):raise ValueError('Unknown owner source format')
    functions, blocks = (read_qbe if source_format == 'qbe' else read_assembly)(source_path)
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
        raise ValueError("Table references missing function: " + sorted(missing)[0])
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
        rows.append(dict(symbol=symbol, decoded=name,
                         **({'qbe_line':line} if source_format == 'qbe' else {'assembly_line':line}),
                         fid=public["fid"] if public and symbol == public["symbol"] else None,
                         lowered_owner=owner,
                         owner_basis=("exact_public_symbol" if public and symbol == public["symbol"] else
                                      "exact_decoded_segment_identity") if owner is not None else "unknown"))
    stats = collections.Counter(row["owner_basis"] for row in rows)
    report = {
        "schema": "bend-qbe-lowered-owners-v1" if source_format == 'qbe' else NATIVE_SCHEMA, "descriptor": abi,
        "identities": {"qbe" if source_format == 'qbe' else 'assembly': identity, "analyzer": pin(__file__),
                       "emitter_contract_sources": [pin(path) for path in emitter_sources]},
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
            "Emitted-source identity and structural checks are exact; lexical ownership additionally assumes the recorded emitter contract and separately verified producer lineage.",
            "Explicit emitter-source pins document the assumed contract; an empty list leaves it unbound. Neither proves production of arbitrary emitted text.",
            "This is lowered-definition ownership, not dynamic logical ancestry, original inline origin, allocation origin, or source-line provenance.",
            "Inlining can place another source definition's work inside this owner; private product/observer/region functions may have composite origins and remain unknown.",
            "Runtime FIDs outside the descriptor segment count are not program definitions and must be interpreted from the separately pinned runtime ABI.",
        ],
    }
    verify_pin(identity)
    if source_format != 'qbe':report['sourceFormat'] = source_format
    return report


def parse_qbe_owners(qbe_path, emitter_sources=()):
    return parse_owners(qbe_path,emitter_sources,'qbe')


def source_identity(owner_map):
    if owner_map.get('schema') == 'bend-qbe-lowered-owners-v1':
        return owner_map['identities']['qbe']
    if owner_map.get('schema') == NATIVE_SCHEMA and owner_map.get('sourceFormat') == ASSEMBLY_FORMAT:
        return owner_map['identities']['assembly']
    raise ValueError('Unknown owner map schema/source format')


def same(a,b):
    return all(a.get(key)==b.get(key) and key in a for key in ('bytes','sha256'))


def verify_pin(row):
    if not same(pin(row['file']),row):raise ValueError('Owner provenance input changed: '+row['file'])
    return row


def build_provenance(receipt_path, assembly, abi):
    """Bind completed current-tool evidence; do not infer a source from symbols."""
    receipt = pin(receipt_path)
    report = json.loads(Path(receipt['file']).read_text())
    if (report.get('kind') != 'bend-native-build' or report.get('target') != 'x86'
            or report.get('complete') is not True or report.get('error') or report.get('changedInputs')
            or report.get('timedOut') or not report.get('request')):
        raise ValueError('Completed source-emitting x86 native build receipt required')
    request = report['request']
    if request.get('target') != 'x86' or not same(report['assembly'],assembly) or not same(report['assemblyDigest'],assembly):
        raise ValueError('Build receipt assembly/source request differs')
    if report.get('runtimeABI',abi['magic']) != abi['magic']:
        raise ValueError('Build runtime ABI differs from emitted descriptor')
    jobs = report['jobs']
    for label in ('compiler','assemble','link'):
        selected = [job for job in jobs if job.get('label') == label]
        if len(selected) != 1 or selected[0].get('complete') is not True or selected[0].get('exitCode') != 0 or selected[0].get('timedOut'):
            raise ValueError('Incomplete build provenance stage: '+label)
        if label == 'compiler' and (not same(selected[0]['stdout'],assembly) or selected[0]['stderr']['bytes'] != 0):
            raise ValueError('Compiler emission differs from assembly artifact')
    values = dict(source=request['source'],producerImage=request['image'],binary=report['binary'],
                  runtime=report['runtime'],assembly=report['assembly'])
    for row in values.values():verify_pin(row)
    verify_pin(receipt)
    return dict(kind='completed-x86-native-build-receipt-v1',receipt=receipt,**values,
                scope='Exact completed emission/build receipt and artifact pins; lexical grouping remains conditional on the emitter contract.')


def source_map_provenance(map_path, source_root, compiled_source):
    """Validate source.py's physical spans against the actual compiled source."""
    source = Path(verify_pin(compiled_source)['file']).read_bytes()
    map_pin = pin(map_path); rows = json.loads(Path(map_pin['file']).read_text())
    root = Path(source_root).resolve(strict=True)
    if not isinstance(rows,list) or not 0 < len(rows) <= 65536:raise ValueError('Bounded source-map rows required')
    modules, definitions, seen, previous_end, module_lines = {}, {}, set(), None, {}
    source_lines = [i for i,value in enumerate(source) if value == 10]
    for row in rows:
        name = row['file']; relative = Path(name)
        file = root/relative
        if relative.is_absolute() or '..' in relative.parts or file.resolve() != file:
            raise ValueError('Source map must name exact physical files inside its root')
        if name not in modules:
            modules[name] = (pin(file),file.read_bytes())
            module_lines[name] = [i for i,value in enumerate(modules[name][1]) if value == 10]
        module_pin, data = modules[name]
        fields = ('sourceStartByte','generatedStartByte','spanBytes','sourceByte','generatedByte','bytes','sourceLine','generatedLine')
        if any(type(row[k]) is not int or row[k] < 0 for k in fields):raise ValueError('Invalid source-map span')
        a,b,size = row['sourceStartByte'],row['generatedStartByte'],row['spanBytes']
        offset = row['sourceByte']-a
        if (size <= 0 or not 0 <= offset < size or a+size > len(data) or b+size > len(source)
                or row['generatedByte'] != b+offset or row['bytes'] != size-offset
                or data[a:a+size] != source[b:b+size] or previous_end is not None and b != previous_end
                or row['sourceLine'] != bisect.bisect_left(module_lines[name],a+offset)+1
                or row['generatedLine'] != bisect.bisect_left(source_lines,b+offset)+1):
            raise ValueError('Source-map span differs from actual compiled/physical source')
        header = re.match(rb'(def|law|type) ([A-Za-z0-9_.]+)\b',data[a+offset:a+size])
        key = (row['kind'],row['name'])
        if not header or tuple(part.decode() for part in header.groups()) != key or key in seen:
            raise ValueError('Source-map declaration name/kind differs or duplicates')
        seen.add(key); previous_end = b+size
        if row['kind'] == 'def':
            definitions[row['name']] = dict(file=module_pin['file'],sourceLine=row['sourceLine'],
                sourceByte=row['sourceByte'],generatedLine=row['generatedLine'],generatedByte=row['generatedByte'],
                bytes=row['bytes'],sha256=hashlib.sha256(data[a+offset:a+size]).hexdigest())
    if previous_end != len(source):raise ValueError('Source map does not cover the compiled source suffix')
    for item,_ in modules.values():verify_pin(item)
    verify_pin(map_pin); verify_pin(compiled_source)
    return dict(kind='exact-maintained-source-map-v1',map=map_pin,root=str(root),source=compiled_source,
                modules=[row[0] for row in modules.values()],definitions=definitions,
                scope='Exact physical declaration spans; source locations attach only to an identical lowered owner name, never inferred inline origins.')


def parse_assembly_owners(assembly_path, emitter_sources=(), build_receipt=None, source_map=None, source_root=None):
    report = parse_owners(assembly_path,emitter_sources,ASSEMBLY_FORMAT)
    if build_receipt is not None:
        report['buildProvenance'] = build_provenance(build_receipt,source_identity(report),report['descriptor'])
        report['producer_provenance_verified'] = True
    if source_map is not None or source_root is not None:
        if source_map is None or source_root is None or build_receipt is None:
            raise ValueError('Source-map binding requires map, physical root and build receipt')
        binding = source_map_provenance(source_map,source_root,report['buildProvenance']['source'])
        report['sourceMap'] = binding
        for row in report['functions']+report['fids']:
            row['sourceLocation'] = binding['definitions'].get(row['lowered_owner'])
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--qbe", type=Path)
    source.add_argument("--assembly", type=Path)
    parser.add_argument('--build-receipt',type=Path,help='Optional completed x86 bend-native-build receipt; requires --assembly.')
    parser.add_argument('--source-map',type=Path,help='Optional source.py map of the actual compiled source; requires --build-receipt and --source-root.')
    parser.add_argument('--source-root',type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--emitter-source", action="append", default=[], type=Path,
                        help="Explicit maintained source implementing this owner-order contract; repeatable. No historical fallback.")
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Refusing to overwrite owner map")
    if (args.build_receipt or args.source_map or args.source_root) and not args.assembly:parser.error('Build/source-map binding requires --assembly')
    report = (parse_assembly_owners(args.assembly,args.emitter_source,args.build_receipt,args.source_map,args.source_root)
              if args.assembly else parse_qbe_owners(args.qbe, args.emitter_source))
    with args.output.open("x") as stream:
        json.dump(report, stream, indent=2)
        stream.write("\n")
    print(json.dumps(report["coverage"], indent=2))


if __name__ == "__main__":
    main()
