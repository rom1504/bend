#!/usr/bin/env python3
"""Exact retained JS observation overlay and replay plans; no targets/acquisition."""
import argparse, hashlib, json, re, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json,fresh_output
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
out=fresh_output(a.out,ROOT)
receipt_path=ROOT/'selfhost/build/phase152/composite-api01/report.json'
receipt=json.loads(receipt_path.read_text());require(receipt['complete'] and receipt['checked'],'Checked parent required')
verify(receipt['api']); text=Path(receipt['api']['file']).read_text()
require(receipt['api']['sha256']=='b5bda080852437823a6d7391c09bef8b467694f388daa5a18627ad480f9e50df','Wrong API generation')
marks=['p112s_prepare','p144o_prepared','p111_compile_defs','p140or_finish','nq_signatures',
 'p113pl_candidates','p128raw_plan_finish','p126sc_candidates','p113d_passes','p128raw_session_finish',
 'p114s_open','p114s_inline','p134v_commit','p146c_verify','p128raw_verified','p134e_begin','p134e_prepare',
 'p134e_registered','p134e_next','nr_compile_prepared','ns_prepare','nf_plan_scoped','nc_compile_defs',
 'nc_finish','nf_finish_plan','nc_with_show','ne_program_runtime']
calls=['p113pl_flat_candidate','p113pl_boxed_candidate','p121f_selected','p113d_pass_one',
 'p113k_function','p113k_stmt','p113k_get','p113k_put','p111v_stmt','p147v_stmt','p147d_stmt',
 'p112c_candidate','p112c_passes','p134e_private','p134e_legacy','p134e_public',
 'nc_uses','nc_live_env','nc_compact_definition','nc_compact']
rows={'p111_compile_defs':'_names_0','p113pl_candidates':'_names_0','p113d_pass':'_candidates_0',
      'p112c_candidates':'_segments_0','nc_compile_defs':'_todo_0'}
starts=list(re.finditer(r'^function ([^ (]+)\([^\n]*\) \{',text,re.M))
functions={m.group(1):(m,starts[i+1].start() if i+1<len(starts) else len(text)) for i,m in enumerate(starts)}
edits=[];sites=[]
for name in sorted(set(marks+calls+list(rows))):
    m,end=functions['$'+name+'$']; body=text[m.start():end]
    code=''
    if name in marks: code+='\n  __p166_mark('+json.dumps(name)+');'
    if name in calls: code+='\n  __p166_count('+json.dumps('call:'+name)+');'
    if name in rows:
        arg=rows[name]
        require(('if ('+arg+'.$ === "Nil")') in body,'Unexpected list dispatch '+name)
        require(not body[len(m.group(0)):].lstrip().startswith('for (;;)'),'Row hook needs loop handling '+name)
        code+='\n  if ('+arg+'.$ !== "Nil") __p166_count('+json.dumps('row:'+name)+');'
    edits.append((m.end(),m.end(),code+'\n'))
    sites.append(dict(name=name,start=m.start(),end=end,sha256=hashlib.sha256(body.encode()).hexdigest(),
                      signature=m.group(0),insertion=code,unit='JS function entry; explicit row labels exclude Nil'))

# Token scan skips quoted strings and comments. The one runtime regexp literal
# has no target tokens and is skipped explicitly. Refuse a template literal;
# the retained source contains backtick CHAR strings, not JS templates.
i=0;tags={};tag_sites=0
while i<len(text):
    c=text[i]
    if text.startswith('//',i):
        j=text.find('\n',i);i=len(text) if j<0 else j+1;continue
    if text.startswith('/*',i):
        j=text.find('*/',i+2);require(j>=0,'Unclosed comment');i=j+2;continue
    if text.startswith('/inf\\w*/i',i):i+=len('/inf\\w*/i');continue
    require(c!='`','Unexpected JS template syntax')
    if c in ['"',"'"]:
        quote=c;i+=1
        while i<len(text):
            if text[i]=='\\':i+=2
            elif text[i]==quote:i+=1;break
            else:i+=1
        continue
    if text.startswith('$:',i):
        m=re.match(r'\$:\s*("(?:\\.|[^"\\])*")',text[i:])
        if m:
            j=i-1
            while j>=0 and text[j].isspace():j-=1
            before=text[j:j+1]
            require(before in ['{',','],'Not a literal object property')
            literal=m.group(1);tag=json.loads(literal);begin=i+m.start(1);end=i+m.end(1)
            edits.append((begin,end,'(__p166_object('+literal+'), '+literal+')'))
            tags[tag]=tags.get(tag,0)+1;tag_sites+=1;i=end;continue
    i+=1
