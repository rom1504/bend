#!/usr/bin/env python3
"""Bounded, read-only audit of the Phase174 linker filename discrepancy."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import common

CHUNK=1024*1024
HEADER_KEYS=('ident','type','machine','version','entry','phoff','shoff','flags','ehsize','phentsize','phnum','shentsize','shnum','shstrndx')
SECTION_KEYS=('nameIndex','type','flags','address','offset','size','link','info','alignment','entryBytes')


def require(condition,message):
    common.require(condition,message)


def digest_region(path,offset,size):
    digest=hashlib.sha256()
    with Path(path).open('rb') as stream:
        stream.seek(offset)
        while size:
            data=stream.read(min(CHUNK,size));require(data,'Truncated ELF region')
            digest.update(data);size-=len(data)
    return digest.hexdigest()


def bytes_region(path,offset,size,limit=8*CHUNK):
    require(0<=size<=limit,'Bounded ELF metadata limit exceeded')
    with Path(path).open('rb') as stream:
        stream.seek(offset);data=stream.read(size)
    require(len(data)==size,'Truncated ELF metadata')
    return data


def parse(path):
    pin=common.pin(path);raw=bytes_region(path,0,64)
    h=dict(zip(HEADER_KEYS,struct.unpack('<16sHHIQQQIHHHHHH',raw)))
    require(h['ident'][:7]==b'\x7fELF\x02\x01\x01' and h['type']==2 and h['machine']==62 and h['version']==1,'Pinned ELF64 AMD64 executable required')
    require(h['ehsize']==64 and h['phentsize']==56 and 0<h['phnum']<=64,'Unsupported program table')
    require(h['shentsize']==64 and 0<h['shnum']<=128 and h['shstrndx']<h['shnum'],'Unsupported section table')
    require(h['shoff']+h['shnum']*64==pin['bytes'],'Section table must terminate the executable')
    phraw=bytes_region(path,h['phoff'],h['phnum']*56)
    ph=[dict(zip(('type','flags','offset','address','physicalAddress','fileBytes','memoryBytes','alignment'),struct.unpack('<IIQQQQQQ',phraw[i:i+56]))) for i in range(0,len(phraw),56)]
    shraw=bytes_region(path,h['shoff'],h['shnum']*64)
    sections=[dict(zip(SECTION_KEYS,struct.unpack('<IIQQQQIIQQ',shraw[i:i+64]))) for i in range(0,len(shraw),64)]
    names_section=sections[h['shstrndx']];names=bytes_region(path,names_section['offset'],names_section['size'])
    for index,s in enumerate(sections):
        require(s['nameIndex']<len(names),'Section name out of bounds')
        end=names.find(b'\0',s['nameIndex']);require(end>=0,'Unterminated section name')
        s['index']=index;s['name']=names[s['nameIndex']:end].decode('ascii')
        if s['type']!=8:
            require(s['offset']+s['size']<=pin['bytes'],'Section outside file')
            s['sha256']=digest_region(path,s['offset'],s['size'])
    require(len({s['name'] for s in sections})==len(sections),'Duplicate section name')
    return dict(pin=pin,header=h,headerBytes=raw,programHeaders=ph,programHeaderBytes=phraw,sections=sections)


def differences(old,new,base=0):
    require(len(old)==len(new),'Equal span sizes required')
    return [dict(offset=base+i,old=a,new=b) for i,(a,b) in enumerate(zip(old,new)) if a!=b]


def gaps(elf):
    h=elf['header'];ranges=[(0,64,'ELF header'),(h['phoff'],h['phoff']+h['phnum']*56,'program headers'),(h['shoff'],elf['pin']['bytes'],'section headers')]
    ranges.extend((s['offset'],s['offset']+s['size'],s['name']) for s in elf['sections'] if s['type']!=8 and s['size'])
    ranges.sort();end=0;result=[];last='start'
    for start,stop,name in ranges:
        require(start>=end,'Overlapping ELF metadata/sections not admitted')
        if start>end:
            data=bytes_region(elf['pin']['file'],end,start-end)
            result.append(dict(before=name,after=last,offset=end,bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),allZero=not any(data)))
        end=stop;last=name
    require(end==elf['pin']['bytes'],'Unaccounted ELF trailer')
    return result


def audit(old_path,new_path,old_object,new_object):
    old=parse(old_path);new=parse(new_path)
    report=dict(kind='phase174-elf-metadata-audit',version=1,complete=False,targetsRun=False,
        old=old['pin'],new=new['pin'],oldObjectPath=str(Path(old_object).resolve()),newObjectPath=str(Path(new_object).resolve()))
    oh,nh=old['header'],new['header']
    changed_header=[k for k in HEADER_KEYS if oh[k]!=nh[k]]
    require(changed_header==['shoff'],'Only ELF e_shoff may differ')
    require(old['programHeaderBytes']==new['programHeaderBytes'],'Program headers differ')
    report.update(headerDifferences=[dict(field=k,old=oh[k],new=nh[k]) for k in changed_header],headerByteDifferences=differences(old['headerBytes'],new['headerBytes']),programHeadersEqual=True,programHeaders=old['programHeaders'])
    require(len(old['sections'])==len(new['sections']),'Section counts differ')
    section_rows=[];alloc_count=0
    build_id_name='.note.gnu.build-id'
    os={s['name']:s for s in old['sections']};ns={s['name']:s for s in new['sections']}
    ob,nb=os[build_id_name],ns[build_id_name]
    require(ob['type']==nb['type']==7 and ob['flags']==nb['flags']==2 and ob['size']==nb['size']==36 and ob['offset']==nb['offset'],'Exact GNU build-id note layout required')
    obdata=bytes_region(old_path,ob['offset'],ob['size']);nbdata=bytes_region(new_path,nb['offset'],nb['size'])
    require(obdata[:16]==nbdata[:16]==struct.pack('<III',4,20,3)+b'GNU\0','Exact GNU 20-byte build-id note required')
    build_id_start=ob['offset']+16;build_id_end=build_id_start+20
    report['buildId']=dict(section=build_id_name,descriptorOffset=build_id_start,descriptorBytes=20,old=obdata[16:].hex(),new=nbdata[16:].hex(),headerAndNameEqual=True)
    def metadata_offset(pos):return 40<=pos<48 or build_id_start<=pos<build_id_end
    for a,b in zip(old['sections'],new['sections']):
        require(a['name']==b['name'],'Section order differs')
        fields=[k for k in SECTION_KEYS if a[k]!=b[k]]
        expected={'.strtab':['size'],'.shstrtab':['offset']}.get(a['name'],[])
        require(fields==expected,'Unexpected section metadata difference: '+a['name'])
        same_data=a.get('sha256')==b.get('sha256')
        require(same_data or a['name'] in ('.symtab','.strtab',build_id_name),'Unexpected changed section contents: '+a['name'])
        if a['flags']&2:
            require(not fields and (same_data or a['name']==build_id_name),'Allocatable section differs beyond GNU build-id: '+a['name']);alloc_count+=1
        section_rows.append(dict(name=a['name'],index=a['index'],allocatable=bool(a['flags']&2),type=a['type'],oldOffset=a['offset'],newOffset=b['offset'],oldBytes=a['size'],newBytes=b['size'],oldSha256=a.get('sha256'),newSha256=b.get('sha256'),contentEqual=same_data,changedFields=fields))
    report.update(sections=section_rows,allocatedSectionsEqual=False,allocatedSectionsExceptGnuBuildIdEqual=True,allocatedSectionCount=alloc_count)
    os={s['name']:s for s in old['sections']};ns={s['name']:s for s in new['sections']}
    ot=bytes_region(old_path,os['.strtab']['offset'],os['.strtab']['size']);nt=bytes_region(new_path,ns['.strtab']['offset'],ns['.strtab']['size'])
    of=report['oldObjectPath'].encode()+b'\0';nf=report['newObjectPath'].encode()+b'\0'
    require(ot.count(of)==1,'Original object filename not unique')
    position=ot.index(of);delta=len(nf)-len(of)
    require(ot[:position]+nf+ot[position+len(of):]==nt,'String table differs beyond the one object filename')
    require(delta==-9 and ns['.strtab']['size']-os['.strtab']['size']==delta,'Unexpected filename-size difference')
    report['stringTableEdit']=dict(offset=position,oldBytes=len(of),newBytes=len(nf),byteDelta=delta,old=report['oldObjectPath'],new=report['newObjectPath'],exactSingleReplacement=True)
    st,tt=os['.symtab'],ns['.symtab']
    require(st['entryBytes']==tt['entryBytes']==24 and st['size']==tt['size'] and st['size']%24==0,'Unsupported symbol table')
    pointer_changes=0;name_changes=[];records_hash=hashlib.sha256();raw_differences=0
    with Path(old_path).open('rb') as a,Path(new_path).open('rb') as b:
        a.seek(st['offset']);b.seek(tt['offset'])
        for index in range(st['size']//24):
            ar=a.read(24);br=b.read(24);av=struct.unpack('<IBBHQQ',ar);bv=struct.unpack('<IBBHQQ',br)
            require(av[1:]==bv[1:],'Symbol value/type/size/section differs')
            require(av[0]<len(ot) and bv[0]<len(nt),'Symbol name out of bounds')
            ae=ot.find(b'\0',av[0]);be=nt.find(b'\0',bv[0]);require(ae>=0 and be>=0,'Unterminated symbol name')
            an,bn=ot[av[0]:ae],nt[bv[0]:be]
            expected_pointer=av[0] if av[0]<=position else av[0]+delta
            require(bv[0]==expected_pointer,'Unexpected symbol-name pointer adjustment')
            if an!=bn:
                require(an==of[:-1] and bn==nf[:-1] and av[0]==position and av[1:]==(4,0,65521,0,0),'Changed symbol is not the exact STT_FILE path')
                name_changes.append(dict(index=index,type='STT_FILE',old=an.decode(),new=bn.decode()))
            if av[0]!=bv[0]:pointer_changes+=1
            raw_differences+=sum(x!=y for x,y in zip(ar,br))
            records_hash.update(ar);records_hash.update(br)
    require(len(name_changes)==1,'Exactly one changed filename symbol required')
    report['symbols']=dict(count=st['size']//24,changedNamePointers=pointer_changes,changedNameRecords=name_changes,allOtherDecodedSymbolsEqual=True,allNonNameFieldsEqual=True,rawDifferingBytes=raw_differences,allPairRecordsSha256=records_hash.hexdigest())
    og,ng=gaps(old),gaps(new);require(len(og)==len(ng),'Gap count differs')
    gap_rows=[]
    for a,b in zip(og,ng):
        require((a['before'],a['after'])==(b['before'],b['after']),'Gap placement differs')
        special=a['after']=='.shstrtab' and a['before']=='section headers'
        if special:require(a['allZero'] and b['allZero'] and a['bytes']<8 and b['bytes']<8 and oh['shoff']%8==nh['shoff']%8==0,'Invalid section-table alignment padding')
        else:require(a==b,'Unexplained bytes outside sections')
        gap_rows.append(dict(old=a,new=b,sectionTableAlignmentPadding=special))
    report['gaps']=gap_rows
    load_rows=[];loaded_diffs=[]
    for index,header in enumerate(old['programHeaders']):
        if header['type']!=1:continue
        require(header['fileBytes']<=header['memoryBytes'],'Invalid PT_LOAD zero fill')
        same=True;normalized=True;count=0;left=header['fileBytes'];offset=header['offset']
        with Path(old_path).open('rb') as a,Path(new_path).open('rb') as b:
            a.seek(offset);b.seek(offset)
            while left:
                ar=a.read(min(CHUNK,left));br=b.read(len(ar));require(ar and len(ar)==len(br),'Truncated PT_LOAD')
                if ar!=br:
                    same=False
                    for pos,x,y in ((offset+i,x,y) for i,(x,y) in enumerate(zip(ar,br)) if x!=y):
                        count+=1;require(metadata_offset(pos),'Runtime PT_LOAD byte differs outside explicitly audited metadata')
                        loaded_diffs.append(dict(offset=pos,old=x,new=y,programHeader=index,virtualAddress=header['address']+pos-header['offset']))
                    normalized=normalized and all(x==y or metadata_offset(offset+i) for i,(x,y) in enumerate(zip(ar,br)))
                offset+=len(ar);left-=len(ar)
        load_rows.append(dict(programHeader=index,offset=header['offset'],bytes=header['fileBytes'],exactBytesEqual=same,differingBytes=count,bytesEqualExceptExplicitMetadata=normalized))
    require(loaded_diffs and all(r['bytesEqualExceptExplicitMetadata'] for r in load_rows),'Expected narrow header exception absent')
    require(common.pin(old_path)==old['pin'] and common.pin(new_path)==new['pin'],'ELF inputs changed during audit')
    report.update(loadSegments=load_rows,loadedByteDifferences=loaded_diffs,loadedSegmentsEqual=False,wholeELFEqual=False,
        loaderRelevantHeadersEqual=True,loadedBytesExceptExplicitMetadataEqual=True,
        eShoffOnlyExceptionSufficient=False,
        admittedMetadataRanges=[dict(field='ELF64 e_shoff',offset=40,bytes=8),dict(field='GNU build-id descriptor',offset=build_id_start,bytes=20)],
        allNonloadedDifferencesExplained=True,runtimeImageEquivalent=True,complete=True,
        equivalenceScope='Identical program headers, entry point, all allocatable sections except the GNU build-id note, and every PT_LOAD byte except ELF e_shoff[40:48] and its authenticated 20-byte descriptor. All mapped differences are listed explicitly. All nonloaded file changes are the exact linker STT_FILE object-path replacement, corresponding symbol-name offsets, section offsets/sizes and zero alignment padding. Execution-image equivalence assumes ordinary ELF loading and no file/header/build-id introspection; this is neither whole-file nor all-mapped-byte identity. No claim about build-id hashing causation is needed.')
    return report


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    require(not args.out.exists(),'Refuse replacing existing ELF audit')
    old=ROOT/'selfhost/build/phase171/native-candidate01/program';new=ROOT/'selfhost/build/phase174/native-n2/program'
    result=audit(old,new,old.with_name('program.o'),new.with_name('program.o'))
    result['method']=common.pin(__file__);args.out.parent.mkdir(parents=True,exist_ok=True);common.write_json(args.out,result)
    print(json.dumps({k:result[k] for k in ('complete','loadedSegmentsEqual','runtimeImageEquivalent','allocatedSectionCount')}))


if __name__=='__main__':main()
