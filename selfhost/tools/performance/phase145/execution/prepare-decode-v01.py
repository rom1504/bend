#!/usr/bin/env python3
"""Add three fixed Base-decoder entry hooks to an existing diagnostic plan."""
import argparse,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
s=importlib.util.spec_from_file_location('p145n',ROOT/'selfhost/tools/performance/phase130/native-request.py');N=importlib.util.module_from_spec(s);s.loader.exec_module(N)
def main():
 p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();N.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145'),'Fresh Phase145 output');plan=json.loads(a.plan.read_text());source=N.verify(plan['diagnosticApi']).read_text();text=source;patches=[]
 for name in ['p88_number','p88_field','p130m_word']:
  matches=list(re.finditer(r'function \$'+name+r'\$\(([^\n]*)\) \{',text));N.require(len(matches)==1,'Unique decoder declaration');m=matches[0];arg=m[1].split(',')[0].strip();patch='\n  /*p145decode*/globalThis.__p145hit('+json.dumps(name)+','+arg+');/*p145decodeend*/';patches.append(patch);text=text[:m.end()]+patch+text[m.end():]
 undone=text
 for patch in patches:N.require(undone.count(patch)==1,'Unique hook');undone=undone.replace(patch,'')
 N.require(undone==source,'Decoder hooks not reversible');out.mkdir(parents=True);(out/'diagnostic-api.mjs').write_text(text);plan['inputs'] += [N.pin(a.plan),N.pin(__file__),plan['diagnosticApi']];plan['diagnosticApi']=N.pin(out/'diagnostic-api.mjs');plan['decoderHooks']=['p88_number','p88_field','p130m_word']
 for item in plan['inputs']:N.verify(item)
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
if __name__=='__main__':main()
