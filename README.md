### A *rather simple* utility to send and receive (once) an ICMP packet to *(to ping)* a Google DNS server at 8.8.8.8.

Assemble with `nasm -felf64` and `ld` it.

You **need to be root**'ed to open a raw socket.

I tried to comment as much as possible for it to be useful for someone trying to figure it out. Block comments are just excerpts from the manual(s).
