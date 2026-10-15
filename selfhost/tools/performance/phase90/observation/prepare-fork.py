#!/usr/bin/env python3
"""Offline exact-product controls and native source74 derivative. No target runs."""
import argparse, hashlib, importlib.util, json, re
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p90_shared', HERE/'prepare.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
ROOT=s.ROOT
SOURCE74='74b390d3ba7ada2c001dbdc6f63b0eb63b2231d129279114b1d5d55fa39d7052'

def blocks(text):
    starts=list(re.finditer(r'(?m)^(?:@unsafe\n)?(type|law|def)\s+([^\s(<:]+)', text))
    return [(m[1],m[2],text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)].rstrip()+'\n') for i,m in enumerate(starts)]

def native_eq(text):
    return re.sub(s.TOKEN, lambda m:'p88_string_eq' if m[0]=='String.eq' else m[0],text)

def main():
    p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);p.add_argument('--compiler',type=Path)
    p.add_argument('--scales',default='8,32',help='Two chain orders per size; larger values are explicitly a slow lane.')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    scales=[int(x) for x in a.scales.split(',') if x];assert all(1<=x<=1024 for x in scales)
    files=[ROOT/'selfhost/src/core/term.bend',ROOT/'selfhost/src/core/index.bend',ROOT/'selfhost/src/back/native/ir.bend',ROOT/'selfhost/src/back/native/text.bend',ROOT/'selfhost/tools/performance/phase90/tables/tables.bend',HERE/'fork-indexed.bend',ROOT/'selfhost/tools/performance/phase88/strings/helpers.bend']
    term,index,ir,text,tables,proposal,equality=[x.read_text() for x in files]
    termdefs={'kc','kt','atom','dn','dk','da','dx','dc','missing'}
    common=[b for b in blocks(term) if b[0]=='type' or b[1] in termdefs]+blocks(index.split('\n# A cached name miss')[0])+blocks(ir)
    common += [b for b in blocks(text) if b[1] in {'nt_choose','nt_count_go','nt_count','nt_text_finish','nt_bool'}]
    table_names={'nb_contains','nb_fork_roots_go','nb_fork_roots','nb_reaches','nb_fork_step','nb_fork_next','nb_fork_close','nb_flags_chunks','nb_flags_go','nb_flags'}
    oldblocks=[b for b in blocks(tables) if b[1] in table_names]
    def assembled(extra):
        parts=common+extra
        return 'import Base\n\n'+equality.split('\ndef p88_string_order_go')[0]+'\n'+ '\n'.join(native_eq(t) for kind in ('type','law','def') for k,n,t in parts if k==kind)
    old=assembled(oldblocks)
    new=assembled([b for b in oldblocks if b[1] not in {'nb_fork_close','nb_flags_chunks'}]+blocks(proposal))
    false,true=s.ctor('False'),s.ctor('True')
    def seg(name,refs=(),fork=False,bang=False):
        return dict(name=name,refs=list(refs),fork=fork,bang=bang)
    def literal_seg(v):
        return s.ctor('N_Segment',v['name'],[s.ctor('N_Param','p😀',s.ctor('N_W64'))],3,s.ctor('N_Frame',1,['saved']),'retained body é😀',v['refs'],true,false,true if v['fork'] else false,true if v['bang'] else false)
    chain=[seg('a',['b']),seg('b',['seed']),seg('seed',fork=True)]
    fixed=[('empty',[],['dup','dup','']),('empty-roots',chain,[]),('seeded-chain',chain,['seed']),('reverse-chain',list(reversed(chain)),['seed']),('duplicates',[seg('a',['seed']),seg('a',['other']),seg('seed',fork=True)],['seed','seed','']),('seeded-cycle',[seg('a',['b']),seg('b',['a'])],['a']),('unseeded-cycle',[seg('a',['b']),seg('b',['a'])],[]),('mixed',[seg('fork',fork=True,bang=True),seg('caller',['fork'],bang=True),seg('plain'),seg('bang',bang=True)],['fork']),('fork-not-in-seed',[seg('fork',fork=True),seg('caller',['fork'])],[]),('unicode-empty',[seg('',['é😀']),seg('é😀',fork=True),seg('é😁',[''])],['é😀']),('collision-one',[seg('costarring',['liquid']),seg('liquid')],['costarring']),('collision-other',[seg('costarring',['liquid']),seg('liquid')],['liquid']),('duplicate-refs',[seg('a',['missing','seed','seed']),seg('seed',fork=True)],['seed']),('self-edge',[seg('a',['a'])],[])]
    cases=[]
    for label,ss,roots in fixed:
        for fuel in sorted(set([0,1,len(ss)+3])):cases.append((label+'-fuel'+str(fuel),ss,roots,fuel))
    for count in scales:
        ss=[seg('shared.long.prefix.'+str(i),['shared.long.prefix.'+str(i+1)]) for i in range(count-1)]+[seg('shared.long.prefix.'+str(count-1),fork=True)]
        for reverse in (False,True):cases.append(('scale'+str(count)+('-forward' if not reverse else '-reverse'),list(reversed(ss)) if reverse else ss,[ss[-1]['name']],count))
    def close(ss,roots,fuel):
        roots=list(roots);passes=0;comparisons=0
        def member(name):
            nonlocal comparisons
            for root in roots:
                comparisons+=1
                if name==root:return True
            return False
        for _ in range(fuel):
            before=len(roots);passes+=1
            for x in ss:
                if not x['fork'] and not member(x['name']) and any(member(n) for n in x['refs']):roots.insert(0,x['name'])
            if len(roots)==before:break
        return roots,dict(passes=passes,legacyNameComparisons=comparisons)
    helper='''
type P90ForkCase is Data:
  P90ForkCase{+id: U32, +label: String, +roots: List<&2,String>, +flags: String, +prefixed: String, +chunks: String, +initial: List<&2,String>, +onePass: List<&2,String>, +retainedRoots: List<&2,String>, +retainedSegments: List<&2,N_Segment>}

@unsafe
def p90_fork_case(id: U32, label: String, +ss: List<&2,N_Segment>, +seeds: List<&2,String>, fuel: U32) -> P90ForkCase:
  +roots = nb_fork_close(ss, seeds, fuel)
  P90ForkCase{id, label, roots, nb_flags(ss, roots), nb_flags_go(ss, roots, "prefix é😀:"), nb_flags_chunks(ss, roots, ["second:","first:"]), nb_fork_roots(ss), nb_fork_step(ss, seeds), seeds, ss}

@unsafe
def main() -> List<&2,P90ForkCase>:
  [ROWS]
'''
    rows=[];expected=[];diagnostics=[]
    for i,(label,ss,roots,fuel) in enumerate(cases):
        result,diag=close(ss,roots,fuel);once,_=close(ss,roots,1)
        flags=''.join(str(int(x['bang'])+2*int(not x['fork'] and x['name'] not in result))+', ' for x in ss)+'2, 0'
        segments=[literal_seg(x) for x in ss]
        rows.append('p90_fork_case('+','.join(s.literal(x) for x in (i,label,segments,roots,fuel))+')')
        expected.append(s.ctor('P90ForkCase',i,label,result,flags,'prefix é😀:'+flags,'first:second:'+flags,[x['name'] for x in reversed(ss) if x['fork']],once,roots,segments))
        diagnostics.append(dict(id=i,label=label,segments=len(ss),initialRoots=len(roots),finalRoots=len(result),fuel=fuel,**diag))
    helper=helper.replace('ROWS',',\n   '.join(rows))
    # Place declarations ahead of definitions, matching normal source assembly.
    helperblocks=blocks(helper)
    typed='\n'.join(t for k,n,t in helperblocks if k=='type')
    tail='\n'.join(t for k,n,t in helperblocks if k!='type')
    baseline=a.out/'legacy.bend';candidate=a.out/'indexed.bend'
    baseline.write_text(old+typed+tail);candidate.write_text(new+typed+tail)
    meta=dict(kind='phase90-indexed-fork-controls',complete=True,targetExecuted=False,cases=len(cases),labels=[x[0] for x in cases],expected=expected,diagnostics=diagnostics,oracle='Independent ordered-list closure; full root order/duplicates, flags, accumulator prefixes, one-pass result and retained inputs. Python name-comparison counts describe this fixture, not measured target time.',inputs=[s.pin(Path(__file__))]+[s.pin(x) for x in files],outputs=[s.pin(baseline),s.pin(candidate)])
    def fnv(name):
        h=2166136261
        for c in name:h=((h^ord(c))*16777619)&0xffffffff
        return h
    assert fnv('costarring')==fnv('liquid');meta['collision']=dict(names=['costarring','liquid'],hash=fnv('liquid'))
    if a.compiler:
        source=a.compiler.read_text();assert hashlib.sha256(source.encode()).hexdigest()==SOURCE74
        replacements=[];candidate_source=source
        for name in ('nb_fork_close','nb_flags_chunks'):
            olddef=s.declaration(source,name);newdef=native_eq(s.declaration(proposal,name))
            assert candidate_source.count(olddef)==1
            candidate_source=candidate_source.replace(olddef,newdef,1);replacements.append(dict(name=name,before=olddef,after=newdef))
        extra='\n'.join(native_eq(t) for k,n,t in blocks(proposal) if n not in ('nb_fork_close','nb_flags_chunks'))
        marker='@unsafe\ndef nb_fork_close(';assert candidate_source.count(marker)==1
        candidate_source=candidate_source.replace(marker,extra+'\n'+marker,1)
        path=a.out/'compiler-fork.bend';path.write_text(candidate_source)
        proof=dict(kind='phase90-source74-exact-fork-derivative',parent=s.pin(a.compiler),output=s.pin(path),replacements=replacements,insertBefore=marker,insertion=extra+'\n')
        restored=candidate_source.replace(extra+'\n'+marker,marker,1)
        for r in reversed(replacements):assert restored.count(r['after'])==1;restored=restored.replace(r['after'],r['before'],1)
        assert restored==source;proof['inverseByteExact']=True
        (a.out/'compiler-fork.derivation.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n')
        meta['inputs'].append(s.pin(a.compiler));meta['outputs'].append(s.pin(path));meta['compilerLineDelta']=len(candidate_source.splitlines())-len(source.splitlines())
    (a.out/'manifest.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetExecuted=False,cases=len(cases),outputs=meta['outputs'])))
if __name__=='__main__':main()
