"""Read-only allocated-ELF, symbol and relocation comparison after renaming."""
import argparse,hashlib,importlib.util,json,re,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('compact',HERE/'compact.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
spec=importlib.util.spec_from_file_location('sections',ROOT/'selfhost/tools/performance/phase127/compare-machine.py');E=importlib.util.module_from_spec(spec);spec.loader.exec_module(E)

def digest(value):return hashlib.sha256(json.dumps(value,separators=(',',':')).encode()).hexdigest()

def symbols(path,inverse):
    output=subprocess.check_output(['readelf','-W','-s',str(path)],text=True);rows=[];files=[];exports=[]
    for line in output.splitlines():
        fields=line.split()
        if len(fields)<8 or not fields[0].endswith(':')or not fields[0][:-1].isdigit():continue
        number,value,size,typ,bind,vis,section,name=fields[:8]
        if typ=='FILE':files.append(name);continue
        if bind=='GLOBAL'and section!='UND':exports.append(name)
        rows.append((int(value,16),int(size),typ,bind,vis,section,inverse.get(name,name)))
    return dict(count=len(rows),normalizedSha256=digest(sorted(rows)),rawExports=sorted(set(exports)),fileNames=sorted(files))

def relocations(path,inverse):
    text=subprocess.check_output(['readelf','-W','-r',str(path)],text=True);section='';rows=[]
    for line in text.splitlines():
        m=re.match(r"Relocation section '([^']+)'",line)
        if m:section=m[1];continue
        fields=line.split()
        if len(fields)<5 or not re.fullmatch(r'[0-9a-fA-F]+',fields[0])or not fields[2].startswith('R_'):continue
        offset,info,kind,value,name=fields[:5]
        rows.append((section,int(offset,16),kind,int(value,16),inverse.get(name,name),*fields[5:]))
    return dict(count=len(rows),normalizedSha256=digest(rows))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ['before','after','mapping','out']:p.add_argument('--'+key,type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase132')
    left=json.loads(a.before.read_text());right=json.loads(a.after.read_text());mapping=json.loads(a.mapping.read_text())
    assert left['complete']and right['complete']and mapping['bijection']
    inverse={x['compact']:x['original']for x in mapping['entries']};assert len(inverse)==len(mapping['entries'])
    inputs=[C.pin(__file__),C.pin(a.before),C.pin(a.after),C.pin(a.mapping),C.pin(E.__file__),C.pin(shutil.which('readelf'))]
    for b in [left,right]:
        for row in b['inputs']+[b['binary'],b['object']]:assert C.pin(row['file'])==row
        inputs += [b['binary'],b['object']]
    sa,_,pa=E.inspect(Path(left['binary']['file']));sb,_,pb=E.inspect(Path(right['binary']['file']))
    changed=sorted(n for n in sa.keys()|sb.keys()if sa.get(n)!=sb.get(n))
    syma=symbols(Path(left['binary']['file']),{});symb=symbols(Path(right['binary']['file']),inverse)
    rela=relocations(Path(left['object']['file']),{});relb=relocations(Path(right['object']['file']),inverse)
    result=dict(complete=True,targetsRun=False,inputs=inputs,beforeBinary=left['binary'],afterBinary=right['binary'],
        textByteIdentical=sa.get('.text')==sb.get('.text'),allocatedSectionsIdenticalExceptBuildId=not(set(changed)-{'.note.gnu.build-id'}),
        changedAllocatedSections=changed,descriptorAddressEqual=pa==pb,beforeSections=sa,afterSections=sb,
        normalizedSymbolsEqual=syma['normalizedSha256']==symb['normalizedSha256'],
        rawExportSetEqual=syma['rawExports']==symb['rawExports'],
        beforeSymbols=syma,afterSymbols=symb,beforeRelocations=rela,afterRelocations=relb,
        normalizedRelocationsEqual=rela==relb,
        stages={role:{x['label']:x['seconds']for x in build['jobs']}for role,build in [('before',left),('after',right)]},
        scope='No targets executed. Compare allocated bytes/addresses/flags; build-ID note may differ. '
              'ELF symbol type/binding/visibility/value/size compared after inverse map, excluding nonsemantic FILE names. '
              'Object relocations ignore symbol-table indices but preserve offset/type/name/value/addend. '
              'One build pair gives descriptive QBE/as/link cost, not a controlled statistical speedup or Bend emission cost.')
    out.mkdir();(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k]for k in ['complete','textByteIdentical','allocatedSectionsIdenticalExceptBuildId','normalizedSymbolsEqual','rawExportSetEqual','normalizedRelocationsEqual']}))

if __name__=='__main__':main()
