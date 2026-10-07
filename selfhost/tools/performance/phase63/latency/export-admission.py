#!/usr/bin/env python3
"""Freeze source-backed export admission, then join a real checked attempt."""
import argparse
import difflib
import hashlib
import json
import re
import shlex
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase63'
PROJECT = ROOT/'selfhost'
OLD_ATTEMPT = PROJECT/'build/phase61/checked-state08/attempt.json'
HISTORY = PROJECT/'build/phase55/bootstrap-own-host02-plan01/full77.json'
BASE_ADDED = ['base_prefix_prepare','check_program_diagnostic_seed','f_fresh_prefix_prepare','f_graph_trace_from_prefix']
OLD_ADDED = ['f_prefix_graph_empty','f_prefix_complete_seed','f_prefix_complete_source','f_prefix_graph_trace','check_program_diagnostic_prefix']
GROUPS = {
    'src/check/prefix-state.bend': ['base_prefix_world_prepare','check_program_diagnostic_world'],
    'src/load/prefix.bend': ['f_ready_prefix_prepare','f_prefix_complete_ready_seed'],
    'src/back/js/direct/reach.bend': ['jd_plan_selected','jd_plan_defs','jd_plan_error','jd_plan_library'],
}
NEW = [name for names in GROUPS.values() for name in names]


def identity(value):
    file = Path(value['file'] if isinstance(value,dict) else value).resolve(strict=True)
    result = dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value,dict): assert result['sha256']==value['sha256'],str(file)
    return result


def read(value): return json.loads(Path(identity(value)['file']).read_text())


def save(file,value):
    file.parent.mkdir(parents=True,exist_ok=True)
    with file.open('x') as stream: stream.write(json.dumps(value,indent=2)+'\n')


def export_block(text):
    begin=text.index('  const exports=[...roots];')
    end=text.index('  const snapshots=files.map(',begin)
    return text[begin:end]


p=argparse.ArgumentParser(description=__doc__)
s=p.add_subparsers(dest='mode',required=True)
ad=s.add_parser('admit');ad.add_argument('out',type=Path)
rf=s.add_parser('reference');rf.add_argument('admission',type=Path);rf.add_argument('attempt',type=Path);rf.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(RAW.resolve()) and not out.exists()
old=read(OLD_ATTEMPT);old_boot=read(old['bootstrapReport']);old_roots=old_boot['exports']
assert len(old_roots)==86 and len(set(old_roots))==86
historical=read(HISTORY)['roots']
assert [name for name in old_roots if name not in BASE_ADDED+OLD_ADDED]==historical
assert set(old_roots)==set(historical+BASE_ADDED+OLD_ADDED)
if a.mode=='admit':
    driver=PROJECT/'tools/typed-driver.mjs';driver_id=identity(driver)
    old_driver=Path(old['snapshot']['root'])/'tools/typed-driver.mjs'
    old_text,new_text=old_driver.read_text(),driver.read_text()
    old_block,new_block=export_block(old_text),export_block(new_text)
    admitted_lines=[]
    for module,names in GROUPS.items():
        expected=(f"  if(files.includes('{module}')&&fs.readFileSync(path.join(project,'{module}'),'utf8').includes('def {names[0]}('))exports.push("+
                  ','.join(repr(name) for name in names)+');\n')
        assert new_block.count(expected)==1,(module,'missing exact conditional source-backed export line')
        admitted_lines.append(expected)
    stripped=new_block
    for line in admitted_lines: stripped=stripped.replace(line,'')
    assert stripped==old_block,'Unexpected changes to historical bootstrap export construction'
    manifest=read(PROJECT/'src/compiler.json')
    source_rows=[]
    out.mkdir(parents=True)
    for module,names in GROUPS.items():
        assert module in manifest['modules']
        source=PROJECT/module;before=identity(source);text=source.read_text()
        for name in names:
            assert len(re.findall(r'^def '+re.escape(name)+r'\(',text,re.M))==1,name
        frozen=out/'sources'/module;frozen.parent.mkdir(parents=True,exist_ok=True)
        frozen.write_bytes(source.read_bytes());after=identity(frozen)
        assert before['sha256']==after['sha256'] and identity(source)==before
        source_rows.append(dict(original=before,frozen=after,exports=names))
    selected_driver=out/'typed-driver.mjs';selected_driver.write_bytes(driver.read_bytes())
    assert identity(selected_driver)['sha256']==driver_id['sha256'] and identity(driver)==driver_id
    (out/'driver-export.diff').write_text(''.join(difflib.unified_diff(old_block.splitlines(True),new_block.splitlines(True),fromfile='State08 exports',tofile='Phase63 exports')))
    (out/'driver-full.diff').write_text(''.join(difflib.unified_diff(old_text.splitlines(True),new_text.splitlines(True),fromfile=str(old_driver),tofile=str(driver))))
    admission=dict(kind='phase61-bootstrap-export-admission',version=1,driver=identity(selected_driver),
        addedRoots=OLD_ADDED+NEW,phase63AddedRoots=NEW,previousAttempt=identity(OLD_ATTEMPT),
        previousBootstrap=identity(old['bootstrapReport']),historical=identity(HISTORY),sourceDefinitions=source_rows,
        driverOriginal=driver_id,driverPrevious=identity(old_driver),manifest=identity(PROJECT/'src/compiler.json'),
        exportDiff=identity(out/'driver-export.diff'),fullDriverDiff=identity(out/'driver-full.diff'),
        producer=identity(__file__),scope='Source-backed proposal for eight supplementary exports; old86 order preserved. '
        'No checked API or semantic permission is established until actual checked attempt and API validation join.')
    save(out/'admission.json',admission)
    print(json.dumps(dict(admission=identity(out/'admission.json'),newRoots=NEW,expectedRoots=94)))
