// File.read's upstream JS effect uses bun:ffi. Supply only the read syscall
// transport for the Node-hosted pilot, through the runtime's BEND_SYS hook.
// No Bend algorithms or generated compiler functions are replaced.
const fs=require('node:fs');
let errno=0;
globalThis.BEND_SYS={
  ptr:bytes=>bytes,
  read(fd,bytes,length){try{return fs.readSync(fd,bytes,0,length,null);}catch(e){errno=Math.abs(e.errno??5);return -1;}},
  errno:()=>errno,
  strerror:code=>'errno '+code,
};
