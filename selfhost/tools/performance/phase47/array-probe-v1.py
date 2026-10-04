#!/usr/bin/env python3
"""Produce unchecked array-loop ablations from one hash-pinned saved JS module.

Usage: array-probe.py SOURCE/program.mjs FRESH_DIRECTORY
Writes original/shell/view/length program.mjs files and a provenance manifest.
Never imports, executes, compiles, or times JavaScript. These are diagnostic
derivatives, not production-safe transformations or newly checked compilers.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path


PARENT_SHA = '0a079e6ee0ce4f8c261943cd708c86df1d7dd2e0d67cf4d72e91b0122ad8a2a4'
FUNCTION_SHA = '9cf6a281e143aecae7ef16b7d14e0f4a0840bc8cc2d7b651a7ba3791cfbbf769'
SOURCE_NAME = '../phase37/fixtures-historical/local-fold.fold.loop'
FUNCTION_NAME = '$R' + ''.join('_' + str(ord(c)) for c in SOURCE_NAME)
PREFIX = 'function ' + FUNCTION_NAME + '($p0,$p1,$p2){'
ARRAYSET = 'function arrayset(a,i,v){const xs=arraydata(a);xs[Number(i)%xs.length]=v;return a}'
READ = 'const $data=arraydata($array);const $p4=$data[Number($index)%$data.length];'
VALUE = '(/* primitive */(((x3420)^($p0))>>>0))'
WRITE = '$n2_0=arrayset($p3,$p0,' + VALUE + ',);'
SETUP = 'let $w0=$p2[0];let $w1=$p2[1];for(;;){'
ZERO = 'if($p0===0n){return (($p0,$p1)=>{return $p1;})($p1,$p2);}'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def identity(path):
    path = path.resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=sha(data), bytes=len(data))


def once(text, old, new):
    assert text.count(old) == 1, 'Missing/ambiguous exact anchor: ' + old
    return text.replace(old, new, 1)


def function_end(source, start):
    """Balance a pinned function, ignoring quoted strings and comments.

    Refuse templates and unclassified slashes instead of pretending to be a
    general JS parser. The full module and each resulting span are hash-pinned.
    """
    i = start + len(PREFIX)
    depth = 1
    while i < len(source):
        char = source[i]
        if char in ('"', "'"):
            quote = char
            i += 1
            while i < len(source) and source[i] != quote:
                i += 2 if source[i] == '\\' else 1
            assert i < len(source), 'Unterminated string'
        elif source.startswith('/*', i):
            end = source.find('*/', i + 2)
            assert end >= 0, 'Unterminated comment'
            i = end + 1
        elif source.startswith('//', i):
            end = source.find('\n', i + 2)
            assert end >= 0, 'Unterminated line comment'
            i = end
        elif char in ('`', '/'):
            raise AssertionError('Unsupported token in pinned function')
        elif char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    raise AssertionError('Unterminated function')


def transform(function, variant):
    if variant == 'original':
        return function
    # All three arguments are evaluated before entering the old helper body.
    # Preserve this ordering, its second Number conversion and handle result.
    write = ('const $p47a=$p3;const $p47i=$p0;const $p47v=' + VALUE + ';'
             'const $p47xs=arraydata($p47a);'
             '$p47xs[Number($p47i)%$p47xs.length]=$p47v;$n2_0=$p47a;')
    result = once(function, WRITE, write)
    if variant != 'shell':
        # Declarations after the zero guard do not demand the backing array.
        declarations = 'let $p47View;' + ('let $p47Length;' if variant == 'length' else '')
        result = once(result, SETUP, SETUP.replace('for(;;){', declarations + 'for(;;){'))
        read = 'const $data=$p47View===undefined?($p47View=arraydata($array)):$p47View;'
        if variant == 'length':
            # Original read order is arraydata, Number(index), length, element.
            read += ('const $p47ReadIndex=Number($index);'
                     'if($p47Length===undefined)$p47Length=$data.length;'
                     'const $p4=$data[$p47ReadIndex%$p47Length];')
        else:
            read += 'const $p4=$data[Number($index)%$data.length];'
        result = once(result, READ, read)
        result = once(result, 'const $p47xs=arraydata($p47a);', 'const $p47xs=$p47View;')
        if variant == 'length':
            result = once(result, 'Number($p47i)%$p47xs.length', 'Number($p47i)%$p47Length')
    assert result.startswith(PREFIX + ZERO), 'Zero-iteration demand changed'
    assert result.count('Number(') == 2, 'Both observable index conversions must remain'
    assert result.count('$n2_0=$p47a;') == 1
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    source = args.source.resolve(strict=True)
    emission = Path(str(source) + '.json')
    inputs = [identity(source), identity(emission), identity(Path(__file__))]
    assert inputs[0]['sha256'] == PARENT_SHA, 'Only the preserved Phase46 batch03 array module is admitted'
    receipt = json.loads(emission.read_text())
    assert receipt['complete'] is True and receipt['role'] == 'selfhost' and receipt['target'] == 'js'
    assert receipt['observation']['status'] == 'ok' and receipt['observation']['checked'] is True
    assert Path(receipt['output']['file']).resolve(strict=True) == source
    assert receipt['output']['sha256'] == PARENT_SHA
    original = source.read_text()
    assert '$p47' not in original, 'Fresh binding prefix collides'
    assert original.count(ARRAYSET) == 1, 'Runtime helper differs'
    spans = []
    for match in re.finditer(re.escape(PREFIX), original):
        end = function_end(original, match.start())
        function = original[match.start():end]
        assert sha(function.encode()) == FUNCTION_SHA, 'Private loop differs'
        spans.append((match.start(), end, function))
    assert len(spans) == 3, 'Expected bench, p46.loop and p46.batch copies'
    variants = {}
    for variant in ('original', 'shell', 'view', 'length'):
        cursor, chunks, changes = 0, [], []
        for start, end, function in spans:
            replacement = transform(function, variant)
            chunks.extend((original[cursor:start], replacement))
            changes.append(dict(start=start, end=end, sourceName=SOURCE_NAME,
                beforeSha256=FUNCTION_SHA, afterSha256=sha(replacement.encode()),
                beforeBytes=len(function.encode()), afterBytes=len(replacement.encode())))
            cursor = end
        chunks.append(original[cursor:])
        variants[variant] = (''.join(chunks), changes)
    assert variants['original'][0].encode() == source.read_bytes()
    for item in inputs:
        assert identity(Path(item['file'])) == item, 'Consumed input changed'
    output = args.output.resolve()
    assert not output.exists(), 'Output directory must be fresh'
    output.mkdir(parents=True, exist_ok=False)
    manifest = dict(kind='phase47-array-view-probe', schemaVersion=1, complete=True,
        diagnosticOnly=True, productionSafe=False, correctness='not-run', measurements='not-run',
        inputs=inputs, parentCompiler=receipt['compiler'], parentSource=receipt['input'],
        parsing='Exact module/function hashes plus balanced function spans; not a general JS rewriter.',
        unchanged='All bytes outside the three admitted function spans; original variant byte-identical.',
        preserved='Zero-iteration early return; original first read-demand position; Number called separately for read and write; write arguments evaluated before its body; returned array handle.',
        hazards=['View caching requires stable backing storage across every alias and callback.',
                 'Length caching additionally requires stable length and ordinary indexing.',
                 'Retained Number calls may invoke a replaced host function that mutates backing view/length.',
                 'Public getters/proxies/array mutation and error-stack observations are not proved equivalent.',
                 'Existing descriptor guards are preserved but do not prove these additional permissions.'],
        variants={})
    for variant, (code, changes) in variants.items():
        directory = output / variant
        directory.mkdir()
        module = directory / 'program.mjs'
        with module.open('x') as handle:
            handle.write(code)
        manifest['variants'][variant] = dict(module=identity(module), changes=changes,
            mechanism={'original':'unchanged reference', 'shell':'inline only the arrayset helper body',
                       'view':'shell plus lazy backing-view cache; length reads retained',
                       'length':'view plus lazy length cache after first read index conversion'}[variant])
    with (output / 'manifest.json').open('x') as handle:
        json.dump(manifest, handle, indent=2)
        handle.write('\n')
    print(json.dumps(dict(complete=True, manifest=str(output / 'manifest.json'), variants=list(variants))))


if __name__ == '__main__':
    main()
