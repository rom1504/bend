#!/usr/bin/env python3
"""Prepare genuine pre-lowering input capture; emit one root-owned target job."""
import argparse,hashlib,importlib.util,json,subprocess,sys,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output,pin,require,verify,write_json
spec=importlib.util.spec_from_file_location('phase147_exact_extraction',ROOT/'experiments/phase147/tools/prepare.py')
extraction=importlib.util.module_from_spec(spec);spec.loader.exec_module(extraction)

def acquisition_history(api,out):
    """Recover only changed historical producer metadata, never executing code."""
    receipt=json.loads(api.read_text());changed=[]
    allowed={'selfhost/tools/build/hosted.mjs','selfhost/src/compiler.json'}
    for row in receipt['inputs']:
        try:verify(row)
        except (OSError,ValueError):
            require(str(Path(row['file']).relative_to(ROOT))in allowed,'Unexpected acquisition input drift: '+row['file']);changed.append(row)
    if not changed:return [],[]
    index_file=ROOT/'implementation/phase152/evidence/capsule.json';index=json.loads(index_file.read_text())
    archive=dict(index['archive'],file=str(ROOT/index['archive']['file']));verify(archive)
    directory=out/'historical-acquisition-inputs';directory.mkdir();result=[]
    with tarfile.open(archive['file'],'r:gz')as tar:
        members={m.name:m for m in tar.getmembers()}
        for old in changed:
            matches=[r for r in index['payloads']if r['bytes']==old['bytes']and r['sha256']==old['sha256']]
            if matches:
                member=matches[0]['file'];data=tar.extractfile(members[member]).read();origin=dict(archiveMember=member)
            else:
                require(str(Path(old['file']).relative_to(ROOT))=='selfhost/src/compiler.json','Historical input absent from capsule')
                revision='326d42ea8499ea5d1d6005a7e3af9726c9d7af22';object_name=revision+':selfhost/src/compiler.json'
                data=subprocess.check_output(['git','show',object_name],cwd=ROOT)
                origin=dict(gitCommit=revision,gitObject=subprocess.check_output(['git','rev-parse',object_name],cwd=ROOT,text=True).strip(),originalRelativePath='selfhost/src/compiler.json')
            require(len(data)==old['bytes']and hashlib.sha256(data).hexdigest()==old['sha256'],'Historical archive member differs')
            destination=directory/(old['sha256'][:12]+'-'+Path(old['file']).name);destination.write_bytes(data)
            result.append(dict(declared=old,retained=pin(destination),**origin))
    return result,[pin(index_file),pin(archive['file'])]

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--functions',type=int,default=8);a=p.parse_args();require(6<=a.functions<=12,'Select6–12 complete owners')
    receipt=ROOT/'implementation/phase152/qualification.json';qualified=json.loads(receipt.read_text())
    source=assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json',ROOT/'selfhost','qbe')
    require(len(source)==qualified['source']['bytes']and hashlib.sha256(source).hexdigest()==qualified['source']['sha256'],'Current source differs from qualified Phase152')
    _,blocks=assembly.blocks(source);original=b''.join(r['data']for r in blocks if r['name']!='main')
    main_body=b'def main() -> U32:\n  Bool.to_u32(String.is_empty(p111_verify_program(p111_empty())))\n'
    workload,selected=extraction.extract([('canonical',original),('workload',main_body)],['main'],250_000)
    out=fresh_output(a.out,ROOT);(out/'compiler-workload.bend').write_bytes(workload)
    api=ROOT/'selfhost/build/phase152/composite-api01/report.json';base=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
    history,history_inputs=acquisition_history(api,out)
    families=[dict(name='compiler-verifier-slice',source=pin(out/'compiler-workload.bend'),owners=[r['name']for r in selected if r['kind']=='def'],selectionScope='Reached definitions from the freshly extracted compiler workload.'),
        dict(name='coverage-map-churn-128',source=pin(ROOT/'selfhost/tests/consolidation/native-broad/coverage-map-churn-128.bend'),ownerPrefixes=['Map.','Map:','p37.map.'],ownerNames=['main'],selectionScope='Reached Map library and benchmark owners; unrelated Base support owners remain in the full request but are excluded from the selected set.')]
    manifest=dict(kind='phase154-prelower-capture-plan',version=1,complete=True,targetsRun=False,functions=a.functions,
        inputs=[pin(__file__),pin(extraction.__file__),pin(assembly.__file__),pin(ROOT/'selfhost/src/compiler.json'),pin(receipt),*history_inputs],
        historicalAcquisitionInputs=history,
        qualification=pin(receipt),canonicalIdentity={k:qualified['source'][k]for k in ['bytes','sha256']},apiReceipt=pin(api),base=pin(base),families=families,
        scope='Capture exact pre-lowering request/erased owners, then original small backend once for exact metadata/complete program. No compiler/image acquisition.')
    write_json(out/'manifest.json',manifest)
    command=[ROOT/'selfhost/.assets/bin/bun',Path(__file__).with_name('capture.mjs'),'--plan',out/'manifest.json','--out',out/'capture']
    jobs=[extraction.guard('phase154-prelower-capture',out/'capture',command,120,2048,256)]
    write_json(out/'jobs.json',jobs);print(json.dumps(dict(plan=str(out/'manifest.json'),jobs=str(out/'jobs.json'),compilerSourceBytes=len(workload),targetsRun=False)))

if __name__=='__main__':main()
