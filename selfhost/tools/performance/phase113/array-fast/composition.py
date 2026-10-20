"""Data-only replay of the frozen Phase113 declaration composer, never executes it."""
import hashlib
import json
import re
from pathlib import Path

METHOD_SHA = 'd354403aa40030a93f597b785037a57401641f5ce1ecf66675f0a130691c2c37'
BASE_SHA = '1df2df372cb3614f7cb4d70f5d81741112b7b15943a4eba204407ef7c3232c71'
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(file):
    file = Path(file).resolve()
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def authenticate(row):
    if pin(row['file']) != row:
        raise ValueError('composition pin mismatch: ' + row['file'])


def parts(text):
    hits = list(DECL.finditer(text))
    prefix = text[:hits[0].start()] if hits else text
    rows = [(m.group(1), m.group(2), text[m.start():hits[i+1].start() if i+1 < len(hits) else len(text)])
            for i, m in enumerate(hits)]
    return prefix, rows


def replay(baseline, snapshots):
    prefix, rows = parts(baseline)
    names = {(kind, name): i for i, (kind, name, body) in enumerate(rows)}
    if len(names) != len(rows):
        raise ValueError('duplicate baseline declarations')
    edits = []
    for snapshot in snapshots:
        module = snapshot['original']['file']
        _, declarations = parts(Path(snapshot['snapshot']['file']).read_text())
        for kind, name, raw in declarations:
            body = raw.rstrip() + '\n\n'
            key = kind, name
            if key in names:
                i = names[key]
                old = rows[i][2]
                rows[i] = kind, name, body
                edits.append(dict(kind=kind, name=name, action='replace',
                                  oldSha256=hashlib.sha256(old.encode()).hexdigest(), module=module))
            else:
                if rows:
                    k, n, previous = rows[-1]
                    rows[-1] = k, n, previous + '\n'
                else:
                    prefix += '\n'
                names[key] = len(rows)
                rows.append((kind, name, body))
                edits.append(dict(kind=kind, name=name, action='append', module=module))
    return prefix + ''.join(body for _, _, body in rows), edits


def validate(profile, compiler):
    """Profile is a separately frozen approved manifest pin, not caller authority."""
    authenticate(profile['composition'])
    record = json.loads(Path(profile['composition']['file']).read_text())
    if record['kind'] != 'phase113-source-composition' or not record['prepared']:
        raise ValueError('unexpected composition kind')
    if record['baseline']['sha256'] != BASE_SHA or record['method']['sha256'] != METHOD_SHA:
        raise ValueError('unapproved baseline or composition method')
    for row in [record['baseline'], record['method'], record['source']]:
        authenticate(row)
    if pin(compiler) != record['source']:
        raise ValueError('compiler does not match frozen composition')
    snapshots = record['moduleSnapshots']
    if record['modules'] != [row['original'] for row in snapshots]:
        raise ValueError('composition module order changed')
    for row in snapshots:
        authenticate(row['snapshot'])
        if any(row['original'][k] != row['snapshot'][k] for k in ['bytes', 'sha256']):
            raise ValueError('module snapshot content mismatch')
    expected, edits = replay(Path(record['baseline']['file']).read_text(), snapshots)
    if edits != record['edits'] or expected != Path(compiler).read_text():
        raise ValueError('exact ordered composition replay failed')
    return record
