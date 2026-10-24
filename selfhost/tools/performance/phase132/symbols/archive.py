"""Archive compact-name receipts; no generated program or compiler is executed."""
import gzip, hashlib, importlib.util, json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
OUT = ROOT / 'implementation/phase132/evidence/symbols'
assert not OUT.exists(), 'Fresh evidence destination required'
OUT.mkdir(parents=True)


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


inputs = []
artifacts = []


def preserve(source, name, compressed=False):
    source = ROOT / source
    original = pin(source)
    raw = source.read_bytes()
    target = OUT / name
    target.write_bytes(gzip.compress(raw, compresslevel=6, mtime=0) if compressed else raw)
    if compressed:
        assert gzip.decompress(target.read_bytes()) == raw
    inputs.append(original)
    artifacts.append(dict(original=original, archive=pin(target), gzip=compressed))


preserve('selfhost/build/phase132/compact-symbols01/report.json', 'globals.json.gz', True)
preserve('selfhost/build/phase132/compact-locals01/report.json', 'locals.json')
preserve('selfhost/build/phase132/compact-build02/private-local-machine/report.json', 'machine.json.gz', True)
for role in ['baseline', 'private-local']:
    preserve(f'selfhost/build/phase111/p132-compact-build02-{role}/report.json', role + '-build.json')
    for name in ['method.json', 'inputs.json', 'process.json']:
        preserve(f'selfhost/build/phase132/compact-build02/{role}-guard/{name}', role + '-guard-' + name)
preserve('selfhost/build/phase132/compact-build01/jobs.json', 'plan01.json')
preserve('selfhost/build/phase132/compact-build02/jobs.json', 'plan02.json')

machine = json.loads((ROOT / 'selfhost/build/phase132/compact-build02/private-local-machine/report.json').read_text())
local = json.loads((ROOT / 'selfhost/build/phase132/compact-locals01/report.json').read_text())
glob = json.loads((ROOT / 'selfhost/build/phase132/compact-symbols01/report.json').read_text())
brief = {key: machine[key] for key in ['complete', 'textByteIdentical',
    'allocatedSectionsIdenticalExceptBuildId', 'changedAllocatedSections',
    'normalizedSymbolsEqual', 'rawExportSetEqual', 'normalizedRelocationsEqual',
    'descriptorAddressEqual', 'stages', 'beforeBinary', 'afterBinary']}
before = sum(machine['stages']['before'].values())
after = sum(machine['stages']['after'].values())
brief.update(buildChildSumBefore=before, buildChildSumAfter=after,
    buildChildRatio=after / before,
    qbeChildRatio=machine['stages']['after']['qbe'] / machine['stages']['before']['qbe'],
    rewriteHostSeconds=local['rewriteSeconds'],
    localProducerHostSeconds=local['totalHostSeconds'],
    globalProducerHostSeconds=glob['totalHostSeconds'],
    controlledTimingCampaign=False, pairs=1, targetsRunByArchive=False,
    scope='Single descriptive same-toolchain build pair. Allocated machine bytes and addresses '
          'are equal except linker build-ID. Host preparation is additional cost, not production '
          'Bend emission savings. No production change or program-runtime performance claim.')
(OUT / 'summary.json').write_text(json.dumps(brief, indent=2) + '\n')

# Reproduce the original metadata parser refusal without any target execution.
spec = importlib.util.spec_from_file_location('phase132_machine_negative', HERE / 'machine.py')
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)
binary = ROOT / 'selfhost/build/phase111/p131-final-native01-n2/program'
try:
    old.symbols(binary, {})
except ValueError as error:
    assert str(error) == "invalid literal for int() with base 10: '0x100000'"
    negative = dict(expectedRejection=True, error=repr(error), generatedTargetsRun=False,
                    inputs=[pin(HERE / 'machine.py'), pin(binary)],
                    scope='Read-only readelf metadata preflight, before target builds. '
                          'Version02 handles hexadecimal readelf symbol sizes.')
else:
    raise AssertionError('Original parser refusal no longer reproduces')
(OUT / 'parser-negative.json').write_text(json.dumps(negative, indent=2) + '\n')

manifest = dict(complete=True, generatedTargetsRun=False, archiveTool=pin(__file__),
    artifacts=artifacts, summaries=[pin(OUT / name) for name in ['summary.json', 'parser-negative.json']],
    scope='Exact original receipts, gzip where verbose. Full rewritten QBE and deterministic '
          'name maps remain in the pinned build directories; their hashes and inverse whole-source '
          'proofs are in the archived producer receipts. Recreate them from frozen input and tools '
          'without a native compiler build. No further timing pairs requested.')
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps(dict(complete=True, out=str(OUT), artifacts=len(artifacts),
                     bytes=sum(path.stat().st_size for path in OUT.iterdir()))))
