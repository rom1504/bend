#!/usr/bin/env python3
"""Read completed receipts and inspect machine code; never execute a target."""
import collections
import hashlib
import json
import math
import re
import statistics
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
SYMBOL='p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_'


def pin(p):
    p=Path(p).resolve();data=p.read_bytes()
    return {'file':str(p),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}


def main():
    out=ROOT/'selfhost/build/phase144/predicate-machine-audit01'
    assert not out.exists();out.mkdir(parents=True)
    timing=ROOT/'selfhost/build/phase144/predicate-proxy-timing01/report.json'
    t=json.loads(timing.read_text());assert t['complete']
    summary=[]
    for size in (64,256):
        rows=[r for r in t['rows']if r['size']==size];assert len(rows)==5
        values={mode:[next(c['elapsedMilliseconds']for c in row['calls']if c['mode']==mode)for row in rows]
                for mode in ('original','positive')}
        summary.append({'size':size,'samplesMilliseconds':values,
          'medianMilliseconds':{m:statistics.median(v)for m,v in values.items()},
          'medianPairedRatio':statistics.median(r['ratio']for r in rows),
          'geometricPairedRatio':math.exp(statistics.mean(math.log(r['ratio'])for r in rows)),
          'minimumMilliseconds':min(v for xs in values.values()for v in xs)})
    machines=[]
    for mode in ('original','positive'):
        folder=ROOT/f'selfhost/build/phase134/p144-predicate-{mode}-native01'
        source=folder/'program.ssa';binary=folder/'program';text=source.read_text()
        matches=list(re.finditer(r'^export function [^\n]*\$'+SYMBOL+r'\([^\n]*\{\n.*?^\}',text,re.M|re.S))
        assert len(matches)==1;body=matches[0][0]+'\n'
        qbe=out/(mode+'.ssa');qbe.write_text(body)
        command=['objdump','-d','--no-show-raw-insn','--disassemble='+SYMBOL,str(binary)]
        asm=subprocess.check_output(command,text=True)
        assembly=out/(mode+'.asm');assembly.write_text(asm)
        instructions=[s for s in asm.splitlines()if re.match(r'^\s+[0-9a-f]+:\s',s)]
        calls=[s.strip()for s in instructions if re.search(r'\bcallq?\b',s)]
        frame=[s for s in body.splitlines()if re.search(r'_next_sp =l add .*_sp, 64$',s)]
        boolcall=[s for s in calls if '66_111_111_108_46_110_111_116_'in s]
        returns=[s for s in calls if '<p111_rt_return>'in s]
        if mode=='original':assert len(frame)==len(boolcall)==len(returns)==1
        else:assert not frame and not boolcall and not returns
        machines.append({'mode':mode,'source':pin(source),'binary':pin(binary),'report':pin(folder/'report.json'),
          'qbeExtract':pin(qbe),'assemblyExtract':pin(assembly),'objdumpCommand':command,
          'qbeEntryLines':len(body.splitlines()),'entryMachineInstructions':len(instructions),
          'continuation64BytePush':frame,'boolNotMachineCall':boolcall,'returnMachineCall':returns,
          'wholeQbeFunctions':len(re.findall(r'^(?:export )?function ',text,re.M))})
    candidates=ROOT/'selfhost/build/phase144/predicate-canonical-source01/manifest.json'
    c=json.loads(candidates.read_text());owners={x['owner']for x in c['accepted']}
    profile=ROOT/'selfhost/build/phase144/profile01/attribution/report.json'
    p=json.loads(profile.read_text());counts=collections.Counter()
    for row in p['dispatchContexts']:
        if row['loweredOwner']in owners:counts[row['loweredOwner']]+=row['samples']
    report={'kind':'phase144-predicate-proxy-machine-audit','complete':True,'compilerTargetsRun':False,
      'inputs':[pin(__file__),pin(timing),pin(candidates),pin(profile)],'timings':summary,'machine':machines,
      'sourceCanonicalization':{'conditions':len(c['accepted']),'owners':len(owners),
        'refused':dict(collections.Counter(x['reason']for x in c['rejected'])),
        'oldProfileWholeOwnerSamples':sum(counts.values()),'oldProfileSamples':10083,
        'oldProfileWholeOwnerFraction':sum(counts.values())/10083,
        'oldProfileWholeOwnerRows':[{'owner':k,'samples':v}for k,v in counts.most_common()]},
      'limits':['Proxy construction/update/query workload uses256actual names; two tested sizes are one family, not unrelated transfer.',
        'IO.now timer is milliseconds; whole child-wall observations are coarsened by process-poll scheduling and are not the runtime claim.',
        'Entry instruction count increases because its continuation is local; machine benefit is a removed scheduler boundary, not fewer total entry instructions.',
        'Profile is Phase143 qualified residual, not fresh integrated candidate. Whole owner samples are exposure, not predicate-exclusive time or a speedup prediction.',
        'Broad source rewrite is unselected and unqualified; proof/protected/attached-law owners stay unchanged.']}
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'complete':True,'timings':summary,'wholeOwnerSamples':sum(counts.values()),'machine':[{k:r[k]for k in ('mode','qbeEntryLines','entryMachineInstructions','wholeQbeFunctions')}for r in machines]}))


if __name__=='__main__':main()
