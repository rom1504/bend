"""Authentication/argv only: no compiler, cache decoder, or request execution.

Build receipts bind preserved snapshots, not today's mutable production tree.
The private prepared cache is admitted only for the exact experimental consumer
and externally trusted payload below; receipt/stamp self-claims grant no trust.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
RUNTIME = ROOT / 'selfhost/build/phase86/runtime01/runtime.c'
EFFS = ROOT / 'selfhost/src/runtime/native/effs'
DEFAULT_CACHE = Path(__file__).parent / 'base/carrier01/receipt.json'
BASE_SHA = '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
CACHE_SHA = '97368c6813bad695800b1404af84ab13e5e34b1d5f575828f8fcb681aa2b5627'
API_SHA = '098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092'
CARRIER_SHA = '07af8cddb84820d861fc9f5d9475907754a64a9319de7d597c925149d8b186a7'
# Reviewed native02 snapshot with cache decoder and consuming compiler equality.
CACHED_CONSUMER = (
    '5babec07f3ff4c3a8c8e7be00566a681a4068b098349f9ee5207e53aa3231c9c',
    '08ea659193cc0c5f040f209e63e9b6df71ff3c928784db81706c264b41d05e4f',
    '8a636bf108bcc7f8378975b0077a8886be7300556be044b53e27a1023f09c659')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), sha256=digest.hexdigest(), bytes=path.stat().st_size)


def verify(record, digest=None):
    actual = pin(record.get('file', record.get('path')))
    require(actual['sha256'] == record['sha256'], 'Changed artifact: ' + actual['file'])
    require(actual['bytes'] == record['bytes'], 'Changed length: ' + actual['file'])
    if digest is not None:
        require(actual['sha256'] == digest, 'Untrusted artifact: ' + actual['file'])
    return actual


def read(path):
    return json.loads(Path(path).read_text())


def authenticate(image, cache_receipt=None):
    image = pin(image)
    build_path = image['file'] + '.build.json'
    build = read(build_path)
    require(build['complete'] and verify(build['binary']) == image, 'Incomplete/mismatched native build')
    checked_pin, guard_pin = verify(build['checked']), verify(build['guard'])
    checked, guard = read(checked_pin['file']), read(guard_pin['file'])
    source, c = verify(checked['source']), verify(checked['c'])
    require(checked['complete'] and guard['complete'], 'Incomplete checked acquisition/build guard')
    require(verify(build['source']) == c, 'Native build is not bound to checked C')
    require(build['command'] == guard['command'] and image['file'] in guard['command']
            and c['file'] in guard['command'], 'Build command/source mismatch')
    require(any(p['sha256'] == c['sha256'] and p.get('file', p.get('path')) == c['file']
                for p in build['inputs']), 'Checked C absent from build inputs')
    require(checked['upstream'] == '059266225b77c8ca256ac6b25ee5c21449bab151', 'Wrong compiler pin')
    require({'load', 'check', 'emit-c'} <= {p['name'] for p in checked['phases']}, 'Missing checked acquisition stages')
    base = pin(BASE)
    require(base['sha256'] == BASE_SHA, 'Wrong Base')
    transport = read(RUNTIME.parent / 'receipt.json')
    template = pin(transport['template'])
    require(template['sha256'] == transport['templateSha256'] ==
            'f9f5a1c98f17f892d891032ca35489234e43d3b4112a18e592e6da408b09736c', 'Wrong runtime template')
    canonical, runtime = read(template['file']), pin(RUNTIME)
    require(runtime['sha256'] == canonical['runtimeSha256'] == transport['runtimeSha256'], 'Wrong runtime')
    require(len(transport['parts']) == len(canonical['parts']) == 5, 'Expected five runtime parts')
    parts = [verify(p) for p in transport['parts']]
    for i, part in enumerate(parts):
        require(part['file'] == str(RUNTIME) + f'.part{i}' and
                Path(part['file']).read_bytes() == canonical['parts'][i].encode(), 'Wrong runtime part')
    effects = []
    for name, digest in {
        'args.c': '7209a5fa11396fa8b0667a6738c913c40f554797e442c847a25e13a5f69676e0',
        'print.c': '709500d2ace6e2eaeec0f5f1e4373d4ec5e402b3c1e289bd70dfef7e2a635b26',
        'now.c': 'da5fde65701c4fadc7560625c9615b4d60b2eefbd7b6bbe1aedda61887b825b9',
    }.items():
        effect = pin(EFFS / name)
        require(effect['sha256'] == digest, 'Untrusted scalar effect: ' + name)
        effects.append(effect)
    result = dict(image=image, source=source, c=c, build=pin(build_path), checked=checked_pin,
                  base=base, runtime=runtime, runtimeParts=parts, template=template,
                  effectsDir=str(EFFS), effects=effects, cache=None)
    if cache_receipt is not None:
        require(tuple(p['sha256'] for p in (image, source, c)) == CACHED_CONSUMER, 'Unqualified cached consumer')
        receipt = read(cache_receipt)
        require(receipt['complete'] and receipt['kind'] == 'phase88-private-base-carrier', 'Wrong cache receipt')
        carrier = verify(receipt['carrier'], CARRIER_SHA)
        inputs = receipt['inputPins']
        cache, api, cache_base = [verify(inputs[k], h) for k, h in
                                 [('cache', CACHE_SHA), ('api', API_SHA), ('base', BASE_SHA)]]
        require(cache_base == base, 'Cache Base path/identity mismatch')
        with Path(cache['file']).open('rb') as stream:
            header = json.loads(stream.readline(65536))
        expected = dict(format='bend-base-cache-frame-4', version=6, termAbi=1, spanAbi=3,
                        compilerSha256=API_SHA, baseSha256=BASE_SHA, sourcePath=base['file'],
                        sourceBegin=1, sourceEnd=75066, validatedBy='check_book')
        for name, version, producer in [('checkedPrefixState', 1, 'base_prefix_prepare'),
                ('freshPrefixState', 1, 'f_fresh_prefix_prepare'), ('preparedWorld', 3, 'base_prefix_world_prepare'),
                ('frontendReadyState', 1, 'f_ready_prefix_prepare')]:
            expected.update({name+'Version': version, name+'Producer': producer})
        require(receipt['cacheHeader'] == header and all(header.get(k) == v for k, v in expected.items()), 'Cache ABI/path/producer mismatch')
        binding = dict(format='p88-private-base-text-1', cache=CACHE_SHA, api=API_SHA,
                       base=BASE_SHA, path=base['file'], begin=1, end=75066, termAbi=1, spanAbi=3, worldVersion=3)
        stamp = binding['format'] + ':' + hashlib.sha256(json.dumps(binding, separators=(',', ':')).encode()).hexdigest()
        require(receipt['stampBinding'] == binding and receipt['stamp'] == stamp, 'Cache stamp binding mismatch')
        result['cache'] = dict(receipt=pin(cache_receipt), carrier=carrier, producerCache=cache, api=api, stamp=stamp)
    return result


def native_args(auth, source, output_prefix, calls=1):
    require(calls in (1, 5), 'Calls must be 1 or 5')
    args = [auth['image']['file'], '--threads', '1', '--gpu', 'off', '--',
            str(Path(source).resolve()), auth['base']['file'], auth['runtime']['file'],
            auth['effectsDir'], str(Path(output_prefix).resolve()), str(calls)]
    if auth['cache']:
        args.extend([auth['cache']['carrier']['file'], auth['cache']['stamp']])
    return args
