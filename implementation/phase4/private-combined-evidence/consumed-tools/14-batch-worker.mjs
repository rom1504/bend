// Internal sequential IPC worker. Only data requests/results cross this boundary.
import fs from 'node:fs';import path from 'node:path';
import {readJson,verifyImage,verifyIdentity,identity} from './common.mjs';import {createPrivateSession} from './session.mjs';
const [configFile]=process.argv.slice(2);if(!process.send||!configFile)throw Error('Batch worker requires its supervised IPC configuration');
const configIdentity=identity(configFile),config=readJson(configFile),directory=fs.realpathSync(config.directory);
if(fs.realpathSync(process.execPath)!==config.node.canonicalPath||process.version!==config.node.version)throw Error('Worker Node runtime differs from supervised executable');
const session=await createPrivateSession(config.image);let busy=false,count=0;
process.on('message',async message=>{
 if(busy){process.send({kind:'fatal',error:'Concurrent private requests are forbidden'});process.exitCode=2;process.disconnect();return;}
 if(message?.kind==='finish'){
  try{verifyIdentity(configIdentity);verifyImage(config.image);process.send({kind:'finished',count},()=>process.disconnect());}catch(error){process.send({kind:'fatal',error:String(error)},()=>process.disconnect());process.exitCode=2;}return;
 }
 if(message?.kind!=='request'||!Number.isInteger(message.index)||message.index<0||message.index>=256||count>=32){process.send({kind:'fatal',error:'Invalid finite private request'},()=>process.disconnect());process.exitCode=2;return;}
 busy=true;
 try{
  const out=path.join(directory,String(message.index).padStart(3,'0'));
  if(fs.realpathSync(out)!==out)throw Error('Request output directory must be canonical');
  await session.inspect(message.request,out);count++;busy=false;process.send({kind:'result',index:message.index});
 }catch(error){busy=false;process.send({kind:'fatal',index:message.index,error:error.stack},()=>process.disconnect());process.exitCode=2;}
});
process.on('disconnect',()=>{if(busy)process.exit(2);});
process.send({kind:'ready',node:{file:process.execPath,version:process.version,args:process.execArgv},manifest:session.manifestIdentity});
