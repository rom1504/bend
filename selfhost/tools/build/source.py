#!/usr/bin/env python3
"""Extract and assemble byte-exact Bend modules; never execute a compiler.

This is a source transport/ownership inventory, not a Bend parser or checker.
Assembly reads only the explicit module root and manifest. Historical sources
are inputs to extraction/audit only, never implicit build dependencies.
"""
import argparse
import collections
import hashlib
import json
import re
import shutil
from pathlib import Path

HEADER = re.compile(rb'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
WORDS = re.compile(r'\b[A-Za-z_][A-Za-z0-9_.]*\b')
LITERALS = re.compile(r'''"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\#[^\n]*''')
LIMIT = 20 * 1024 * 1024


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    data = Path(path).read_bytes()
    if len(data) > LIMIT:
        raise ValueError('Source/manifest exceeds 20 MiB: ' + str(path))
    return data


def pin(path):
    data = read(path)
    return {'file': str(Path(path).resolve()), 'bytes': len(data), 'sha256': digest(data)}


def dump(path, value):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(json.dumps(value, indent=2) + '\n')


def safe_path(root, relative):
    p = Path(relative)
    if p.is_absolute() or '..' in p.parts:
        raise ValueError('Module path must be relative and confined: ' + str(p))
    result = (Path(root) / p).resolve()
    if not result.is_relative_to(Path(root).resolve()):
        raise ValueError('Module escapes root: ' + str(p))
    return result


def blocks(data):
    """Keep every byte; attach contiguous leading blank/comment lines to headers."""
    hits = list(HEADER.finditer(data))
    if not hits:
        raise ValueError('No top-level declaration headers')
    starts = []
    for hit in hits:
        start = hit.start()
        while start:
            before = data.rfind(b'\n', 0, start - 1) + 1
            line = data[before:start].rstrip(b'\r\n')
            if line.strip() and not line.startswith(b'#'):
                break
            start = before
        if starts and start <= starts[-1]:
            raise ValueError('Overlapping declaration boundaries')
        starts.append(start)
    answer = []
    for i, hit in enumerate(hits):
        end = starts[i + 1] if i + 1 < len(starts) else len(data)
        answer.append({'name': hit[2].decode(), 'kind': hit[1].decode(),
                       'offset': starts[i], 'headerOffset': hit.start(),
                       'data': data[starts[i]:end]})
    return data[:starts[0]], answer


def grouped(items):
    result = collections.defaultdict(list)
    for item in items:
        result[item['name']].append(item)
    return dict(result)


def normalized(items):
    data = b''.join(item['data'] for item in items)
    return b'\n'.join(line.rstrip() for line in data.splitlines()
                      if line.strip() and not line.lstrip().startswith(b'#'))


def relation(name, selected, other):
    if name not in other:
        return 'absent'
    if normalized(selected[name]) == normalized(other[name]):
        return 'normalized-identical'
    return 'structurally-different'


def assemble(manifest_path, root):
    manifest = json.loads(read(manifest_path))
    if manifest.get('kind') != 'bend-byte-exact-source-v1':
        raise ValueError('Unknown source manifest schema')
    modules = []
    for row in manifest['modules']:
        data = read(safe_path(root, row['file']))
        if len(data) != row['bytes'] or digest(data) != row['sha256']:
            raise ValueError('Changed module: ' + row['file'])
        modules.append(data)
    covered = [0] * len(modules)
    chunks = []
    for module, offset, length in manifest['parts']:
        if not 0 <= module < len(modules) or offset != covered[module] or length < 0:
            raise ValueError('Noncontiguous, duplicated or invalid module range')
        end = offset + length
        if end > len(modules[module]):
            raise ValueError('Module range exceeds file')
        chunks.append(modules[module][offset:end])
        covered[module] = end
    if covered != [len(data) for data in modules]:
        raise ValueError('Unassembled source bytes')
    result = b''.join(chunks)
    if len(result) != manifest['source']['bytes'] or digest(result) != manifest['source']['sha256']:
        raise ValueError('Assembled source differs from the pinned source')
    return result


def declaration_closure(rows, roots):
    """Select a conservative lexical closure, preserving declaration bytes/order.

    This is compiler source transport, not name resolution or source checking.
    Local names can retain extra declarations; constructors retain their type.
    Every selected declaration still needs the ordinary Bend checking gate.
    """
    if (not isinstance(roots, list) or not roots or
            any(not isinstance(name, str) or not WORDS.fullmatch(name) for name in roots) or
            len(set(roots)) != len(roots)):
        raise ValueError('Profile roots must be distinct explicit declaration names')
    groups, constructors = {}, {}
    for key, data, location in rows:
        groups.setdefault(key[2], []).append(data)
        if key[1] == 'type':
            for name in re.findall(rb'^  ([A-Za-z_][A-Za-z0-9_.]*)\{', data, re.M):
                name = name.decode()
                if name in constructors and constructors[name] != key[2]:
                    raise ValueError('Ambiguous constructor in profile: ' + name)
                constructors[name] = key[2]
    todo, needed = list(roots), set()
    while todo:
        name = todo.pop()
        if name not in groups:
            raise ValueError('Missing profile root declaration: ' + name)
        if name in needed:
            continue
        needed.add(name)
        for data in groups[name]:
            # Strip char/string literals together: a quote character must not
            # swallow later source, and comment/string words are not edges.
            words = WORDS.findall(LITERALS.sub(' ', data.decode()))
            refs = {constructors.get(word, word) for word in words}
            todo.extend((refs & groups.keys()) - needed)
    return [row for row in rows if row[0][2] in needed]


def maintained_assemble(manifest_path, root, profile=None, with_map=False):
    """Assemble editable bodies using stable declaration identities, not offsets."""
    manifest = json.loads(read(manifest_path))
    if manifest.get('kind') != 'bend-maintained-source-v1':
        raise ValueError('Normal builds need source.json; use verify for frozen assembly.json')
    profile = profile or manifest['defaultProfile']
    if profile not in manifest['profiles']:
        raise ValueError('Unknown entry profile: ' + profile)
    entries, owners, name_owners, locations = {}, {}, {}, {}
    for index, name in enumerate(manifest['modules']):
        data = read(safe_path(root, name))
        if name == manifest['preamble']:
            continue
        prefix, items = blocks(data)
        if prefix:
            raise ValueError('Module has unassigned preamble bytes: ' + name)
        for item in items:
            key = (index, item['kind'], item['name'])
            global_key = (item['kind'], item['name'])
            if global_key in owners:
                raise ValueError('Duplicate declaration: ' + repr(global_key))
            if item['name'] in name_owners and name_owners[item['name']] != name:
                raise ValueError('Law/definition split across source owners: ' + item['name'])
            name_owners[item['name']] = name
            owners[global_key] = name
            entries[key] = item['data']
            locations[key] = (name, data, item)
    order = [tuple(row) for row in manifest['order']]
    if len(set(order)) != len(order) or set(order) != set(entries):
        raise ValueError('Declaration inventory changed; refresh the source recipe explicitly')
    for name, expected in manifest.get('protectedDeclarations', {}).items():
        values = [{'data': entries[key]} for key in order if key[2] == name]
        if not values or digest(normalized(values)) != expected['normalizedSha256']:
            raise ValueError('Protected verifier/proof declaration changed: ' + name)
    config = manifest['profiles'][profile]
    replacement, replacement_location = None, None
    if config.get('entryModule'):
        replacement = read(safe_path(root, config['entryModule']))
        prefix, entry_items = blocks(replacement)
        if prefix or [(x['kind'], x['name']) for x in entry_items] != [('def', 'main')]:
            raise ValueError('Entry adapter must contain exactly def main')
        replacement_location = (config['entryModule'], replacement, entry_items[0])
    # Profile-only modules extend the maintained inventory without changing the
    # canonical source used by other targets. Their order is explicit. Forward
    # laws and definitions can live in separate additive modules; no additive
    # declaration may shadow a canonical declaration, even with another kind.
    extra_modules = config.get('modules', [])
    if (not isinstance(extra_modules, list) or
            any(not isinstance(name, str) for name in extra_modules) or
            len(set(extra_modules)) != len(extra_modules)):
        raise ValueError('Profile modules must be distinct relative paths')
    additions, extra_owners = [], set()
    for index, name in enumerate(extra_modules, len(manifest['modules'])):
        if name in manifest['modules'] or name == config.get('entryModule'):
            raise ValueError('Repeated profile module: ' + name)
        data = read(safe_path(root, name))
        prefix, items = blocks(data)
        if prefix:
            raise ValueError('Profile module has unassigned preamble bytes: ' + name)
        for item in items:
            global_key = (item['kind'], item['name'])
            if item['name'] in name_owners or item['name'] == 'main' or global_key in extra_owners:
                raise ValueError('Duplicate or shadowed profile declaration: ' + repr(global_key))
            extra_owners.add(global_key)
            additions.append(((index, *global_key), item['data'], (name, data, item)))
    selected, entry = [], []
    for key in order:
        chunk, location = entries[key], locations[key]
        if key[1:] == ('def', 'main'):
            if config.get('omitMain'):
                continue
            if replacement is not None:
                chunk, location = replacement, replacement_location
            if extra_modules:
                entry.append((key, chunk, location))
                continue
        selected.append((key, chunk, location))
    selected += additions + entry
    if 'roots' in config:
        selected = declaration_closure(selected, config['roots'])
    chunks = [read(safe_path(root, manifest['preamble']))]
    source_map, generated_byte, generated_line = [], len(chunks[0]), chunks[0].count(b'\n') + 1
    for key, chunk, location in selected:
        filename, module, item = location
        header = item['headerOffset']
        if module[header:].startswith(b'@unsafe\n'):
            header += len(b'@unsafe\n')
        relative = header - item['offset']
        source_map.append({'file': filename,
            'sourceLine': module[:header].count(b'\n') + 1,
            'generatedLine': generated_line + chunk[:relative].count(b'\n'),
            'lines': max(1, len(chunk[relative:].splitlines())),
            'kind': key[1], 'name': key[2],
            'sourceByte': header, 'generatedByte': generated_byte + relative,
            'bytes': len(chunk) - relative, 'sourceStartByte': item['offset'],
            'generatedStartByte': generated_byte, 'spanBytes': len(chunk)})
        chunks.append(chunk)
        generated_byte += len(chunk)
        generated_line += chunk.count(b'\n')
    result = b''.join(chunks)
    if len(result) > LIMIT:
        raise ValueError('Assembled source exceeds 20 MiB')
    return (result, source_map) if with_map else result


def source_recipe(stage, manifest, audit):
    preamble_index = manifest['parts'][0][0]
    preamble = manifest['modules'][preamble_index]['file']
    module_names = [row['file'] for i, row in enumerate(manifest['modules']) if i != preamble_index]
    new_index = {name: i for i, name in enumerate(module_names)}
    by_part = {}
    for declaration in audit['declarations']:
        for part in declaration['parts']:
            by_part[part['part']] = [new_index[declaration['owner']], part['kind'], declaration['name']]
    if set(by_part) != set(range(1, len(manifest['parts']))):
        raise ValueError('Ownership audit does not cover the frozen assembly')
    return {'kind': 'bend-maintained-source-v1', 'preamble': preamble,
        'modules': module_names, 'order': [by_part[i] for i in sorted(by_part)],
        'defaultProfile': 'qbe',
        'profiles': {
            'qbe': {'entryModule': None, 'omitMain': False,
                    'status': 'byte-identical-to-qualified-phase146-before-edits'},
            'native-c': {'entryModule': 'src/host/native-c-main.bend', 'omitMain': False,
                         'status': 'adapter-only-unqualified-requires-C-differential-gates'},
            'js-api': {'entryModule': None, 'omitMain': True,
                       'status': 'entry-omission-only-unqualified-requires-JS-differential-gates'}},
        'frozenSource': manifest['source'],
        'scope': 'One implementation per declaration. Entry profiles do not select historical frontends. Normal assembly permits body edits; verify checks the frozen source identity. Qualification is never inherited after edits.'}


def refresh_recipe(manifest_path, root):
    """Explicit inventory update: keep known order, insert additions per module."""
    manifest = json.loads(read(manifest_path))
    if manifest.get('kind') != 'bend-maintained-source-v1':
        raise ValueError('Refresh needs a maintained source recipe')
    current, global_keys, name_owners = [], set(), {}
    for index, name in enumerate(manifest['modules']):
        if name == manifest['preamble']:
            current.append([])
            continue
        prefix, items = blocks(read(safe_path(root, name)))
        if prefix:
            raise ValueError('Unassigned module preamble: ' + name)
        sequence = []
        for item in items:
            key = (item['kind'], item['name'])
            if key in global_keys:
                raise ValueError('Duplicate declaration: ' + repr(key))
            if item['name'] in name_owners and name_owners[item['name']] != name:
                raise ValueError('Law/definition split across source owners: ' + item['name'])
            name_owners[item['name']] = name
            global_keys.add(key)
            sequence.append((index, *key))
        current.append(sequence)
    old = [tuple(row) for row in manifest['order']]
    current_set = {key for sequence in current for key in sequence}
    survivors = [key for key in old if key in current_set]
    survivor_set = set(survivors)
    before, tails = {}, {}
    for sequence in current:
        pending = []
        for key in sequence:
            if key in survivor_set:
                before[key] = pending
                pending = []
            else:
                pending.append(key)
        if sequence:
            tails[sequence[0][0]] = pending
    last = {key[0]: i for i, key in enumerate(survivors)}
    order = []
    for i, key in enumerate(survivors):
        order.extend(before.get(key, []))
        order.append(key)
        if last[key[0]] == i:
            order.extend(tails.pop(key[0], []))
    for index in sorted(tails):
        order.extend(tails[index])
    if len(order) != len(current_set) or set(order) != current_set:
        raise ValueError('Recipe refresh did not cover the declaration inventory')
    manifest['order'] = order
    manifest['inventoryChange'] = {
        'added': [list(key) for key in order if key not in set(old)],
        'removed': [list(key) for key in old if key not in current_set],
        'scope': 'Ordering proposal only; source checking and target qualification remain required.'}
    return manifest


def extract(args):
    stage = args.stage.resolve()
    if stage.exists():
        raise ValueError('Fresh staging directory required')
    source = read(args.source)
    preamble, pieces = blocks(source)
    selected = grouped(pieces)
    canonical_manifest = json.loads(read(args.canonical_manifest))
    canonical, owners, canonical_pins, canonical_locations = {}, {}, [], collections.defaultdict(list)
    for name in canonical_manifest['modules']:
        path = safe_path(args.canonical_root, name)
        _, items = blocks(read(path))
        canonical_pins.append(pin(path))
        for declaration, values in grouped(items).items():
            existing = canonical.get(declaration, [])
            if {x['kind'] for x in existing} & {x['kind'] for x in values}:
                raise ValueError('Duplicate canonical declaration kind: ' + declaration)
            canonical_locations[declaration].append(name)
            if declaration not in owners or any(x['kind'] in ('def', 'type') for x in values):
                owners[declaration] = name
            canonical[declaration] = existing + values
    _, native_pieces = blocks(read(args.native_source))
    native = grouped(native_pieces)
    policy = json.loads(read(args.policy))
    rules = [(re.compile(row['pattern']), row['module']) for row in policy['rules']]
    chosen = {}
    for name in selected:
        if name in policy.get('exact', {}):
            chosen[name] = policy['exact'][name]
        elif name in owners:
            chosen[name] = owners[name]
        else:
            matches = [module for pattern, module in rules if pattern.match(name)]
            if not matches:
                raise ValueError('No proposed module owner: ' + name)
            chosen[name] = matches[0]
    duplicate_kinds = []
    for name, values in selected.items():
        counts = collections.Counter(item['kind'] for item in values)
        if any(n > 1 for n in counts.values()):
            duplicate_kinds.append({'name': name, 'kinds': dict(counts)})
    if duplicate_kinds:
        raise ValueError('Duplicate declarations of one kind: ' + repr(duplicate_kinds[:10]))
    module_names = sorted(set(chosen.values()) | {policy['preamble']})
    module_index = {name: i for i, name in enumerate(module_names)}
    module_data = {name: bytearray() for name in module_names}
    parts, ranges = [], collections.defaultdict(list)

    def append(module, data):
        offset = len(module_data[module])
        module_data[module].extend(data)
        parts.append([module_index[module], offset, len(data)])
        return len(parts) - 1

    append(policy['preamble'], preamble)
    for item in pieces:
        part = append(chosen[item['name']], item['data'])
        ranges[item['name']].append({'part': part, 'kind': item['kind'],
                                    'sourceOffset': item['offset'],
                                    'headerOffset': item['headerOffset'],
                                    'bytes': len(item['data'])})
    modules = [{'file': name, 'bytes': len(module_data[name]),
                'sha256': digest(module_data[name])} for name in module_names]
    manifest = {'kind': 'bend-byte-exact-source-v1', 'source': {
        'bytes': len(source), 'sha256': digest(source)}, 'modules': modules, 'parts': parts,
        'scope': 'Byte transport only; source checking, semantic equivalence and target qualification are separate.'}
    rows = []
    for name in sorted(selected):
        rows.append({'name': name, 'owner': chosen[name], 'parts': ranges[name],
                     'canonical': relation(name, selected, canonical),
                     'nativeC': relation(name, selected, native),
                     'canonicalOwner': owners.get(name),
                     'canonicalLocations': canonical_locations.get(name, [])})
    counts = lambda other: dict(collections.Counter(relation(n, selected, other) for n in selected))
    audit = {'kind': 'bend-source-consolidation-map-v1', 'source': pin(args.source),
        'canonicalManifest': pin(args.canonical_manifest), 'canonicalModules': canonical_pins,
        'nativeSource': pin(args.native_source), 'policy': pin(args.policy),
        'counts': {'selectedNames': len(selected), 'canonicalNames': len(canonical),
                   'nativeNames': len(native), 'modules': len(modules), 'parts': len(parts),
                   'selectedVsCanonical': counts(canonical), 'selectedVsNative': counts(native)},
        'canonicalMissingFromSelected': [{'name': n, 'owner': owners[n]} for n in sorted(set(canonical)-set(selected))],
        'nativeMissingFromSelected': sorted(set(native)-set(selected)),
        'declarations': rows,
        'entry': {'selected': [x['data'].decode() for x in selected.get('main', [])],
                  'native': [x['data'].decode() for x in native.get('main', [])],
                  'canonical': [x['data'].decode() for x in canonical.get('main', [])]},
        'scope': 'Structural ownership/difference map, not semantic regressions. No missing declaration is automatically deleted or accepted. JS/C differential gates remain required.'}
    encoded_size = sum(len(v) for v in module_data.values()) + len(source)
    encoded_size += len(json.dumps(manifest, indent=2)) + len(json.dumps(audit, indent=2))
    if encoded_size > LIMIT:
        raise ValueError('Staging package would exceed 20 MiB')
    stage.mkdir(parents=True)
    for row in modules:
        output = safe_path(stage / 'modules', row['file'])
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(module_data[row['file']])
    dump(stage / 'assembly.json', manifest)
    dump(stage / 'audit.json', audit)
    result = assemble(stage / 'assembly.json', stage / 'modules')
    if result != source:
        raise ValueError('Literal extraction/reassembly mismatch')
    (stage / 'reassembled.bend').write_bytes(result)
    receipt = {'kind': 'bend-source-extraction-receipt-v1', 'complete': True,
        'compilerExecuted': False, 'literalSourceEquality': True,
        'source': pin(args.source), 'assembly': pin(stage / 'assembly.json'),
        'audit': pin(stage / 'audit.json'), 'method': pin(__file__),
        'modules': len(modules), 'declarations': len(selected),
        'stageBytesCeiling': LIMIT, 'counts': audit['counts']}
    dump(stage / 'receipt.json', receipt)
    print(json.dumps(receipt, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    p = commands.add_parser('extract', help='Stage modules, ownership audit and exact source receipt')
    for flag in ['source', 'canonical-manifest', 'canonical-root', 'native-source', 'policy', 'stage']:
        p.add_argument('--' + flag, type=Path, required=True)
    p = commands.add_parser('assemble', help='Assemble editable modules from source.json without frozen hashes')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--profile')
    p.add_argument('--map', type=Path, help='Write compatible line maps plus exact source/module byte ranges')
    p.add_argument('--reuse-identical', action='store_true',
                   help='Accept an already identical output without rewriting it')
    p = commands.add_parser('verify', help='Check frozen source identity; does not qualify edited source')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--out', type=Path)
    p = commands.add_parser('refresh', help='Explicitly update the maintained declaration-order inventory')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p = commands.add_parser('apply', help='Copy an authenticated staged package into a fresh maintained destination')
    p.add_argument('--stage', type=Path, required=True)
    p.add_argument('--destination', type=Path, required=True)
    p.add_argument('--protected-manifest', type=Path,
                   help='Import source-bound protected verifier/proof names once; future builds use no historical input')
    p.add_argument('--recipe-path', default='source.json',
                   help='Relative destination recipe; use src/compiler.json for the canonical selfhost layout')
    p.add_argument('--metadata', type=Path,
                   help='Copy upstream and targetVersion from the named compiler manifest')
    p.add_argument('--plan-against', type=Path,
                   help='Record proposed writes against this existing root without modifying it')
    args = parser.parse_args()
    if args.command == 'extract':
        extract(args)
    elif args.command == 'assemble':
        data, source_map = maintained_assemble(args.manifest, args.root, args.profile, with_map=True)
        products = [(args.out, data)]
        if args.map:
            if args.map.resolve() == args.out.resolve():
                raise ValueError('Source and source map need distinct paths')
            products.append((args.map, (json.dumps(source_map, indent=2) + '\n').encode()))
        for path, content in products:
            if path.exists() and (not args.reuse_identical or read(path) != content):
                raise ValueError('Fresh or explicitly reused identical output required: ' + str(path))
        for path, content in products:
            if not path.exists():
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(content)
        print(json.dumps({**pin(args.out), 'declarations': len(source_map),
                          'map': pin(args.map) if args.map else None}))
    elif args.command == 'verify':
        manifest = json.loads(read(args.manifest))
        if manifest['kind'] == 'bend-maintained-source-v1':
            data = maintained_assemble(args.manifest, args.root, 'qbe')
            expected = manifest['frozenSource']
            if len(data) != expected['bytes'] or digest(data) != expected['sha256']:
                raise ValueError('Current edited source differs from the frozen source')
        else:
            data = assemble(args.manifest, args.root)
        if args.out:
            if args.out.exists():
                raise ValueError('Fresh output required')
            args.out.parent.mkdir(parents=True, exist_ok=True)
            args.out.write_bytes(data)
        print(json.dumps({'complete': True, 'compilerExecuted': False,
                          'bytes': len(data), 'sha256': digest(data)}))
    elif args.command == 'refresh':
        if args.out.exists():
            raise ValueError('Fresh recipe output required; review before replacing the current recipe')
        refreshed = refresh_recipe(args.manifest, args.root)
        dump(args.out, refreshed)
        maintained_assemble(args.out, args.root)
        print(json.dumps({'complete': True, 'recipe': pin(args.out),
                          'change': refreshed['inventoryChange'], 'compilerExecuted': False}))
    else:
        if args.destination.exists():
            raise ValueError('Fresh destination required; merging current sources needs explicit review')
        receipt = json.loads(read(args.stage / 'receipt.json'))
        for key, filename in [('assembly', 'assembly.json'), ('audit', 'audit.json')]:
            data = read(args.stage / filename)
            if len(data) != receipt[key]['bytes'] or digest(data) != receipt[key]['sha256']:
                raise ValueError('Changed staged ' + key)
        before = assemble(args.stage / 'assembly.json', args.stage / 'modules')
        manifest = json.loads(read(args.stage / 'assembly.json'))
        audit = json.loads(read(args.stage / 'audit.json'))
        recipe = source_recipe(args.stage, manifest, audit)
        recipe_path = safe_path(args.destination, args.recipe_path)
        if args.metadata:
            metadata = json.loads(read(args.metadata))
            for key in ('upstream', 'targetVersion'):
                if key not in metadata:
                    raise ValueError('Compiler metadata missing ' + key)
                recipe[key] = metadata[key]
        if args.recipe_path == 'src/compiler.json':
            if not args.metadata:
                raise ValueError('Canonical compiler layout requires explicit --metadata')
            # Existing hosted bootstraps snapshot manifest.modules. Keep the
            # preamble in that input list without giving it a declaration slot.
            recipe['modules'].append(recipe['preamble'])
        if args.protected_manifest:
            protected = json.loads(read(args.protected_manifest))
            if any(protected['source'][key] != manifest['source'][key] for key in ('bytes', 'sha256')):
                raise ValueError('Protection manifest belongs to another compiler source')
            _, selected_parts = blocks(before)
            selected_groups = grouped(selected_parts)
            verifier_names = protected.get('protectedDeclarations', [])
            proof_names = protected.get('unchangedProofDeclarations', [])
            recipe['protectedDeclarations'] = {}
            for name in sorted(set(verifier_names) | set(proof_names)):
                if name not in selected_groups:
                    raise ValueError('Unknown protected declaration: ' + name)
                recipe['protectedDeclarations'][name] = {
                    'normalizedSha256': digest(normalized(selected_groups[name])),
                    'verifier': name in verifier_names, 'proof': name in proof_names}
            recipe['protectionOrigin'] = pin(args.protected_manifest)
        native_entry = ''.join(audit['entry']['native']).encode()
        prefix, entry_items = blocks(native_entry)
        if prefix or [(x['kind'], x['name']) for x in entry_items] != [('def', 'main')]:
            raise ValueError('Native baseline has no simple main adapter')
        args.destination.mkdir(parents=True)
        for row in manifest['modules']:
            target = safe_path(args.destination, row['file'])
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(safe_path(args.stage / 'modules', row['file']), target)
        if args.recipe_path == 'source.json':
            shutil.copyfile(args.stage / 'assembly.json', args.destination / 'assembly.json')
        entry_path = args.destination / 'src/host/native-c-main.bend'
        if entry_path.exists():
            raise ValueError('Native entry adapter collides with an extracted module')
        entry_path.parent.mkdir(parents=True, exist_ok=True)
        entry_path.write_bytes(native_entry)
        dump(recipe_path, recipe)
        if assemble(args.stage / 'assembly.json', args.destination) != before:
            raise ValueError('Applied package changed source bytes')
        if maintained_assemble(recipe_path, args.destination) != before:
            raise ValueError('Editable recipe does not reproduce the frozen source')
        if args.plan_against:
            names = [row['file'] for row in manifest['modules']]
            names.extend(['src/host/native-c-main.bend', args.recipe_path])
            writes = []
            for name in names:
                staged = safe_path(args.destination, name)
                target = safe_path(args.plan_against, name)
                old = pin(target) if target.exists() else None
                new = pin(staged)
                status = 'create' if old is None else ('identical' if old['sha256'] == new['sha256'] else 'replace')
                writes.append({'relative': name, 'status': status,
                               'target': str(target), 'old': old, 'staged': new})
            dump(args.destination / 'apply-plan.json', {
                'kind': 'bend-canonical-source-write-plan-v1', 'complete': True,
                'applied': False, 'sourceBytesEqual': True,
                'targetRoot': str(args.plan_against.resolve()), 'writes': writes,
                'scope': 'Review only. No existing module is modified or retired by this plan.'})
        print(json.dumps({'complete': True, 'destination': str(args.destination.resolve()),
                          'recipe': str(recipe_path),
                          'sourceBytes': len(before), 'sourceSha256': digest(before),
                          'compilerExecuted': False}))


if __name__ == '__main__':
    main()
