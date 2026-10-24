
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040acd0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_>:
  40acd0:	endbr64 
  40acd4:	push   %rbp
  40acd5:	mov    %rsp,%rbp
  40acd8:	sub    $0x828,%rsp
  40acdf:	push   %rbx
  40ace0:	push   %r12
  40ace2:	push   %r13
  40ace4:	push   %r14
  40ace6:	push   %r15
  40ace8:	mov    %rsi,%rax
  40aceb:	shr    $0x28,%rax
  40acef:	and    $0xffff,%rax
  40acf5:	cmp    $0x99,%rax
  40acfb:	sete   %cl
  40acfe:	movzbl %cl,%ecx
  40ad01:	cmp    $0x0,%ecx
  40ad04:	jne    40ad93 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_+0xc3>
  40ad0a:	cmp    $0x9a,%rax
  40ad10:	je     40ad6b <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_+0x9b>
  40ad12:	cmp    $0x9b,%rax
  40ad18:	je     40ad2e <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_+0x5e>
  40ad1a:	mov    $0x4,%esi
  40ad1f:	callq  432730 <p111_rt_fail>
  40ad24:	mov    $0x0,%eax
  40ad29:	jmpq   40aed7 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_+0x207>
  40ad2e:	lea    -0x820(%rbp),%rdx
  40ad35:	mov    %rdi,%rbx
  40ad38:	callq  437c20 <p125_rt_take4>
  40ad3d:	mov    %rbx,%rdi
  40ad40:	mov    -0x810(%rbp),%rsi
  40ad47:	mov    -0x808(%rbp),%r12
  40ad4e:	mov    %rdi,%rbx
  40ad51:	callq  431fa0 <p111_rt_sink>
  40ad56:	mov    %r12,%rsi
  40ad59:	mov    %rbx,%rdi
  40ad5c:	callq  431fa0 <p111_rt_sink>
  40ad61:	mov    $0x0,%eax
  40ad66:	jmpq   40aed7 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_+0x207>
  40ad6b:	lea    -0x820(%rbp),%rdx
  40ad72:	mov    %rdi,%rbx
  40ad75:	callq  437750 <p125_rt_take2>
  40ad7a:	mov    %rbx,%rdi
  40ad7d:	mov    -0x818(%rbp),%rsi
  40ad84:	callq  431fa0 <p111_rt_sink>
  40ad89:	mov    $0x0,%eax
  40ad8e:	jmpq   40aed7 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_+0x207>
  40ad93:	mov    $0x9,%ecx
  40ad98:	lea    -0x820(%rbp),%rdx
  40ad9f:	mov    %rdi,%rbx
  40ada2:	callq  432190 <p111_rt_take>
  40ada7:	mov    %rbx,%rdi
  40adaa:	mov    -0x820(%rbp),%rsi
  40adb1:	mov    -0x818(%rbp),%r12
  40adb8:	mov    -0x810(%rbp),%r13
  40adbf:	mov    -0x808(%rbp),%r15
  40adc6:	mov    -0x800(%rbp),%r14
  40adcd:	mov    -0x7f8(%rbp),%rbx
  40add4:	mov    %rbx,-0x8(%rbp)
  40add8:	mov    -0x7f0(%rbp),%rbx
  40addf:	mov    %rbx,-0x10(%rbp)
  40ade3:	mov    -0x7e8(%rbp),%rbx
  40adea:	mov    %rbx,-0x18(%rbp)
  40adee:	mov    -0x7e0(%rbp),%rbx
  40adf5:	mov    %rbx,-0x20(%rbp)
  40adf9:	mov    %rdi,%rbx
  40adfc:	callq  431fa0 <p111_rt_sink>
  40ae01:	mov    %r13,%rsi
  40ae04:	mov    %rbx,%rdi
  40ae07:	mov    -0x8(%rbp),%r13
  40ae0b:	mov    %rdi,%rbx
  40ae0e:	callq  431fa0 <p111_rt_sink>
  40ae13:	mov    %r15,%rsi
  40ae16:	mov    %rbx,%rdi
  40ae19:	mov    -0x10(%rbp),%r15
  40ae1d:	mov    %rdi,%rbx
  40ae20:	callq  431fa0 <p111_rt_sink>
  40ae25:	mov    %r14,%rsi
  40ae28:	mov    %rbx,%rdi
  40ae2b:	mov    -0x18(%rbp),%r14
  40ae2f:	mov    %rdi,%rbx
  40ae32:	callq  431fa0 <p111_rt_sink>
  40ae37:	mov    %r13,%rsi
  40ae3a:	mov    %rbx,%rdi
  40ae3d:	mov    -0x20(%rbp),%r13
  40ae41:	mov    %rdi,%rbx
  40ae44:	callq  431fa0 <p111_rt_sink>
  40ae49:	mov    %r15,%rsi
  40ae4c:	mov    %rbx,%rdi
  40ae4f:	mov    %rdi,%rbx
  40ae52:	callq  431fa0 <p111_rt_sink>
  40ae57:	mov    %r14,%rsi
  40ae5a:	mov    %rbx,%rdi
  40ae5d:	mov    %rdi,%rbx
  40ae60:	callq  431fa0 <p111_rt_sink>
  40ae65:	mov    %r13,%rsi
  40ae68:	mov    %rbx,%rdi
  40ae6b:	mov    %rdi,%rbx
  40ae6e:	callq  431fa0 <p111_rt_sink>
  40ae73:	mov    %r12,%rsi
  40ae76:	mov    %rbx,%rdi
  40ae79:	mov    %rdi,%rbx
  40ae7c:	callq  431f10 <p111_rt_keep>
  40ae81:	mov    %rbx,%rdi
  40ae84:	mov    %rax,%rsi
  40ae87:	mov    %rsi,%r12
  40ae8a:	movabs $0x20019000310867c,%rsi
  40ae94:	mov    %rdi,%rbx
  40ae97:	callq  431f10 <p111_rt_keep>
  40ae9c:	mov    %r12,%rsi
  40ae9f:	mov    %rbx,%rdi
  40aea2:	mov    %rax,%r13
  40aea5:	mov    $0x1,%ecx
  40aeaa:	mov    %r13,%rdx
  40aead:	mov    %rsi,%r12
  40aeb0:	mov    %rdi,%rbx
  40aeb3:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40aeb8:	mov    %r12,%rsi
  40aebb:	mov    %rbx,%rdi
  40aebe:	mov    %rax,%rbx
  40aec1:	mov    %rdi,%r12
  40aec4:	callq  431fa0 <p111_rt_sink>
  40aec9:	mov    %r13,%rsi
  40aecc:	mov    %r12,%rdi
  40aecf:	callq  431fa0 <p111_rt_sink>
  40aed4:	mov    %rbx,%rax
  40aed7:	pop    %r15
  40aed9:	pop    %r14
  40aedb:	pop    %r13
  40aedd:	pop    %r12
  40aedf:	pop    %rbx
  40aee0:	leaveq 
  40aee1:	retq   

Disassembly of section .fini:
