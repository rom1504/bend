#!/usr/bin/env python3
"""Freeze two-algorithm QBE transfer comparison; generate generic timing only."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','image','general-qualification','fixed-qualification','string-qualification','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text())
source_file=a.source.resolve()/'manifest.json';source=read(source_file);image_file=a.image.resolve()/'report.json';image=read(image_file)
qfiles=[a.general_qualification.resolve(),a.fixed_qualification.resolve(),a.string_qualification.resolve()];general,fixed,string=[read(f) for f in qfiles]
if not all(m['complete'] for m in [source,image,general,fixed,string]) or source['runtimeProfile']!='compact-general':raise ValueError('qualified compact-general image required')
if not all(any(row==value for row in general['inputs']) for value in [pin(source_file),pin(image_file),image['binary']]):raise ValueError('general qualification differs')
if not any(row==pin(qfiles[0]) for row in fixed['inputs']) or not any(row==pin(qfiles[0]) for row in string['inputs']):raise ValueError('qualification chains differ')
list_dir=ROOT/'selfhost/build/phase110/controls-calls-heldout01';string_dir=ROOT/'selfhost/build/phase110/base-string-append-controls01';list_prep=read(list_dir/'manifest.json');string_prep=read(string_dir/'manifest.json')
original=string_dir/'harness.c';text=original.read_text();main=text[text.index('int main('):]
helpers='''#include <stdarg.h>
#include <time.h>
static FILE *p110_output;
static double p110_worker_seconds;
static unsigned p110_worker_calls;
static double p110_now(void) { struct timespec t; if (clock_gettime(CLOCK_MONOTONIC,&t)) abort(); return (double)t.tv_sec+(double)t.tv_nsec*1e-9; }
static int p110_printf(const char *fmt,...) { va_list a;va_start(a,fmt);int r=vfprintf(p110_output,fmt,a);va_end(a);return r; }
static int p110_putchar(int c) { return fputc(c,p110_output); }
static int p110_puts(const char *s) { int r=fputs(s,p110_output);fputc('\\n',p110_output);return r; }
'''
body=text[:text.index('int main(')];body=re.sub(r'\b(printf|putchar|puts)\(',r'p110_\1(',body)
needle='  uint64_t result=nx_entry(ctx,left,right);'
if body.count(needle)!=1:raise ValueError('exact original worker call changed')
body=body.replace(needle,'  double begin=p110_now();\n'+needle+'\n  p110_worker_seconds+=p110_now()-begin;++p110_worker_calls;',1)
body=body.replace('#include <string.h>','#include <string.h>\n'+helpers,1)
body+='''int main(int argc,char **argv) {
  uint32_t matched=0;require(argc<=3,"optional case and repetitions only");
  unsigned repetitions=argc>2?(unsigned)strtoul(argv[2],NULL,10):1;
  require(repetitions>0 && repetitions<=10000,"repetitions outside 1..10000");
  FILE *quiet=fopen("/dev/null","w");require(quiet!=NULL,"cannot open null observation stream");
  for (uint32_t i=0;i<sizeof(CASES)/sizeof(CASES[0]);++i)
    if (argc==1 || !strcmp(argv[1],CASES[i].name)) {
      p110_worker_seconds=0;p110_worker_calls=0;
      for (unsigned rep=0;rep<repetitions;++rep) { p110_output=rep?quiet:stdout;run(&CASES[i],0);run(&CASES[i],1); }
      fprintf(stderr,"{\\"name\\":\\"%s\\",\\"repetitions\\":%u,\\"workerCalls\\":%u,\\"workerSeconds\\":%.9f}\\n",CASES[i].name,repetitions,p110_worker_calls,p110_worker_seconds);++matched;
    }
  require(matched!=0,"unknown case");require(fclose(quiet)==0,"null observation stream close failed");return 0;
}
'''
selected_list=next(row['output'] for row in fixed['rows'] if row['contract']=='append' and row['format']=='qbe');selected_string=next(row['nativeProduct'] for row in string['rows'] if row['backend']=='qbe')
base_list=ROOT/'selfhost/build/phase110/general-append02/emit-fused';base_report=read(base_list/'report.json');base_product=next(row for row in base_report['outputs'] if Path(row['file']).name=='program.ssa')
inputs=[pin(Path(__file__)),pin(source_file),pin(image_file),*map(pin,qfiles),*general['inputs'],*fixed['inputs'],*string['inputs'],pin(list_dir/'manifest.json'),pin(string_dir/'manifest.json'),*list_prep['inputs'],*list_prep['outputs'],*string_prep['inputs'],*string_prep['outputs'],selected_list,selected_string,pin(base_list/'report.json'),base_product]
for row in inputs:verify(row)
out.mkdir();(out/'string-harness.c').write_text(body)
for name in ['abi.h','cases.inc.c']:(out/name).write_bytes((string_dir/name).read_bytes())
algorithms=[dict(name='nt_append',mode='fixed',source=source['contracts']['append'],entry='append',prepared=str(list_dir),harness=pin(list_dir/'harness.c'),expected=pin(list_dir/'expected.jsonl'),selected=selected_list,baselineExpected=base_product,repetitions=8,callsPerRepetition=1,cases=['append-deep-same-root','append-odd-shared-tail','append-deep-distinct']),dict(name='String.append',mode='general',source=pin(string_dir/'source.bend'),entry='String.append',prepared=str(out),harness=pin(out/'string-harness.c'),expected=pin(string_dir/'expected.jsonl'),selected=selected_string,repetitions=256,callsPerRepetition=2,cases=['base-string-append-shared-left-512','base-string-append-unique-left-1024'])]
manifest=dict(kind='phase110-frozen-native-transfer',complete=True,targetsRun=False,inputs=inputs,outputs=[pin(out/name) for name in ['string-harness.c','abi.h','cases.inc.c']],image=image['binary'],rounds=5,baseline='fused',selected='runtime-ir-single',backend='qbe',algorithms=algorithms,scope='Fixed policy transfer comparison, no candidate search or selection change. Worker-only CLOCK_MONOTONIC intervals; construction, observations and release outside timer. Original graph/oracle/depth limits unchanged.',instrumentation=dict(original=pin(original),fullObservationEveryRepetition=True,stdout='Original full-value oracle on first repetition; later observations go to /dev/null.',maxStringRecursion=1024))
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,manifest=str(out/'manifest.json'),cases=5,rounds=5)))
