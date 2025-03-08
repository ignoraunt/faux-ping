global _start

section .data

address:
dw 2
dw 0

db 8
db 8
db 8
db 8

dd 0
dd 0

packet:
db 8
db 0

checksum:
dw 9
dw 0
dw 1

buffer:
times 1024 db 0ffh

success:
db 'Yep, we did get a reply.', 0xA

void:
db 'Sorry, nothing happend.', 0xA

section .text

_start:

; So basically all we need to do is open a socket, send a packet to some
; IP-address and receive a reply (if there is any).


; *****************************************************
; * socket -- create an endpoint for communication    *
; *                                                   *
; * int socket(int domain,                            *
; *            int type,                              *
; *            int protocol)                          *
; *****************************************************

mov rax, 41 ; `socket` syscall
mov rdi, 2  ; family (IPv4)
mov rsi, 3  ; type (raw socket)
mov rdx, 1  ; protocol (ICMP)
syscall

mov r12, rax
not word [checksum] ; fix the checksum


; *******************************************************
; * sendto -- send a message on a socket                *
; *                                                     *
; * ssize_t sendto(int sockfd,                          *
; *                const void buf[.len],                *
; *                size_t len,                          *
; *                int flags,                           *
; *                const struct sockaddr *dest_addr,    *
; *                socklen_t addrlen)                   *
; *******************************************************

mov rax, 44     ; `sendto` syscall
mov rdi, r12    ; socket fd
mov rsi, packet ; packet buffer
mov rdx, 8      ; packet buffer length
mov r10, 0      ; flags
mov r8, address ; socket address buffer
mov r9, 16      ; socket address buffer length
syscall


; *******************************************************************
; * recvfrom -- receive a message from a socket                     *
; *                                                                 *
; * ssize_t recvfrom(int sockfd,                                    *
; *                void buf[restrict .len],                         *
; *                size_t len,                                      *
; *                int flags,                                       *
; *                struct sockaddr *_Nullable restrict src_addr,    *
; *                socklen_t *_Nullable restrict addrlen)           *
; *******************************************************************

mov rax, 45     ; `recvfrom` syscall
mov rdi, r12    ; socket fd
mov rsi, buffer ; buffer to get a packet
mov rdx, 1024   ; packet buffer length
mov r10, 0      ; flags
mov r8, 0       ; socket address
mov r9, 0       ; socket address length
syscall

cmp word [buffer+20], 0 ; skipping 20 IP header bytes
jne no_answer           ; jump if there was no echo reply

; got an answer, success, exit
mov rax, 1
mov rdi, 1
mov rsi, success
mov rdx, 25
syscall

mov rax, 60
mov rdi, 0
syscall

; got no answer, exit
no_answer:
mov rax, 1
mov rdi, 1
mov rsi, void
mov rdx, 24
syscall

mov rax, 60
mov rdi, 0
syscall