"""Freeze an additive QBE retry diagnostic and root-only jobs; execute no targets."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
    parent_dir = ROOT/'selfhost/build/phase144/integrated-source01'
    parent = json.loads((parent_dir/'manifest.json').read_text())
    assert parent['complete'] and C.pin(parent['source']['file']) == parent['source']
    assert parent['source']['sha256'] == '992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b'
    module = HERE/'product-retry-v01.bend'
    before = Path(parent['source']['file']).read_text()
    text, added, protected = C.compose(before, [module.read_text()], set(), set())
    assert text.startswith(before)
    old, new = C.blocks(before, combine=True), C.blocks(text, combine=True)
    for name, body in old.items():
        assert C.norm(body) == C.norm(new[name]), name
    out.mkdir()
    source = out/'compiler.bend'
    source.write_text(text)
    (out/'module.bend').write_bytes(module.read_bytes())
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    inputs = [C.pin(__file__), C.pin(C.__file__), C.pin(parent_dir/'manifest.json'), parent['source'], C.pin(module)]
    manifest = dict(kind='phase144-additive-product-retry', complete=True,
                    targetsRun=False, checked=False, selected=False, source=C.pin(source),
                    inputs=inputs, added=added, overrides=[], originalSourcePrefixByteExact=True,
                    allOriginalDeclarationsNormalizedExact=True,
                    originalDeclarationCount=len(old), physicalLines=len(text.splitlines()))
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    native = json.loads((ROOT/'selfhost/build/phase144/verifier-lexer-native01/manifest.json').read_text())
    summed = json.loads((ROOT/'selfhost/build/phase144/verifier-lexer-sum01/manifest.json').read_text())
    fixtures = [('product-head', C.pin(HERE/'admission-fixture-v01.bend'), '42\n'),
                ('verifier-original', native['variants']['old']['source'], '2048\n'),
                ('verifier-product', native['variants']['new']['source'], '2048\n'),
                ('verifier-sum', summed['variants']['new']['source'], '2048\n')]
    for _, row, _ in fixtures:
        assert C.pin(row['file']) == row
    cases = dict(kind='phase144-product-retry-fixtures', complete=True,
                 inputs=[C.pin(ROOT/'selfhost/build/phase144/verifier-lexer-native01/manifest.json'),
                         C.pin(ROOT/'selfhost/build/phase144/verifier-lexer-sum01/manifest.json')],
                 cases=[dict(name=name, source=row, expectedOutput=expected) for name, row, expected in fixtures])
    (out/'cases.json').write_text(json.dumps(cases, indent=2)+'\n')
    api = ROOT/'selfhost/build/phase111/p144-product-retry-api01'
    result = ROOT/'selfhost/build/phase144/product-retry-census01'
    assert not api.exists() and not result.exists()
    guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
    checker = ROOT/'selfhost/tools/performance/phase111/check-api.py'
    runner = HERE/'product-retry-census-v01.mjs'
    bun = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
    exports = ['p88_cache_prepare', 'p86_plan', 'p128raw_lower_request', 'p144pf_probe',
               'p113e_verify', 'p144pf_emit_request', 'p134e_collect']

    def command(name, seconds, cmd):
        return ['/usr/bin/python3', '-B', str(guard), '--out', str(out/(name+'-guard')),
                '--seconds', str(seconds), '--cpu', '3', '--rss-mib', '3072',
                '--available-mib', '16384', '--file-mib', '100', '--', *map(str, cmd)]

    jobs = dict(kind='phase144-product-retry-root-jobs', complete=True, targetsRun=False,
                sequential=True, inputs=[C.pin(out/'manifest.json'), C.pin(out/'cases.json'),
                    C.pin(guard), C.pin(checker), C.pin(runner), C.pin(bun)],
                jobs=[dict(name='checked-api', seconds=140, command=command('api', 120,
                    ['/usr/bin/python3', '-B', checker, '--source', source, '--out', api, *exports])),
                    dict(name='four-fixture-census', seconds=280, command=command('census', 260,
                    [bun, runner, api/'report.json', out/'cases.json', result]))],
                gate='Do not emit/build candidates unless API is independently checked and census complete with allCandidatesVerified true. Inspect new ready workers and retry cost before native acquisition.')
    (out/'jobs.json').write_text(json.dumps(jobs, indent=2)+'\n')
    print(json.dumps(dict(prepared=True, targetsRun=False, source=C.pin(source), jobs=str(out/'jobs.json'))))


if __name__ == '__main__':
    main()
