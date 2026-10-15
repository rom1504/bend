#!/usr/bin/env python3
"""Compare accepted complete B1/B2 captures and exact generated-C mechanisms offline."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT / 'selfhost/build/phase98'
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def symbol(name, prefix='WL_FID_'):
    return prefix + ''.join(str(ord(c)) + '_' for c in name)


def decoded(name):
    m = re.fullmatch(r'(NF|WL)_FID_((?:\d+_)+)', name)
    return m[1]+':'+''.join(chr(int(c)) for c in m[2].rstrip('_').split('_')) if m else name


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); assert not args.out.exists()
    inputs = []; stages = {}; cs = {}; images = {}; preps = {}; requests = {}; spans = []
    for stage in ['b1', 'b2']:
        wpath = BUILD / ('ownership-origin-'+stage+'-self01/windows.json')
        w = json.loads(wpath.read_text()); inputs.append(pin(wpath))
        assert all(w[k] for k in ['complete', 'targetComplete', 'fullCExact', 'diagnosticExact', 'zeroLoss'])
        for k in ['preparation', 'binding', 'analysis', 'method', 'process', 'samples', 'output']:
            assert pin(w[k]['file']) == w[k]
            inputs.append(w[k])
        prep = json.loads(Path(w['preparation']['file']).read_text()); preps[stage] = prep
        for item in prep['inputs']: assert pin(item['file']) == item
        assert prep['periodUs'] == 16000 and prep['rssMiB'] == 2048 and prep['deadlineSeconds'] == 300
        assert prep['source']['sha256'] == '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
        cs[stage] = Path(prep['c']['file']).read_text(); images[stage] = Path(prep['image']['file'])
        inputs += [prep['source'], prep['c'], prep['image']]
        analysis = json.loads(Path(w['analysis']['file']).read_text())
        phase = next(x for x in analysis['phases'] if x['name'] == 'request-1'); requests[stage] = phase
        leaves = Counter({x['function']: x['samples'] for x in phase['leaf_functions']})
        owners = Counter()
        for row in phase['ownership_callers']: owners[row['physical_owner']] += row['samples']
        assert phase['samples'] == w['requestSamples'] == sum(leaves.values())
        assert phase['ownership_samples'] == phase['ownership_physical_owner_recovered'] == sum(owners.values())
        count = phase['samples']; cpu = phase['process_cpu_ms']/1000
        def rows(counter):
            return [dict(symbol=s,name=decoded(s),samples=n,percentRequest=100*n/count,estimatedCpuSeconds=n/count*cpu)
                    for s,n in counter.most_common()]
        stages[stage] = dict(image=prep['image'], generatedC=prep['c'], output=w['output'],
            request={k: phase[k] for k in ['wall_ms','process_cpu_ms','reported_ms','samples','ownership_samples','ownership_physical_owner_recovered']},
            coverage=w['coverage'], header=analysis['header'], leaves=rows(leaves), physicalOwnershipOwners=rows(owners),
            windows=[dict(startSeconds=x['startRequestWallSeconds'],endSeconds=x['endRequestWallSeconds'],samples=x['samples'],
                          topLeaves=[dict(name=decoded(r['function']),samples=r['samples'],percent=r['percent']) for r in x['leaves'][:8]]) for x in w['windows']])
    assert preps['b1']['source'] == preps['b2']['source']
    assert preps['b1']['oracle']['c']['sha256'] == preps['b2']['oracle']['c']['sha256']
    assert preps['b1']['oracle']['diagnostic']['sha256'] == preps['b2']['oracle']['diagnostic']['sha256']
    normalized = {}
    for stage in ['b1','b2']:
        argv = preps[stage]['commands']['capture']; argv = argv[argv.index(str(images[stage]))+1:]
        argv = [x for x in argv if x != 'phase90-native']
        output = str(Path(preps[stage]['captureDirectory'])/'program')
        normalized[stage] = ['<output>' if x == output else x for x in argv]
    assert normalized['b1'] == normalized['b2']

    def add_span(stage, name, kind):
        c = cs[stage]
        if kind == 'scheduler':
            label = 'FID_'+name if stage == 'b1' else symbol(name,'FID_')
            start = c.index('  WL_CASE('+label+')\n'); end = c.index('\n  WL_CASE(',start+1)
        else:
            label = name if stage == 'b1' else symbol(name,'NF_FID_')
            match = re.search(r'(?m)^(?:INLINE|NF_INLINE) Term '+label+r'\([^\n;]*\) \{',c)
            assert match, (stage,name); start=match.start(); pos=c.index('{',start); depth=0
            while pos<len(c):
                if c[pos]=='{': depth+=1
                elif c[pos]=='}':
                    depth-=1
                    if depth==0: end=pos+2; break
                pos+=1
            else: raise AssertionError(name)
        body=c[start:end]; data=body.encode()
        spans.append(dict(stage=stage,name=name,cSymbol=label,kind=kind,lineStart=c.count('\n',0,start)+1,
                          lineEnd=c.count('\n',0,end-1)+1,byteStart=len(c[:start].encode()),byteEnd=len(c[:end].encode()),
                          bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),text=body))
        return body
    b1spin = {i:add_span('b1','spin_'+str(i),'native') for i in range(1,8)}
    b2eq = add_span('b2','p88_string_eq','native')
    b2worker = add_span('b2','$observer.p88_string_eq_go','native')
    b2adapter = add_span('b2','$observer.adapter.p88_string_eq_go','native')
    b2tag = add_span('b2','p98_tag_eq_read','native')
    assert 'term_peek(e.mem' in b1spin[3] and 'u32 _same_0' in b1spin[3] and 'WL_AGAIN(spin_3)' in b1spin[3]
    assert all(x not in b1spin[3] for x in ['ctr_take(', 'term_sink(', 'term_keep(', 'heap_alloc('])
    assert all(x not in b1spin[5] for x in ['term_keep(', 'term_sink(', 'ctr_take('])
    assert 'spin_3(' in b1spin[5] and 'spin_6(' in b1spin[5]
    assert b1spin[6].count('term_sink(')==2
    assert 'term_peek(e.mem, _term_2)' in b1spin[2] and 'ctr_take(' not in b1spin[2]
    assert 'spin_3(e, _o_1, _f_0, _key_1, 1)' in b1spin[2]
    assert b2eq.count('term_keep(')==2 and b2adapter.count('term_sink(')==2
    assert 'ctr_take(' in b2tag and 'term_sink(' in b2tag
    assert 'term_peek(' in b2worker and 'term_sink(' not in b2worker
    sched = {}
    for stage,names in [('b1',['KC','NT_CHOOSE','STRING_APPEND','STRING_APPEND_K21896','HAS_NAME']),
                        ('b2',['$direct.kc','$direct.nt_choose','$direct.String.append','native_k_44186','$direct.has_name'])]:
        for name in names:sched[stage,name]=add_span(stage,name,'scheduler')
    assert 'STK(1) = FID_STRING_APPEND_K21896;' in sched['b1','STRING_APPEND']
    assert ('STK(1) = '+symbol('native_k_44186','FID_')+';') in sched['b2','$direct.String.append']
    assert 'spin_5(e,' in sched['b1','HAS_NAME']
    assert 'u32 _b_0' in sched['b1','KC'] and 'if (_b_0 == 1)' in sched['b1','KC']
    assert 'native_bool(' in sched['b2','$direct.kc']
    mappings=[('kc',['WL_FID_KC'],[symbol('$direct.kc')]),
              ('nt_choose',['WL_FID_NT_CHOOSE'],[symbol('$direct.nt_choose')]),
              ('String.append and its exact SCON reconstruction continuation',['WL_FID_STRING_APPEND','WL_FID_STRING_APPEND_K21896'],[symbol('$direct.String.append'),symbol('native_k_44186')]),
              ('has_name physical owner, including backend-specific inlining',['WL_FID_HAS_NAME'],[symbol('$direct.has_name')]),
              ('nb_contains physical owner, including backend-specific inlining',['WL_FID_NB_CONTAINS'],[symbol('$direct.nb_contains')]),
              ('index_find physical owner, including backend-specific inlining',['WL_FID_INDEX_FIND'],[symbol('$direct.index_find')]),
              ('generic closure application',['WL_FID_CLO_APPLY'],['WL_BEND_CLO_APPLY'])]
    buckets=[]
    for label,left,right in mappings:
        row=dict(name=label)
        for stage,syms in [('b1',left),('b2',right)]:
            leaves={r['symbol']:r['samples'] for r in stages[stage]['leaves']}; owners={r['symbol']:r['samples'] for r in stages[stage]['physicalOwnershipOwners']}
            n=sum(leaves.get(s,0) for s in syms); o=sum(owners.get(s,0) for s in syms); req=requests[stage]
            row[stage]=dict(symbols=syms,leafSamples=n,ownershipSamples=o,totalSamples=n+o,
                            percentRequest=100*(n+o)/req['samples'],estimatedCpuSeconds=(n+o)/req['samples']*req['process_cpu_ms']/1000)
        row['estimatedCpuSecondsB2MinusB1']=row['b2']['estimatedCpuSeconds']-row['b1']['estimatedCpuSeconds']; buckets.append(row)
    runtime=[]
    for helper in ['term_drop','span_fade','rfc_wrap']:
        row=dict(helper=helper)
        for stage in ['b1','b2']:row[stage]=next(x for x in stages[stage]['leaves'] if x['symbol']==helper)
        row['estimatedCpuSecondsB2MinusB1']=row['b2']['estimatedCpuSeconds']-row['b1']['estimatedCpuSeconds'];runtime.append(row)
    args.out.mkdir(parents=True)
    assembly=[]
    for stage,names in [('b1',['WL_FID_KC','WL_FID_STRING_APPEND','WL_FID_STRING_APPEND_K21896','spin_1']),
                        ('b2',[symbol('$direct.kc'),symbol('$direct.String.append'),symbol('native_k_44186')])]:
        table={}
        for line in subprocess.check_output(['nm','-n','-S','--defined-only',str(images[stage])],text=True).splitlines():
            a=line.split()
            if len(a)==4:table[a[3]]=(int(a[0],16),int(a[1],16))
        for index,name in enumerate(names):
            start,size=table[name]; command=['objdump','-d','--no-show-raw-insn','--start-address='+hex(start),'--stop-address='+hex(start+size),str(images[stage])]
            path=args.out/(stage+'-'+str(index)+'.asm');path.write_text(subprocess.check_output(command,text=True))
            assembly.append(dict(stage=stage,symbol=name,start=hex(start),bytes=size,command=command,output=pin(path)))
    report=dict(kind='phase98-matched-complete-origin-stage-profile-comparison',complete=True,targetsRun=False,
        method=pin(__file__),inputs=list({x['file']:x for x in inputs}.values()),normalizedTargetArguments=normalized['b1'],
        stages=stages,runtimeHelpers=runtime,selectedPhysicalBuckets=buckets,cSpans=spans,assembly=assembly,
        staticMappings=[
            'B1 spin_3 structurally corresponds to the source String walker; spin_5 calls it and spin_6 disposal. Source argument names, constructor cases, recursion and has_name caller provide the explicit correspondence; no surviving ELF p88 symbol is presumed.',
            'B1 spin_2 structurally corresponds to tag read; its KTerm branch borrows the tag and calls spin_3. spin_1 calls spin_2 then spin_7 final disposal.',
            'B1 String.append schedules STRING_APPEND_K21896; B2 $direct.String.append schedules native_k_44186. Both mapped continuations construct SCON.'],
        limitations=[
            'Two successful full requests with identical source and exact C/diagnostic output; one capture per image, no randomized repeat or causal isolation.',
            'Percentages and CPU-second estimates are sampled attribution, not allocation counts or confidence intervals. CPU-second estimates multiply each request CPU time by its sample fraction.',
            'Physical owner buckets include inlined work and differ across backends. Inlined spin_3/spin_5 do not have a whole-profile B1 equality bucket comparable to B2 symbol totals.',
            'Runtime-helper table overlaps ownership assigned to selected physical owners. Do not sum those tables.',
            'Thirty-second windows are wall intervals rather than aligned compiler stages.',
            'Static contract/code differences support hypotheses; they do not assign a precise causal share of the total stage gap.',
            'No earlier partial/watchdog capture is used. No target was run by this comparison method.'])
    out=args.out/'report.json';out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,report=pin(out),samples={k:v['request']['samples'] for k,v in stages.items()})))


if __name__=='__main__':main()
