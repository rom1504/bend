// Disposable compiler-private representation ablations. Not a public ABI rewrite.
// Preconditions: data-only request boundary, compiler-created immutable ADTs,
// unchanged internal G bindings, and no escaped positional arrays/getters.
import assert from 'node:assert/strict';
export function representationTransform(original,{mode='baseline',instrument=false}={}) {
  assert.ok(['baseline','no-copy','direct-kid','combined'].includes(mode));
  let source=original;const stats={mode,privateOnly:true,projectionSites:0,kidWorkers:0,instrument};
  if(['no-copy','combined'].includes(mode))source=source.replace(/project\(("[^"\n]+"),a\[0\]\)\.slice\(\)\[(\d+)\]/g,(whole,name,slot)=>{stats.projectionSites++;return `project(${name},a[0])[${slot}]`;});
  if(['direct-kid','combined'].includes(mode)){
    const lines=source.split('\n'),index=lines.findIndex(line=>line.startsWith('G["kid"]=fn(2,'));assert.ok(index>=0,'Expected a single generated kid worker');
    assert.equal(lines.filter(line=>line.startsWith('G["kid"]=')).length,1);
    lines[index]='G["kid"]=fn(2,function(a){let xs=project("KTerm",a[0])[4],n=a[1];while(xs.$==="Con"){if(n===0)return xs.a[0];xs=xs.a[1];n=(n-1)>>>0;}return call(get(G,"atom"),["Absent"]);});';
    source=lines.join('\n');stats.kidWorkers=1;
  }
  if(instrument){
    source='const representationCounts={calls:{},projections:{},projectionCopies:{},constructors:{},termTags:{},termArity:{},kidIndices:{},termListIndices:{}};\n'+source;
    assert.ok(source.includes('function project(k,x){'));source=source.replace('function project(k,x){','function project(k,x){representationCounts.projections[k]=(representationCounts.projections[k]||0)+1;');
    assert.ok(source.includes('function ctor(k,a){'));source=source.replace('function ctor(k,a){','function ctor(k,a){representationCounts.constructors[k]=(representationCounts.constructors[k]||0)+1;if(k==="KTerm"){const tag=a[0];representationCounts.termTags[tag]=(representationCounts.termTags[tag]||0)+1;let xs=a[4],n=0;while(xs?.$==="Con"){n++;xs=xs.a[1];}representationCounts.termArity[n]=(representationCounts.termArity[n]||0)+1;}');
    source=source.replace(/project\(("[^"\n]+"),a\[0\]\)\.slice\(\)\[(\d+)\]/g,(_,name,slot)=>`representationCopy(${name},a[0],${slot})`);
    source+='\nfunction representationCopy(name,value,slot){representationCounts.projectionCopies[name]=(representationCounts.projectionCopies[name]||0)+1;return project(name,value).slice()[slot];}\n';
    source+='for(const name of ["tg","nm","ix","qt","ks","rm","kid","terms_at","dn","dk","da","dx","dt","dv","dc","db","du","kt","atom","lookup","subst","wnf","core_beta","core_rebuild"]){const f=G[name];if(!f?.code)continue;const code=f.code;f.code=function(a){representationCounts.calls[name]=(representationCounts.calls[name]||0)+1;if(name==="kid")representationCounts.kidIndices[a[1]]=(representationCounts.kidIndices[a[1]]||0)+1;if(name==="terms_at")representationCounts.termListIndices[a[1]??"partial"]=(representationCounts.termListIndices[a[1]??"partial"]||0)+1;return code.call(this,a);};}\n';
    source+='export {representationCounts};export function resetRepresentationCounts(){for(const k of Object.keys(representationCounts))representationCounts[k]={};}\n';
  }
  return {source,stats};
}