require(tag_sites>10000,'Unexpected constructor-site coverage')
pieces=[];cursor=0
for begin,end,after in sorted(edits):
    require(begin>=cursor,'Overlapping observation edits')
    pieces.extend([text[cursor:begin],after]);cursor=end
pieces.append(text[cursor:]);text=''.join(pieces)
observer=ROOT/'experiments/phase166/observer.mjs'
instrumented=out/'instrumented-api.mjs';instrumented.write_text(observer.read_text()+'\n'+text)

# Keep the complete replay and exact output gates. Load the instrumented copy
# separately from the authentic checked-source receipt; never forge that receipt.
runner_source=ROOT/'experiments/phase165/tools/backend-replay-v2.mjs'
runner=runner_source.read_text()
old="const api = (await import(pathToFileURL(plan.api.file))).default;"
require(runner.count(old)==1,'Replay import changed')
runner=runner.replace(old,"verify(plan.instrumentedApi);\n  const instrumentedModule = await import(pathToFileURL(plan.instrumentedApi.file));\n  const api = instrumentedModule.default;")
runner=runner.replace("root + '/selfhost/build/phase165/'","root + '/selfhost/build/phase166/'")
runner=runner.replace("const begin=performance.now();", "instrumentedModule.p166_begin(role);\n    const begin=performance.now();")
runner=runner.replace("const seconds=elapsed(begin);", "const seconds=elapsed(begin);\n    (report.census ??= {})[role]=instrumentedModule.p166_end();")
runner=runner.replace("acquisitionSeconds:0,", "acquisitionSeconds:0, diagnosticInstrumentation:true, instrumentedApi:plan.instrumentedApi,")
runner_file=out/'census-replay.mjs';runner_file.write_text(runner)
# Relative imports must retain their original meaning after the artifact move.
runner=runner.replace("'../../phase147/tools/support.mjs'",json.dumps(str(ROOT/'experiments/phase147/tools/support.mjs')))
runner_file.write_text(runner)
inputs=[pin(__file__),pin(observer),pin(runner_source),pin(receipt_path),receipt['api'],pin(instrumented),pin(runner_file)]
manifest=dict(complete=True,targetsRun=False,acquisitionRequired=False,inputs=inputs,sites=sites,
              literalTagSites=tag_sites,staticSiteCountsByTag=tags,
              scope='Diagnostic generated-JS observer; exact untouched checked Bend source. Dynamic constructor-site events are not native allocator events. Counts enabled only during complete backend roles.')
write_json(out/'manifest.json',manifest)
jobs=[]
for name,prior_name in [('map','backend-plan05'),('verifier','backend-plan06')]:
    prior_path=ROOT/'selfhost/build/phase165'/prior_name/'plan.json'
    plan=json.loads(prior_path.read_text())
    # This role never reads/captures a request graph. Phase165 retention may
    # have archived that historical artifact; retain its descriptor through
    # the pinned prior plan without requiring a duplicate/restoration.
    plan['historicalGraphNotRead']=plan['previousRequest']
    plan['inputs']=[v for v in plan['inputs'] if v['file']!=plan['previousRequest']['file']]
    plan['instrumentedApi']=pin(instrumented)
    plan['inputs'] += inputs+[pin(prior_path),pin(out/'manifest.json')]
    for value in plan['inputs']:verify(value)
    plan_file=out/(name+'-plan.json');write_json(plan_file,plan)
    prior_jobs=json.loads((prior_path.parent/'jobs.json').read_text())
    command=prior_jobs[0]['command'];dest=out/(name+'-replay')
    command[command.index('--out')+1]=str(out/(name+'-guard'))
    command[command.index('--run-root')+1]=str(dest)
    command[command.index('--disk-mib')+1]='24'
    command[-3:]=[str(runner_file),str(plan_file),str(dest)]
    # Actual retained products are under4MiB total; keep the explicit16MiB
    # per-product cap but whole-job budget may stop a larger unexpected output.
    jobs.append(dict(name=name,command=command))
write_json(out/'jobs.json',jobs)
print(json.dumps(dict(out=str(out),instrumentedBytes=pin(instrumented)['bytes'],sites=len(sites),tagSites=tag_sites,targetsRun=False)))
