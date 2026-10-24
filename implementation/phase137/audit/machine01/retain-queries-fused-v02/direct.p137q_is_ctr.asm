
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409960 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_116_114_>:
  409960:	endbr64 
  409964:	push   %rbp
  409965:	mov    %rsp,%rbp
  409968:	push   %rbx
  409969:	push   %r12
  40996b:	mov    $0x1,%ecx
  409970:	mov    $0x0,%edx
  409975:	mov    %rsi,%r12
  409978:	mov    %rdi,%rbx
  40997b:	callq  437e00 <p118_rt_borrow_scalar_safe>
  409980:	mov    %r12,%rsi
  409983:	mov    %rbx,%rdi
  409986:	cmp    $0x0,%rax
  40998a:	jne    409993 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_116_114_+0x33>
  40998c:	callq  4090c0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_>
  409991:	jmp    4099af <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_116_114_+0x4f>
  409993:	mov    %rsi,%r12
  409996:	mov    %rdi,%rbx
  409999:	callq  4092e0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_99_116_114_>
  40999e:	mov    %r12,%rsi
  4099a1:	mov    %rbx,%rdi
  4099a4:	mov    %rax,%rbx
  4099a7:	callq  431fa0 <p111_rt_sink>
  4099ac:	mov    %rbx,%rax
  4099af:	pop    %r12
  4099b1:	pop    %rbx
  4099b2:	leaveq 
  4099b3:	retq   

Disassembly of section .fini:
