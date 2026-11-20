#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern uint64_t p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_(
    void *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t);

int __wrap_main(void) {
    uint64_t leaf=UINT64_C(72237913944883200);
    uint64_t fuels[]={0,1,2,8,65,1024};
    uint64_t leaves[]={leaf,leaf|123,(UINT64_C(164)<<40)|UINT64_C(0xffffffff),
                       (UINT64_C(0xff)<<56)|(UINT64_C(164)<<40)|7};
    uint64_t paths[]={0,1,UINT64_C(0x0100110000000000)};
    unsigned checks=0;
    for (unsigned f=0;f<6;f++)
      for (unsigned l=0;l<4;l++)
        for (unsigned p=0;p<3;p++) {
            uint64_t out[]={55,66,77,88};
            uint64_t status=p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_(
                0,out+1,fuels[f],7,leaves[l],paths[p]);
            if (status || out[0]!=55 || out[3]!=88 || out[1]!=(fuels[f]?leaf:leaves[l]) || out[2]!=paths[p])
                return 1;
            checks++;
        }
    printf("%u\n",checks);
    return 0;
}