else:
    admission_id=identity(a.admission);admission=read(admission_id)
    assert admission['kind']=='phase61-bootstrap-export-admission' and admission['version']==1
    assert admission['phase63AddedRoots']==NEW and admission['addedRoots']==OLD_ADDED+NEW
    attempt_file=a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt_id=identity(attempt_file);attempt=read(attempt_id)
    assert attempt['kind']=='bend-development-attempt' and attempt['checked'] is True
    assert attempt['config']['strictExact'] is True
    for key in ['api','checkedApi','runtime','base','bootstrapReport']: identity(attempt[key])
    boot_id=identity(attempt['bootstrapReport']);boot=read(boot_id)
    assert boot['stage']=='upstream-bootstrap' and boot['provenance']['verifiedAfterBuild'] is True
    assert identity(boot['source'])['sha256']==boot['sourceSha256']
    assert boot['apiSha256']==identity(attempt['checkedApi'])['sha256']
    roots=boot['exports'];assert len(roots)==len(set(roots))==94
    assert [name for name in roots if name not in NEW]==old_roots
    assert set(roots)==set(old_roots+NEW)
    snapshot=Path(attempt['snapshot']['root'])
    assert identity(snapshot/'tools/typed-driver.mjs')['sha256']==identity(admission['driver'])['sha256']
    for row in admission['sourceDefinitions']:
        identity(row['frozen'])
        relative=Path(row['original']['file']).relative_to(PROJECT)
        assert identity(snapshot/relative)['sha256']==row['frozen']['sha256']
    out.mkdir(parents=True)
    reference=dict(kind='phase61-checked-bootstrap-export-reference',roots=roots,bootstrap=boot_id,
        attempt=attempt_id,historical=identity(HISTORY),addedRoots=sorted(BASE_ADDED+OLD_ADDED+NEW),
        admission=admission_id,baseAddedRoots=sorted(BASE_ADDED),phase63AddedRoots=NEW,
        previousBootstrap=identity(old['bootstrapReport']),producer=identity(__file__),
        scope='Genuine checked bootstrap export/source join; exact API function validation is a separate root-only command.')
    save(out/'roots-reference.json',reference)
    node=attempt['node']['file'];validator=Path(__file__).with_name('validate-exports.mjs')
    command=['python3',str(PROJECT/'tools/performance/phase32/bounded-run.py'),'--seconds','60',
        '--rss-mib','2048','--available-mib','4096',str(out/'api-validation-supervisor'),'--','taskset','-c','3',node,
        '--stack-size=4096','--max-old-space-size=1024',str(validator),str(out/'roots-reference.json'),str(out/'api-validation.json')]
    save(out/'api-validation-recipe.json',dict(dataOnly=True,targetExecuted=False,
        reference=identity(out/'roots-reference.json'),validator=identity(validator),command=command))
    (out/'commands.txt').write_text(shlex.join(command)+'\n')
    print(json.dumps(dict(reference=identity(out/'roots-reference.json'),command=command)))
