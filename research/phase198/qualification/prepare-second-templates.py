#!/usr/bin/env python3
"""Freeze parameterized argv using existing native and runtime tools only."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]; BUILD=ROOT/'selfhost/build/phase198'
names=['native-image01','native-self01','native-reproduction01','native45-01','native45-02','native-generations-compare01','native64-01','runtime10-01']
source=str(BUILD/'selected-source01/compiler.bend')
commands={}
for name in names:
    argv=json.loads((BUILD/(name+'-argv.json')).read_text())
    for i,s in enumerate(argv):
        if s==source:argv[i]='{{source}}';continue
        for n in names:
            if s==n:s='{{prefix}}-'+n
            s=s.replace('selfhost/build/phase198/'+n,'selfhost/build/phase198/{{prefix}}-'+n)
        argv[i]=s
    commands[name]=argv
commands['source-check01']=['python3','-B','research/phase198/qualification/job.py','--rss-mib','3072','{{prefix}}-source-check01','45','32','selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs','--source','{{source}}','--out','selfhost/build/phase198/{{prefix}}-source-check01','--manifest','{{manifest}}','--upstream','selfhost/.bootstrap/upstream-phase182']
merge=json.loads((BUILD/'broad-runtime-prepare-argv01.json').read_text())
cases=merge[merge.index('--cases')+1]
commands['broad-runtime-prepare01']=['python3','-B','selfhost/build/phase195/runtime-calibration.py','merge',
 '--role','c','selfhost/build/phase195/references01/manifest.json','c',
 '--role','phase195','selfhost/build/phase195/native45-01/programs.manifest.json','candidate',
 '--role','phase197','selfhost/build/phase198/native45-01/programs.manifest.json','candidate',
 '--role','candidate','selfhost/build/phase198/{{prefix}}-native45-01/programs.manifest.json','candidate',
 '--reference','c','--cases',cases,'--out','selfhost/build/phase198/{{prefix}}-broad-runtime-plan01']
commands['broad-runtime01']=['python3','-B','research/phase198/qualification/job.py','{{prefix}}-broad-runtime01','800','160','python3','-B','selfhost/build/phase195/runtime-calibration.py','run','--manifest','selfhost/build/phase198/{{prefix}}-broad-runtime-plan01/manifest.json','--out','selfhost/build/phase198/{{prefix}}-broad-runtime01','--rounds','4','--target-ms','250','--cpu','3','--seconds','750','--guarded']
commands['early8-build01']=list(commands['native45-01'])
e=commands['early8-build01'];e[:]=[s.replace('{{prefix}}-native45-01','{{prefix}}-early8-build01') for s in e];e[e.index('--cases')+1]='editdist,coverage-bst-64,tree-bitonic,mandelbrot,local-fold,variation-local-fold-128-0,symreg,raytrace'
i=e.index('{{prefix}}-early8-build01');e[i+1:i+3]=['120','64'];e[e.index('--seconds')+1]='90'
result=dict(kind='phase198-second-native-chain-argv-templates',complete=True,parameterized=True,targetsRun=False,parameters={'source':'Absolute frozen full compiler source path','manifest':'Absolute isolated maintained compiler.json path','prefix':'Fresh simple run prefix; proposed composed','audit':'Complete composition/source audit with selectedSource pin','label':'Human description only; four measured roles stay c/phase195/phase197/candidate'},commands=commands,defaultReference='c',order=['source-check01','native-image01','native45-01','broad-runtime-prepare01','broad-runtime01','native-self01','native-reproduction01','native45-02','native64-01','runtime10-01','native-generations-compare01'],optionalEarlyGate='early8-build01 checks independent outputs on eight distinct workloads before the full45 build; optional only. It never replaces native45 or broad runtime.',costCaps=['Stop on source/checking/independent-output failure before timing.','Keep N2/N3 after the broad runtime assessment; do not pay reproduction for a clearly unsuccessful candidate.','Retain every broad case and dispersion flag; repeat suspicious regressions separately before interpreting them.','The eight-case gate can cheaply reject correctness failures. A timing pre-screen is optional and must be separately frozen, not substituted for broad evidence.'],sourcePolicy='Freeze one source before N1. N2 and N3 must use that exact file, with N3 expected-object bound to N2. No installation change. Existing mature C and Phase195 products stay immutable; phase197 means the first Phase198 N1 compiled from the frozen Phase197 combo.')
out=Path(__file__).with_name('second-chain-templates.json');assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
