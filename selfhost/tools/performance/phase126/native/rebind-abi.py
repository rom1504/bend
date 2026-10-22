"""Bind unchanged reviewed Phase125 runtime authority to a checked Phase126 source."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PARENT_ABI = ROOT/'selfhost/build/phase125/verified-abi06.json'
PARENT_ABI_SHA = 'd7ec32126ba8e434b7f17440dfe3eedece7e1554df8184fa126a928b3cc0ca86'
SQRT_SHA = '6f704b92542b45e87f74c073177e710686d5ee0e5493bc682225d6c66a328b9b'
WORD_SHA = '49ca622d1a5563c9c8108e180d002ead6a2e6322c56cfaaa3b2fb17a093ae432'
SELECTION = ROOT/'implementation/phase125/candidate.json'
DECL = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)


def pin(path):
    path=Path(path).resolve();raw=path.read_bytes()
    return dict(file=str(path),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def blocks(text):
    hits=list(DECL.finditer(text))
    return {m[1]:text[m.start():hits[i+1].start() if i+1<len(hits) else len(text)] for i,m in enumerate(hits)}


def norm(text):
    return '\n'.join(line.rstrip() for line in text.splitlines() if line.strip() and not line.lstrip().startswith('#'))


def module(path,name):
    spec=importlib.util.spec_from_file_location(name,path);value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value);return value


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-manifest',type=Path,required=True)
    parser.add_argument('--api-report',type=Path,required=True)
    parser.add_argument('--runtime-report',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();assert not args.out.exists()
    native=module(ROOT/'selfhost/tools/performance/phase125/native/plan.py','p126_parent_native')
    preparation=module(HERE.parent/'prepare.py','p126_source_gate')
    assert pin(PARENT_ABI)['sha256']==PARENT_ABI_SHA,'Changed frozen parent ABI receipt'
    old=read(PARENT_ABI);selected=read(SELECTION)
    source,api,runtime=map(read,[args.source_manifest,args.api_report,args.runtime_report])
    assert old['complete'] and old['kind']=='phase125-native-runtime-abi-admission'
    assert selected['complete'] and selected['nativeQualified'] and old['source']==selected['source']
    assert source['complete'] and api['complete'] and api['checked'] and source['source'] in api['inputs']
    assert runtime['complete'] and runtime['object']==old['runtime'] and runtime['source']==old['runtimeSource']
    assert runtime['object']==selected['runtime'] and source['parent']==selected['source']
    contract=native.source_contract(Path(source['source']['file']),source)
    previous_text=Path(old['source']['file']).read_text();current_text=Path(source['source']['file']).read_text()
    previous=blocks(previous_text);current=blocks(current_text)
    # Authenticate the original authority first; then require the actual same
    # declaration bytes in the new compiled source, not new host-supplied hashes.
    authorities={r['name']:r for r in old['sourceDeclarations']}
    required={name for row in old['imports'] for name in row['authority']}
    assert required==set(authorities) and len({r['symbol'] for r in old['imports']})==len(old['imports'])
    declaration_proofs=[]
    for name,row in authorities.items():
        before=previous[name].encode();after=current[name].encode()
        assert len(before)==row['bytes'] and hashlib.sha256(before).hexdigest()==row['sha256']
        assert after==before,'Changed admitted runtime authority: '+name
        declaration_proofs.append(dict(name=name,bytes=len(after),sha256=hashlib.sha256(after).hexdigest(),byteExact=True))
    verifier_names=(preparation.ENTRY_GATES | set(blocks(preparation.DIRECT_VERIFIER.read_text())) |
                    {n for n in previous if n.startswith('p111v_')}) & set(previous)
    for name in verifier_names:
        assert name in current and norm(current[name])==norm(previous[name]),'Changed original gate: '+name
    library=[];extra_inputs=[]
    if 'p126t_sqrt' in current:
        sqrt=HERE.parent/'typed/sqrt.bend';expected=blocks(sqrt.read_text())
        assert pin(sqrt)['sha256']==SQRT_SHA,'Unreviewed sqrt overlay bytes'
        assert set(expected)=={'p114so_group_call','p126t_sqrt','p114fl_text','p114fl_result'}
        # The independently reviewed low-word transport overlay changes only
        # dispatch around sqrt; it introduces no external call or float operation.
        word=HERE.parent/'typed/word-transport.bend';dispatch=blocks(word.read_text())
        dispatch_names={'p114so_group_call','p114fl_text'}
        if any(norm(current.get(n,''))!=norm(expected[n]) for n in dispatch_names):
            assert pin(word)['sha256']==WORD_SHA,'Unreviewed word transport overlay bytes'
            for name in dispatch_names:expected[name]=dispatch[name]
            extra_inputs.append(pin(word))
        for name,body in expected.items():
            assert name in current and norm(current[name])==norm(body),'Changed sqrt projection: '+name
        # The same runtime already links libm and implements this double call.
        runtime_text=Path(runtime['source']['file']).read_text()
        assert 'return f32_rewrap((f32)sqrt(f32_unbox(args[0])));' in runtime_text
        review=ROOT/'implementation/phase126/typed-review.md'
        extra_inputs += [pin(sqrt),pin(review),pin(ROOT/'selfhost/tools/performance/phase123/build-aligned.py')]
        library=[dict(symbol='sqrt',arguments=['F64'],result='F64',authority=sorted(expected),
            contract='Existing libm double sqrt(double), with exact F32→F64→sqrt→F32 projection. No owning inputs/results, sqrtf substitution, or arithmetic reassociation.',
            declarations=[dict(name=n,normalizedSha256=hashlib.sha256(norm(current[n]).encode()).hexdigest()) for n in sorted(expected)])]
    # A supplementary closed spelling check catches newly introduced external
    # symbols. It is not a parser/proof: exact source replay, authority declarations
    # and the original verifier are the actual admission premises above.
    runtime_names=lambda text:set(re.findall(r'\bp[0-9]+_rt_[A-Za-z0-9_]+\b',text))
    literal_names=lambda text:set(re.findall(r'\$[A-Za-z][A-Za-z0-9_.]*',text))
    assert runtime_names(current_text)==runtime_names(previous_text),'Changed runtime import spelling catalogue'
    added_symbols=literal_names(current_text)-literal_names(previous_text)
    assert added_symbols <= ({'$sqrt'} if library else set()),'Unadmitted new literal QBE symbol'
    inputs=[pin(__file__),pin(HERE/'plan.py'),pin(PARENT_ABI),pin(SELECTION),pin(args.source_manifest),
        pin(args.api_report),pin(args.runtime_report),pin(preparation.__file__),pin(preparation.DIRECT_VERIFIER),
        source['source'],api['api'],runtime['source'],runtime['object'],*source['inputs'],*api['inputs'],
        *runtime['inputs'],*old['inputs'],*extra_inputs]
    inputs=native.unique(inputs)
    for record in inputs:
        assert pin(record['file'])==record,'Changed identity: '+record['file']
    result=dict(kind=old['kind'],complete=True,targetsRun=False,source=source['source'],runtime=old['runtime'],
        runtimeSource=old['runtimeSource'],imports=old['imports'],sourceDeclarations=declaration_proofs,
        libraryCalls=library,inputs=inputs,parentAuthority=pin(PARENT_ABI),transportContract=contract,
        runtimeSymbolSpellings=sorted(runtime_names(current_text)),newLiteralSymbols=sorted(added_symbols),
        unchangedVerifierDeclarations=sorted(verifier_names),
        scope='Exact unchanged Phase125 runtime/import authority rebound to the newly checked source after source-contract replay and byte-exact authority comparison. Original gates remain equal. Optional sqrt is admitted only by the exact reviewed projection to the existing double libm ABI. No symbol/link inference, new runtime permission, native qualification or installation.')
    args.out.parent.mkdir(parents=True,exist_ok=True)
    with args.out.open('x') as stream:json.dump(result,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True,targetsRun=False,imports=len(result['imports']),libraryCalls=len(library),receipt=pin(args.out))))


if __name__=='__main__':
    main()
