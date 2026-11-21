"""Count calls in a separate, untimed copy of each current fixture's assembly."""
from pathlib import Path
import re
import subprocess
from project import CALL,sha

def counts(folder,source,assembler,linker,runtime,tc,point):
    targets=[]
    def instrument(match):
        i=len(targets)
        sym=match[1]
        targets.append(''.join(chr(int(t)) for t in sym.split('_FID_')[1].strip('_').split('_')))
        return f'  incq p198_counter+{8*i}(%rip)\n'+match[0]
    listing=CALL.sub(instrument,source)
    asm=folder/'counter.s'
    asm.write_text(listing+'\n.bss\n.balign 8\n.globl p198_counter\np198_counter:\n  .zero '+str(8*len(targets))+'\n')
    observer=folder/'observer.c'
    observer.write_text('#include <inttypes.h>\n#include <stdio.h>\n'
        'extern uint64_t p198_counter[];\n__attribute__((destructor)) static void report(void) {\n'
        '  fputs("p198-pair-count", stderr);\n  for (int i=0; i<'+str(len(targets))+'; ++i) fprintf(stderr, " %" PRIu64, p198_counter[i]);\n'
        '  fputc(10, stderr);\n}\n')
    obj=folder/'counter.o'
    elf=folder/'counter'
    for cmd in ([assembler,*tc['assemblerFlags'],'-o',obj,asm],
                [linker,*tc['linkerFlags'],obj,runtime,observer,*tc['libraries'],'-o',elf]):
        child=subprocess.run(cmd,capture_output=True,timeout=10)
        assert child.returncode==0,child.stderr
    result={}
    for n in (0,1):
        cmd=[str(elf),'+RTS','--threads','1','--gpu','off','-RTS','--RTS',str(n),'0',*map(str,point['runtimeArgs'])]
        child=subprocess.run(cmd,capture_output=True,timeout=10)
        assert child.returncode==0 and child.stdout.decode().startswith(point['expectedStdout']),child
        lines=[l for l in child.stderr.decode().splitlines() if l.startswith('p198-pair-count ')]
        assert len(lines)==1,child.stderr
        result[n]=[int(x) for x in lines[0].split()[1:]]
        assert len(result[n])==len(targets)
    return dict(targets=targets,zeroTimed=result[0],oneTimed=result[1],difference=[y-x for x,y in zip(result[0],result[1])],
                instrument=sha(asm),binary=sha(elf))
