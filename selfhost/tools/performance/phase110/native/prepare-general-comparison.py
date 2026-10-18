#!/usr/bin/env python3
"""Replace only the oversized Base equality with a qualified exact comparator.

Preserve failed full-literal source and all its receipts; require both completed
Bend semantic controls and the minimal comparator's completed native emission.
"""
import argparse,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p110_prep',HERE/'prepare.py');PREP=importlib.util.module_from_spec(spec);spec.loader.exec_module(PREP)
pin,verify=PREP.pin,PREP.verify
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','comparison','controls','native-controls','emission','out']:p.add_argument('--'+name,required=True,type=Path)
a=p.parse_args();prepared=a.source.resolve();comparison=a.comparison.resolve();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
old_manifest=prepared/'manifest.json';old=json.loads(old_manifest.read_text());comparison_manifest=comparison/'manifest.json';cmp=json.loads(comparison_manifest.read_text());controls_file=a.controls.resolve();controls=json.loads(controls_file.read_text());emission_file=a.emission.resolve();emission=json.loads(emission_file.read_text())
native_file=a.native_controls.resolve();native=json.loads(native_file.read_text())
if not old['complete'] or not old.get('generalEntry') or old.get('sourceRuntimeAdmission') is not None:raise ValueError('supported general source required')
if not cmp['complete'] or not cmp['inverseExact'] or cmp['base']!=old['assets']['base']:raise ValueError('exact same Base comparison required')
if controls.get('kind')!='phase110-chunked-base-comparison-controls' or not controls.get('complete') or len(controls['rows'])!=11 or any(row['actual']!=row['expected'] for row in controls['rows']):raise ValueError('complete exact comparison controls required')
if not any(row==cmp['module'] for row in controls['inputs']):raise ValueError('controls are not bound to selected comparator module')
if native.get('kind')!='phase110-native-packed-matcher-controls' or not native.get('complete') or len(native['rows'])!=14 or any(row['status']!=0 or row['stdout']!=row['expected'] for row in native['rows']):raise ValueError('complete native exact comparison controls required')
if not any(row==cmp['module'] for row in native['inputs']) or not any(row==cmp['source'] for row in native['inputs']):raise ValueError('native controls are not bound to selected comparator')
if not emission.get('complete') or emission.get('source')!=cmp['source']:raise ValueError('minimal exact comparator native emission did not pass')
inputs=[*old['inputs'],*cmp['inputs'],*controls['inputs'],*native['inputs'],*emission['inputs'],pin(old_manifest),pin(comparison_manifest),pin(controls_file),pin(native_file),pin(emission_file),cmp['source'],cmp['module'],pin(Path(__file__)),*emission['outputs']]
if 'packed' in cmp:inputs.append(cmp['packed'])
for row in inputs:verify(row)
source=verify(old['source']).read_text();entry=verify(old['entry']).read_text();config=verify(old['config']).read_text();bridge=verify(old['bridge']).read_text();module=verify(cmp['module']).read_text()
old_literal=PREP.blocks(config)['p110_general_base_source'];old_test='String.eq(base,p110_general_base_source())';new_test='p110_general_base_matches(base)'
if source.count(old_literal)!=1 or config.count(old_literal)!=1 or source.count(old_test)!=1 or entry.count(old_test)!=1:raise ValueError('exact old full-literal boundary differs')
source=source.replace(old_literal,'',1).replace(old_test,new_test,1)+'\n\n'+module
entry=entry.replace(old_test,new_test,1);config=config.replace(old_literal,'',1)
if set(PREP.blocks(bridge))&set(PREP.blocks(module)):raise ValueError('comparator declaration collision')
if 'p110_general_base_source' in source or len(re.findall(r'^def main\(',source,re.M))!=1:raise ValueError('old literal remains or main differs')
out.mkdir();(out/'compiler.bend').write_text(source);(out/'entry.bend').write_text(entry);(out/'config.bend').write_text(config);(out/'modules.bend').write_text((prepared/'modules.bend').read_text()+'\n'+module)
(out/'bridge').mkdir();(out/'bridge/source.bend').write_text(bridge+'\n'+module)
def retarget(value):
 if isinstance(value,list):return [retarget(item) for item in value]
 if isinstance(value,dict):return {key:retarget(item) for key,item in value.items()}
 if isinstance(value,str):return value.replace(str(prepared),str(out)).replace('p110-'+prepared.name,'p110-'+out.name)
 return value
result=dict(old);result.update(version=3,inputs=inputs,source=pin(out/'compiler.bend'),entry=pin(out/'entry.bend'),config=pin(out/'config.bend'),bridge=pin(out/'bridge/source.bend'),modules=[*old['modules'],cmp['module']],commands=retarget(old['commands']),guardedCommands=retarget(old['guardedCommands']),
 exactBaseComparison={'encoding':cmp.get('encoding','String-chunks'),'base':cmp['base'],'length':cmp['characters'],'module':cmp['module'],'preparation':pin(comparison_manifest),'controls':pin(controls_file),'nativeControls':pin(native_file),'minimalNativeEmission':pin(emission_file),'fullTextEquality':True,'staticCapChanged':False},
 generalEntry={**old['generalEntry'],'baseExactBytes':True,'baseComparison':'qualified bounded exact packed comparison' if 'packed' in cmp else 'qualified bounded exact chunk comparison'})
(out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,source=result['source'],manifest=str(out/'manifest.json'))))
