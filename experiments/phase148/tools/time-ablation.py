#!/usr/bin/env python3
"""Diagnostic full/analysis/transport ablations in one runtime-selected binary."""
import argparse,json,statistics,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import fresh_output,pin,require,run,verify,write_json,same_bytes

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--pairs',type=int,default=4);p.add_argument('--budget-seconds',type=float,default=60)
    a=p.parse_args();require(2<=a.pairs<=8,'Bounded paired policy required')
    plan=json.loads(a.manifest.read_text());require(plan['kind']=='phase148-native-unit-preparation'and plan['complete'],'Prepared harness required')
    checked_file=Path(plan['harnessCheckReport']);checked=json.loads(checked_file.read_text())
    require(checked['kind']=='bend-checked-hosted-api'and checked['complete']and checked['checked']and checked['source']==plan['source']and checked['exports']==['p148h_text'],'Independent complete harness source check required')
    build_file=Path(plan['buildReport']);build=json.loads(build_file.read_text())
    require(build['complete']and not build.get('changedInputs')and not build.get('error'),'Successful native build required')
    require(build['request']['source']==plan['source'],'Native source binding differs')
    binary=pin(plan['binary']);require(binary==build['binary'],'Actual executable differs')
    inputs=[pin(__file__),pin(ROOT/'selfhost/tools/build/common.py'),pin(a.manifest),pin(build_file),pin(checked_file),binary,plan['source'],plan['oracle'],*plan['inputs'],*build['inputs'],*checked['inputs']]
    for row in inputs:verify(row)
    out=fresh_output(a.out,ROOT);started=time.monotonic()
    result=dict(kind='phase148-native-unit-ablation',version=1,complete=False,passed=False,performanceQualified=False,
       inputs=inputs,family=plan['family'],functions=plan['functions'],calls=[],pairs=[],
       contextLifetime=plan['contextLifetime'],region=plan['region'],
       scope='Diagnostic ablation only, separate from the frozen full-pipeline result. Analysis modes skip rendering only and still optimize, admit, independently verify, write an empty string and clean up. Transport adds fresh pack/unpack before the entire old pipeline. Whole-child costs include fixed preparation and final cleanup. No subtracted stage attribution or whole-compiler speed claim.')
    def save():write_json(out/'report.json',result)
    save()
    def invoke(mode,output,count,kind):
        require(time.monotonic()-started<a.budget_seconds,'Whole timing soft budget exceeded')
        folder=out/str(len(result['calls']));folder.mkdir()
        process=run([binary['file'],'--threads','1','--gpu','off','--','compact-unit',mode,output,str(count)],cwd=ROOT,
                    stdout=folder/'stdout',stderr=folder/'stderr',seconds=12)
        row=dict(index=len(result['calls']),mode=mode,output=output,repeats=count,kind=kind,process=process,passed=False)
        result['calls'].append(row);save()
        require(process['complete']and process['exitCode']==0 and (folder/'stderr').stat().st_size==0,'Child process/diagnostic failed')
        if output=='oracle':require(same_bytes(folder/'stdout',plan['oracle']['file']),'Complete rendered native output differs')
        else:require((folder/'stdout').stat().st_size==0,'Timed child emitted unexpected stdout')
        row['passed']=True;save();return row
    modes=['old','new','transport','old-analysis','new-analysis']
    categories={'full':['old','new'],'analysis':['old-analysis','new-analysis'],'transport':['old','transport']}
    try:
        for mode in ['old','new','transport']:invoke(mode,'oracle',1,'before-full-output')
        startup=[invoke(mode,'bench',0,'zero-repeat')for mode in modes]
        target=max(.1,5*max(row['process']['seconds']for row in startup));result['minimumTimedSeconds']=target
        count=1
        while True:
            rows=[invoke(mode,'bench',count,'calibration')for mode in modes]
            if min(row['process']['seconds']for row in rows)>=target:break
            require(count<65536,'No sufficient runtime signal within repetition bound');count=min(count*4,65536)
        result['repeats']=count
        for pair in range(a.pairs):
            keys=list(categories);keys=keys[pair%3:]+keys[:pair%3]
            for category in keys:
                reference,candidate=categories[category];order=[reference,candidate]if pair%2==0 else[candidate,reference]
                rows={mode:invoke(mode,'bench',count,'timed')for mode in order}
                result['pairs'].append(dict(index=pair,category=category,order=order,calls={k:v['index']for k,v in rows.items()},
                    ratio=rows[candidate]['process']['seconds']/rows[reference]['process']['seconds']));save()
        for mode in ['transport','new','old']:invoke(mode,'oracle',1,'after-full-output')
        result['categories']={}
        for category,(reference,candidate)in categories.items():
            pairs=[row for row in result['pairs']if row['category']==category]
            medians={mode:statistics.median(result['calls'][row['calls'][mode]]['process']['seconds']for row in pairs)for mode in [reference,candidate]}
            result['categories'][category]=dict(reference=reference,candidate=candidate,medianSeconds=medians,ratio=medians[candidate]/medians[reference])
        timed=[r for r in result['calls']if r['kind']=='timed']
        result['performanceQualified']=min(r['process']['seconds']for r in timed)>=.8*target
        for row in inputs:verify(row)
        result['complete']=result['passed']=True
    except BaseException as error:result['error']=repr(error);raise
    finally:result['totalSeconds']=time.monotonic()-started;save()
    print(json.dumps({k:result[k]for k in ['complete','passed','performanceQualified','family','repeats','categories','totalSeconds']}))

if __name__=='__main__':main()
