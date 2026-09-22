// Reduce diagnostic counts without interpreting them as time or allocated bytes.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
const [input,output]=process.argv.slice(2);if(!output)throw Error('Usage: matcher-family-summary.mjs REPORT NEW_OUTPUT');
const sha=x=>crypto.createHash('sha256').update(x).digest('hex'),raw=fs.readFileSync(input),report=JSON.parse(raw);
assert.equal(report.complete,true);assert.equal(report.inputsUnchanged,true);assert.equal(report.emitted.sha256,'016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186');
const families=['subst_node','subst_terms','ka_defs_except','tele_check','ka_args'];
const sum=(rows,test)=>Object.entries(rows).reduce((n,[k,v])=>n+(test(k)?v:0),0),percent=(a,b)=>b?100*a/b:null;
function summarize(rows){
 assert.equal(rows['all:under']??0,rows['all:partialRecords']??0);
 const applications=rows['all:apply']??0,partialRecords=rows['all:partialRecords']??0;
 const family=families.map(name=>{const is=k=>k.startsWith(name+':');const applications=sum(rows,k=>is(k)&&k.includes(':apply:')),partialRecords=sum(rows,k=>is(k)&&k.endsWith(':partialRecords'));return {name,entries:(rows[name+':workerEntry']??0)+(rows[name+':entryMatcher:apply:exact']??0)+(rows[name+':entryMatcher:apply:over']??0)+(rows[name+':entryFn:apply:exact']??0)+(rows[name+':entryFn:apply:over']??0),applications,partialRecords,matcherApplications:sum(rows,k=>is(k)&&(/:(entryMatcher|matcher|matcher1):apply:/.test(k))),createdRecords:sum(rows,k=>is(k)&&k.includes(':created:'))};});
 const taggedApplications=family.reduce((n,r)=>n+r.applications,0),taggedPartialRecords=family.reduce((n,r)=>n+r.partialRecords,0);
 return {applications,partialRecords,taggedApplications,taggedApplicationPercent:percent(taggedApplications,applications),taggedPartialRecords,taggedPartialPercent:percent(taggedPartialRecords,partialRecords),families:family};
}
const total={};for(const [phase,rows]of Object.entries(report.counts))if(phase.startsWith('request:'))for(const [k,v]of Object.entries(rows))total[k]=(total[k]??0)+v;
const result={kind:'phase4-matcher-family-count-summary',complete:true,source:{file:input,sha256:sha(raw)},tool:{file:import.meta.filename,sha256:sha(fs.readFileSync(import.meta.filename))},scope:'One exact-output compilation request. Counts are not times, allocated bytes, unique source calls or a removable-work ceiling. Preparation, discovery, setup and self-controls excluded from request totals.',request:summarize(total),byPhase:Object.entries(report.counts).map(([phase,rows])=>({phase,...summarize(rows)}))};
fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(result.request));
