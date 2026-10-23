
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409680 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>:
  409680:	f3 0f 1e fa          	endbr64 
  409684:	55                   	push   %rbp
  409685:	48 89 e5             	mov    %rsp,%rbp
  409688:	48 81 ec 58 0d 00 00 	sub    $0xd58,%rsp
  40968f:	53                   	push   %rbx
  409690:	41 54                	push   %r12
  409692:	41 55                	push   %r13
  409694:	41 56                	push   %r14
  409696:	41 57                	push   %r15
  409698:	48 89 d3             	mov    %rdx,%rbx
  40969b:	48 89 da             	mov    %rbx,%rdx
  40969e:	49 89 ce             	mov    %rcx,%r14
  4096a1:	4d 89 c7             	mov    %r8,%r15
  4096a4:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  4096ab:	00 00 00 00 
  4096af:	90                   	nop
  4096b0:	48 89 f0             	mov    %rsi,%rax
  4096b3:	48 c1 e8 28          	shr    $0x28,%rax
  4096b7:	48 25 ff ff 00 00    	and    $0xffff,%rax
  4096bd:	44 89 f3             	mov    %r14d,%ebx
  4096c0:	48 89 5d 88          	mov    %rbx,-0x78(%rbp)
  4096c4:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  4096ca:	0f 84 b9 06 00 00    	je     409d89 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x709>
  4096d0:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  4096d6:	0f 84 50 04 00 00    	je     409b2c <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x4ac>
  4096dc:	0f 1f 40 00          	nopl   0x0(%rax)
  4096e0:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  4096e6:	0f 85 2c 04 00 00    	jne    409b18 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x498>
  4096ec:	49 89 d5             	mov    %rdx,%r13
  4096ef:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  4096f6:	49 89 fc             	mov    %rdi,%r12
  4096f9:	e8 62 13 02 00       	callq  42aa60 <p125_rt_take4>
  4096fe:	4c 89 f1             	mov    %r14,%rcx
  409701:	4c 89 ea             	mov    %r13,%rdx
  409704:	4c 89 e7             	mov    %r12,%rdi
  409707:	48 8b 85 b0 f2 ff ff 	mov    -0xd50(%rbp),%rax
  40970e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  409712:	48 8b 85 b8 f2 ff ff 	mov    -0xd48(%rbp),%rax
  409719:	48 8b b5 c0 f2 ff ff 	mov    -0xd40(%rbp),%rsi
  409720:	48 89 75 e8          	mov    %rsi,-0x18(%rbp)
  409724:	48 8b b5 c8 f2 ff ff 	mov    -0xd38(%rbp),%rsi
  40972b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  40972f:	89 c0                	mov    %eax,%eax
  409731:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  409735:	48 83 f8 00          	cmp    $0x0,%rax
  409739:	0f 84 f5 00 00 00    	je     409834 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1b4>
  40973f:	49 89 ce             	mov    %rcx,%r14
  409742:	b9 00 00 00 00       	mov    $0x0,%ecx
  409747:	49 89 d5             	mov    %rdx,%r13
  40974a:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409751:	be 00 00 00 00       	mov    $0x0,%esi
  409756:	49 89 fc             	mov    %rdi,%r12
  409759:	e8 f2 b6 01 00       	callq  424e50 <p111_rt_ctor>
  40975e:	4c 89 e7             	mov    %r12,%rdi
  409761:	48 89 c6             	mov    %rax,%rsi
  409764:	49 89 fc             	mov    %rdi,%r12
  409767:	e8 74 b6 01 00       	callq  424de0 <p111_rt_sink>
  40976c:	4c 89 e7             	mov    %r12,%rdi
  40976f:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  409773:	49 89 f4             	mov    %rsi,%r12
  409776:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  40977a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  40977e:	48 21 d8             	and    %rbx,%rax
  409781:	48 83 f8 00          	cmp    $0x0,%rax
  409785:	74 52                	je     4097d9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x159>
  409787:	48 89 fb             	mov    %rdi,%rbx
  40978a:	e8 51 b6 01 00       	callq  424de0 <p111_rt_sink>
  40978f:	4c 89 f1             	mov    %r14,%rcx
  409792:	4c 89 ea             	mov    %r13,%rdx
  409795:	4c 89 e6             	mov    %r12,%rsi
  409798:	48 89 df             	mov    %rbx,%rdi
  40979b:	49 89 ce             	mov    %rcx,%r14
  40979e:	b9 00 00 00 00       	mov    $0x0,%ecx
  4097a3:	49 89 d5             	mov    %rdx,%r13
  4097a6:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  4097ad:	49 89 f4             	mov    %rsi,%r12
  4097b0:	be 00 00 00 00       	mov    $0x0,%esi
  4097b5:	48 89 fb             	mov    %rdi,%rbx
  4097b8:	e8 93 b6 01 00       	callq  424e50 <p111_rt_ctor>
  4097bd:	48 89 df             	mov    %rbx,%rdi
  4097c0:	48 89 c6             	mov    %rax,%rsi
  4097c3:	48 89 fb             	mov    %rdi,%rbx
  4097c6:	e8 15 b6 01 00       	callq  424de0 <p111_rt_sink>
  4097cb:	4c 89 e6             	mov    %r12,%rsi
  4097ce:	48 89 df             	mov    %rbx,%rdi
  4097d1:	4c 89 ea             	mov    %r13,%rdx
  4097d4:	e9 d7 fe ff ff       	jmpq   4096b0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x30>
  4097d9:	4c 87 e6             	xchg   %r12,%rsi
  4097dc:	48 89 fb             	mov    %rdi,%rbx
  4097df:	e8 fc b5 01 00       	callq  424de0 <p111_rt_sink>
  4097e4:	4c 89 f1             	mov    %r14,%rcx
  4097e7:	4c 89 ea             	mov    %r13,%rdx
  4097ea:	4c 89 e6             	mov    %r12,%rsi
  4097ed:	48 89 df             	mov    %rbx,%rdi
  4097f0:	49 89 ce             	mov    %rcx,%r14
  4097f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  4097f8:	49 89 d5             	mov    %rdx,%r13
  4097fb:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409802:	49 89 f4             	mov    %rsi,%r12
  409805:	be 00 00 00 00       	mov    $0x0,%esi
  40980a:	48 89 fb             	mov    %rdi,%rbx
  40980d:	e8 3e b6 01 00       	callq  424e50 <p111_rt_ctor>
  409812:	48 89 df             	mov    %rbx,%rdi
  409815:	48 89 c6             	mov    %rax,%rsi
  409818:	48 89 fb             	mov    %rdi,%rbx
  40981b:	e8 c0 b5 01 00       	callq  424de0 <p111_rt_sink>
  409820:	4c 89 f1             	mov    %r14,%rcx
  409823:	4c 89 ea             	mov    %r13,%rdx
  409826:	4c 89 e6             	mov    %r12,%rsi
  409829:	48 89 df             	mov    %rbx,%rdi
  40982c:	49 89 ce             	mov    %rcx,%r14
  40982f:	e9 7c fe ff ff       	jmpq   4096b0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x30>
  409834:	4c 8b 65 f0          	mov    -0x10(%rbp),%r12
  409838:	4c 8b 6d e8          	mov    -0x18(%rbp),%r13
  40983c:	48 89 d6             	mov    %rdx,%rsi
  40983f:	b9 00 00 00 00       	mov    $0x0,%ecx
  409844:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  40984b:	49 89 f7             	mov    %rsi,%r15
  40984e:	be 00 00 00 00       	mov    $0x0,%esi
  409853:	49 89 fe             	mov    %rdi,%r14
  409856:	e8 f5 b5 01 00       	callq  424e50 <p111_rt_ctor>
  40985b:	4c 89 f7             	mov    %r14,%rdi
  40985e:	48 89 c6             	mov    %rax,%rsi
  409861:	49 89 fe             	mov    %rdi,%r14
  409864:	e8 77 b5 01 00       	callq  424de0 <p111_rt_sink>
  409869:	4c 89 fe             	mov    %r15,%rsi
  40986c:	4c 89 f7             	mov    %r14,%rdi
  40986f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  409873:	89 c0                	mov    %eax,%eax
  409875:	48 39 d8             	cmp    %rbx,%rax
  409878:	0f 84 fa 01 00 00    	je     409a78 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x3f8>
  40987e:	48 89 fb             	mov    %rdi,%rbx
  409881:	e8 5a b5 01 00       	callq  424de0 <p111_rt_sink>
  409886:	4c 89 ee             	mov    %r13,%rsi
  409889:	48 89 df             	mov    %rbx,%rdi
  40988c:	48 89 f3             	mov    %rsi,%rbx
  40988f:	48 89 fb             	mov    %rdi,%rbx
  409892:	e8 49 b5 01 00       	callq  424de0 <p111_rt_sink>
  409897:	4c 89 e6             	mov    %r12,%rsi
  40989a:	48 89 df             	mov    %rbx,%rdi
  40989d:	49 89 f4             	mov    %rsi,%r12
  4098a0:	48 89 fb             	mov    %rdi,%rbx
  4098a3:	e8 38 b5 01 00       	callq  424de0 <p111_rt_sink>
  4098a8:	48 89 df             	mov    %rbx,%rdi
  4098ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  4098b0:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  4098b7:	be 00 00 00 00       	mov    $0x0,%esi
  4098bc:	48 89 fb             	mov    %rdi,%rbx
  4098bf:	e8 8c b5 01 00       	callq  424e50 <p111_rt_ctor>
  4098c4:	48 89 df             	mov    %rbx,%rdi
  4098c7:	48 89 c6             	mov    %rax,%rsi
  4098ca:	48 89 fb             	mov    %rdi,%rbx
  4098cd:	e8 0e b5 01 00       	callq  424de0 <p111_rt_sink>
  4098d2:	48 89 df             	mov    %rbx,%rdi
  4098d5:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  4098dc:	19 00 02 
  4098df:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  4098e6:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  4098ed:	18 00 01 
  4098f0:	48 89 85 08 ff ff ff 	mov    %rax,-0xf8(%rbp)
  4098f7:	48 c7 85 10 ff ff ff 	movq   $0x0,-0xf0(%rbp)
  4098fe:	00 00 00 00 
  409902:	48 c7 85 18 ff ff ff 	movq   $0x0,-0xe8(%rbp)
  409909:	00 00 00 00 
  40990d:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409914:	11 00 01 
  409917:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  40991e:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409925:	11 00 01 
  409928:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
  40992f:	48 c7 85 30 ff ff ff 	movq   $0x0,-0xd0(%rbp)
  409936:	00 00 00 00 
  40993a:	48 c7 85 38 ff ff ff 	movq   $0x0,-0xc8(%rbp)
  409941:	00 00 00 00 
  409945:	b9 08 00 00 00       	mov    $0x8,%ecx
  40994a:	48 8d 95 00 ff ff ff 	lea    -0x100(%rbp),%rdx
  409951:	be 96 00 00 00       	mov    $0x96,%esi
  409956:	48 89 fb             	mov    %rdi,%rbx
  409959:	e8 f2 b4 01 00       	callq  424e50 <p111_rt_ctor>
  40995e:	48 89 df             	mov    %rbx,%rdi
  409961:	48 89 c3             	mov    %rax,%rbx
  409964:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40996b:	19 00 02 
  40996e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  409975:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40997c:	18 00 01 
  40997f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  409986:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  40998d:	00 00 00 00 
  409991:	48 c7 85 58 ff ff ff 	movq   $0x0,-0xa8(%rbp)
  409998:	00 00 00 00 
  40999c:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  4099a3:	11 00 01 
  4099a6:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  4099ad:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  4099b4:	11 00 01 
  4099b7:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  4099be:	48 c7 85 70 ff ff ff 	movq   $0x0,-0x90(%rbp)
  4099c5:	00 00 00 00 
  4099c9:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  4099d0:	00 00 00 00 
  4099d4:	b9 08 00 00 00       	mov    $0x8,%ecx
  4099d9:	48 8d 95 40 ff ff ff 	lea    -0xc0(%rbp),%rdx
  4099e0:	be 96 00 00 00       	mov    $0x96,%esi
  4099e5:	49 89 fc             	mov    %rdi,%r12
  4099e8:	e8 63 b4 01 00       	callq  424e50 <p111_rt_ctor>
  4099ed:	4c 89 e7             	mov    %r12,%rdi
  4099f0:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  4099f7:	18 00 01 
  4099fa:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  409a01:	48 b9 2c 82 10 03 00 	movabs $0x20019000310822c,%rcx
  409a08:	19 00 02 
  409a0b:	48 89 8d c0 fe ff ff 	mov    %rcx,-0x140(%rbp)
  409a12:	48 c7 85 c8 fe ff ff 	movq   $0x0,-0x138(%rbp)
  409a19:	00 00 00 00 
  409a1d:	48 c7 85 d0 fe ff ff 	movq   $0x0,-0x130(%rbp)
  409a24:	00 00 00 00 
  409a28:	48 89 9d d8 fe ff ff 	mov    %rbx,-0x128(%rbp)
  409a2f:	48 89 85 e0 fe ff ff 	mov    %rax,-0x120(%rbp)
  409a36:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409a3d:	11 00 01 
  409a40:	48 89 85 e8 fe ff ff 	mov    %rax,-0x118(%rbp)
  409a47:	48 c7 85 f0 fe ff ff 	movq   $0x0,-0x110(%rbp)
  409a4e:	00 00 00 00 
  409a52:	48 c7 85 f8 fe ff ff 	movq   $0x0,-0x108(%rbp)
  409a59:	00 00 00 00 
  409a5d:	b9 09 00 00 00       	mov    $0x9,%ecx
  409a62:	48 8d 95 b8 fe ff ff 	lea    -0x148(%rbp),%rdx
  409a69:	be 99 00 00 00       	mov    $0x99,%esi
  409a6e:	e8 dd b3 01 00       	callq  424e50 <p111_rt_ctor>
  409a73:	e9 2b 0f 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  409a78:	4c 89 eb             	mov    %r13,%rbx
  409a7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  409a80:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409a87:	49 89 f6             	mov    %rsi,%r14
  409a8a:	be 00 00 00 00       	mov    $0x0,%esi
  409a8f:	49 89 fd             	mov    %rdi,%r13
  409a92:	e8 b9 b3 01 00       	callq  424e50 <p111_rt_ctor>
  409a97:	4c 89 ef             	mov    %r13,%rdi
  409a9a:	48 89 c6             	mov    %rax,%rsi
  409a9d:	49 89 fd             	mov    %rdi,%r13
  409aa0:	e8 3b b3 01 00       	callq  424de0 <p111_rt_sink>
  409aa5:	4c 89 f6             	mov    %r14,%rsi
  409aa8:	4c 89 ef             	mov    %r13,%rdi
  409aab:	4c 89 a5 b0 f2 ff ff 	mov    %r12,-0xd50(%rbp)
  409ab2:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409ab9:	11 00 01 
  409abc:	48 89 85 b8 f2 ff ff 	mov    %rax,-0xd48(%rbp)
  409ac3:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409aca:	49 89 f5             	mov    %rsi,%r13
  409acd:	be 12 00 00 00       	mov    $0x12,%esi
  409ad2:	49 89 fc             	mov    %rdi,%r12
  409ad5:	e8 c6 09 02 00       	callq  42a4a0 <p125_rt_ctor2>
  409ada:	4c 89 ee             	mov    %r13,%rsi
  409add:	4c 89 e7             	mov    %r12,%rdi
  409ae0:	48 89 9d b0 f2 ff ff 	mov    %rbx,-0xd50(%rbp)
  409ae7:	48 89 85 b8 f2 ff ff 	mov    %rax,-0xd48(%rbp)
  409aee:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409af5:	49 89 f5             	mov    %rsi,%r13
  409af8:	be 12 00 00 00       	mov    $0x12,%esi
  409afd:	48 89 fb             	mov    %rdi,%rbx
  409b00:	e8 9b 09 02 00       	callq  42a4a0 <p125_rt_ctor2>
  409b05:	48 89 df             	mov    %rbx,%rdi
  409b08:	48 89 c6             	mov    %rax,%rsi
  409b0b:	4c 89 ea             	mov    %r13,%rdx
  409b0e:	e8 2d e2 ff ff       	callq  407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  409b13:	e9 8b 0e 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  409b18:	be 04 00 00 00       	mov    $0x4,%esi
  409b1d:	e8 4e ba 01 00       	callq  425570 <p111_rt_fail>
  409b22:	b8 00 00 00 00       	mov    $0x0,%eax
  409b27:	e9 77 0e 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  409b2c:	49 89 d5             	mov    %rdx,%r13
  409b2f:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409b36:	49 89 fc             	mov    %rdi,%r12
  409b39:	e8 52 0a 02 00       	callq  42a590 <p125_rt_take2>
  409b3e:	4c 89 ee             	mov    %r13,%rsi
  409b41:	4c 89 e7             	mov    %r12,%rdi
  409b44:	48 8b 85 b0 f2 ff ff 	mov    -0xd50(%rbp),%rax
  409b4b:	4c 8b a5 b8 f2 ff ff 	mov    -0xd48(%rbp),%r12
  409b52:	89 c0                	mov    %eax,%eax
  409b54:	48 39 d8             	cmp    %rbx,%rax
  409b57:	0f 84 e9 01 00 00    	je     409d46 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x6c6>
  409b5d:	49 89 f7             	mov    %rsi,%r15
  409b60:	48 89 fb             	mov    %rdi,%rbx
  409b63:	e8 78 b2 01 00       	callq  424de0 <p111_rt_sink>
  409b68:	4c 89 e6             	mov    %r12,%rsi
  409b6b:	48 89 df             	mov    %rbx,%rdi
  409b6e:	48 89 fb             	mov    %rdi,%rbx
  409b71:	e8 6a b2 01 00       	callq  424de0 <p111_rt_sink>
  409b76:	48 89 df             	mov    %rbx,%rdi
  409b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  409b7e:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409b85:	be 00 00 00 00       	mov    $0x0,%esi
  409b8a:	48 89 fb             	mov    %rdi,%rbx
  409b8d:	e8 be b2 01 00       	callq  424e50 <p111_rt_ctor>
  409b92:	48 89 df             	mov    %rbx,%rdi
  409b95:	48 89 c6             	mov    %rax,%rsi
  409b98:	48 89 fb             	mov    %rdi,%rbx
  409b9b:	e8 40 b2 01 00       	callq  424de0 <p111_rt_sink>
  409ba0:	48 89 df             	mov    %rbx,%rdi
  409ba3:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  409baa:	19 00 02 
  409bad:	48 89 85 38 fe ff ff 	mov    %rax,-0x1c8(%rbp)
  409bb4:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  409bbb:	18 00 01 
  409bbe:	48 89 85 40 fe ff ff 	mov    %rax,-0x1c0(%rbp)
  409bc5:	48 c7 85 48 fe ff ff 	movq   $0x0,-0x1b8(%rbp)
  409bcc:	00 00 00 00 
  409bd0:	48 c7 85 50 fe ff ff 	movq   $0x0,-0x1b0(%rbp)
  409bd7:	00 00 00 00 
  409bdb:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409be2:	11 00 01 
  409be5:	48 89 85 58 fe ff ff 	mov    %rax,-0x1a8(%rbp)
  409bec:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409bf3:	11 00 01 
  409bf6:	48 89 85 60 fe ff ff 	mov    %rax,-0x1a0(%rbp)
  409bfd:	48 c7 85 68 fe ff ff 	movq   $0x0,-0x198(%rbp)
  409c04:	00 00 00 00 
  409c08:	48 c7 85 70 fe ff ff 	movq   $0x0,-0x190(%rbp)
  409c0f:	00 00 00 00 
  409c13:	b9 08 00 00 00       	mov    $0x8,%ecx
  409c18:	48 8d 95 38 fe ff ff 	lea    -0x1c8(%rbp),%rdx
  409c1f:	be 96 00 00 00       	mov    $0x96,%esi
  409c24:	48 89 fb             	mov    %rdi,%rbx
  409c27:	e8 24 b2 01 00       	callq  424e50 <p111_rt_ctor>
  409c2c:	48 89 df             	mov    %rbx,%rdi
  409c2f:	48 89 c3             	mov    %rax,%rbx
  409c32:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  409c39:	19 00 02 
  409c3c:	48 89 85 78 fe ff ff 	mov    %rax,-0x188(%rbp)
  409c43:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  409c4a:	18 00 01 
  409c4d:	48 89 85 80 fe ff ff 	mov    %rax,-0x180(%rbp)
  409c54:	48 c7 85 88 fe ff ff 	movq   $0x0,-0x178(%rbp)
  409c5b:	00 00 00 00 
  409c5f:	48 c7 85 90 fe ff ff 	movq   $0x0,-0x170(%rbp)
  409c66:	00 00 00 00 
  409c6a:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409c71:	11 00 01 
  409c74:	48 89 85 98 fe ff ff 	mov    %rax,-0x168(%rbp)
  409c7b:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409c82:	11 00 01 
  409c85:	48 89 85 a0 fe ff ff 	mov    %rax,-0x160(%rbp)
  409c8c:	48 c7 85 a8 fe ff ff 	movq   $0x0,-0x158(%rbp)
  409c93:	00 00 00 00 
  409c97:	48 c7 85 b0 fe ff ff 	movq   $0x0,-0x150(%rbp)
  409c9e:	00 00 00 00 
  409ca2:	b9 08 00 00 00       	mov    $0x8,%ecx
  409ca7:	48 8d 95 78 fe ff ff 	lea    -0x188(%rbp),%rdx
  409cae:	be 96 00 00 00       	mov    $0x96,%esi
  409cb3:	49 89 fc             	mov    %rdi,%r12
  409cb6:	e8 95 b1 01 00       	callq  424e50 <p111_rt_ctor>
  409cbb:	4c 89 e7             	mov    %r12,%rdi
  409cbe:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  409cc5:	18 00 01 
  409cc8:	48 89 8d f0 fd ff ff 	mov    %rcx,-0x210(%rbp)
  409ccf:	48 b9 2c 82 10 03 00 	movabs $0x20019000310822c,%rcx
  409cd6:	19 00 02 
  409cd9:	48 89 8d f8 fd ff ff 	mov    %rcx,-0x208(%rbp)
  409ce0:	48 c7 85 00 fe ff ff 	movq   $0x0,-0x200(%rbp)
  409ce7:	00 00 00 00 
  409ceb:	48 c7 85 08 fe ff ff 	movq   $0x0,-0x1f8(%rbp)
  409cf2:	00 00 00 00 
  409cf6:	48 89 9d 10 fe ff ff 	mov    %rbx,-0x1f0(%rbp)
  409cfd:	48 89 85 18 fe ff ff 	mov    %rax,-0x1e8(%rbp)
  409d04:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  409d0b:	11 00 01 
  409d0e:	48 89 85 20 fe ff ff 	mov    %rax,-0x1e0(%rbp)
  409d15:	48 c7 85 28 fe ff ff 	movq   $0x0,-0x1d8(%rbp)
  409d1c:	00 00 00 00 
  409d20:	48 c7 85 30 fe ff ff 	movq   $0x0,-0x1d0(%rbp)
  409d27:	00 00 00 00 
  409d2b:	b9 09 00 00 00       	mov    $0x9,%ecx
  409d30:	48 8d 95 f0 fd ff ff 	lea    -0x210(%rbp),%rdx
  409d37:	be 99 00 00 00       	mov    $0x99,%esi
  409d3c:	e8 0f b1 01 00       	callq  424e50 <p111_rt_ctor>
  409d41:	e9 5d 0c 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  409d46:	49 89 f7             	mov    %rsi,%r15
  409d49:	4c 89 e6             	mov    %r12,%rsi
  409d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  409d51:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409d58:	49 89 f4             	mov    %rsi,%r12
  409d5b:	be 00 00 00 00       	mov    $0x0,%esi
  409d60:	48 89 fb             	mov    %rdi,%rbx
  409d63:	e8 e8 b0 01 00       	callq  424e50 <p111_rt_ctor>
  409d68:	48 89 df             	mov    %rbx,%rdi
  409d6b:	48 89 c6             	mov    %rax,%rsi
  409d6e:	48 89 fb             	mov    %rdi,%rbx
  409d71:	e8 6a b0 01 00       	callq  424de0 <p111_rt_sink>
  409d76:	4c 89 e6             	mov    %r12,%rsi
  409d79:	48 89 df             	mov    %rbx,%rdi
  409d7c:	4c 89 fa             	mov    %r15,%rdx
  409d7f:	e8 bc df ff ff       	callq  407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  409d84:	e9 1a 0c 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  409d89:	4c 89 f1             	mov    %r14,%rcx
  409d8c:	49 89 ce             	mov    %rcx,%r14
  409d8f:	b9 09 00 00 00       	mov    $0x9,%ecx
  409d94:	49 89 d5             	mov    %rdx,%r13
  409d97:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409d9e:	48 89 fb             	mov    %rdi,%rbx
  409da1:	e8 2a b2 01 00       	callq  424fd0 <p111_rt_take>
  409da6:	48 89 df             	mov    %rbx,%rdi
  409da9:	48 8b b5 b0 f2 ff ff 	mov    -0xd50(%rbp),%rsi
  409db0:	48 8b 85 b8 f2 ff ff 	mov    -0xd48(%rbp),%rax
  409db7:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  409dbb:	48 8b 9d c0 f2 ff ff 	mov    -0xd40(%rbp),%rbx
  409dc2:	48 89 5d 90          	mov    %rbx,-0x70(%rbp)
  409dc6:	48 8b 9d c8 f2 ff ff 	mov    -0xd38(%rbp),%rbx
  409dcd:	48 89 5d 98          	mov    %rbx,-0x68(%rbp)
  409dd1:	48 8b 85 d0 f2 ff ff 	mov    -0xd30(%rbp),%rax
  409dd8:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  409ddc:	48 8b 85 d8 f2 ff ff 	mov    -0xd28(%rbp),%rax
  409de3:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  409de7:	4c 8b a5 e0 f2 ff ff 	mov    -0xd20(%rbp),%r12
  409dee:	48 8b 85 e8 f2 ff ff 	mov    -0xd18(%rbp),%rax
  409df5:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  409df9:	48 8b 85 f0 f2 ff ff 	mov    -0xd10(%rbp),%rax
  409e00:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  409e04:	48 89 fb             	mov    %rdi,%rbx
  409e07:	e8 d4 af 01 00       	callq  424de0 <p111_rt_sink>
  409e0c:	48 89 df             	mov    %rbx,%rdi
  409e0f:	48 8b 75 d8          	mov    -0x28(%rbp),%rsi
  409e13:	48 89 fb             	mov    %rdi,%rbx
  409e16:	e8 c5 af 01 00       	callq  424de0 <p111_rt_sink>
  409e1b:	48 89 df             	mov    %rbx,%rdi
  409e1e:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  409e22:	48 89 fb             	mov    %rdi,%rbx
  409e25:	e8 b6 af 01 00       	callq  424de0 <p111_rt_sink>
  409e2a:	48 89 df             	mov    %rbx,%rdi
  409e2d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  409e31:	48 89 fb             	mov    %rdi,%rbx
  409e34:	e8 a7 af 01 00       	callq  424de0 <p111_rt_sink>
  409e39:	48 89 df             	mov    %rbx,%rdi
  409e3c:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  409e40:	48 89 fb             	mov    %rdi,%rbx
  409e43:	e8 98 af 01 00       	callq  424de0 <p111_rt_sink>
  409e48:	48 89 df             	mov    %rbx,%rdi
  409e4b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  409e4f:	48 89 fb             	mov    %rdi,%rbx
  409e52:	e8 f9 ae 01 00       	callq  424d50 <p111_rt_keep>
  409e57:	48 89 df             	mov    %rbx,%rdi
  409e5a:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  409e5e:	48 be 2c 82 10 03 00 	movabs $0x20019000310822c,%rsi
  409e65:	19 00 02 
  409e68:	48 89 fb             	mov    %rdi,%rbx
  409e6b:	e8 e0 ae 01 00       	callq  424d50 <p111_rt_keep>
  409e70:	4c 89 f1             	mov    %r14,%rcx
  409e73:	4c 89 ea             	mov    %r13,%rdx
  409e76:	48 89 df             	mov    %rbx,%rdi
  409e79:	48 89 c6             	mov    %rax,%rsi
  409e7c:	48 89 f0             	mov    %rsi,%rax
  409e7f:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  409e83:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  409e87:	49 89 ce             	mov    %rcx,%r14
  409e8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  409e8f:	49 89 d5             	mov    %rdx,%r13
  409e92:	48 89 c2             	mov    %rax,%rdx
  409e95:	48 89 fb             	mov    %rdi,%rbx
  409e98:	e8 63 bd ff ff       	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  409e9d:	4c 89 e6             	mov    %r12,%rsi
  409ea0:	48 89 df             	mov    %rbx,%rdi
  409ea3:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  409ea7:	49 89 f4             	mov    %rsi,%r12
  409eaa:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  409eae:	48 89 fb             	mov    %rdi,%rbx
  409eb1:	e8 2a af 01 00       	callq  424de0 <p111_rt_sink>
  409eb6:	4c 89 e6             	mov    %r12,%rsi
  409eb9:	48 89 df             	mov    %rbx,%rdi
  409ebc:	49 89 f4             	mov    %rsi,%r12
  409ebf:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  409ec3:	48 89 fb             	mov    %rdi,%rbx
  409ec6:	e8 15 af 01 00       	callq  424de0 <p111_rt_sink>
  409ecb:	4d 89 f8             	mov    %r15,%r8
  409ece:	4c 89 f1             	mov    %r14,%rcx
  409ed1:	4c 89 ea             	mov    %r13,%rdx
  409ed4:	4c 89 e6             	mov    %r12,%rsi
  409ed7:	48 89 df             	mov    %rbx,%rdi
  409eda:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  409ede:	49 83 f9 01          	cmp    $0x1,%r9
  409ee2:	0f 94 c0             	sete   %al
  409ee5:	0f b6 c0             	movzbl %al,%eax
  409ee8:	49 c1 e9 28          	shr    $0x28,%r9
  409eec:	49 81 e1 ff ff 7f 00 	and    $0x7fffff,%r9
  409ef3:	49 81 f9 02 00 01 00 	cmp    $0x10002,%r9
  409efa:	4d 89 c6             	mov    %r8,%r14
  409efd:	41 0f 94 c0          	sete   %r8b
  409f01:	45 0f b6 c0          	movzbl %r8b,%r8d
  409f05:	44 09 c0             	or     %r8d,%eax
  409f08:	0f 85 8a 08 00 00    	jne    40a798 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1118>
  409f0e:	83 f0 01             	xor    $0x1,%eax
  409f11:	0f 84 21 08 00 00    	je     40a738 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x10b8>
  409f17:	49 89 cf             	mov    %rcx,%r15
  409f1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  409f1f:	49 89 d5             	mov    %rdx,%r13
  409f22:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409f29:	49 89 f4             	mov    %rsi,%r12
  409f2c:	be 00 00 00 00       	mov    $0x0,%esi
  409f31:	48 89 fb             	mov    %rdi,%rbx
  409f34:	e8 17 af 01 00       	callq  424e50 <p111_rt_ctor>
  409f39:	48 89 df             	mov    %rbx,%rdi
  409f3c:	48 89 c6             	mov    %rax,%rsi
  409f3f:	48 89 fb             	mov    %rdi,%rbx
  409f42:	e8 99 ae 01 00       	callq  424de0 <p111_rt_sink>
  409f47:	4c 89 e6             	mov    %r12,%rsi
  409f4a:	48 89 df             	mov    %rbx,%rdi
  409f4d:	49 89 f4             	mov    %rsi,%r12
  409f50:	48 8b 75 98          	mov    -0x68(%rbp),%rsi
  409f54:	48 89 fb             	mov    %rdi,%rbx
  409f57:	e8 f4 ad 01 00       	callq  424d50 <p111_rt_keep>
  409f5c:	4c 89 f9             	mov    %r15,%rcx
  409f5f:	4c 89 e6             	mov    %r12,%rsi
  409f62:	48 89 df             	mov    %rbx,%rdi
  409f65:	49 89 f4             	mov    %rsi,%r12
  409f68:	48 8b 75 90          	mov    -0x70(%rbp),%rsi
  409f6c:	49 89 cf             	mov    %rcx,%r15
  409f6f:	89 c1                	mov    %eax,%ecx
  409f71:	48 89 4d 80          	mov    %rcx,-0x80(%rbp)
  409f75:	48 83 f9 00          	cmp    $0x0,%rcx
  409f79:	0f 84 31 05 00 00    	je     40a4b0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xe30>
  409f7f:	2e 2e 2e 2e 48 89 fb 	cs cs cs cs mov %rdi,%rbx
  409f86:	e8 55 ae 01 00       	callq  424de0 <p111_rt_sink>
  409f8b:	2e 2e 4c 89 f9       	cs cs mov %r15,%rcx
  409f90:	4c 89 ea             	mov    %r13,%rdx
  409f93:	4c 89 e6             	mov    %r12,%rsi
  409f96:	48 89 df             	mov    %rbx,%rdi
  409f99:	49 89 cf             	mov    %rcx,%r15
  409f9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  409fa1:	49 89 d4             	mov    %rdx,%r12
  409fa4:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  409fab:	49 89 f5             	mov    %rsi,%r13
  409fae:	be 00 00 00 00       	mov    $0x0,%esi
  409fb3:	48 89 fb             	mov    %rdi,%rbx
  409fb6:	e8 95 ae 01 00       	callq  424e50 <p111_rt_ctor>
  409fbb:	48 89 df             	mov    %rbx,%rdi
  409fbe:	48 89 c6             	mov    %rax,%rsi
  409fc1:	48 89 fb             	mov    %rdi,%rbx
  409fc4:	e8 17 ae 01 00       	callq  424de0 <p111_rt_sink>
  409fc9:	4c 89 ee             	mov    %r13,%rsi
  409fcc:	48 89 df             	mov    %rbx,%rdi
  409fcf:	48 8b 5d 88          	mov    -0x78(%rbp),%rbx
  409fd3:	48 89 f0             	mov    %rsi,%rax
  409fd6:	48 c1 e8 28          	shr    $0x28,%rax
  409fda:	48 25 ff ff 00 00    	and    $0xffff,%rax
  409fe0:	48 83 f8 11          	cmp    $0x11,%rax
  409fe4:	0f 84 e7 02 00 00    	je     40a2d1 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xc51>
  409fea:	48 83 f8 12          	cmp    $0x12,%rax
  409fee:	74 20                	je     40a010 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x990>
  409ff0:	be 04 00 00 00       	mov    $0x4,%esi
  409ff5:	48 89 fb             	mov    %rdi,%rbx
  409ff8:	e8 73 b5 01 00       	callq  425570 <p111_rt_fail>
  409ffd:	4c 89 e2             	mov    %r12,%rdx
  40a000:	48 89 df             	mov    %rbx,%rdi
  40a003:	4c 89 f9             	mov    %r15,%rcx
  40a006:	be 00 00 00 00       	mov    $0x0,%esi
  40a00b:	e9 b9 02 00 00       	jmpq   40a2c9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xc49>
  40a010:	4c 89 e2             	mov    %r12,%rdx
  40a013:	49 89 d4             	mov    %rdx,%r12
  40a016:	48 8d 95 40 fc ff ff 	lea    -0x3c0(%rbp),%rdx
  40a01d:	49 89 fd             	mov    %rdi,%r13
  40a020:	e8 6b 05 02 00       	callq  42a590 <p125_rt_take2>
  40a025:	4c 89 ef             	mov    %r13,%rdi
  40a028:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  40a02c:	48 8b b5 40 fc ff ff 	mov    -0x3c0(%rbp),%rsi
  40a033:	49 89 f5             	mov    %rsi,%r13
  40a036:	48 8b b5 48 fc ff ff 	mov    -0x3b8(%rbp),%rsi
  40a03d:	48 21 d8             	and    %rbx,%rax
  40a040:	48 83 f8 00          	cmp    $0x0,%rax
  40a044:	0f 94 c0             	sete   %al
  40a047:	0f b6 c0             	movzbl %al,%eax
  40a04a:	83 f0 01             	xor    $0x1,%eax
  40a04d:	48 83 f8 01          	cmp    $0x1,%rax
  40a051:	74 19                	je     40a06c <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x9ec>
  40a053:	48 89 fb             	mov    %rdi,%rbx
  40a056:	e8 85 ad 01 00       	callq  424de0 <p111_rt_sink>
  40a05b:	4c 89 ee             	mov    %r13,%rsi
  40a05e:	48 89 df             	mov    %rbx,%rdi
  40a061:	4c 89 e2             	mov    %r12,%rdx
  40a064:	4c 89 f9             	mov    %r15,%rcx
  40a067:	e9 5d 02 00 00       	jmpq   40a2c9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xc49>
  40a06c:	49 87 f5             	xchg   %rsi,%r13
  40a06f:	48 89 fb             	mov    %rdi,%rbx
  40a072:	e8 69 ad 01 00       	callq  424de0 <p111_rt_sink>
  40a077:	4c 89 ee             	mov    %r13,%rsi
  40a07a:	48 89 df             	mov    %rbx,%rdi
  40a07d:	48 89 f0             	mov    %rsi,%rax
  40a080:	48 c1 e8 28          	shr    $0x28,%rax
  40a084:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40a08a:	48 83 f8 11          	cmp    $0x11,%rax
  40a08e:	74 68                	je     40a0f8 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xa78>
  40a090:	48 83 f8 12          	cmp    $0x12,%rax
  40a094:	74 20                	je     40a0b6 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xa36>
  40a096:	be 04 00 00 00       	mov    $0x4,%esi
  40a09b:	48 89 fb             	mov    %rdi,%rbx
  40a09e:	e8 cd b4 01 00       	callq  425570 <p111_rt_fail>
  40a0a3:	4c 89 e2             	mov    %r12,%rdx
  40a0a6:	48 89 df             	mov    %rbx,%rdi
  40a0a9:	4c 89 f9             	mov    %r15,%rcx
  40a0ac:	be 00 00 00 00       	mov    $0x0,%esi
  40a0b1:	e9 13 02 00 00       	jmpq   40a2c9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xc49>
  40a0b6:	4c 89 e2             	mov    %r12,%rdx
  40a0b9:	49 89 d5             	mov    %rdx,%r13
  40a0bc:	48 8d 95 18 fd ff ff 	lea    -0x2e8(%rbp),%rdx
  40a0c3:	48 89 fb             	mov    %rdi,%rbx
  40a0c6:	e8 c5 04 02 00       	callq  42a590 <p125_rt_take2>
  40a0cb:	48 89 df             	mov    %rbx,%rdi
  40a0ce:	48 8b b5 18 fd ff ff 	mov    -0x2e8(%rbp),%rsi
  40a0d5:	49 89 f4             	mov    %rsi,%r12
  40a0d8:	48 8b b5 20 fd ff ff 	mov    -0x2e0(%rbp),%rsi
  40a0df:	48 89 fb             	mov    %rdi,%rbx
  40a0e2:	e8 f9 ac 01 00       	callq  424de0 <p111_rt_sink>
  40a0e7:	4c 89 f9             	mov    %r15,%rcx
  40a0ea:	4c 89 ea             	mov    %r13,%rdx
  40a0ed:	4c 89 e6             	mov    %r12,%rsi
  40a0f0:	48 89 df             	mov    %rbx,%rdi
  40a0f3:	e9 d1 01 00 00       	jmpq   40a2c9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xc49>
  40a0f8:	4c 89 e2             	mov    %r12,%rdx
  40a0fb:	4c 89 f9             	mov    %r15,%rcx
  40a0fe:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a105:	19 00 02 
  40a108:	48 89 85 70 fd ff ff 	mov    %rax,-0x290(%rbp)
  40a10f:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a116:	18 00 01 
  40a119:	48 89 85 78 fd ff ff 	mov    %rax,-0x288(%rbp)
  40a120:	48 c7 85 80 fd ff ff 	movq   $0x0,-0x280(%rbp)
  40a127:	00 00 00 00 
  40a12b:	48 c7 85 88 fd ff ff 	movq   $0x0,-0x278(%rbp)
  40a132:	00 00 00 00 
  40a136:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a13d:	11 00 01 
  40a140:	48 89 85 90 fd ff ff 	mov    %rax,-0x270(%rbp)
  40a147:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a14e:	11 00 01 
  40a151:	48 89 85 98 fd ff ff 	mov    %rax,-0x268(%rbp)
  40a158:	48 c7 85 a0 fd ff ff 	movq   $0x0,-0x260(%rbp)
  40a15f:	00 00 00 00 
  40a163:	48 c7 85 a8 fd ff ff 	movq   $0x0,-0x258(%rbp)
  40a16a:	00 00 00 00 
  40a16e:	49 89 cd             	mov    %rcx,%r13
  40a171:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a176:	49 89 d4             	mov    %rdx,%r12
  40a179:	48 8d 95 70 fd ff ff 	lea    -0x290(%rbp),%rdx
  40a180:	be 96 00 00 00       	mov    $0x96,%esi
  40a185:	48 89 fb             	mov    %rdi,%rbx
  40a188:	e8 c3 ac 01 00       	callq  424e50 <p111_rt_ctor>
  40a18d:	4c 89 e9             	mov    %r13,%rcx
  40a190:	4c 89 e2             	mov    %r12,%rdx
  40a193:	48 89 df             	mov    %rbx,%rdi
  40a196:	48 89 c3             	mov    %rax,%rbx
  40a199:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a1a0:	19 00 02 
  40a1a3:	48 89 85 b0 fd ff ff 	mov    %rax,-0x250(%rbp)
  40a1aa:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a1b1:	18 00 01 
  40a1b4:	48 89 85 b8 fd ff ff 	mov    %rax,-0x248(%rbp)
  40a1bb:	48 c7 85 c0 fd ff ff 	movq   $0x0,-0x240(%rbp)
  40a1c2:	00 00 00 00 
  40a1c6:	48 c7 85 c8 fd ff ff 	movq   $0x0,-0x238(%rbp)
  40a1cd:	00 00 00 00 
  40a1d1:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a1d8:	11 00 01 
  40a1db:	48 89 85 d0 fd ff ff 	mov    %rax,-0x230(%rbp)
  40a1e2:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a1e9:	11 00 01 
  40a1ec:	48 89 85 d8 fd ff ff 	mov    %rax,-0x228(%rbp)
  40a1f3:	48 c7 85 e0 fd ff ff 	movq   $0x0,-0x220(%rbp)
  40a1fa:	00 00 00 00 
  40a1fe:	48 c7 85 e8 fd ff ff 	movq   $0x0,-0x218(%rbp)
  40a205:	00 00 00 00 
  40a209:	49 89 cf             	mov    %rcx,%r15
  40a20c:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a211:	49 89 d5             	mov    %rdx,%r13
  40a214:	48 8d 95 b0 fd ff ff 	lea    -0x250(%rbp),%rdx
  40a21b:	be 96 00 00 00       	mov    $0x96,%esi
  40a220:	49 89 fc             	mov    %rdi,%r12
  40a223:	e8 28 ac 01 00       	callq  424e50 <p111_rt_ctor>
  40a228:	4c 89 f9             	mov    %r15,%rcx
  40a22b:	4c 89 ea             	mov    %r13,%rdx
  40a22e:	4c 89 e7             	mov    %r12,%rdi
  40a231:	48 be 00 00 00 00 00 	movabs $0x100180000000000,%rsi
  40a238:	18 00 01 
  40a23b:	48 89 b5 28 fd ff ff 	mov    %rsi,-0x2d8(%rbp)
  40a242:	48 be 2c 82 10 03 00 	movabs $0x20019000310822c,%rsi
  40a249:	19 00 02 
  40a24c:	48 89 b5 30 fd ff ff 	mov    %rsi,-0x2d0(%rbp)
  40a253:	48 c7 85 38 fd ff ff 	movq   $0x0,-0x2c8(%rbp)
  40a25a:	00 00 00 00 
  40a25e:	48 c7 85 40 fd ff ff 	movq   $0x0,-0x2c0(%rbp)
  40a265:	00 00 00 00 
  40a269:	48 89 9d 48 fd ff ff 	mov    %rbx,-0x2b8(%rbp)
  40a270:	48 89 85 50 fd ff ff 	mov    %rax,-0x2b0(%rbp)
  40a277:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a27e:	11 00 01 
  40a281:	48 89 85 58 fd ff ff 	mov    %rax,-0x2a8(%rbp)
  40a288:	48 c7 85 60 fd ff ff 	movq   $0x0,-0x2a0(%rbp)
  40a28f:	00 00 00 00 
  40a293:	48 c7 85 68 fd ff ff 	movq   $0x0,-0x298(%rbp)
  40a29a:	00 00 00 00 
  40a29e:	49 89 cd             	mov    %rcx,%r13
  40a2a1:	b9 09 00 00 00       	mov    $0x9,%ecx
  40a2a6:	49 89 d4             	mov    %rdx,%r12
  40a2a9:	48 8d 95 28 fd ff ff 	lea    -0x2d8(%rbp),%rdx
  40a2b0:	be 99 00 00 00       	mov    $0x99,%esi
  40a2b5:	48 89 fb             	mov    %rdi,%rbx
  40a2b8:	e8 93 ab 01 00       	callq  424e50 <p111_rt_ctor>
  40a2bd:	4c 89 e9             	mov    %r13,%rcx
  40a2c0:	4c 89 e2             	mov    %r12,%rdx
  40a2c3:	48 89 df             	mov    %rbx,%rdi
  40a2c6:	48 89 c6             	mov    %rax,%rsi
  40a2c9:	4d 89 f0             	mov    %r14,%r8
  40a2cc:	e9 d4 01 00 00       	jmpq   40a4a5 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0xe25>
  40a2d1:	4c 89 e2             	mov    %r12,%rdx
  40a2d4:	4c 89 f9             	mov    %r15,%rcx
  40a2d7:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a2de:	19 00 02 
  40a2e1:	48 89 85 98 fc ff ff 	mov    %rax,-0x368(%rbp)
  40a2e8:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a2ef:	18 00 01 
  40a2f2:	48 89 85 a0 fc ff ff 	mov    %rax,-0x360(%rbp)
  40a2f9:	48 c7 85 a8 fc ff ff 	movq   $0x0,-0x358(%rbp)
  40a300:	00 00 00 00 
  40a304:	48 c7 85 b0 fc ff ff 	movq   $0x0,-0x350(%rbp)
  40a30b:	00 00 00 00 
  40a30f:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a316:	11 00 01 
  40a319:	48 89 85 b8 fc ff ff 	mov    %rax,-0x348(%rbp)
  40a320:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a327:	11 00 01 
  40a32a:	48 89 85 c0 fc ff ff 	mov    %rax,-0x340(%rbp)
  40a331:	48 c7 85 c8 fc ff ff 	movq   $0x0,-0x338(%rbp)
  40a338:	00 00 00 00 
  40a33c:	48 c7 85 d0 fc ff ff 	movq   $0x0,-0x330(%rbp)
  40a343:	00 00 00 00 
  40a347:	49 89 cd             	mov    %rcx,%r13
  40a34a:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a34f:	49 89 d4             	mov    %rdx,%r12
  40a352:	48 8d 95 98 fc ff ff 	lea    -0x368(%rbp),%rdx
  40a359:	be 96 00 00 00       	mov    $0x96,%esi
  40a35e:	48 89 fb             	mov    %rdi,%rbx
  40a361:	e8 ea aa 01 00       	callq  424e50 <p111_rt_ctor>
  40a366:	4c 89 e9             	mov    %r13,%rcx
  40a369:	4c 89 e2             	mov    %r12,%rdx
  40a36c:	48 89 df             	mov    %rbx,%rdi
  40a36f:	48 89 c3             	mov    %rax,%rbx
  40a372:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a379:	19 00 02 
  40a37c:	48 89 85 d8 fc ff ff 	mov    %rax,-0x328(%rbp)
  40a383:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a38a:	18 00 01 
  40a38d:	48 89 85 e0 fc ff ff 	mov    %rax,-0x320(%rbp)
  40a394:	48 c7 85 e8 fc ff ff 	movq   $0x0,-0x318(%rbp)
  40a39b:	00 00 00 00 
  40a39f:	48 c7 85 f0 fc ff ff 	movq   $0x0,-0x310(%rbp)
  40a3a6:	00 00 00 00 
  40a3aa:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a3b1:	11 00 01 
  40a3b4:	48 89 85 f8 fc ff ff 	mov    %rax,-0x308(%rbp)
  40a3bb:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a3c2:	11 00 01 
  40a3c5:	48 89 85 00 fd ff ff 	mov    %rax,-0x300(%rbp)
  40a3cc:	48 c7 85 08 fd ff ff 	movq   $0x0,-0x2f8(%rbp)
  40a3d3:	00 00 00 00 
  40a3d7:	48 c7 85 10 fd ff ff 	movq   $0x0,-0x2f0(%rbp)
  40a3de:	00 00 00 00 
  40a3e2:	49 89 cf             	mov    %rcx,%r15
  40a3e5:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a3ea:	49 89 d5             	mov    %rdx,%r13
  40a3ed:	48 8d 95 d8 fc ff ff 	lea    -0x328(%rbp),%rdx
  40a3f4:	be 96 00 00 00       	mov    $0x96,%esi
  40a3f9:	49 89 fc             	mov    %rdi,%r12
  40a3fc:	e8 4f aa 01 00       	callq  424e50 <p111_rt_ctor>
  40a401:	4c 89 f9             	mov    %r15,%rcx
  40a404:	4c 89 ea             	mov    %r13,%rdx
  40a407:	4c 89 e7             	mov    %r12,%rdi
  40a40a:	48 be 00 00 00 00 00 	movabs $0x100180000000000,%rsi
  40a411:	18 00 01 
  40a414:	48 89 b5 50 fc ff ff 	mov    %rsi,-0x3b0(%rbp)
  40a41b:	48 be 2c 82 10 03 00 	movabs $0x20019000310822c,%rsi
  40a422:	19 00 02 
  40a425:	48 89 b5 58 fc ff ff 	mov    %rsi,-0x3a8(%rbp)
  40a42c:	48 c7 85 60 fc ff ff 	movq   $0x0,-0x3a0(%rbp)
  40a433:	00 00 00 00 
  40a437:	48 c7 85 68 fc ff ff 	movq   $0x0,-0x398(%rbp)
  40a43e:	00 00 00 00 
  40a442:	48 89 9d 70 fc ff ff 	mov    %rbx,-0x390(%rbp)
  40a449:	48 89 85 78 fc ff ff 	mov    %rax,-0x388(%rbp)
  40a450:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a457:	11 00 01 
  40a45a:	48 89 85 80 fc ff ff 	mov    %rax,-0x380(%rbp)
  40a461:	48 c7 85 88 fc ff ff 	movq   $0x0,-0x378(%rbp)
  40a468:	00 00 00 00 
  40a46c:	48 c7 85 90 fc ff ff 	movq   $0x0,-0x370(%rbp)
  40a473:	00 00 00 00 
  40a477:	49 89 cd             	mov    %rcx,%r13
  40a47a:	b9 09 00 00 00       	mov    $0x9,%ecx
  40a47f:	49 89 d4             	mov    %rdx,%r12
  40a482:	48 8d 95 50 fc ff ff 	lea    -0x3b0(%rbp),%rdx
  40a489:	be 99 00 00 00       	mov    $0x99,%esi
  40a48e:	48 89 fb             	mov    %rdi,%rbx
  40a491:	e8 ba a9 01 00       	callq  424e50 <p111_rt_ctor>
  40a496:	4d 89 f0             	mov    %r14,%r8
  40a499:	4c 89 e9             	mov    %r13,%rcx
  40a49c:	4c 89 e2             	mov    %r12,%rdx
  40a49f:	48 89 df             	mov    %rbx,%rdi
  40a4a2:	48 89 c6             	mov    %rax,%rsi
  40a4a5:	49 89 ce             	mov    %rcx,%r14
  40a4a8:	4d 89 c7             	mov    %r8,%r15
  40a4ab:	e9 00 f2 ff ff       	jmpq   4096b0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x30>
  40a4b0:	2e 2e 49 89 f6       	cs cs mov %rsi,%r14
  40a4b5:	48 89 c6             	mov    %rax,%rsi
  40a4b8:	4d 89 ef             	mov    %r13,%r15
  40a4bb:	48 8b 5d 88          	mov    -0x78(%rbp),%rbx
  40a4bf:	49 89 fd             	mov    %rdi,%r13
  40a4c2:	e8 19 a9 01 00       	callq  424de0 <p111_rt_sink>
  40a4c7:	4c 89 fe             	mov    %r15,%rsi
  40a4ca:	4c 89 ef             	mov    %r13,%rdi
  40a4cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a4d2:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  40a4d9:	49 89 f7             	mov    %rsi,%r15
  40a4dc:	be 00 00 00 00       	mov    $0x0,%esi
  40a4e1:	49 89 fd             	mov    %rdi,%r13
  40a4e4:	e8 67 a9 01 00       	callq  424e50 <p111_rt_ctor>
  40a4e9:	4c 89 ef             	mov    %r13,%rdi
  40a4ec:	48 89 c6             	mov    %rax,%rsi
  40a4ef:	49 89 fd             	mov    %rdi,%r13
  40a4f2:	e8 e9 a8 01 00       	callq  424de0 <p111_rt_sink>
  40a4f7:	4c 89 fe             	mov    %r15,%rsi
  40a4fa:	4c 89 ef             	mov    %r13,%rdi
  40a4fd:	44 89 f0             	mov    %r14d,%eax
  40a500:	48 39 d8             	cmp    %rbx,%rax
  40a503:	0f 84 e9 01 00 00    	je     40a6f2 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1072>
  40a509:	48 89 f3             	mov    %rsi,%rbx
  40a50c:	48 89 fb             	mov    %rdi,%rbx
  40a50f:	e8 cc a8 01 00       	callq  424de0 <p111_rt_sink>
  40a514:	4c 89 e6             	mov    %r12,%rsi
  40a517:	48 89 df             	mov    %rbx,%rdi
  40a51a:	48 89 fb             	mov    %rdi,%rbx
  40a51d:	e8 be a8 01 00       	callq  424de0 <p111_rt_sink>
  40a522:	48 89 df             	mov    %rbx,%rdi
  40a525:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a52a:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  40a531:	be 00 00 00 00       	mov    $0x0,%esi
  40a536:	48 89 fb             	mov    %rdi,%rbx
  40a539:	e8 12 a9 01 00       	callq  424e50 <p111_rt_ctor>
  40a53e:	48 89 df             	mov    %rbx,%rdi
  40a541:	48 89 c6             	mov    %rax,%rsi
  40a544:	48 89 fb             	mov    %rdi,%rbx
  40a547:	e8 94 a8 01 00       	callq  424de0 <p111_rt_sink>
  40a54c:	48 89 df             	mov    %rbx,%rdi
  40a54f:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a556:	19 00 02 
  40a559:	48 89 85 c0 fb ff ff 	mov    %rax,-0x440(%rbp)
  40a560:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a567:	18 00 01 
  40a56a:	48 89 85 c8 fb ff ff 	mov    %rax,-0x438(%rbp)
  40a571:	48 c7 85 d0 fb ff ff 	movq   $0x0,-0x430(%rbp)
  40a578:	00 00 00 00 
  40a57c:	48 c7 85 d8 fb ff ff 	movq   $0x0,-0x428(%rbp)
  40a583:	00 00 00 00 
  40a587:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a58e:	11 00 01 
  40a591:	48 89 85 e0 fb ff ff 	mov    %rax,-0x420(%rbp)
  40a598:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a59f:	11 00 01 
  40a5a2:	48 89 85 e8 fb ff ff 	mov    %rax,-0x418(%rbp)
  40a5a9:	48 c7 85 f0 fb ff ff 	movq   $0x0,-0x410(%rbp)
  40a5b0:	00 00 00 00 
  40a5b4:	48 c7 85 f8 fb ff ff 	movq   $0x0,-0x408(%rbp)
  40a5bb:	00 00 00 00 
  40a5bf:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a5c4:	48 8d 95 c0 fb ff ff 	lea    -0x440(%rbp),%rdx
  40a5cb:	be 96 00 00 00       	mov    $0x96,%esi
  40a5d0:	48 89 fb             	mov    %rdi,%rbx
  40a5d3:	e8 78 a8 01 00       	callq  424e50 <p111_rt_ctor>
  40a5d8:	48 89 df             	mov    %rbx,%rdi
  40a5db:	48 89 c3             	mov    %rax,%rbx
  40a5de:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a5e5:	19 00 02 
  40a5e8:	48 89 85 00 fc ff ff 	mov    %rax,-0x400(%rbp)
  40a5ef:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a5f6:	18 00 01 
  40a5f9:	48 89 85 08 fc ff ff 	mov    %rax,-0x3f8(%rbp)
  40a600:	48 c7 85 10 fc ff ff 	movq   $0x0,-0x3f0(%rbp)
  40a607:	00 00 00 00 
  40a60b:	48 c7 85 18 fc ff ff 	movq   $0x0,-0x3e8(%rbp)
  40a612:	00 00 00 00 
  40a616:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a61d:	11 00 01 
  40a620:	48 89 85 20 fc ff ff 	mov    %rax,-0x3e0(%rbp)
  40a627:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a62e:	11 00 01 
  40a631:	48 89 85 28 fc ff ff 	mov    %rax,-0x3d8(%rbp)
  40a638:	48 c7 85 30 fc ff ff 	movq   $0x0,-0x3d0(%rbp)
  40a63f:	00 00 00 00 
  40a643:	48 c7 85 38 fc ff ff 	movq   $0x0,-0x3c8(%rbp)
  40a64a:	00 00 00 00 
  40a64e:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a653:	48 8d 95 00 fc ff ff 	lea    -0x400(%rbp),%rdx
  40a65a:	be 96 00 00 00       	mov    $0x96,%esi
  40a65f:	49 89 fc             	mov    %rdi,%r12
  40a662:	e8 e9 a7 01 00       	callq  424e50 <p111_rt_ctor>
  40a667:	4c 89 e7             	mov    %r12,%rdi
  40a66a:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  40a671:	18 00 01 
  40a674:	48 89 8d 78 fb ff ff 	mov    %rcx,-0x488(%rbp)
  40a67b:	48 b9 2c 82 10 03 00 	movabs $0x20019000310822c,%rcx
  40a682:	19 00 02 
  40a685:	48 89 8d 80 fb ff ff 	mov    %rcx,-0x480(%rbp)
  40a68c:	48 c7 85 88 fb ff ff 	movq   $0x0,-0x478(%rbp)
  40a693:	00 00 00 00 
  40a697:	48 c7 85 90 fb ff ff 	movq   $0x0,-0x470(%rbp)
  40a69e:	00 00 00 00 
  40a6a2:	48 89 9d 98 fb ff ff 	mov    %rbx,-0x468(%rbp)
  40a6a9:	48 89 85 a0 fb ff ff 	mov    %rax,-0x460(%rbp)
  40a6b0:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a6b7:	11 00 01 
  40a6ba:	48 89 85 a8 fb ff ff 	mov    %rax,-0x458(%rbp)
  40a6c1:	48 c7 85 b0 fb ff ff 	movq   $0x0,-0x450(%rbp)
  40a6c8:	00 00 00 00 
  40a6cc:	48 c7 85 b8 fb ff ff 	movq   $0x0,-0x448(%rbp)
  40a6d3:	00 00 00 00 
  40a6d7:	b9 09 00 00 00       	mov    $0x9,%ecx
  40a6dc:	48 8d 95 78 fb ff ff 	lea    -0x488(%rbp),%rdx
  40a6e3:	be 99 00 00 00       	mov    $0x99,%esi
  40a6e8:	e8 63 a7 01 00       	callq  424e50 <p111_rt_ctor>
  40a6ed:	e9 b1 02 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  40a6f2:	48 89 f3             	mov    %rsi,%rbx
  40a6f5:	4c 89 e6             	mov    %r12,%rsi
  40a6f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a6fd:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  40a704:	49 89 f5             	mov    %rsi,%r13
  40a707:	be 00 00 00 00       	mov    $0x0,%esi
  40a70c:	49 89 fc             	mov    %rdi,%r12
  40a70f:	e8 3c a7 01 00       	callq  424e50 <p111_rt_ctor>
  40a714:	4c 89 e7             	mov    %r12,%rdi
  40a717:	48 89 c6             	mov    %rax,%rsi
  40a71a:	49 89 fc             	mov    %rdi,%r12
  40a71d:	e8 be a6 01 00       	callq  424de0 <p111_rt_sink>
  40a722:	4c 89 ee             	mov    %r13,%rsi
  40a725:	4c 89 e7             	mov    %r12,%rdi
  40a728:	48 89 da             	mov    %rbx,%rdx
  40a72b:	49 89 f4             	mov    %rsi,%r12
  40a72e:	e8 0d d6 ff ff       	callq  407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  40a733:	e9 6b 02 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  40a738:	49 89 f4             	mov    %rsi,%r12
  40a73b:	4c 8b 6d 98          	mov    -0x68(%rbp),%r13
  40a73f:	4c 8b 75 90          	mov    -0x70(%rbp),%r14
  40a743:	48 89 d6             	mov    %rdx,%rsi
  40a746:	48 89 fb             	mov    %rdi,%rbx
  40a749:	e8 92 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a74e:	4c 89 f6             	mov    %r14,%rsi
  40a751:	48 89 df             	mov    %rbx,%rdi
  40a754:	49 89 f6             	mov    %rsi,%r14
  40a757:	48 89 fb             	mov    %rdi,%rbx
  40a75a:	e8 81 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a75f:	4c 89 ee             	mov    %r13,%rsi
  40a762:	48 89 df             	mov    %rbx,%rdi
  40a765:	49 89 f5             	mov    %rsi,%r13
  40a768:	48 89 fb             	mov    %rdi,%rbx
  40a76b:	e8 70 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a770:	4c 89 e6             	mov    %r12,%rsi
  40a773:	48 89 df             	mov    %rbx,%rdi
  40a776:	49 89 f4             	mov    %rsi,%r12
  40a779:	48 89 fb             	mov    %rdi,%rbx
  40a77c:	e8 5f a6 01 00       	callq  424de0 <p111_rt_sink>
  40a781:	48 89 df             	mov    %rbx,%rdi
  40a784:	be 04 00 00 00       	mov    $0x4,%esi
  40a789:	e8 e2 ad 01 00       	callq  425570 <p111_rt_fail>
  40a78e:	b8 00 00 00 00       	mov    $0x0,%eax
  40a793:	e9 0b 02 00 00       	jmpq   40a9a3 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x1323>
  40a798:	49 89 f4             	mov    %rsi,%r12
  40a79b:	4c 8b 6d 98          	mov    -0x68(%rbp),%r13
  40a79f:	4c 8b 75 90          	mov    -0x70(%rbp),%r14
  40a7a3:	48 89 d6             	mov    %rdx,%rsi
  40a7a6:	48 89 fb             	mov    %rdi,%rbx
  40a7a9:	e8 32 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a7ae:	4c 89 f6             	mov    %r14,%rsi
  40a7b1:	48 89 df             	mov    %rbx,%rdi
  40a7b4:	48 89 fb             	mov    %rdi,%rbx
  40a7b7:	e8 24 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a7bc:	4c 89 ee             	mov    %r13,%rsi
  40a7bf:	48 89 df             	mov    %rbx,%rdi
  40a7c2:	48 89 fb             	mov    %rdi,%rbx
  40a7c5:	e8 16 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a7ca:	4c 89 e6             	mov    %r12,%rsi
  40a7cd:	48 89 df             	mov    %rbx,%rdi
  40a7d0:	48 89 fb             	mov    %rdi,%rbx
  40a7d3:	e8 08 a6 01 00       	callq  424de0 <p111_rt_sink>
  40a7d8:	48 89 df             	mov    %rbx,%rdi
  40a7db:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a7e0:	48 8d 95 b0 f2 ff ff 	lea    -0xd50(%rbp),%rdx
  40a7e7:	be 00 00 00 00       	mov    $0x0,%esi
  40a7ec:	48 89 fb             	mov    %rdi,%rbx
  40a7ef:	e8 5c a6 01 00       	callq  424e50 <p111_rt_ctor>
  40a7f4:	48 89 df             	mov    %rbx,%rdi
  40a7f7:	48 89 c6             	mov    %rax,%rsi
  40a7fa:	48 89 fb             	mov    %rdi,%rbx
  40a7fd:	e8 de a5 01 00       	callq  424de0 <p111_rt_sink>
  40a802:	48 89 df             	mov    %rbx,%rdi
  40a805:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a80c:	19 00 02 
  40a80f:	48 89 85 f8 fa ff ff 	mov    %rax,-0x508(%rbp)
  40a816:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a81d:	18 00 01 
  40a820:	48 89 85 00 fb ff ff 	mov    %rax,-0x500(%rbp)
  40a827:	48 c7 85 08 fb ff ff 	movq   $0x0,-0x4f8(%rbp)
  40a82e:	00 00 00 00 
  40a832:	48 c7 85 10 fb ff ff 	movq   $0x0,-0x4f0(%rbp)
  40a839:	00 00 00 00 
  40a83d:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a844:	11 00 01 
  40a847:	48 89 85 18 fb ff ff 	mov    %rax,-0x4e8(%rbp)
  40a84e:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a855:	11 00 01 
  40a858:	48 89 85 20 fb ff ff 	mov    %rax,-0x4e0(%rbp)
  40a85f:	48 c7 85 28 fb ff ff 	movq   $0x0,-0x4d8(%rbp)
  40a866:	00 00 00 00 
  40a86a:	48 c7 85 30 fb ff ff 	movq   $0x0,-0x4d0(%rbp)
  40a871:	00 00 00 00 
  40a875:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a87a:	48 8d 95 f8 fa ff ff 	lea    -0x508(%rbp),%rdx
  40a881:	be 96 00 00 00       	mov    $0x96,%esi
  40a886:	48 89 fb             	mov    %rdi,%rbx
  40a889:	e8 c2 a5 01 00       	callq  424e50 <p111_rt_ctor>
  40a88e:	48 89 df             	mov    %rbx,%rdi
  40a891:	48 89 c3             	mov    %rax,%rbx
  40a894:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  40a89b:	19 00 02 
  40a89e:	48 89 85 38 fb ff ff 	mov    %rax,-0x4c8(%rbp)
  40a8a5:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  40a8ac:	18 00 01 
  40a8af:	48 89 85 40 fb ff ff 	mov    %rax,-0x4c0(%rbp)
  40a8b6:	48 c7 85 48 fb ff ff 	movq   $0x0,-0x4b8(%rbp)
  40a8bd:	00 00 00 00 
  40a8c1:	48 c7 85 50 fb ff ff 	movq   $0x0,-0x4b0(%rbp)
  40a8c8:	00 00 00 00 
  40a8cc:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a8d3:	11 00 01 
  40a8d6:	48 89 85 58 fb ff ff 	mov    %rax,-0x4a8(%rbp)
  40a8dd:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a8e4:	11 00 01 
  40a8e7:	48 89 85 60 fb ff ff 	mov    %rax,-0x4a0(%rbp)
  40a8ee:	48 c7 85 68 fb ff ff 	movq   $0x0,-0x498(%rbp)
  40a8f5:	00 00 00 00 
  40a8f9:	48 c7 85 70 fb ff ff 	movq   $0x0,-0x490(%rbp)
  40a900:	00 00 00 00 
  40a904:	b9 08 00 00 00       	mov    $0x8,%ecx
  40a909:	48 8d 95 38 fb ff ff 	lea    -0x4c8(%rbp),%rdx
  40a910:	be 96 00 00 00       	mov    $0x96,%esi
  40a915:	49 89 fc             	mov    %rdi,%r12
  40a918:	e8 33 a5 01 00       	callq  424e50 <p111_rt_ctor>
  40a91d:	4c 89 e7             	mov    %r12,%rdi
  40a920:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  40a927:	18 00 01 
  40a92a:	48 89 8d b0 fa ff ff 	mov    %rcx,-0x550(%rbp)
  40a931:	48 b9 2c 82 10 03 00 	movabs $0x20019000310822c,%rcx
  40a938:	19 00 02 
  40a93b:	48 89 8d b8 fa ff ff 	mov    %rcx,-0x548(%rbp)
  40a942:	48 c7 85 c0 fa ff ff 	movq   $0x0,-0x540(%rbp)
  40a949:	00 00 00 00 
  40a94d:	48 c7 85 c8 fa ff ff 	movq   $0x0,-0x538(%rbp)
  40a954:	00 00 00 00 
  40a958:	48 89 9d d0 fa ff ff 	mov    %rbx,-0x530(%rbp)
  40a95f:	48 89 85 d8 fa ff ff 	mov    %rax,-0x528(%rbp)
  40a966:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40a96d:	11 00 01 
  40a970:	48 89 85 e0 fa ff ff 	mov    %rax,-0x520(%rbp)
  40a977:	48 c7 85 e8 fa ff ff 	movq   $0x0,-0x518(%rbp)
  40a97e:	00 00 00 00 
  40a982:	48 c7 85 f0 fa ff ff 	movq   $0x0,-0x510(%rbp)
  40a989:	00 00 00 00 
  40a98d:	b9 09 00 00 00       	mov    $0x9,%ecx
  40a992:	48 8d 95 b0 fa ff ff 	lea    -0x550(%rbp),%rdx
  40a999:	be 99 00 00 00       	mov    $0x99,%esi
  40a99e:	e8 ad a4 01 00       	callq  424e50 <p111_rt_ctor>
  40a9a3:	41 5f                	pop    %r15
  40a9a5:	41 5e                	pop    %r14
  40a9a7:	41 5d                	pop    %r13
  40a9a9:	41 5c                	pop    %r12
  40a9ab:	5b                   	pop    %rbx
  40a9ac:	c9                   	leaveq 
  40a9ad:	c3                   	retq   

Disassembly of section .fini:
