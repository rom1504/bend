#!/usr/bin/env python3
"""Derive three isolated P68-016 saved-C interventions; execute no targets."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path


SOURCE_SHA = '19087b31006dd02e8fb51fd38e3b6df29b19885abb55700eaef06b0f3caf3826'
PREFIX = '../phase37/fixtures-historical/local-fold:'


def pin(path):
    path = Path(path).resolve(strict=True)
    raw = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))


def worker(text, name):
    symbol = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in name)
    header = 'NF_INLINE Term ' + symbol + '('
    assert text.count(header) == 2, (name, 'expected one prototype and body')
    start = text.index(header, text.index(header) + len(header))
    brace = text.index('{', start)
    assert '\n' not in text[start:brace], name
    depth, end = 1, brace + 1
    while depth:
        char = text[end]
        # Exact pinned worker bodies contain no strings/comments with braces.
        assert char not in ('"', "'"), name
        depth += (char == '{') - (char == '}')
        end += 1
    return start, end, text[start:end]


def edit(text, name, before, after, edits, expected=1):
    start, end, body = worker(text, name)
    assert body.count(before) == expected, (name, before, body.count(before))
    changed = body.replace(before, after)
    edits.append(dict(worker=name, before=before, after=after, count=expected))
    return text[:start] + changed + text[end:]


def derive(source, out):
    source = Path(source).resolve(strict=True)
    out = Path(out).resolve()
    original = source.read_text()
    source_pin = pin(source)
    assert source_pin['sha256'] == SOURCE_SHA, 'Only exact products15 source is admitted'
    receipt_path = Path(str(source) + '.json')
    receipt = json.loads(receipt_path.read_text())
    assert receipt['complete'] and receipt['role'] == 'selfhost' and receipt['target'] == 'c'
    assert receipt['observation']['status'] == 'ok' and receipt['observation']['checked']
    assert receipt['observation']['typeAccepted'] and receipt['observation']['exitCode'] == 0
    assert receipt['output'] == source_pin
    assert 'p68_counts' not in original
    inputs = [source_pin, pin(receipt_path), pin(__file__)]
    out.mkdir(parents=True, exist_ok=False)
    results = []
    for name, packed, unshared in [('packed', True, False), ('unshared', False, True), ('combined', True, True)]:
        text, edits = original, []
        if packed:
            text = edit(text, PREFIX + 'bench',
                'blk_new(e, 1, v_4294967277, 0, 1, init)',
                'blk_new(e, 0, v_4294967277, 0, 1, init)', edits)
            text = edit(text, '$product.' + PREFIX + 'fold.cell',
                'blk_keep(e, term_peek(e, v_4294967283) + at)',
                'blk_read(e.mem, 0, term_peek(e, v_4294967283), at)', edits)
            text = edit(text, '$product.' + PREFIX + 'fold.step',
                'term_sink(e, blk_read(e.mem, 1, term_peek(e, v_4294967285), at));\n'
                'blk_write(e.mem, 1, term_peek(e, v_4294967285), at, rfc_seal(e, v_4294967283));',
                'blk_write(e.mem, 0, term_peek(e, v_4294967285), at, v_4294967283);', edits)
        if unshared:
            text = edit(text, '$product.' + PREFIX + 'fold.cell',
                'term_peek(e, v_4294967283)', 'term_loc(v_4294967283)', edits)
            text = edit(text, '$product.' + PREFIX + 'fold.step',
                'term_peek(e, v_4294967285)', 'term_loc(v_4294967285)', edits,
                expected=1 if packed else 2)
        directory = out/name
        directory.mkdir()
        path = directory/'program.c'
        path.write_text(text)
        patch = directory/'source.patch'
        patch.write_text(''.join(difflib.unified_diff(original.splitlines(True), text.splitlines(True),
            fromfile='products15/program.c', tofile=name+'/program.c')))
        report = dict(kind='phase68-scalar-array-saved-c-v1', complete=True,
            diagnosticOnly=True, targetExecuted=False, variant=name,
            axes=dict(packedU32=packed, directUnsharedLocation=unshared),
            inputs=inputs, parentEmission=source_pin, sourceInput=receipt['input'],
            output=pin(path), patch=pin(patch), replacements=edits,
            scope='Only three selected host worker bodies may change. The actual closed '
                'array flow constructs U32 elements, writes U32 arithmetic, never shares '
                'the array, and finally drops it. Scheduler/raw/foreign entry equivalence '
                'is not claimed. No runtime helper, compiler image or worker ABI changes. '
                'Worker names identify intervention sites only, never production eligibility.')
        (directory/'derivation.json').write_text(json.dumps(report, indent=2)+'\n')
        results.append(dict(name=name, source=pin(path), derivation=pin(directory/'derivation.json')))
    for item in inputs:
        assert pin(item['path']) == item
    manifest = dict(kind='phase68-scalar-array-two-axis-v1', complete=True,
        targetExecuted=False, baseline=source_pin, inputs=inputs, variants=results,
        status='Source derivation only. Root must compile, check independent oracles and measure.')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    return pin(out/'manifest.json')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(derive(args.source, args.output)))
