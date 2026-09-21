// Generate isolated filesystem graphs, including symlinks and absent assets.
import fs from 'node:fs';import path from 'node:path';
export function makeNativeGraphFixtures(directory,base){
  fs.mkdirSync(directory,{recursive:false});const cases=[];
  const add=(name,files,options={})=>{
    const dir=path.join(directory,name);fs.mkdirSync(dir);
    for(const [file,text]of Object.entries(files)){const out=path.join(dir,file);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,text);}
    for(const [alias,target]of Object.entries(options.symlinks??{}))fs.symlinkSync(target,path.join(dir,alias));
    const main=options.main??'main.bend';
    const modules=options.modules??Object.keys(files).filter(file=>file.endsWith('.bend')&&file!==main);
    const manifest={version:1,main,base,modules,assets:options.assets??Object.keys(files).filter(file=>file.endsWith('.js'))};
    const manifestFile=path.join(dir,'manifest.json');fs.writeFileSync(manifestFile,JSON.stringify(manifest,null,2)+'\n');
    cases.push({name,input:path.resolve(dir,main),manifest:manifestFile,mode:options.mode??'program',accepted:options.accepted??true,stdout:options.stdout??'42\n',...options});
  };
  const value='import Base\ndef answer() -> U32:\n  42\n';
  const main=imports=>`import Base\n${imports}\ndef main() -> IO(Unit):\n  IO.print(U32.show(A.answer()))\n`;
  add('nested-parent',{'main.bend':main('import ./sub/a.bend as A'),'sub/a.bend':'import Base\nimport ../shared/value.bend as V\ndef answer() -> U32:\n  V.answer()\n','shared/value.bend':value});
  add('diamond',{'main.bend':'import Base\nimport ./left.bend as L\nimport ./right.bend as R\ndef main() -> IO(Unit):\n  IO.print(U32.show((L.answer() + R.answer() : U32)))\n','left.bend':'import Base\nimport ./shared.bend as S\ndef answer() -> U32:\n  S.answer()\n','right.bend':'import Base\nimport ./shared.bend as S\ndef answer() -> U32:\n  S.answer()\n','shared.bend':value},{stdout:'84\n'});
  add('repeated-alias',{'main.bend':'import Base\nimport ./value.bend as A\nimport ././value.bend as B\ndef main() -> IO(Unit):\n  IO.print(U32.show((A.answer() + B.answer() : U32)))\n','value.bend':value},{stdout:'84\n'});
  add('unused-malformed',{'main.bend':main('import ./value.bend as A'),'value.bend':value,'unused.bend':'this is not Bend!!!'});
  add('unicodé 猫',{'main.bend':main('import ./value.bend as A'),'value.bend':value});
  add('non-bmp-source',{'main.bend':'import Base\ndef main() -> IO(Unit):\n  IO.print("😀🦋猫")\n'},{stdout:'😀🦋猫\n'});
  add('symlink-main',{'real.bend':main('import ./value.bend as A'),'value.bend':value},{main:'main.bend',symlinks:{'main.bend':'real.bend'}});
  add('namespace-conflict',{'main.bend':main('import ./value.bend as A\nimport ./alias.bend as B'),'value.bend':value},{modules:['value.bend','alias.bend'],symlinks:{'alias.bend':'value.bend'},accepted:false,phase:'parse',checked:false});
  add('cycle',{'main.bend':main('import ./a.bend as A'),'a.bend':'import Base\nimport ./b.bend as B\ndef answer() -> U32:\n  42\n','b.bend':'import Base\nimport ./a.bend as A\ndef other() -> U32:\n  1\n'},{accepted:false,phase:'parse',checked:false});
  add('missing-module',{'main.bend':main('import ./missing.bend as A')},{accepted:false,phase:'load',checked:false});
  add('imported-parse-error',{'main.bend':main('import ./bad.bend as A'),'bad.bend':'def bad(\n'},{accepted:false,phase:'parse',checked:false});
  add('imported-type-error',{'main.bend':main('import ./bad.bend as A'),'bad.bend':'import Base\ndef answer() -> U32:\n  "bad"\n'},{accepted:false,phase:'check',checked:true});
  add('imported-adt',{'main.bend':'import Base\nimport ./box.bend as B\ndef main() -> IO(Unit):\n  IO.print(U32.show(B.get(B.Box{42})))\n','box.bend':'import Base\ntype Box is Data:\n  Box{value: U32}\ndef get(box: Box) -> U32:\n  match box:\n    case Box{value}: value\n'});
  add('imported-template',{'main.bend':'import Base\nimport ./template.bend as T\ndef main() -> IO(Unit):\n  IO.print(U32.show(T.twice(~(x => (x + 21 : U32)), 0)))\n','template.bend':'import Base\ndef twice(~f: U32 -> U32, x: U32) -> U32:\n  f(f(x))\n'});
  add('library',{'main.bend':'import Base\nimport ./value.bend as A\ndef answer() -> U32:\n  A.answer()\n','value.bend':value},{mode:'library',export:'answer',value:42});
  const foreign='import Base\ndef external() -> IO(U32):\n  import "./external.js"\n';
  add('foreign-imported',{'main.bend':'import Base\nimport ./foreign.bend as F\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- F.external()\n    IO.print(U32.show(x))\n','foreign.bend':foreign,'external.js':'function external() { return 42; }\n'});
  add('foreign-shared',{'main.bend':'import Base\ndef one() -> IO(U32):\n  import "./external.js"\ndef two() -> IO(U32):\n  import "./external.js"\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- one()\n    y : U32 <- two()\n    IO.print(U32.show((x + y : U32)))\n','external.js':'function one() { return 20; }\nfunction two() { return 22; }\n'});
  add('missing-unused-asset',{'main.bend':foreign+'\ndef main() -> IO(Unit):\n  IO.print("42")\n'},{assets:['external.js']});
  add('missing-required-asset',{'main.bend':foreign+'\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- external()\n    IO.print(U32.show(x))\n'},{assets:['external.js'],accepted:false,phase:'compile',checked:true});
  add('undeclared-required-asset',{'main.bend':foreign+'\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- external()\n    IO.print(U32.show(x))\n','external.js':'function external() { return 42; }\n'},{assets:[],accepted:false,phase:'compile',checked:true,scopeDifference:true,hostAccepted:true});
  add('foreign-alias-precedence',{'main.bend':'import Base\ndef external() -> IO(U32):\n  import "./actual.js"\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- external()\n    IO.print(U32.show(x))\n','actual.js':'function external() { return 42; }\n','correct.js':'function external() { return 42; }\n'},{assets:[{name:'other.js',path:'actual.js'},{name:'actual.js',path:'correct.js'}],usedAssetIds:[1]});
  add('foreign-unicode-path',{'main.bend':'import Base\ndef external() -> IO(U32):\n  import "./external 猫.js"\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- external()\n    IO.print(U32.show(x))\n','external 猫.js':'function external() { return 42; }\n'});
  add('foreign-no-js',{'main.bend':'import Base\ndef external() -> IO(U32):\n  import "./external.c"\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    x : U32 <- external()\n    IO.print(U32.show(x))\n'},{accepted:false,phase:'compile',checked:true});
  add('imported-todo',{'main.bend':main('import ./hole.bend as A'),'hole.bend':'import Base\nlaw answer:\n  U32\n'},{accepted:false,phase:'check',checked:true});
  return cases;
}
