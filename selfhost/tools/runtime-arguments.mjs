// A declaration on the executing provider selects its CLI. The active language
// pin does not change the convention of an already linked historical image.
export function runtimeArgumentConvention(provider={}) {
  if(!provider||typeof provider!=='object'||Array.isArray(provider))throw Error('Runtime provider metadata required');
  const value=provider.runtimeArgumentConvention===undefined?'bend-legacy-v1':provider.runtimeArgumentConvention;
  if(!['bend-legacy-v1','bend-rts-v1'].includes(value))throw Error('Unknown runtime argument convention: '+value);
  return value;
}
export function runtimeArguments(provider={}, {application=false,options=['--threads','1','--gpu','off']}={}) {
  return runtimeArgumentConvention(provider)==='bend-rts-v1'
    ?['+RTS',...options,'-RTS',...(application?['--RTS']:[])]
    :[...options,...(application?['--']:[])];
}
export function runtimeTemplateConvention(artifact, runtimeSha256) {
  if(artifact?.version!==1||artifact.runtimeSha256!==runtimeSha256)
    throw Error('Runtime argument template does not bind the selected runtime bytes');
  return runtimeArgumentConvention(artifact);
}
