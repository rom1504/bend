#!/usr/bin/env python3
"""Build a reversible synchronous-verifier observation; no targets."""
import argparse,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('p145n',ROOT/'selfhost/tools/performance/phase130/native-request.py');N=importlib.util.module_from_spec(sp);sp.loader.exec_module(N)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve();N.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145'),'Fresh diagnostic output required')
 plan=json.loads(a.plan.read_text());original=N.verify(plan['diagnosticApi']).read_text();text=original;patches=[]
 for name in ['p114s_open','p113a_verify','p113e_verify','p112s_verify']:
  pattern=r'(function \$'+name+r'\$\(([^\n]*)\) \{)(.*?)(\n\})(?=\n\nfunction )';matches=list(re.finditer(pattern,text,re.S));N.require(len(matches)==1,'Unique function block required '+name);m=matches[0];args=m[2]
  if name=='p112s_verify':
   N.require('run_loop($p111_verify_program$(_program_0))' in m[3] and 'run_loop($p112s_image_error$(' in m[3],'Expected synchronous complete verifier changed')
   before='\n  const __p145token=globalThis.__p145verifyBegin("p112s_verify",['+args+']);\n  try {';after='\n  } finally {globalThis.__p145verifyEnd(__p145token,['+args+']);}'
  else:before='\n  globalThis.__p145scopeEnter('+json.dumps(name)+');\n  try {';after='\n  } finally {globalThis.__p145scopeExit('+json.dumps(name)+');}'
  text=text[:m.end(1)]+before+m[3]+after+text[m.start(4):];patches.extend([before,after])
 undone=text
 for patch in patches:N.require(undone.count(patch)==1,'Unique reversible hook required');undone=undone.replace(patch,'')
 N.require(undone==original,'Verifier diagnostic does not reverse exactly')
 prefix='import '+json.dumps(str(HERE/'verified-inputs-v01.mjs'))+';\n'
 out.mkdir(parents=True);(out/'diagnostic-api.mjs').write_text(prefix+text)
 # Reuse the exact observer/supervisor, while recording strict hashes in a separate process-exit hook.
 # beforeExit is reached after all synchronous observations; writes are diagnostic only.
 helper=(HERE/'verified-inputs-v01.mjs').read_text();N.require('process.on(' not in helper,'Unexpected process hook')
 driver=out/'verified-driver.mjs';driver.write_text('import fs from "node:fs";\nimport '+json.dumps(str(HERE/'verified-inputs-v01.mjs'))+';\nprocess.on("beforeExit",()=>{const input=JSON.parse(fs.readFileSync(process.argv[2],"utf8"));fs.writeFileSync(input.observation+".verified-inputs.json",JSON.stringify({kind:"phase145-verified-input-identities",records:globalThis.__p145verifiedInputs},null,2)+"\\n");});\nawait import('+json.dumps(str(HERE/'hosted-v01.mjs'))+');\n')
 plan['diagnosticApi']=N.pin(out/'diagnostic-api.mjs');plan['verifiedDriver']=N.pin(driver);plan['inputs'] += [N.pin(a.plan),N.pin(__file__),N.pin(HERE/'run-verified-v01.py'),N.pin(HERE/'verified-inputs-v01.mjs'),plan['verifiedDriver']];plan['verifierFingerprintScope']='Complete sole argument to synchronous p112s_verify; no omitted caller context, fixed code/runtime. Exact object identity and structural data hash before/after. This does not prove reusable per-instruction judgments.'
 for p in plan['inputs']:N.verify(p)
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
if __name__=='__main__':main()
