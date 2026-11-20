#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

typedef uint64_t Worker(void *, uint64_t *, uint64_t, uint64_t, uint64_t);
extern Worker p198_base0,p198_base1,p198_base2,p198_base3,p198_base4,p198_base5,p198_base6;
extern Worker p198_new0,p198_new1,p198_new2,p198_new3,p198_new4,p198_new5,p198_new6;
int main(void) {
  Worker *workers[7][2]={{p198_base0,p198_new0},{p198_base1,p198_new1},
                        {p198_base2,p198_new2},{p198_base3,p198_new3},{p198_base4,p198_new4},
                        {p198_base5,p198_new5},{p198_base6,p198_new6}};
  uint64_t k=(UINT64_C(1)<<56)|(UINT64_C(173)<<40);
  uint64_t full=UINT64_C(0xfedcba9876543210);
  uint64_t words[]={0,7,9,k,k|731,(UINT64_C(255)<<56)|(UINT64_C(173)<<40)|19,
                    full,full^UINT64_C(0x8000000000000000),UINT64_MAX};
  uint64_t counts[]={0,1,2,8,65,1024};
  uint64_t inputs[]={0,3,UINT64_MAX-7};
  unsigned checks=0,errors=0;
  for(unsigned mode=0;mode<7;mode++)for(unsigned w=0;w<9;w++)
    for(unsigned f=0;f<6;f++)for(unsigned d=0;d<3;d++) {
      uint64_t word=words[w],data=inputs[d],fuel=counts[f];
      for(uint64_t j=0;j<fuel;j++) {
        if(mode==0 && ((word>>40)&65535)==173)word=k;
        else if((mode==1 || mode==3) && word==full)word=full;
        else if(mode==2 && word!=7)word=9;
        else if(mode>=4 && ((word>>40)&65535)==173){
          if(mode==4)word=k^(UINT64_C(1)<<40);
          if(mode==5){word=k;data++;}
          if(mode==6){data=word;word=k;}
        } else data++;
      }
      for(unsigned r=0;r<2;r++){
        uint64_t out[]={99,0,0,313};
        uint64_t status=workers[mode][r](0,out+1,mode==3?words[w]:fuel,mode==3?fuel:words[w],inputs[d]);
        if(status||out[0]!=99||out[3]!=313||out[1]!=word||out[2]!=data)errors++;
        checks++;
      }
    }
  /* A positive absorbing edge is a closed form even at maximal word fuel. */
  for(unsigned mode=0;mode<4;mode++){
    uint64_t state=mode==0?(k|731):mode==2?8:full;
    uint64_t expected=mode==0?k:mode==2?9:full;
    uint64_t out[]={92,0,0,17};
    uint64_t status=workers[mode][1](0,out+1,mode==3?state:UINT64_MAX,mode==3?UINT64_MAX:state,123);
    if(status||out[0]!=92||out[3]!=17||out[1]!=expected||out[2]!=123)errors++;
    checks++;
  }
  printf("checks=%u errors=%u\n",checks,errors);
  return errors!=0;
}
