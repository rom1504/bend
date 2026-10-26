"""Prepare an extra-export checked API job for unchanged final04 source; no targets."""
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]

def pin(path):
    path=Path(path).resolve(); h=hashlib.sha256(); size=0
    with path.open('rb') as stream:
        while data:=stream.read(1024*1024): h.update(data); size+=len(data)
    return dict(file=str(path),bytes=size,sha256=h.hexdigest())

def main():
    prior_path=ROOT/'selfhost/build/phase111/p144-integrated-api04/report.json'
    prior=json.loads(prior_path.read_text());assert prior['complete'] and prior['checked'] and prior['status']==0
    source=ROOT/'selfhost/build/phase144/final04-source01/compiler.bend'
    identity=pin(source);assert identity['sha256']=='865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed'
    assert identity in prior['inputs'] and prior['command'][2:4]==[str(source),prior['api']['file']]
    extra=['f_source_end','p140s_empty','p140s_named','p140g_prepare','p140r_begin_cursor','p140r_next']
    exports=prior['exports']+extra;assert len(exports)==len(set(exports))
    out=ROOT/'selfhost/build/phase144/final04-session-api-plan01'
    api=ROOT/'selfhost/build/phase111/p144-final04-session-api01'
    guard_out=ROOT/'selfhost/build/phase144/final04-session-api01-guard'
    assert not out.exists() and not api.exists() and not guard_out.exists()
    checker=ROOT/'selfhost/tools/performance/phase111/check-api.py'
    guard=checker.with_name('guard.py')
    inner=['/usr/bin/python3','-B',str(checker),'--source',str(source),'--out',str(api),*exports]
    command=['/usr/bin/python3','-B',str(guard),'--out',str(guard_out),'--seconds','120','--rss-mib','3072','--available-mib','16384','--file-mib','128','--cpu','3','--',*inner]
    inputs=[pin(__file__),pin(prior_path),prior['api'],*prior['inputs'],pin(checker),pin(guard)]
    for row in inputs:assert pin(row['file'])==row,row['file']
    out.mkdir()
    plan=dict(kind='phase144-final04-additional-api-exports',complete=True,targetsRun=False,checked=False,
        source=identity,originalCheckedApi=pin(prior_path),originalApi=prior['api'],
        originalExports=prior['exports'],additionalExports=extra,exports=exports,
        sourceSameAsOriginalApi=True,originalApiNotReplaced=True,inputs=inputs,
        report=str(api/'report.json'),guardReport=str(guard_out/'process.json'),command=inner,
        scope='New checked API artifact over byte-identical final04 source. Extra exports expose existing session/registry/cursor methods only. Does not replace qualification plan API04 identity, modify compiler declarations, or establish an execution result.')
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out/'plan.json'),jobs=[dict(name='extra-export-checked-api',command=command,report=plan['report'],guardReport=plan['guardReport'])]),indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out/'plan.json'),jobs=pin(out/'jobs.json'))))
if __name__=='__main__':main()
