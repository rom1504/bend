// Offline metadata only. Does not import the compiler or execute target programs.
import fs from 'node:fs';
import crypto from 'node:crypto';
const root = new URL('../../../', import.meta.url);
const read = p => JSON.parse(fs.readFileSync(new URL(p, root)));
const hash = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const decode = s => s.replace(/FID_([0-9_]+)/g, (_, x) => x.split('_').filter(Boolean).map(Number).map(x => String.fromCharCode(x)).join(''));
const pin = p => ({path:p, sha256:hash(p)});
const diagnostics = read('selfhost/build/phase192/diagnostic01/report.json');
const ir = [];
for (const row of diagnostics.rows) {
  if (hash(row.preselection.file) !== row.preselection.sha256) throw Error('IR identity mismatch');
  const j = JSON.parse(fs.readFileSync(row.preselection.file));
  for (const f of j.functions) {
    const name = decode(f.symbol);
    if (name !== 'p113d_$direct.p37.numeric' && name !== 'p113d_$product.fold.loop') continue;
    const defs = [];
    function walk(rows,path) {
      rows.forEach((s,i) => {
        const at = `${path}/${i}`;
        if (s[0] === 'P113DScalar') {
          const x=s[1];
          if (['N111Set','N111Bin','N111Call','N111Load','N111Offset','N111Alloca'].includes(x[0])) defs.push({at,row:x});
          if (x[0] === 'N111If') {walk(x[2],at+'/yes');walk(x[3],at+'/no');}
        } else if (s[0] === 'P113DIf') {walk(s[2],at+'/yes');walk(s[3],at+'/no');}
      });
    }
    walk(f.setup,'setup');walk(f.body,'body');
    ir.push({case:row.id,name,source:row.preselection,
      valueDefinitions:defs.filter(d=>d.row[1]==='value'),
      existingHoistDefinitions:defs.filter(d=>d.row[1].includes('hoist_')),
      positiveBody:f.body[1][3][1][2]});
  }
}
const audit=read('selfhost/build/phase192/parity-audit01/report.json');
const machine=[];
for (const [name,roles] of Object.entries(audit.cases)) for (const [role,r] of Object.entries(roles)) {
  if(hash(r.artifact.path)!==r.artifact.sha256) throw Error('ELF identity mismatch');
  machine.push({case:name,role,artifact:r.artifact,functions:Object.entries(r.functions).map(([symbol,f])=>({name:decode(symbol),address:f.address,counts:f.whole_function_static,disassembly:f.raw_disassembly}))});
}
const profiles=read('selfhost/build/phase192/profile-analysis01/report.json');
const physical=Object.values(profiles.roles).map(r=>({case:r.case,role:r.role,binary:r.binary,
  samples:r.samples,unknown:r.unknownPeriodWeightedFraction,cleanCpuUs:r.cleanCpuMicrosecondsPerRepetition,
  leadingLeaves:r.functions.slice(0,8)}));
const sources=['function.bend','program.bend','expression-reuse.bend','float-registers.bend','loop-liveness.bend','transient.bend'].map(p=>pin(new URL('selfhost/src/back/x86/'+p,root).pathname));
const result={kind:'phase192-architectural-survey-offline',targetsRun:false,compilersRun:false,
  sourceScope:'Dirty active source at HEAD 0e2a9d0; hashes identify inspected bytes, not qualification.',sources,ir,machine,physical};
fs.writeFileSync(new URL('observations.json',import.meta.url),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({irFunctions:ir.length,machineProducts:machine.length,profileRoles:physical.length,targetsRun:false}));
