#!/usr/bin/env python3
"""Prepare closed native batch inputs without running a compiler or program."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SOURCE_MANIFEST = ROOT / 'selfhost/build/phase88/broad-fixtures03/manifest.json'
TEMPLATE = HERE / 'batch-template.bend'
PARSER_PATTERN = ROOT / 'selfhost/tools/performance/phase46/numeric-batch.bend'
MARKER = '\n# Phase88: exact catalog point, ordinary IO entry.\n'


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def verify(record):
    actual = pin(record['file'])
    assert actual == record, actual['file']
    return actual


def derive(origin, catalog_case, template):
    """Replace only the final IO entry; keep the prior body and adapter exact."""
    assert origin['id'] == catalog_case['id']
    point = catalog_case['point']
    args = point['args']
    assert len(args) <= 2 and all(type(x) is int and 0 <= x < 2**32 for x in args)
    assert re.fullmatch(r'[A-Za-z_][A-Za-z_0-9.]*', point['exportName'])
    expected = point['expected']
    assert type(expected) in (int, str)
    assert type(expected) is str or 0 <= expected < 2**32
    assert origin['expected'] == str(expected)
    assert origin['original']['sha256'] == catalog_case['source']['sha256']
    source = Path(verify(origin['source'])['file']).read_text()
    original = Path(verify(origin['original'])['file']).read_text()
    renamed, main_count = re.subn(r'^def main\(', 'def p88_original_main(', original, flags=re.M)
    renamed, law_count = re.subn(r'^law main:', 'law p88_original_main:', renamed, flags=re.M)
    assert main_count in (0, 1) and bool(main_count) == origin['renamedMain']
    assert law_count in (0, 1) and bool(law_count) == origin['renamedLaw']
    assert source == renamed + origin['append']
    assert source.count(MARKER) == 1 and origin['append'].count(MARKER) == 1
    prefix, entry = source.rsplit(MARKER, 1)
    assert origin['append'].endswith(MARKER + entry)
    assert entry.startswith('def main() -> IO(Unit):\n  IO.print(') and entry.endswith(')\n')
    assert re.findall(r'^import .*$', source, re.M) == ['import Base']
    assert not re.search(r'^(?:def|law|type) p93[._]', source, re.M)

    parameters = ['a', 'b'][:len(args)]
    value = point['exportName'] + '(' + ', '.join(parameters) + ')'
    if origin['adapter'] == 'generic-row':
        assert type(expected) is str and len(args) == 2
        value = 'p88_row_output(row.probe(a, b))'
    else:
        assert origin['adapter'] is None
    return_type = 'String' if type(expected) is str else 'U32'
    runtime_args = args + [0] * (2 - len(args))
    values = {
        '@ARG0@': str(runtime_args[0]), '@ARG1@': str(runtime_args[1]),
        '@RETURN_TYPE@': return_type, '@VALUE@': value,
        '@EQUALITY@': 'String.eq' if return_type == 'String' else 'U32.is_eq',
        '@EXPECTED@': json.dumps(expected, ensure_ascii=False),
        '@SHOW_VALUE@': 'p93.value(a, b)' if return_type == 'String' else 'U32.show(p93.value(a, b))',
    }
    assert set(re.findall(r'@[A-Z_0-9]+@', template)) == set(values)
    suffix = re.sub(r'@[A-Z_0-9]+@', lambda match: values[match[0]], template)
    result = prefix + suffix
    assert result.startswith(prefix) and result[len(prefix):] == suffix
    derivation = dict(
        operation='Replace only the final Phase88 catalog IO entry with the rendered batch template.',
        removedSuffix=MARKER + entry,
        preservedPrefix=dict(bytes=len(prefix.encode()), sha256=hashlib.sha256(prefix.encode()).hexdigest()),
        appendedSuffix=dict(bytes=len(suffix.encode()), sha256=hashlib.sha256(suffix.encode()).hexdigest()),
        originalMainRenamed=origin['renamedMain'], originalLawRenamed=origin['renamedLaw'],
        adapter=origin['adapter'], valueExpression=value,
        workload='Original catalog arguments remain fixed on every iteration; no alternating inputs.',
        observer='Compare every complete result with the frozen expected value and sum Bool.to_u32 into U32.',
    )
    metadata = dict(id=origin['id'], name=origin['id'], family=origin['family'],
                    source88=origin['source'], original=origin['original'], point=point,
                    args=args, runtimeArgs=runtime_args, expected=str(expected),
                    expectedStdout=str(expected) + '\n', returnType=return_type,
                    derivation=derivation)
    return result, metadata


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase93') and not out.exists()
    manifest_pin = pin(SOURCE_MANIFEST)
    manifest = json.loads(SOURCE_MANIFEST.read_text())
    catalog_pin = verify(manifest['catalog'])
    catalog = json.loads(Path(catalog_pin['file']).read_text())
    cases = {case['id']: case for case in catalog['cases']}
    assert len(cases) == len(catalog['cases']) == len(manifest['cases']) == 45
    assert set(cases) == {case['id'] for case in manifest['cases']}
    method, template_pin = pin(__file__), pin(TEMPLATE)
    inputs = [manifest_pin, catalog_pin, method, template_pin, verify(manifest['method']), pin(PARSER_PATTERN)]
    template = TEMPLATE.read_text()
    outputs = []
    for origin in manifest['cases']:
        assert re.fullmatch(r'[a-z][a-z0-9-]*', origin['id'])
        text, metadata = derive(origin, cases[origin['id']], template)
        inputs.extend([origin['source'], origin['original']])
        outputs.append((out / (origin['id'] + '.bend'), text, metadata))
    inputs = list({row['file']: row for row in inputs}.values())
    for row in inputs:
        verify(row)
    out.mkdir(parents=True, exist_ok=False)
    rows = []
    for file, text, metadata in outputs:
        with file.open('x') as stream:
            stream.write(text)
        rows.append(dict(metadata, source=pin(file)))
    for row in inputs:
        verify(row)
    report = dict(kind='phase93-fixed-catalog-native-batches', complete=True, targetExecuted=False,
                  method=method, template=template_pin, sourceManifest=manifest_pin, catalog=catalog_pin,
                  inputs=inputs, inputsUnchanged=True, cases=rows,
                  runtimeArgumentOrder=['repetitions', 'warmups', 'arg0', 'arg1'],
                  defaultCounts=dict(repetitions=8, warmups=2),
                  countBound='Use repetition and warmup counts below 2^32; success counts are U32.',
                  outputLines=['full expected value', 'warmup successes', 'measured successes', 'elapsed milliseconds'],
                  clock='IO.now interval includes every measured evaluation/comparison and success-count formatting/print.',
                  scope='Closed catalog45: original workload arguments and full expected values; generated source preparation only.')
    with (out / 'manifest.json').open('x') as stream:
        json.dump(report, stream, indent=2, ensure_ascii=False)
        stream.write('\n')
    print(json.dumps(dict(complete=True, targetExecuted=False, cases=len(rows), manifest=pin(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
