// Actual checked-source probes for the bounded Bend entry certificate factory.
// Corruption controls below are labeled data mutations, never checked source.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const script=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,captureArg,outArg]=process.argv.slice(2);
if(!apiArg||!captureArg||!outArg)throw Error('usage: admission/check.mjs API CHECKED_CAPTURE FRESH_OUT');
const pin=file=>{const bytes=fs.readFileSync(file);return {file:path.resolve(file),bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=row=>{const found=pin(path.resolve(root,row.file));if(found.bytes!==row.bytes||found.sha256!==row.sha256)throw Error('changed '+row.file);return found;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=value=>{const items=[];while(value?.$==='Con'){items.push(value.head);value=value.tail;}if(value?.$!=='Nil')throw Error('bad Bend list');return items;};
const clone=value=>JSON.parse(JSON.stringify(value));
const role=value=>({NxeString:'String',NxeListString:'List<String>',NxeUnknown:'unknown'}[value?.$]??'invalid');
const apiFile=path.resolve(apiArg),captureFile=path.resolve(captureArg,'report.json'),out=path.resolve(outArg);
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep))throw Error('fresh Phase110 output required');
const manifestFile=path.join(root,'selfhost/tools/performance/phase110/controls/admission/manifest.json');
const manifest=read(manifestFile),oracleFile=path.resolve(root,manifest.oracle.file),oracle=read(oracleFile),captured=read(captureFile);
const source=verify(manifest.source);verify(manifest.oracle);verify(manifest.baseSource);
const trustedBase=pin(path.join(root,'selfhost/dist/base.bend'));
if(trustedBase.sha256!==manifest.baseSource.sha256||trustedBase.bytes!==manifest.baseSource.bytes)throw Error('driver Base differs from frozen Base contract');
if(!captured.complete||captured.result?.checked!==true||captured.result?.exitCode!==0)throw Error('incomplete checked capture');
for(const row of [...captured.inputs,...captured.products,...captured.sourceFiles])verify(row);
if(!captured.sourceFiles.some(row=>path.resolve(row.file)===source.file&&row.sha256===source.sha256)||
   !captured.sourceFiles.some(row=>path.resolve(row.file)===trustedBase.file&&row.sha256===trustedBase.sha256)||
   !captured.inputs.some(row=>path.resolve(row.file)===trustedBase.file&&row.sha256===trustedBase.sha256))throw Error('capture source or trusted Base path/bytes differs');
const typedFile=path.resolve(captureArg,'checked-graph.json'),erasedFile=path.resolve(captureArg,'native-facts.json');
for(const file of [typedFile,erasedFile])if(!captured.products.some(row=>path.resolve(row.file)===file))throw Error('unauthenticated capture product '+file);
const typed=read(typedFile),erased=read(erasedFile),definitions=array(typed),facts=array(erased);
const exact=(items,name)=>{const found=items.filter(row=>row.name===name);if(found.length!==1)throw Error('expected exactly one captured definition '+name);return found[0];};
const api=(await import(pathToFileURL(apiFile))).default;
if(typeof api.nxe_entry!=='function'||typeof api.nxe_layout_ok!=='function')throw Error('prototype API missing');
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase110-checked-entry-certificate-probes',complete:false,
  trustedBase,
  inputs:[pin(script),pin(apiFile),pin(manifestFile),pin(oracleFile),source,trustedBase,...captured.inputs,...captured.products,...captured.sourceFiles],
  rows:[],mutations:[],limits:['Entry role/layout certificate only; no body, call-closure, native execution or generic specialization claim.',
    'Source and erased identities are authenticated by this one checked capture; raw API inputs are not trusted provenance.',
    'Corruption controls are explicit mutated data and are not represented as checked source cases.']};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  if(api.nxe_layout_ok(typed)!==true)throw Error('actual canonical Base layout refused');
  for(const test of oracle.entryCases){
    const original=exact(definitions,test.name),fact=exact(facts,test.name),result=api.nxe_entry(typed,erased,test.name);
    const accepted=result.certificate?.$==='Some'&&!result.error;
    const row={name:test.name,expectedAccepted:test.entryCertificateAccepted,accepted,error:result.error,sourceArity:original.arity,erasedArity:fact.arity};
    if(accepted){
      const certificate=result.certificate.value;
      row.parameters=array(certificate.params).map(role);row.result=role(certificate.result);
      if(JSON.stringify(row.parameters)!==JSON.stringify(test.parameterRoles)||row.result!==test.resultRole)throw Error('wrong certified roles '+test.name);
      if(JSON.stringify(certificate.source)!==JSON.stringify(original)||JSON.stringify(certificate.erased)!==JSON.stringify(fact))throw Error('certificate changed source/fact '+test.name);
      const constructors=array(certificate.constructors).map(({name,cid,arity})=>[name,cid,arity]);
      if(JSON.stringify(constructors)!==JSON.stringify([['Nil',0,0],['Con',1,2],['SNil',2,0],['SCon',3,2]]))throw Error('wrong runtime constructor map');
      fs.writeFileSync(path.join(out,test.name+'.certificate.json'),JSON.stringify(certificate,null,2)+'\n');
    }
    if(Object.hasOwn(test,'closedLibraryAccepted')){
      if(typeof api.nxe_close!=='function')throw Error('closed-library API missing');
      const closure=api.nxe_close(typed,erased,list([{$:'NxeRoot',source:test.name,symbol:'entry'}]));
      row.closedLibraryAccepted=!closure.error;row.closureError=closure.error;
      if(row.closedLibraryAccepted!==test.closedLibraryAccepted)throw Error('closed-library expectation mismatch '+test.name);
    }
    report.rows.push(row);save();
    if(accepted!==test.entryCertificateAccepted)throw Error('entry expectation mismatch '+test.name);
  }
  const entry='p110_cert_list_identity';
  const mutate=(name,change)=>{
    const sourceRows=clone(definitions),factRows=clone(facts);change(sourceRows,factRows);
    const result=api.nxe_entry(list(sourceRows),list(factRows),entry),refused=result.certificate?.$==='None'&&!!result.error;
    report.mutations.push({name,refused,error:result.error});save();if(!refused)throw Error('corruption admitted '+name);
  };
  mutate('erased-arity-mismatch',(ds,es)=>{exact(es,entry).arity=2;});
  mutate('Base-provenance-removed',(ds,es)=>{exact(ds,'String').native=false;});
  mutate('Base-List-arity-changed',(ds,es)=>{exact(ds,'List').arity=1;});
  mutate('Base-constructor-order-swapped',(ds,es)=>{const owner=exact(ds,'List');owner.ctors=list(array(owner.ctors).reverse());});
  mutate('Base-constructor-live-width-changed',(ds,es)=>{exact(array(exact(ds,'List').ctors),'Con').arity=1;});
  mutate('Base-constructor-head-type-changed',(ds,es)=>{
    const term=exact(array(exact(ds,'List').ctors),'Con').typ;
    const element=term.kids.tail.head,head=element.kids.tail.head;
    head.kids.head={...head.kids.head,tag:'Ref',name:'U32',id:0};
  });
  mutate('Base-constructor-recursive-element-binder-changed',(ds,es)=>{
    const term=exact(array(exact(ds,'List').ctors),'Con').typ;
    const element=term.kids.tail.head,head=element.kids.tail.head,tail=head.kids.tail.head;
    tail.kids.head.kids.tail.head.id=term.id;
  });
  mutate('duplicate-Base-identity',(ds,es)=>{ds.push(clone(exact(ds,'String')));});
  mutate('triple-Base-identity',(ds,es)=>{const d=clone(exact(ds,'String'));ds.push(clone(d),clone(d));});
  for(const row of report.inputs)verify(row);
  report.complete=true;report.sourceCases=report.rows.length;report.dataMutations=report.mutations.length;save();
  console.log(JSON.stringify({complete:true,sourceCases:report.sourceCases,dataMutations:report.dataMutations}));
}catch(error){report.error=String(error);save();throw error;}
