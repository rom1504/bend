
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040aef0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_>:
  40aef0:	endbr64 
  40aef4:	push   %rbp
  40aef5:	mov    %rsp,%rbp
  40aef8:	sub    $0x838,%rsp
  40aeff:	push   %rbx
  40af00:	push   %r12
  40af02:	push   %r13
  40af04:	push   %r14
  40af06:	push   %r15
  40af08:	mov    %rdx,%rax
  40af0b:	mov    %rax,%rcx
  40af0e:	shr    $0x28,%rcx
  40af12:	and    $0xffff,%rcx
  40af19:	cmp    $0x99,%rcx
  40af20:	sete   %dl
  40af23:	movzbl %dl,%edx
  40af26:	cmp    $0x0,%edx
  40af29:	jne    40b0ac <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x1bc>
  40af2f:	cmp    $0x9a,%rcx
  40af36:	je     40b013 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x123>
  40af3c:	nopl   0x0(%rax)
  40af40:	cmp    $0x9b,%rcx
  40af47:	je     40af6b <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x7b>
  40af49:	mov    %rsi,%r12
  40af4c:	mov    %rdi,%rbx
  40af4f:	callq  431fa0 <p111_rt_sink>
  40af54:	mov    %rbx,%rdi
  40af57:	mov    $0x4,%esi
  40af5c:	callq  432730 <p111_rt_fail>
  40af61:	mov    $0x0,%eax
  40af66:	jmpq   40b1f4 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x304>
  40af6b:	mov    %rsi,%r12
  40af6e:	mov    %rax,%rsi
  40af71:	lea    -0x830(%rbp),%rdx
  40af78:	mov    %rdi,%rbx
  40af7b:	callq  437c20 <p125_rt_take4>
  40af80:	mov    %rbx,%rdi
  40af83:	mov    -0x820(%rbp),%rsi
  40af8a:	mov    -0x818(%rbp),%r13
  40af91:	mov    %rdi,%rbx
  40af94:	callq  431fa0 <p111_rt_sink>
  40af99:	mov    %r13,%rsi
  40af9c:	mov    %rbx,%rdi
  40af9f:	mov    %rdi,%rbx
  40afa2:	callq  431fa0 <p111_rt_sink>
  40afa7:	mov    %r12,%rsi
  40afaa:	mov    %rbx,%rdi
  40afad:	mov    %rsi,%r12
  40afb0:	mov    %rdi,%rbx
  40afb3:	callq  431f10 <p111_rt_keep>
  40afb8:	mov    %rbx,%rdi
  40afbb:	mov    %rax,%rsi
  40afbe:	mov    %rsi,%r12
  40afc1:	movabs $0x100180000000000,%rsi
  40afcb:	mov    %rdi,%rbx
  40afce:	callq  431f10 <p111_rt_keep>
  40afd3:	mov    %r12,%rsi
  40afd6:	mov    %rbx,%rdi
  40afd9:	mov    %rax,%r13
  40afdc:	mov    $0x1,%ecx
  40afe1:	mov    %r13,%rdx
  40afe4:	mov    %rsi,%r12
  40afe7:	mov    %rdi,%rbx
  40afea:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40afef:	mov    %r12,%rsi
  40aff2:	mov    %rbx,%rdi
  40aff5:	mov    %rax,%rbx
  40aff8:	mov    %rdi,%r12
  40affb:	callq  431fa0 <p111_rt_sink>
  40b000:	mov    %r13,%rsi
  40b003:	mov    %r12,%rdi
  40b006:	callq  431fa0 <p111_rt_sink>
  40b00b:	mov    %rbx,%rax
  40b00e:	jmpq   40b1f4 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x304>
  40b013:	mov    %rsi,%r12
  40b016:	mov    %rax,%rsi
  40b019:	lea    -0x830(%rbp),%rdx
  40b020:	mov    %rdi,%rbx
  40b023:	callq  437750 <p125_rt_take2>
  40b028:	mov    %r12,%rsi
  40b02b:	mov    %rbx,%rdi
  40b02e:	mov    %rsi,%r12
  40b031:	mov    -0x828(%rbp),%rsi
  40b038:	mov    %rdi,%rbx
  40b03b:	callq  431fa0 <p111_rt_sink>
  40b040:	mov    %r12,%rsi
  40b043:	mov    %rbx,%rdi
  40b046:	mov    %rsi,%r13
  40b049:	mov    %rdi,%rbx
  40b04c:	callq  431f10 <p111_rt_keep>
  40b051:	mov    %rbx,%rdi
  40b054:	mov    %rax,%rsi
  40b057:	mov    %rsi,%r12
  40b05a:	movabs $0x100180000000000,%rsi
  40b064:	mov    %rdi,%rbx
  40b067:	callq  431f10 <p111_rt_keep>
  40b06c:	mov    %r12,%rsi
  40b06f:	mov    %rbx,%rdi
  40b072:	mov    %rax,%r13
  40b075:	mov    $0x1,%ecx
  40b07a:	mov    %r13,%rdx
  40b07d:	mov    %rsi,%r12
  40b080:	mov    %rdi,%rbx
  40b083:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40b088:	mov    %r12,%rsi
  40b08b:	mov    %rbx,%rdi
  40b08e:	mov    %rax,%rbx
  40b091:	mov    %rdi,%r12
  40b094:	callq  431fa0 <p111_rt_sink>
  40b099:	mov    %r13,%rsi
  40b09c:	mov    %r12,%rdi
  40b09f:	callq  431fa0 <p111_rt_sink>
  40b0a4:	mov    %rbx,%rax
  40b0a7:	jmpq   40b1f4 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x304>
  40b0ac:	mov    %rsi,%r13
  40b0af:	mov    %rax,%rsi
  40b0b2:	mov    $0x9,%ecx
  40b0b7:	lea    -0x830(%rbp),%rdx
  40b0be:	mov    %rdi,%rbx
  40b0c1:	callq  432190 <p111_rt_take>
  40b0c6:	mov    %rbx,%rdi
  40b0c9:	mov    -0x830(%rbp),%r12
  40b0d0:	mov    -0x828(%rbp),%rsi
  40b0d7:	mov    -0x820(%rbp),%r14
  40b0de:	mov    -0x818(%rbp),%r15
  40b0e5:	mov    -0x810(%rbp),%rbx
  40b0ec:	mov    %rbx,-0x10(%rbp)
  40b0f0:	mov    -0x808(%rbp),%rbx
  40b0f7:	mov    %rbx,-0x18(%rbp)
  40b0fb:	mov    -0x800(%rbp),%rbx
  40b102:	mov    %rbx,-0x20(%rbp)
  40b106:	mov    -0x7f8(%rbp),%rbx
  40b10d:	mov    %rbx,-0x28(%rbp)
  40b111:	mov    -0x7f0(%rbp),%rbx
  40b118:	mov    %rbx,-0x30(%rbp)
  40b11c:	mov    %rdi,%rbx
  40b11f:	callq  431fa0 <p111_rt_sink>
  40b124:	mov    %r14,%rsi
  40b127:	mov    %rbx,%rdi
  40b12a:	mov    -0x10(%rbp),%r14
  40b12e:	mov    %rdi,%rbx
  40b131:	callq  431fa0 <p111_rt_sink>
  40b136:	mov    %r15,%rsi
  40b139:	mov    %rbx,%rdi
  40b13c:	mov    -0x18(%rbp),%r15
  40b140:	mov    %rdi,%rbx
  40b143:	callq  431fa0 <p111_rt_sink>
  40b148:	mov    %r14,%rsi
  40b14b:	mov    %rbx,%rdi
  40b14e:	mov    -0x20(%rbp),%r14
  40b152:	mov    %rdi,%rbx
  40b155:	callq  431fa0 <p111_rt_sink>
  40b15a:	mov    %r15,%rsi
  40b15d:	mov    %rbx,%rdi
  40b160:	mov    -0x28(%rbp),%r15
  40b164:	mov    %rdi,%rbx
  40b167:	callq  431fa0 <p111_rt_sink>
  40b16c:	mov    %r14,%rsi
  40b16f:	mov    %rbx,%rdi
  40b172:	mov    -0x30(%rbp),%r14
  40b176:	mov    %rdi,%rbx
  40b179:	callq  431fa0 <p111_rt_sink>
  40b17e:	mov    %r15,%rsi
  40b181:	mov    %rbx,%rdi
  40b184:	mov    %rdi,%rbx
  40b187:	callq  431fa0 <p111_rt_sink>
  40b18c:	mov    %r14,%rsi
  40b18f:	mov    %rbx,%rdi
  40b192:	mov    %rdi,%rbx
  40b195:	callq  431fa0 <p111_rt_sink>
  40b19a:	mov    %r13,%rsi
  40b19d:	mov    %rbx,%rdi
  40b1a0:	mov    %rdi,%rbx
  40b1a3:	callq  431f10 <p111_rt_keep>
  40b1a8:	mov    %r12,%rsi
  40b1ab:	mov    %rbx,%rdi
  40b1ae:	mov    %rax,%r12
  40b1b1:	mov    %rdi,%rbx
  40b1b4:	callq  431f10 <p111_rt_keep>
  40b1b9:	mov    %r12,%rsi
  40b1bc:	mov    %rbx,%rdi
  40b1bf:	mov    %rax,%r13
  40b1c2:	mov    $0x1,%ecx
  40b1c7:	mov    %r13,%rdx
  40b1ca:	mov    %rsi,%r12
  40b1cd:	mov    %rdi,%rbx
  40b1d0:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40b1d5:	mov    %r12,%rsi
  40b1d8:	mov    %rbx,%rdi
  40b1db:	mov    %rax,%rbx
  40b1de:	mov    %rdi,%r12
  40b1e1:	callq  431fa0 <p111_rt_sink>
  40b1e6:	mov    %r13,%rsi
  40b1e9:	mov    %r12,%rdi
  40b1ec:	callq  431fa0 <p111_rt_sink>
  40b1f1:	mov    %rbx,%rax
  40b1f4:	pop    %r15
  40b1f6:	pop    %r14
  40b1f8:	pop    %r13
  40b1fa:	pop    %r12
  40b1fc:	pop    %rbx
  40b1fd:	leaveq 
  40b1fe:	retq   

Disassembly of section .fini:
