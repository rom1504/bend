"""Freeze exact Phase130 compiler occurrence functions and independent oracle."""
import hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
SOURCE=ROOT/'selfhost/build/phase130/mode-source01/compiler.bend'


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def freeze(name,data):
    p=HERE/name
    if not isinstance(data,str):data=json.dumps(data,indent=2,ensure_ascii=False)+'\n'
    if p.exists():assert p.read_text()==data,'Changed frozen output '+str(p)
    else:p.write_text(data)
    return pin(p)


def main():
    assert pin(SOURCE)['sha256']=='995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd'
    lines=SOURCE.read_text().splitlines(keepends=True)
    names=['KTerm','p88_string_eq_go','p98_eq_finish','p88_string_eq','p98_tag_eq_read','p98_tag_eq_finish','p98_tag_eq',
        'kc','kt','atom','ix','ks','terms_at','kid','terms_len','nt_choose','nt_bool','nq_uses','nq_uses_list','nw_uses']
    blocks=[];spans=[]
    for name in names:
        start=next(i for i,line in enumerate(lines)if re.match(r'^(?:def|type) '+re.escape(name)+r'(?:\(| is)',line))
        end=start+1
        while end<len(lines)and(not lines[end].strip()or lines[end][0].isspace()or lines[end].startswith(') -> ')):end+=1
        while not lines[end-1].strip():end-=1
        if start and lines[start-1].strip()=='@unsafe':start-=1
        text=''.join(lines[start:end]);blocks.append(text)
        spans.append(dict(name=name,firstLine=start+1,lastLine=end,sha256=hashlib.sha256(text.encode()).hexdigest()))
    source=freeze('compiler-uses.bend','import Base\n\n'+'\n'.join(blocks)+'\n'+(HERE/'uses-workload.bend').read_text())
    # A host algebra over semantic tags, independently of Bend implementation:
    # Vars indicate one occurrence, Mat takes max of its two branches, pattern
    # rows take max, ordinary children sum with saturation at two.
    def uses(t,i):
        tag,identifier,kids=t
        if tag=='Var':return int(identifier==i)
        if tag=='Mat'and len(kids)==2:return max(uses(kids[0],i),uses(kids[1],i))
        if tag=='NWPattern':return max([uses(row[2][0],i)if row[2]else 0 for row in kids]+[0])
        return min(2,sum(uses(k,i)for k in kids))
    var=('Var',7,[]);lit=('Lit',0,[])
    def tree(n):return var if n==0 else('App',0,[tree(n-1),tree(n-1)])
    cases=[(tree(4),7),(tree(4),8),(('Mat',0,[var,var]),7),(('Mat',0,[tree(4),('Var',8,[])]),7),
        (('Mat',0,[var]),7),(lit,7),(('Lam',0,[var,lit]),7),
        (('NWPattern',0,[('Row',0,[var]),('Row',0,[var])]),7),(('NWPattern',0,[]),7),(('NWPattern',0,[('Row',0,[])]),7)]
    values=[uses(t,i)for t,i in cases];assert values==[2,0,1,2,1,0,1,1,0,0]
    output=''.join(str(x)+'\n'for x in values)
    expected=freeze('compiler-uses.expected.json',dict(status=0,stdout=output,stderr=''))
    stdout=freeze('compiler-uses.expected.stdout',output)
    manifest=freeze('uses.cases.json',dict(complete=True,cases=[dict(name='compiler-uses',source=source,expected=expected,expectedStdoutEvidence=expected)]))
    freeze('uses.oracle.json',dict(complete=True,targetsRun=False,frozenBeforeExecution=True,checked=False,
        inputs=[pin(SOURCE),pin(__file__),pin(HERE/'uses-workload.bend')],spans=spans,source=source,manifest=manifest,
        ordinary=dict(values=values,expected=stdout),timed=dict(repeats=1000,expectedPrefix='2\n2000\n',
        depth=7,visitsPerTraversal=255,queryIds=[7,8],elapsedUnit='milliseconds',calibrated=False),
        scope='Exact compiler computation and helpers; shared DAG root retained across repeated occurrence queries. Synthetic input tree is not a broad compiler performance measure. No optimization of extracted functions.'))
    print(json.dumps(dict(source=source,manifest=manifest)))


if __name__=='__main__':main()
