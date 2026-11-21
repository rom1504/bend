"""Ablate all helper specialization on the same admitted String-spine sites."""
import argparse,json,sys
from pathlib import Path
from make_fixtures import HERE,ROOT
from stage import NAME,Node,Stage,Unsupported,V,decode_string,lit,parse_program,render,show,spine,transform,walk
import re

class SpineOnly(Stage):
    def __init__(self,defs,returns,kernel):
        super().__init__(defs,returns);self.kernel=kernel
    def eval(self,n,env):
        # Retain every non-recursive call in source evaluation order. The
        # primary stager's known-constructor, primitive and helper folding
        # cannot execute even when every scalar argument happens to be known.
        if n.op=='call' and n.name!=self.kernel:
            vs=[self.eval(a,env) for a in n.args];ty=self.returns.get(n.name,'');self.fuel+=1
            if not ty:raise Unsupported('opaque helper needs source return type: '+n.name)
            return self.let(n.name+'('+', '.join(map(render,vs))+')',False,ty)
        if n.op=='binary' and n.name!=':':
            if n.name in ('||','&&'):raise Unsupported('conditional operator')
            vs=[self.eval(x,env) for x in n.args];kinds={v.typ if v.kind=='dyn' else v.kind for v in vs}
            if len(kinds)!=1 or not kinds<={'Nat','U32'}:raise Unsupported('scalar type')
            ty=next(iter(kinds));return self.let('('+(' '+n.name+' ').join(map(render,vs))+' : '+ty+')',False,ty)
        return super().eval(n,env)

def ablate(src):
    _,primary=transform(src);defs,spans,declared,ctors,imports=parse_program(src);returns={k:t.strip() for k,t in re.findall(r'(?m)^def\s+('+NAME+r')\([^\n]*?\)\s*->\s*([^:\n]+):',src)};returns.update({'Chr':'Char','SCon':'String','SNil':'String'});edits=[];metadata=[]
    for row in primary:
        d=defs[row['kernel']];owner=defs[row['owner']];pos=spine(d);calls=[n for n in walk(owner.body[1]) if n.op=='call' and n.name==d.name];assert len(calls)==1;call=calls[0];string=call.args[pos]
        if string.op=='call':string=defs[string.name].body[1]
        assert string.op=='literal';letters=decode_string(string.name);st=SpineOnly(defs,returns,d.name);st.stack=[d.name]
        # Only the String is static. All remaining formals are passed even
        # when an original call site supplies a literal initial counter.
        vs=[lit(letters,'String') if i==pos else V('dyn',p,d.types[i]) for i,p in enumerate(d.params)];value=st.apply(d,vs);body=st.finish(value);assert st.steps==len(letters) and st.selected==0
        name='p205unfold_fn'+str(len(metadata));formal=', '.join('+'+p+': '+d.types[i] for i,p in enumerate(d.params) if i!=pos);helper='def '+name+'('+formal+') -> '+d.result+':\n'+'\n'.join(body)+'\n\n';newcall=Node('call',name,tuple(a for i,a in enumerate(call.args) if i!=pos))
        def replace(n):return newcall if n is call else Node(n.op,n.name,tuple(replace(a) for a in n.args))
        at,length=spans[owner.name];head=src.rfind('\ndef '+owner.name+'(',0,at)+1;assert head>0;edits.extend([(head,head,helper),(at,at+length,'  '+show(replace(owner.body[1]))+'\n')]);metadata.append(dict(owner=owner.name,kernel=d.name,characters=st.steps,helperBranchesSpecialized=0,residualBindings=len(body)-1,retainedCalls=dict((k,len(re.findall(r'\b'+re.escape(k)+r'\(',helper))) for k in sorted({n.name for n in walk(d.body[2][1][1]) if n.op=='call' and n.name!=d.name}))))
    for a,b,t in sorted(edits,reverse=True):src=src[:a]+t+src[b:]
    return src,metadata

def freeze():
    from measure import B
    existing=HERE/'plan.json';plan=B.read(existing);removed={row['staged']['file'] for row in plan['cases'].values()};inputs=[p for p in plan['inputs'] if p['file'] not in removed]
    for key,row in plan['cases'].items():
        source=Path(row['original']['file']);text,metadata=ablate(source.read_text());assert len(metadata)==1
        dest=HERE/(key+'-spine.bend');dest.write_text(text);row['staged']=B.pin(dest);row['sites']=metadata;inputs.append(row['staged'])
    inputs.extend([B.pin(__file__),B.pin(existing)]);plan['inputs']=B.unique_inputs(inputs);plan['kind']='phase205-string-spine-only-ablation';file=HERE/'plan-spine.json';file.write_text(json.dumps(plan,indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--freeze',action='store_true');p.add_argument('--out',type=Path);a=p.parse_args()
    if a.freeze:freeze()
    else:
        import measure
        measure.PLAN=HERE/'plan-spine.json';measure.run(a.out)
