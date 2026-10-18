#!/usr/bin/env python3
"""Append qualified canonical entry admission to a frozen fixed native source.

Source preparation only; live mode constructs its own checked Base seed. This
leaves the fixed source and all of its preparation scripts/receipts unchanged.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p110_native_prepare',HERE/'prepare.py')
PREP=importlib.util.module_from_spec(spec);spec.loader.exec_module(PREP)
pin,verify=PREP.pin,PREP.verify

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',required=True,type=Path)
    parser.add_argument('--qualification',required=True,type=Path,help='Complete checked closure transport report')
    parser.add_argument('--out',required=True,type=Path)
    args=parser.parse_args();prepared=args.source.resolve();out=args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
    old=prepared/'manifest.json';record=json.loads(old.read_text())
    if not record['complete'] or record['kind']!='phase110-native-selected-library-source':raise ValueError('invalid fixed source')
    if record.get('sourceRuntimeAdmission') is not None:raise ValueError('general composition currently requires baseline/compact-general profile; stored/spare receipts cannot transfer across source bytes')
    for row in record['inputs']:verify(row)
    verify(record['source']);verify(record['config']);verify(record['bridge'])
    qualification=args.qualification.resolve();qualified=json.loads(qualification.read_text())
    if qualified.get('kind')!='phase110-checked-closed-entry-probes' or not qualified.get('complete'):raise ValueError('complete actual checked closure qualification required')
    for row in qualified['inputs']+qualified['outputs']:verify(row)
    if len(qualified['rows'])!=6 or len(qualified['mutations'])<9 or len(qualified['exports'])!=4:raise ValueError('closure coverage incomplete')
    admission=HERE.parent/'admission';modules=[admission/(name+'.bend') for name in ['model','layout','entry','library']]
    # Bind these exact current admission bytes to the checked API that passed.
    api_rows=[row for row in qualified['inputs'] if Path(row['file']).name=='api.mjs']
    if len(api_rows)!=1:raise ValueError('one qualified API pin required')
    api_report_path=Path(api_rows[0]['file']).parent/'report.json'
    api_report=json.loads(api_report_path.read_text())
    if api_report.get('kind')!='phase110-checked-api' or not api_report.get('complete') or api_report.get('api')!=api_rows[0]:raise ValueError('qualified API source binding missing')
    qualified_source=verify(api_report['source']).read_text()
    for module in modules:
        if qualified_source.count(module.read_text().strip())!=1:raise ValueError('qualified admission module differs '+str(module))
    additions='\n\n'.join(module.read_text() for module in modules)
    general=HERE/'general.bend';main_file=HERE/'main.bend'
    original_main=PREP.blocks(main_file.read_text())['main']
    new_main=original_main.replace('p110_native_args(args)','p110_general_args(args)')
    source=Path(record['source']['file']).read_text()
    if source.count(original_main)!=1:raise ValueError('unexpected native entry')
    existing=set(PREP.blocks(source));new=set(PREP.blocks(additions+'\n'+general.read_text()))
    if existing&new:raise ValueError('new declaration collision')
    base=verify(record['assets']['base'])
    config=Path(record['config']['file']).read_text()+'\n\ndef p110_general_base_source() -> String:\n  '+json.dumps(base.read_text(),ensure_ascii=False)+'\n'
    source=source.replace(original_main,new_main,1)+'\n\n'+additions+'\n\n'+general.read_text()+'\n\ndef p110_general_base_source() -> String:\n  '+json.dumps(base.read_text(),ensure_ascii=False)+'\n'
    if len(re.findall(r'^def main\(',source,re.M))!=1:raise ValueError('exactly one main required')
    out.mkdir();(out/'compiler.bend').write_text(source);(out/'config.bend').write_text(config)
    (out/'modules.bend').write_text((prepared/'modules.bend').read_text()+'\n'+additions+'\n')
    bridge=out/'bridge';bridge.mkdir();(bridge/'source.bend').write_text(Path(record['bridge']['file']).read_text()+'\n'+additions+'\n')
    # Exact native entry interfaces remain testable without acquiring the full image.
    entry_text=main_file.read_text().replace(original_main,new_main,1)+'\n\n'+general.read_text()
    (out/'entry.bend').write_text(entry_text)
    inputs=[*record['inputs'],pin(old),pin(qualification),pin(api_report_path),api_report['source'],pin(Path(__file__)),pin(general),*map(pin,modules)]
    for row in inputs:verify(row)
    def retarget(value):
        if isinstance(value,list):return [retarget(item) for item in value]
        if isinstance(value,dict):return {key:retarget(item) for key,item in value.items()}
        if isinstance(value,str):return value.replace(str(prepared),str(out)).replace('p110-'+prepared.name,'p110-'+out.name)
        return value
    result=dict(record)
    result.update(version=2,inputs=inputs,source=pin(out/'compiler.bend'),config=pin(out/'config.bend'),bridge=pin(bridge/'source.bend'),
        modules=[*record['modules'],*map(pin,modules)],entry=pin(out/'entry.bend'),generalModule=pin(general),
        generalAdmissionQualification=pin(qualification),commands=retarget(record['commands']),guardedCommands=retarget(record['guardedCommands']),
        generalEntry={'mode':'live','export':'entry','baseExactBytes':True,'seedFactory':'internal p86_prepare',
            'requires':'Requested entry and callees must be reachable from checked main; no arbitrary source imports beyond Base.',
            'grammar':'ABS_INPUT general SOURCE_ENTRY qbe|c|ir POLICY live',
            'types':['String','List<&2,String>'],'genericSpecialization':False},
        qualificationLimits=[*[limit for limit in record['qualificationLimits'] if not limit.startswith('Frozen source bytes')],
            'Frozen source bytes remain mandatory for the original fixed-contract CLI only.',
            'General mode admits canonical monomorphic owning String/List<String> closed callees from one actual checked request.',
            'General mode has no cached seed or serialized certificate input; Base bytes equal the compiled literal.',
            'General mode and fresh image still require parent-run typecheck and native semantic qualification.'])
    (out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'complete':True,'targetsRun':False,'source':result['source'],'manifest':str(out/'manifest.json')}))
if __name__=='__main__':main()
