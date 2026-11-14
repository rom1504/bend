
selfhost/build/phase184/bend-products01/editdist/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

00000000000117e0 <NF_FID_100_112_46_114_111_119_>:
   117e0:	push   %rbp
   117e1:	push   %r15
   117e3:	push   %r14
   117e5:	push   %r13
   117e7:	push   %r12
   117e9:	push   %rbx
   117ea:	sub    $0x28,%rsp
   117ee:	mov    %ecx,%eax
   117f0:	movabs $0xffffffffff,%r15
   117fa:	movabs $0xffff0000000000,%rcx
   11804:	and    %r8,%rcx
   11807:	movabs $0xa40000000000,%r9
   11811:	cmp    %r9,%rcx
   11814:	jne    11abd <NF_FID_100_112_46_114_111_119_+0x2dd>
   1181a:	mov    %r8,%r11
   1181d:	and    %r15,%r11
   11820:	test   %r8,%r8
   11823:	js     1184d <NF_FID_100_112_46_114_111_119_+0x6d>
   11825:	mov    (%rdi,%r11,8),%r10
   11829:	mov    0x8(%rdi,%r11,8),%r14
   1182e:	mov    0x10(%rdi,%r11,8),%rbx
   11833:	mov    0x18(%rdi,%r11,8),%r13
   11838:	mov    %r11,%rcx
   1183b:	cmp    $0x3108180,%rcx
   11842:	jae    118d0 <NF_FID_100_112_46_114_111_119_+0xf0>
   11848:	jmpq   11908 <NF_FID_100_112_46_114_111_119_+0x128>
   1184d:	mov    0x4(%rdi,%r11,8),%ecx
   11852:	mov    (%rdi,%r11,8),%r10d
   11856:	mov    %r10d,%r9d
   11859:	and    $0xffffff,%r9d
   11860:	cmp    $0x1,%r9
   11864:	jne    1186a <NF_FID_100_112_46_114_111_119_+0x8a>
   11866:	mov    (%rdi,%r11,8),%ebx
   1186a:	shl    $0x20,%rcx
   1186e:	or     %r10,%rcx
   11871:	shr    $0x18,%rcx
   11875:	mov    (%rdi,%rcx,8),%r10
   11879:	mov    0x8(%rdi,%rcx,8),%r14
   1187e:	mov    0x10(%rdi,%rcx,8),%rbx
   11883:	mov    0x18(%rdi,%rcx,8),%r13
   11888:	cmp    $0x1,%r9d
   1188c:	jne    11a85 <NF_FID_100_112_46_114_111_119_+0x2a5>
   11892:	mov    (%rsi),%r8
   11895:	mov    %r8,(%rdi,%r11,8)
   11899:	mov    %r11,(%rsi)
   1189c:	mov    0x100(%rsi),%r8
   118a3:	inc    %r8
   118a6:	mov    %r8,0x100(%rsi)
   118ad:	cmpb   $0x1,0x10625c(%rip)        # 117b10 <KEEP_WORDS>
   118b4:	jne    11a9e <NF_FID_100_112_46_114_111_119_+0x2be>
   118ba:	cmp    $0x8000,%r8
   118c1:	jae    11a9e <NF_FID_100_112_46_114_111_119_+0x2be>
   118c7:	cmp    $0x3108180,%rcx
   118ce:	jb     11908 <NF_FID_100_112_46_114_111_119_+0x128>
   118d0:	mov    0x10(%rsi),%r8
   118d4:	mov    %r8,(%rdi,%rcx,8)
   118d8:	mov    %rcx,0x10(%rsi)
   118dc:	mov    0x110(%rsi),%rcx
   118e3:	add    $0x4,%rcx
   118e7:	mov    %rcx,0x110(%rsi)
   118ee:	cmpb   $0x1,0x10621b(%rip)        # 117b10 <KEEP_WORDS>
   118f5:	jne    11a70 <NF_FID_100_112_46_114_111_119_+0x290>
   118fb:	cmp    $0x8000,%rcx
   11902:	jae    11a70 <NF_FID_100_112_46_114_111_119_+0x290>
   11908:	mov    %r10,%rcx
   1190b:	shr    $0x28,%rcx
   1190f:	mov    $0xffffffff,%r8d
   11915:	mov    $0xffffffff,%r9d
   1191b:	shl    %cl,%r9d
   1191e:	not    %r9d
   11921:	and    %eax,%r9d
   11924:	mov    %r10,0x20(%rsp)
   11929:	mov    %r10,%rcx
   1192c:	and    %r15,%rcx
   1192f:	lea    (%rdi,%rcx,8),%r12
   11933:	mov    %r13,%rcx
   11936:	shr    $0x28,%rcx
   1193a:	mov    $0xffffffff,%r11d
   11940:	shl    %cl,%r11d
   11943:	mov    (%r12,%r9,4),%ebp
   11947:	inc    %eax
   11949:	mov    %r13,0x8(%rsp)
   1194e:	mov    %r13,%r9
   11951:	and    %r15,%r9
   11954:	lea    (%rdi,%r9,8),%r12
   11958:	mov    %r14,%rcx
   1195b:	shr    $0x28,%rcx
   1195f:	mov    $0xffffffff,%r13d
   11965:	shl    %cl,%r13d
   11968:	mov    %eax,(%rdi,%r9,8)
   1196c:	not    %r13d
   1196f:	mov    %r14,0x10(%rsp)
   11974:	mov    %r14,%rax
   11977:	and    %r15,%rax
   1197a:	lea    (%rdi,%rax,8),%rax
   1197e:	mov    %rbx,%rcx
   11981:	shr    $0x28,%rcx
   11985:	shl    %cl,%r8d
   11988:	not    %r8d
   1198b:	mov    %rbx,0x18(%rsp)
   11990:	and    %rbx,%r15
   11993:	lea    (%rdi,%r15,8),%rcx
   11997:	not    %r11d
   1199a:	xor    %r10d,%r10d
   1199d:	nopl   (%rax)
   119a0:	mov    %r10d,%r15d
   119a3:	and    %r13d,%r15d
   119a6:	xor    %r9d,%r9d
   119a9:	cmp    %ebp,(%rax,%r15,4)
   119ad:	setne  %r9b
   119b1:	mov    %r10d,%ebx
   119b4:	and    %r8d,%ebx
   119b7:	inc    %r10
   119ba:	mov    %r10d,%r15d
   119bd:	and    %r8d,%r15d
   119c0:	mov    (%rcx,%r15,4),%r15d
   119c4:	lea    -0x1(%r10),%r14d
   119c8:	and    %r11d,%r14d
   119cb:	mov    (%r12,%r14,4),%r14d
   119cf:	inc    %r15d
   119d2:	inc    %r14d
   119d5:	cmp    %r14d,%r15d
   119d8:	cmovb  %r15d,%r14d
   119dc:	add    (%rcx,%rbx,4),%r9d
   119e0:	cmp    %r9d,%r14d
   119e3:	cmovb  %r14d,%r9d
   119e7:	mov    %r10d,%ebx
   119ea:	and    %r11d,%ebx
   119ed:	mov    %r9d,(%r12,%rbx,4)
   119f1:	cmp    $0x100,%r10
   119f8:	jne    119a0 <NF_FID_100_112_46_114_111_119_+0x1c0>
   119fa:	mov    0x10(%rsi),%rax
   119fe:	test   %rax,%rax
   11a01:	je     11a5e <NF_FID_100_112_46_114_111_119_+0x27e>
   11a03:	mov    (%rdi,%rax,8),%rcx
   11a07:	mov    %rcx,0x10(%rsi)
   11a0b:	addq   $0xfffffffffffffffc,0x110(%rsi)
   11a13:	mov    0x20(%rsp),%rcx
   11a18:	mov    0x18(%rsp),%rsi
   11a1d:	mov    0x10(%rsp),%r8
   11a22:	mov    0x8(%rsp),%r9
   11a27:	mov    %rcx,(%rdi,%rax,8)
   11a2b:	mov    %r8,0x8(%rdi,%rax,8)
   11a30:	mov    %r9,0x10(%rdi,%rax,8)
   11a35:	mov    %rsi,0x18(%rdi,%rax,8)
   11a3a:	movabs $0x200a40000000000,%rcx
   11a44:	or     %rax,%rcx
   11a47:	mov    %rcx,(%rdx)
   11a4a:	mov    $0x1,%eax
   11a4f:	add    $0x28,%rsp
   11a53:	pop    %rbx
   11a54:	pop    %r12
   11a56:	pop    %r13
   11a58:	pop    %r14
   11a5a:	pop    %r15
   11a5c:	pop    %rbp
   11a5d:	retq   
   11a5e:	mov    %rdx,%rcx
   11a61:	mov    $0x2,%edx
   11a66:	callq  13d48 <heap_alloc_miss>
   11a6b:	mov    %rcx,%rdx
   11a6e:	jmp    11a13 <NF_FID_100_112_46_114_111_119_+0x233>
   11a70:	mov    %rdx,%rcx
   11a73:	mov    $0x2,%edx
   11a78:	callq  13c21 <heap_hand>
   11a7d:	mov    %rcx,%rdx
   11a80:	jmpq   11908 <NF_FID_100_112_46_114_111_119_+0x128>
   11a85:	mov    %rdx,%r9
   11a88:	mov    %r8,%rdx
   11a8b:	mov    $0x4,%r8d
   11a91:	callq  13cb2 <span_fade>
   11a96:	mov    %r9,%rdx
   11a99:	jmpq   11908 <NF_FID_100_112_46_114_111_119_+0x128>
   11a9e:	mov    %rdx,%r8
   11aa1:	xor    %edx,%edx
   11aa3:	callq  13c21 <heap_hand>
   11aa8:	mov    %r8,%rdx
   11aab:	cmp    $0x3108180,%rcx
   11ab2:	jae    118d0 <NF_FID_100_112_46_114_111_119_+0xf0>
   11ab8:	jmpq   11908 <NF_FID_100_112_46_114_111_119_+0x128>
   11abd:	cmp    $0xffffffffffffffff,%r8
   11ac1:	je     11aea <NF_FID_100_112_46_114_111_119_+0x30a>
   11ac3:	movabs $0x7e00000000000000,%rax
   11acd:	and    %r8,%rax
   11ad0:	je     11aea <NF_FID_100_112_46_114_111_119_+0x30a>
   11ad2:	add    $0xffffffffffffff81,%r15
   11ad6:	and    %r8,%r15
   11ad9:	cmp    $0x3108180,%r15
   11ae0:	jb     11aea <NF_FID_100_112_46_114_111_119_+0x30a>
   11ae2:	mov    %r8,%rdx
   11ae5:	callq  7130 <term_drop>
   11aea:	lea    -0xf2c1(%rip),%rdi        # 2830 <FID_RESW_T+0x330>
   11af1:	callq  13bc0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
