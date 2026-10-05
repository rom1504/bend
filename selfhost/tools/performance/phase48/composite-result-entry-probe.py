#!/usr/bin/env python3
"""Produce a counter-only derivative of a checked composite-result module.
Usage: composite-result-entry-probe.py MODULE NEW_OUT ENTRY [ENTRY...]
Root runs generated runner.mjs MODULE_POINT_JSON NEW_REPORT_JSON. No timing.
"""
import hashlib
import json
import sys
from pathlib import Path

def identity(p):
    p=Path(p).resolve(strict=True);b=p.read_bytes()
    return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
module,out,*entries=map(str,sys.argv[1:]);assert entries
p=Path(module).resolve(strict=True);inputs=[identity(__file__),identity(p),identity(str(p)+'.json')]
r=json.loads(Path(str(p)+'.json').read_text())
assert r['complete'] and r['observation']['checked'] and r['observation']['status']=='ok'
assert r['output']['sha256']==inputs[1]['sha256']
text=p.read_text();assert '$p48CompositeEntryCounters' not in text
lines=text.splitlines(keepends=True);marker='/* private composite array result */'
for name in entries:
    prefix='G['+json.dumps(name,separators=(',',':'))+']='
    indexes=[i for i,l in enumerate(lines) if l.startswith(prefix)];assert len(indexes)==1
    i=indexes[0];line=lines[i];assert line.count(marker)==1,name+' lacks selected composite result branch'
    key=json.dumps(name)
    line=line.replace(marker,marker+'++$p48CompositeEntryCounters['+key+'].fast;',1)
    # The adapter's successful return is immediately followed by old generic body.
    end=line.index(',$arrayResult);}',line.index(marker))+len(',$arrayResult);}')
    line=line[:end]+'++$p48CompositeEntryCounters['+key+'].fallback;'+line[end:]
    lines[i]=line
out=Path(out).resolve();out.mkdir(parents=True,exist_ok=False)
counts={n:dict(fast=0,fallback=0) for n in entries}
derivative='let $p48CompositeEntryCounters='+json.dumps(counts,separators=(',',':'))+';\n'+''.join(lines)
derivative+='\nexport const phase48CompositeEntries=()=>JSON.parse(JSON.stringify($p48CompositeEntryCounters));\n'
q=out/'instrumented.mjs';q.write_text(derivative)
runner=out/'runner.mjs';runner.write_text('''// Counter derivative only: never use its time as a performance sample.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import program,{phase48CompositeEntries} from './instrumented.mjs';
const [pointFile,reportFile]=process.argv.slice(2);
const point=JSON.parse(fs.readFileSync(pointFile,'utf8'));
const before=phase48CompositeEntries();
const value=program[point.exportName??'bench'](...point.args);
const after=phase48CompositeEntries();
assert.deepEqual(value,point.expected);
for(const name of point.requiredFastEntries??Object.keys(after)){
 assert.equal(after[name].fast-before[name].fast,1,name+' fast activation');
 assert.equal(after[name].fallback-before[name].fallback,0,name+' must not fallback');
}
fs.writeFileSync(reportFile,JSON.stringify({complete:true,passed:true,diagnosticOnly:true,timingEligible:false,value,before,after},null,2)+'\\n',{flag:'wx'});
''')
for row in inputs:assert identity(row['path'])==row
manifest=dict(complete=True,diagnosticOnly=True,timingEligible=False,productionSafe=False,entries=entries,inputs=inputs,module=identity(q),runner=identity(runner),scope='Counter stores only; altered allocation/source footprint, no timing or host-introspection claim.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(dict(complete=True,executed=False,output=str(out))))
