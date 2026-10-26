
/home/ai/bend2/build/publish/bend/selfhost/build/phase134/p144-integrated-n1-01/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000eaabd0 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_>:
  eaabd0:	endbr64 
  eaabd4:	push   %rbp
  eaabd5:	mov    %rsp,%rbp
  eaabd8:	sub    $0x1028,%rsp
  eaabdf:	push   %rbx
  eaabe0:	push   %r12
  eaabe2:	push   %r13
  eaabe4:	push   %r14
  eaabe6:	push   %r15
  eaabe8:	mov    0x28(%rdi),%rsi
  eaabec:	mov    0x30(%rdi),%r12
  eaabf0:	mov    0x38(%rdi),%rbx
  eaabf4:	mov    %rsi,%rax
  eaabf7:	shr    $0x28,%rax
  eaabfb:	and    $0xffff,%rax
  eaac01:	cmp    $0x99,%rax
  eaac07:	sete   %cl
  eaac0a:	movzbl %cl,%ecx
  eaac0d:	cmp    $0x0,%ecx
  eaac10:	jne    eab1cd <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x5fd>
  eaac16:	cmp    $0x9a,%rax
  eaac1c:	sete   %cl
  eaac1f:	movzbl %cl,%ecx
  eaac22:	mov    $0xffffffff,%edx
  eaac27:	mov    %rbx,%r14
  eaac2a:	and    %rdx,%r14
  eaac2d:	mov    %r14,-0x8(%rbp)
  eaac31:	cmp    $0x0,%ecx
  eaac34:	jne    eaafbf <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x3ef>
  eaac3a:	nopw   0x0(%rax,%rax,1)
  eaac40:	cmp    $0x9b,%rax
  eaac46:	je     eaacb1 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xe1>
  eaac48:	mov    %rbx,-0x1020(%rbp)
  eaac4f:	mov    0x10(%rdi),%rax
  eaac53:	mov    %rbx,(%rax)
  eaac56:	movq   $0xc4de,0x8(%rax)
  eaac5e:	add    $0x10,%rax
  eaac62:	mov    %rax,0x10(%rdi)
  eaac66:	mov    %r12,-0x1020(%rbp)
  eaac6d:	mov    0x10(%rdi),%rax
  eaac71:	mov    %r12,(%rax)
  eaac74:	movq   $0xc4df,0x8(%rax)
  eaac7c:	add    $0x10,%rax
  eaac80:	mov    %rax,0x10(%rdi)
  eaac84:	mov    %rsi,-0x1020(%rbp)
  eaac8b:	mov    0x10(%rdi),%rax
  eaac8f:	mov    %rsi,(%rax)
  eaac92:	movq   $0xc4e0,0x8(%rax)
  eaac9a:	add    $0x10,%rax
  eaac9e:	mov    %rax,0x10(%rdi)
  eaaca2:	mov    $0x4,%esi
  eaaca7:	callq  f61640 <p111_rt_fail>
  eaacac:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eaacb1:	lea    -0x1020(%rbp),%rdx
  eaacb8:	mov    %rdi,%r13
  eaacbb:	callq  f66b30 <p125_rt_take4>
  eaacc0:	mov    %r13,%rdi
  eaacc3:	mov    -0x1020(%rbp),%rsi
  eaacca:	mov    -0x1018(%rbp),%r15
  eaacd1:	mov    -0x1010(%rbp),%r14
  eaacd8:	mov    %r14,-0x18(%rbp)
  eaacdc:	mov    %r12,%r13
  eaacdf:	mov    -0x1008(%rbp),%r12
  eaace6:	mov    %r12,-0x10(%rbp)
  eaacea:	mov    %rdi,%r12
  eaaced:	callq  f60e20 <p111_rt_keep>
  eaacf2:	mov    %r15,%rsi
  eaacf5:	mov    %r12,%rdi
  eaacf8:	mov    %rax,%r12
  eaacfb:	mov    %rdi,%r15
  eaacfe:	callq  f60e20 <p111_rt_keep>
  eaad03:	mov    %r15,%rdi
  eaad06:	mov    %rax,%r15
  eaad09:	mov    %r12,%rax
  eaad0c:	mov    $0xffffffff,%ecx
  eaad11:	and    %r15,%rcx
  eaad14:	cmp    $0x0,%rcx
  eaad18:	mov    %rax,%r12
  eaad1b:	sete   %al
  eaad1e:	movzbl %al,%eax
  eaad21:	cmp    $0x1,%rax
  eaad25:	sete   %cl
  eaad28:	movzbl %cl,%ecx
  eaad2b:	mov    %rax,%rdx
  eaad2e:	shr    $0x28,%rdx
  eaad32:	and    $0x7fffff,%rdx
  eaad39:	cmp    $0x10002,%rdx
  eaad40:	sete   %dl
  eaad43:	movzbl %dl,%edx
  eaad46:	or     %edx,%ecx
  eaad48:	jne    eaaf19 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x349>
  eaad4e:	xor    $0x1,%ecx
  eaad51:	jne    eaadcf <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x1ff>
  eaad53:	mov    %eax,%ebx
  eaad55:	mov    %r13,%rsi
  eaad58:	mov    %rdi,%r13
  eaad5b:	callq  f60eb0 <p111_rt_sink>
  eaad60:	mov    %r13,%rdi
  eaad63:	mov    %r12,%rax
  eaad66:	mov    -0x10(%rbp),%r12
  eaad6a:	mov    %rax,%rsi
  eaad6d:	mov    %rdi,%r13
  eaad70:	callq  f60eb0 <p111_rt_sink>
  eaad75:	mov    %r13,%rdi
  eaad78:	mov    %r15,%rsi
  eaad7b:	mov    %rdi,%r13
  eaad7e:	callq  f60eb0 <p111_rt_sink>
  eaad83:	mov    %r13,%rdi
  eaad86:	mov    %r14,%rsi
  eaad89:	mov    %rdi,%r13
  eaad8c:	callq  f60eb0 <p111_rt_sink>
  eaad91:	mov    %r13,%rdi
  eaad94:	mov    %r12,%rsi
  eaad97:	mov    %rdi,%r12
  eaad9a:	callq  f60eb0 <p111_rt_sink>
  eaad9f:	mov    %r12,%rdi
  eaada2:	mov    %rbx,-0x1020(%rbp)
  eaada9:	mov    0x10(%rdi),%rax
  eaadad:	mov    %rbx,(%rax)
  eaadb0:	movq   $0xc4dd,0x8(%rax)
  eaadb8:	add    $0x10,%rax
  eaadbc:	mov    %rax,0x10(%rdi)
  eaadc0:	mov    $0x4,%esi
  eaadc5:	callq  f61640 <p111_rt_fail>
  eaadca:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eaadcf:	mov    $0x0,%ecx
  eaadd4:	lea    -0x1020(%rbp),%rdx
  eaaddb:	mov    $0x0,%esi
  eaade0:	mov    %rdi,%r14
  eaade3:	callq  f60f20 <p111_rt_ctor>
  eaade8:	mov    %r14,%rdi
  eaadeb:	mov    %rax,%rsi
  eaadee:	mov    %rdi,%r14
  eaadf1:	callq  f60eb0 <p111_rt_sink>
  eaadf6:	mov    %r14,%rdi
  eaadf9:	mov    -0x18(%rbp),%r14
  eaadfd:	mov    %r15,%rsi
  eaae00:	mov    %rdi,%r15
  eaae03:	callq  f60e20 <p111_rt_keep>
  eaae08:	mov    %r15,%rdi
  eaae0b:	mov    %rax,%rcx
  eaae0e:	mov    %r12,%rax
  eaae11:	mov    %rbx,%r15
  eaae14:	mov    -0x10(%rbp),%rbx
  eaae18:	mov    %r14,%r12
  eaae1b:	mov    -0x8(%rbp),%r14
  eaae1f:	mov    %r13,-0x1020(%rbp)
  eaae26:	mov    %r15,-0x1018(%rbp)
  eaae2d:	mov    %rax,-0x1010(%rbp)
  eaae34:	mov    %rcx,-0x1008(%rbp)
  eaae3b:	mov    %r12,-0x1000(%rbp)
  eaae42:	mov    %rbx,-0xff8(%rbp)
  eaae49:	mov    %rax,%r12
  eaae4c:	mov    $0xffffffff,%eax
  eaae51:	and    %r12,%rax
  eaae54:	xor    %r14,%rax
  eaae57:	mov    $0xffffffff,%edx
  eaae5c:	and    %rdx,%rax
  eaae5f:	mov    %rax,-0xff0(%rbp)
  eaae66:	mov    0x10(%rdi),%rdx
  eaae6a:	mov    %r13,(%rdx)
  eaae6d:	mov    -0x1018(%rbp),%rsi
  eaae74:	mov    %rsi,0x8(%rdx)
  eaae78:	mov    -0x1010(%rbp),%rsi
  eaae7f:	mov    %rsi,0x10(%rdx)
  eaae83:	mov    -0x1008(%rbp),%rsi
  eaae8a:	mov    %rsi,0x18(%rdx)
  eaae8e:	mov    -0x1000(%rbp),%rsi
  eaae95:	mov    %rsi,0x20(%rdx)
  eaae99:	mov    -0xff8(%rbp),%rsi
  eaaea0:	mov    %rsi,0x28(%rdx)
  eaaea4:	mov    -0xff0(%rbp),%rsi
  eaaeab:	mov    %rsi,0x30(%rdx)
  eaaeaf:	movq   $0xc4d7,0x38(%rdx)
  eaaeb7:	add    $0x40,%rdx
  eaaebb:	mov    %rdx,0x10(%rdi)
  eaaebf:	mov    $0xffffffff,%edx
  eaaec4:	and    %rdx,%rcx
  eaaec7:	sub    $0x1,%rcx
  eaaecb:	mov    $0xffffffff,%edx
  eaaed0:	and    %rdx,%rcx
  eaaed3:	and    %rcx,%rax
  eaaed6:	mov    $0xffffffff,%ecx
  eaaedb:	and    %rcx,%rax
  eaaede:	cmp    $0x0,%rax
  eaaee2:	sete   %sil
  eaaee6:	movzbl %sil,%esi
  eaaeea:	mov    %rsi,-0x1020(%rbp)
  eaaef1:	mov    %rdi,%rbx
  eaaef4:	callq  6658c0 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  eaaef9:	mov    %rbx,%rdi
  eaaefc:	mov    %rax,-0x1020(%rbp)
  eaaf03:	mov    $0x1,%edx
  eaaf08:	lea    -0x1020(%rbp),%rsi
  eaaf0f:	callq  f614d0 <p111_rt_return>
  eaaf14:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eaaf19:	mov    $0x0,%ecx
  eaaf1e:	lea    -0x1020(%rbp),%rdx
  eaaf25:	mov    $0x0,%esi
  eaaf2a:	mov    %rdi,%r14
  eaaf2d:	callq  f60f20 <p111_rt_ctor>
  eaaf32:	mov    %r14,%rdi
  eaaf35:	mov    %rax,%rsi
  eaaf38:	mov    %rdi,%r14
  eaaf3b:	callq  f60eb0 <p111_rt_sink>
  eaaf40:	mov    %r14,%rdi
  eaaf43:	mov    %r12,%rax
  eaaf46:	mov    %rbx,%r12
  eaaf49:	mov    -0x10(%rbp),%rbx
  eaaf4d:	mov    -0x18(%rbp),%r14
  eaaf51:	mov    %rax,-0x1020(%rbp)
  eaaf58:	mov    %r15,-0x1018(%rbp)
  eaaf5f:	mov    %r14,-0x1010(%rbp)
  eaaf66:	mov    %rbx,-0x1008(%rbp)
  eaaf6d:	lea    -0x1020(%rbp),%rdx
  eaaf74:	mov    $0x9b,%esi
  eaaf79:	mov    %rdi,%rbx
  eaaf7c:	callq  f66a60 <p125_rt_ctor4>
  eaaf81:	mov    %rbx,%rdi
  eaaf84:	mov    %rax,-0x1020(%rbp)
  eaaf8b:	mov    %r13,-0x1018(%rbp)
  eaaf92:	mov    %r12,-0x1010(%rbp)
  eaaf99:	movq   $0x20,-0x1008(%rbp)
  eaafa4:	mov    $0x4,%ecx
  eaafa9:	lea    -0x1020(%rbp),%rdx
  eaafb0:	mov    $0xc4c9,%esi
  eaafb5:	callq  f61470 <p111_rt_jump>
  eaafba:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eaafbf:	cs cs cs mov %r12,%r13
  eaafc5:	mov    %rbx,%r12
  eaafc8:	lea    -0x1020(%rbp),%rdx
  eaafcf:	mov    %rdi,%rbx
  eaafd2:	callq  f66660 <p125_rt_take2>
  eaafd7:	mov    %rbx,%rdi
  eaafda:	mov    -0x1020(%rbp),%rsi
  eaafe1:	mov    -0x1018(%rbp),%rbx
  eaafe8:	mov    %rdi,%r15
  eaafeb:	callq  f60e20 <p111_rt_keep>
  eaaff0:	mov    %r15,%rdi
  eaaff3:	mov    %rax,%rsi
  eaaff6:	mov    $0xffffffff,%eax
  eaaffb:	and    %rsi,%rax
  eaaffe:	xor    %r14,%rax
  eab001:	mov    $0xffffffff,%ecx
  eab006:	mov    %rsi,%r15
  eab009:	mov    %rax,%rsi
  eab00c:	and    %rcx,%rsi
  eab00f:	mov    %rdi,%r14
  eab012:	callq  655d70 <p112w_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_115_112_108_105_116_95_98_105_116_>
  eab017:	mov    %r15,%rsi
  eab01a:	mov    %r14,%rdi
  eab01d:	mov    %rax,%r14
  eab020:	mov    %r14,-0x20(%rbp)
  eab024:	mov    $0xffffffff,%eax
  eab029:	and    %r14,%rax
  eab02c:	cmp    $0x0,%rax
  eab030:	mov    %rbx,%r14
  eab033:	sete   %bl
  eab036:	movzbl %bl,%ebx
  eab039:	cmp    $0x1,%rbx
  eab03d:	sete   %al
  eab040:	movzbl %al,%eax
  eab043:	mov    %rbx,%rcx
  eab046:	shr    $0x28,%rcx
  eab04a:	and    $0x7fffff,%rcx
  eab051:	cmp    $0x10002,%rcx
  eab058:	sete   %cl
  eab05b:	movzbl %cl,%ecx
  eab05e:	or     %ecx,%eax
  eab060:	cmp    $0x0,%eax
  eab063:	jne    eab165 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x595>
  eab069:	xor    $0x1,%eax
  eab06c:	jne    eab0cb <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x4fb>
  eab06e:	mov    %r14,%r12
  eab071:	mov    %rsi,%r14
  eab074:	mov    %r13,%rsi
  eab077:	mov    %rdi,%r13
  eab07a:	callq  f60eb0 <p111_rt_sink>
  eab07f:	mov    %r14,%rsi
  eab082:	mov    %r13,%rdi
  eab085:	mov    %rdi,%r13
  eab088:	callq  f60eb0 <p111_rt_sink>
  eab08d:	mov    %r13,%rdi
  eab090:	mov    %r12,%rsi
  eab093:	mov    %rdi,%r12
  eab096:	callq  f60eb0 <p111_rt_sink>
  eab09b:	mov    %r12,%rdi
  eab09e:	mov    %rbx,-0x820(%rbp)
  eab0a5:	mov    0x10(%rdi),%rax
  eab0a9:	mov    %rbx,(%rax)
  eab0ac:	movq   $0xc4d6,0x8(%rax)
  eab0b4:	add    $0x10,%rax
  eab0b8:	mov    %rax,0x10(%rdi)
  eab0bc:	mov    $0x4,%esi
  eab0c1:	callq  f61640 <p111_rt_fail>
  eab0c6:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eab0cb:	cs cs cs cs mov %r14,%rbx
  eab0d2:	mov    $0x0,%ecx
  eab0d7:	lea    -0x820(%rbp),%rdx
  eab0de:	mov    %rsi,%r15
  eab0e1:	mov    $0x0,%esi
  eab0e6:	mov    %rdi,%r14
  eab0e9:	callq  f60f20 <p111_rt_ctor>
  eab0ee:	mov    %r14,%rdi
  eab0f1:	mov    %rax,%rsi
  eab0f4:	mov    %rdi,%r14
  eab0f7:	callq  f60eb0 <p111_rt_sink>
  eab0fc:	mov    %r15,%rsi
  eab0ff:	mov    %r14,%rdi
  eab102:	mov    %rbx,%r14
  eab105:	mov    -0x20(%rbp),%rbx
  eab109:	mov    %rsi,-0x820(%rbp)
  eab110:	mov    %r14,-0x818(%rbp)
  eab117:	lea    -0x820(%rbp),%rdx
  eab11e:	mov    $0x9a,%esi
  eab123:	mov    %rdi,%r14
  eab126:	callq  f66570 <p125_rt_ctor2>
  eab12b:	mov    %r14,%rdi
  eab12e:	mov    %rax,-0x820(%rbp)
  eab135:	mov    %r13,-0x818(%rbp)
  eab13c:	mov    %r12,-0x810(%rbp)
  eab143:	mov    %rbx,-0x808(%rbp)
  eab14a:	mov    $0x4,%ecx
  eab14f:	lea    -0x820(%rbp),%rdx
  eab156:	mov    $0xc47a,%esi
  eab15b:	callq  f61470 <p111_rt_jump>
  eab160:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eab165:	mov    %r14,%rbx
  eab168:	mov    %rdi,%r14
  eab16b:	callq  f60eb0 <p111_rt_sink>
  eab170:	mov    %r14,%rdi
  eab173:	mov    $0x0,%ecx
  eab178:	lea    -0x820(%rbp),%rdx
  eab17f:	mov    $0x0,%esi
  eab184:	mov    %rdi,%r14
  eab187:	callq  f60f20 <p111_rt_ctor>
  eab18c:	mov    %r14,%rdi
  eab18f:	mov    %rax,%rsi
  eab192:	mov    %rdi,%r14
  eab195:	callq  f60eb0 <p111_rt_sink>
  eab19a:	mov    %r14,%rdi
  eab19d:	mov    %r13,-0x820(%rbp)
  eab1a4:	mov    %r12,-0x818(%rbp)
  eab1ab:	mov    %rbx,-0x810(%rbp)
  eab1b2:	mov    $0x3,%ecx
  eab1b7:	lea    -0x820(%rbp),%rdx
  eab1be:	mov    $0xc4c1,%esi
  eab1c3:	callq  f61470 <p111_rt_jump>
  eab1c8:	jmpq   eab2b4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  eab1cd:	mov    $0x9,%ecx
  eab1d2:	lea    -0x1020(%rbp),%rdx
  eab1d9:	mov    %rdi,%r13
  eab1dc:	callq  f610a0 <p111_rt_take>
  eab1e1:	mov    %r13,%rdi
  eab1e4:	mov    -0x1020(%rbp),%r13
  eab1eb:	mov    -0x1018(%rbp),%r11
  eab1f2:	mov    -0x1010(%rbp),%r10
  eab1f9:	mov    -0x1008(%rbp),%r9
  eab200:	mov    -0x1000(%rbp),%r8
  eab207:	mov    -0xff8(%rbp),%rsi
  eab20e:	mov    -0xff0(%rbp),%rdx
  eab215:	mov    -0xfe8(%rbp),%rcx
  eab21c:	mov    -0xfe0(%rbp),%rax
  eab223:	mov    %r13,-0x1020(%rbp)
  eab22a:	mov    %r11,-0x1018(%rbp)
  eab231:	mov    %r10,-0x1010(%rbp)
  eab238:	mov    %r9,-0x1008(%rbp)
  eab23f:	mov    %r8,-0x1000(%rbp)
  eab246:	mov    %rsi,-0xff8(%rbp)
  eab24d:	mov    %rdx,-0xff0(%rbp)
  eab254:	mov    %rcx,-0xfe8(%rbp)
  eab25b:	mov    %rax,-0xfe0(%rbp)
  eab262:	mov    $0x9,%ecx
  eab267:	lea    -0x1020(%rbp),%rdx
  eab26e:	mov    $0x99,%esi
  eab273:	mov    %rdi,%r13
  eab276:	callq  f60f20 <p111_rt_ctor>
  eab27b:	mov    %r13,%rdi
  eab27e:	mov    %rax,-0x1020(%rbp)
  eab285:	mov    %r12,-0x1018(%rbp)
  eab28c:	mov    %rbx,-0x1010(%rbp)
  eab293:	movq   $0x20,-0x1008(%rbp)
  eab29e:	mov    $0x4,%ecx
  eab2a3:	lea    -0x1020(%rbp),%rdx
  eab2aa:	mov    $0xc4c9,%esi
  eab2af:	callq  f61470 <p111_rt_jump>
  eab2b4:	pop    %r15
  eab2b6:	pop    %r14
  eab2b8:	pop    %r13
  eab2ba:	pop    %r12
  eab2bc:	pop    %rbx
  eab2bd:	leaveq 
  eab2be:	retq   

Disassembly of section .fini:
