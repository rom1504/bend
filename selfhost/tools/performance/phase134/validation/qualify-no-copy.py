#!/usr/bin/env python3
"""Separate exact-source no-copy writer contract; keep prior qualifiers frozen."""
import hashlib
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p134_stream_qualification', HERE / 'qualify.py')
Q = importlib.util.module_from_spec(spec); spec.loader.exec_module(Q)
P, C, V = Q.P, Q.C, Q.V
P.require(P.pin(Q.__file__)['sha256'] == '5ccbddb23b681525bce776b5036b3bab7ebbe54e6cbea04180c663474e739b0c', 'Frozen stream qualifier changed')
SOURCE_SHA = 'ae76d5eb1a2120c2885ccb081a5cbbeeef50a637fce4b9192a9274cb65b23cd1'
MODULE = P.TOOLS / 'phase134/native-io-no-copy-v01.bend'
PROBE = P.TOOLS / 'phase134/emission/writer/fixture-v02.bend'
CHECK = P.TOOLS / 'phase134/emission/writer/check.py'
NEW_METHODS = {
    MODULE: 'f2c03ac9a917ed95d70594faf0f432852402f25c0cd2bbc5975550d3feddc8c3',
    PROBE: '9e1fd069bd348936a2c50e3d856ee8942548c0a98415cc32111961c8f8b4b04f',
    CHECK: '3de4e0049562c16156c8d4d1637d6c0becbdc3d9376dfcdfe0a8c8906e7cfc68',
}
ORIGINAL_SOURCE_CONTRACT = Q.source_contract


def source_contract(manifest_path, api_path, finite_path, parent):
    # All existing replay, protected-body, nine success-result and15 predicate
    # checks run on this actual new source with its independently checked API.
    contract = ORIGINAL_SOURCE_CONTRACT(manifest_path, api_path, finite_path, parent)
    prior_path = P.BUILD / 'phase134/stream-source02/manifest.json'
    prior = V.read(prior_path)
    P.require(prior['source']['sha256'] == 'a7c3522a563bb4eb58d215b0f614ba4df06ef57bcd98a096c5d56e9e8cafd9d4', 'Original stream source changed')
    before = C.blocks(P.verify(prior['source']).read_text())
    after = C.blocks(P.verify(contract['source']).read_text())
    P.require(not (set(before)-set(after)) and set(after)-set(before) == {'p134wn_end','p134wn_text'}, 'Unexpected no-copy declaration change')
    P.require([n for n in before if C.norm(before[n]) != C.norm(after[n])] == ['p134w_step'], 'No-copy changes more than writer step')

    # The independently executed native probe contains these actual helpers
    # under different names and an ordinary producer of retained strings.
    probe = C.blocks(P.verify(P.pin(PROBE)).read_text())
    names = {'p134f_bare_written':'p134w_written', 'p134f_bare_end':'p134wn_end',
             'p134f_bare_text':'p134wn_text', 'p134f_bare_step':'p134w_step', 'p134f_bare':'p134w_drain'}
    for old, new in names.items():
        body = probe[old]
        for left in sorted(names,key=len,reverse=True): body = body.replace(left+'(',names[left]+'(')
        if new == 'p134w_step': body = body.replace('ending','legacy_end')
        if new == 'p134w_written': body = body.replace('(file,result)','(file, result)')
        P.require(C.norm(body) == C.norm(after[new]), 'Native writer proxy/helper body mismatch: ' + new)
    _, base, _ = P.authorities()
    request_path = P.BUILD / 'phase130/p134-writer02/report.json'
    product = V.emission(request_path,parent['n3'],P.pin(PROBE),parent['runtime'],Path(parent['preferredCarrierReceipt']['file']))
    build_path = P.BUILD / 'phase111/p134-writer02/report.json'
    image = V.Q.build(V.read(build_path),product,parent['runtime'],base['tools'])
    tiny_request_path = P.BUILD / 'phase130/p134-io-control01/report.json'
    tiny_request = V.read(tiny_request_path)
    P.require(tiny_request['image'] in [parent['n2'],parent['n3']], 'Tiny IO control has no qualified producer')
    tiny_product = V.emission(tiny_request_path,tiny_request['image'],tiny_request['source'],parent['runtime'],Path(parent['preferredCarrierReceipt']['file']))
    tiny_image = V.Q.build(V.read(P.BUILD / 'phase111/p134-io-control01/report.json'),tiny_product,parent['runtime'],base['tools'])
    check_path = P.BUILD / 'phase134/writer-check01/report.json'
    check = V.read(check_path)
    P.require(check.get('complete') and check['inputs'] == [P.pin(CHECK),tiny_image,image], 'Native writer-control image/method differs')
    expected_names = ['pipe-exact-newline','append-preserves-prefix','native-dev-full-fails'] + [f'mode{i}-exact-4MiB' for i in range(6)]
    P.require([r['name'] for r in check['controls']] == expected_names and all(r['passed'] for r in check['controls']), 'Native writer controls missing')
    P.require(P.verify(check['controls'][1]['output']).read_bytes() == b'preserve:one:two\n', 'Append control output differs')
    failure = check['controls'][2]
    P.require(failure['status'] == 28 and P.verify(failure['stderr']).read_bytes() == b'No space left on device\n', 'Real File.write failure was not propagated')
    for mode,row in enumerate(check['controls'][3:]):
        size,count = (1023,4096) if mode < 3 else (8191,512)
        expected = (b'X'*size+b'\n')*count
        P.require(row['pieceChars'] == size and row['pieces'] == count and row['output']['bytes'] == len(expected) and row['output']['sha256'] == hashlib.sha256(expected).hexdigest(), 'Independent4MiB byte oracle differs')
    contract.update(variant='no-copy-writer', changedStreamDeclarations=['p134w_step'], addedWriterHelpers=['p134wn_end','p134wn_text'],
        unchangedRendererAndAdmission=True, nativeWriterControls=P.pin(check_path), nativeWriterBuild=P.pin(build_path),
        nativeWriterSource=P.pin(PROBE), sourceConnectedNativeWriterHelpers=names,
        writerScope='Native six-variant4MiB proxy uses the exact renamed writer helpers with a synthetic producer; shared-string timings are diagnostic, not full compiler gains. Tiny pipe/append/dev-full controls use the retained runtime. Raw write errors stop both text and LF paths; existing File.close ignores delayed-close failures.')
    return contract


def main():
    Q.SOURCE_SHA = SOURCE_SHA
    Q.METHODS.update(NEW_METHODS)
    Q.source_contract = source_contract
    V.retain(P.pin(__file__))
    save = P.save
    def save_no_copy(path,value):
        value['variant'] = 'no-copy-writer'
        if 'scope' in value: value['scope'] += ' Writer additionally bound to exact native proxy helpers and independently constructed output/error observations; no general delayed-close guarantee.'
        save(path,value)
    P.save = save_no_copy
    Q.main()


if __name__ == '__main__': main()
