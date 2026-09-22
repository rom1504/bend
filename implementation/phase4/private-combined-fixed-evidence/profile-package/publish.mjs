import fs from 'node:fs';import path from 'node:path';
import {verifyIdentity} from './common.mjs';
export function publishCheckedOutput(directory,observation,mode) {
 const result=observation.result,expected=result?.status==='ok'&&result.phase==='compile'&&result.checked===true&&['compile','library'].includes(mode);
 if(!observation.emitted){if(expected)throw Error('Successful checked compile has no emitted artifact');return;}
 if(!expected)throw Error('Refusing emitted artifact outside successful checked compile');
 const out=fs.realpathSync(directory),pending=path.join(out,'generated.mjs.pending'),target=path.join(out,'generated.mjs');
 if(observation.emitted.file!==pending||!fs.lstatSync(pending).isFile()||fs.realpathSync(pending)!==pending)throw Error('Unexpected worker output path');
 if(fs.existsSync(target))throw Error('Published output already exists');
 verifyIdentity({...observation.emitted,canonicalPath:pending});
 if(fs.statSync(pending).size!==observation.emitted.bytes)throw Error('Emitted byte count changed');
 fs.renameSync(pending,target);observation.emitted.file=target;observation.emitted.published=true;
}
