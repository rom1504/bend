#!/usr/bin/env python3
"""Metadata-only source migration and source-map integration controls."""
import argparse
import bisect
import hashlib
import json
import subprocess
import tempfile
from pathlib import Path


def sha(data):
    return hashlib.sha256(data).hexdigest()


def run(args, root):
    result = subprocess.run(args, cwd=root, text=True, capture_output=True, timeout=30)
    if result.returncode:
        raise AssertionError(result.stderr or result.stdout)
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument('--stage', type=Path, required=True)
    parser.add_argument('--receipt', type=Path, required=True)
    parser.add_argument('--frozen', action='store_true',
                        help='Additionally require the original extraction identity; ordinary edits use normal assembly')
    args = parser.parse_args()
    root, stage = args.workspace.resolve(), args.stage.resolve()
    if args.receipt.exists():
        raise ValueError('Fresh receipt required')
    recipe = json.loads((stage / 'src/compiler.json').read_text())
    assert recipe['kind'] == 'bend-maintained-source-v1'
    assert recipe['preamble'] in recipe['modules']
    assert recipe['upstream'] and recipe['targetVersion']
    checks = ['canonical-metadata-and-snapshot-inputs']
    assembler = root / 'selfhost/tools/assemble.mjs'
    scratch = root / 'selfhost/build/consolidation'
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=scratch, prefix='source-integration-') as td:
        tmp = Path(td)
        output = tmp / 'compiler.bend'
        script = '''
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const [tool,root,manifest,out]=process.argv.slice(2);
const {assemble}=await import(pathToFileURL(tool));
const files=JSON.parse(fs.readFileSync(manifest,'utf8')).modules;
console.log(JSON.stringify(assemble(files,out,{root})));
'''
        argv = ['node', '--input-type=module', '-e', script, 'source-control', str(assembler), str(stage),
                str(stage / 'src/compiler.json'), str(output)]
        first = run(argv, root)
        data = output.read_bytes()
        frozen_equal = sha(data) == recipe['frozenSource']['sha256']
        if args.frozen:
            assert frozen_equal, 'Source intentionally differs from the original extraction'
        assert first['sourceSha256'] == sha(data)
        checks.append('maintained-js-interface-current-source')
        if args.frozen:
            checks.append('original-extraction-identity')
        stamp = output.stat().st_mtime_ns
        run(argv, root)
        assert output.stat().st_mtime_ns == stamp
        checks.append('identical-bootstrap-snapshot-reuse-does-not-rewrite')
        source_map = json.loads(Path(str(output) + '.map.json').read_text())
        modules = {name: (stage / name).read_bytes() for name in recipe['modules']}
        lines = {name: [i for i, byte in enumerate(content) if byte == 10]
                 for name, content in modules.items()}
        generated_lines = [i for i, byte in enumerate(data) if byte == 10]
        for row in source_map:
            module = modules[row['file']]
            assert module[row['sourceStartByte']:row['sourceStartByte'] + row['spanBytes']] == \
                data[row['generatedStartByte']:row['generatedStartByte'] + row['spanBytes']]
            assert row['sourceLine'] == bisect.bisect_left(lines[row['file']], row['sourceByte']) + 1
            assert row['generatedLine'] == bisect.bisect_left(generated_lines, row['generatedByte']) + 1
            assert data.startswith((row['kind'] + ' ' + row['name']).encode(), row['generatedByte'])
        assert len(source_map) == len(recipe['order'])
        checks.append('all-declaration-byte-and-line-mappings')
        # A standalone explicit-file caller still exercises the legacy protocol.
        (tmp / 'small.bend').write_text('law helper:\n  U32\n\n@unsafe\ndef helper():\n  1\n')
        legacy = '''
import {pathToFileURL} from 'node:url';
const [tool,root,out]=process.argv.slice(2);
const {assemble}=await import(pathToFileURL(tool));
console.log(JSON.stringify(assemble(['small.bend'],out,{root})));
'''
        result = run(['node', '--input-type=module', '-e', legacy, 'source-control', str(assembler), str(tmp),
                      str(tmp / 'legacy.bend')], root)
        assert result['declarations'] == 2 and 'sourceSha256' not in result
        checks.append('explicit-historical-file-interface-retained')
        map_sha = sha(Path(str(output) + '.map.json').read_bytes())
    report = {'kind': 'bend-source-interface-controls-v1', 'complete': True,
        'compilerExecuted': False, 'checks': checks, 'sourceSha256': sha(data),
        'frozenIdentityRequired': args.frozen, 'equalsOriginalExtraction': frozen_equal,
        'mapSha256': map_sha, 'mappedDeclarations': len(source_map),
        'methods': {str(path.relative_to(root)): sha(path.read_bytes()) for path in [
            root / 'selfhost/tools/build/source.py', assembler, Path(__file__).resolve()]}}
    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    args.receipt.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
