"""Explicit sealed producer and new runtime transport; historical receipts stay unchanged."""
import json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
P=ROOT/'selfhost/tools/performance'
sys.path.insert(0,str(P/'phase88'))
from native_support import pin,verify,native_args
SEAL=ROOT/'selfhost/build/phase90/runtime-transition01/transition.json'
SEAL_SHA='d1bfca083361d03422814f8cec1880fb575803b4091c8075b1a08c84a45964b9'
SOURCE_SHA='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
RUNTIME_SHA='9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9'

def read(path):return json.loads(Path(path).read_text())

def transition(audit=False):
    receipt=pin(SEAL);assert receipt['sha256']==SEAL_SHA
    data=read(SEAL);assert data['complete'] and not data['executionPerformed']
    assert data['kind']=='phase90-native06-prior-runtime-transition-seal'
    expected=['selfhost/src/runtime/native/runtime.c','selfhost/src/runtime/native/runtime-template.json','selfhost/tools/typed-driver.mjs']
    assert [str(Path(m['original']['file']).relative_to(ROOT)) for m in data['mutableMappings']]==expected
    for m in data['mutableMappings']:
        frozen=verify(m['frozen']);assert all(frozen[k]==m['original'][k] for k in ['sha256','bytes'])
    if audit:
        for record in data['inputs']:historical(record,data)
        verify(data['admission']);verify(data['qualification']);verify(data['method']);verify(data['verifier'])
    auth=data['producer']
    assert auth['diagnosticOnly'] and auth['provenance']=='C-table-accessor-diagnostic'
    assert auth['image']['sha256']=='2914c0a45305684013bbfc8dd4172f4ddd55347196a4bb3561ec34e0bf60804d'
    assert verify(auth['source'])['sha256']==SOURCE_SHA;verify(auth['image'])
    verify(auth['base'])
    cache=data['cache']
    assert cache['carrier']['sha256']=='07af8cddb84820d861fc9f5d9475907754a64a9319de7d597c925149d8b186a7'
    for record in [cache['receipt'],cache['carrier'],cache['producerCache'],cache['api']]:verify(record)
    return data,receipt

def historical(record,data):
    """Verify the original identity via its explicitly listed exact-byte snapshot."""
    for mapping in data['mutableMappings']:
        if record.get('file',record.get('path'))==mapping['original']['file']:
            assert all(record[k]==mapping['original'][k] for k in ['sha256','bytes'])
            actual=verify(mapping['frozen']);assert all(actual[k]==record[k] for k in ['sha256','bytes'])
            return actual
    return verify(record)

def transport(receipt_path):
    seal,seal_pin=transition();receipt=pin(receipt_path);data=read(receipt_path)
    assert data['kind']=='phase90-new-runtime-native-transport' and data['complete']
    assert data['transition']==seal_pin
    runtime,template=verify(data['runtime']),verify(data['template'])
    assert runtime['sha256']==RUNTIME_SHA
    template_data=read(template['file'])
    assert template_data['version']==1 and template_data['runtimeSha256']==RUNTIME_SHA and len(template_data['parts'])==5
    assert ''.join(template_data['parts']).encode()==Path(runtime['file']).read_bytes()
    parts=[verify(p) for p in data['parts']];assert len(parts)==5
    for i,p in enumerate(parts):
        assert p['file']==runtime['file']+f'.part{i}'
        assert Path(p['file']).read_text()==template_data['parts'][i]
    assert verify(data['base'])==seal['producer']['base']
    names=['args.c','print.c','now.c','print_err.c','file_open.c','file_read.c','file_size.c','file_write.c','file_close.c']
    assert len(data['effects'])==len(data['sourceEffects'])==9
    for name,effect,original in zip(names,data['effects'],data['sourceEffects']):
        verify(effect);verify(original)
        assert Path(effect['file'])==Path(data['effectsDir'])/name
        assert all(effect[k]==original[k] for k in ['sha256','bytes'])
    assert verify(data['plan'])['sha256']=='1d6824d4be2a0a3e763336fe7ee19f67482190b2d8f7701df788d4ffcacdf566'
    ready=read(data['ready']['file'])
    assert ready['complete'] and ready['kind']=='phase90-runtime-large-table-accessor-prepared'
    assert all(runtime[k]==ready['outputs'][0][k] and template[k]==ready['outputs'][1][k] for k in ['sha256','bytes'])
    assert data['driver']==ready['outputs'][2]
    for key in ['ready','plan','templateReceipt','driver','method']:verify(data[key])
    return data,receipt,seal,seal_pin

def request_auth(transport_path,live=False):
    assets,receipt,seal,seal_pin=transport(transport_path)
    auth=dict(seal['producer'],base=assets['base'],runtime=assets['runtime'],template=assets['template'],
        runtimeParts=assets['parts'],effectsDir=assets['effectsDir'],effects=assets['effects'],cache=None if live else seal['cache'])
    return auth,dict(transition=seal_pin,transport=receipt,producer=seal['producer'],requestRuntime=assets)

def args(auth,source,prefix,calls=1):
    argv=native_args(auth,source,prefix,calls);argv.insert(argv.index('--')+1,auth['argvSentinel']);return argv
