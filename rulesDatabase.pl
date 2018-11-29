rule("drop adapter A-C").
rule("accept adapter F,H").
rule("drop ether vid 0x0801 proto 0x0800,0x0802").
rule("reject ether vid 0x0803-0x0807").
rule("accept udp src port 0x123,0x321").
rule("drop tcp dst port 0,1,2 src port 0xFFFF").
rule("accept icmp code 0123,0124").
rule("drop icmp type 111 code 100").
rule("drop ip proto 123").
rule("reject ip src addr 192.167.10.1 dst addr 192.167.10.255 proto 1,2").
rule("drop adapter D").
rule("reject adapter D,E").
rule("reject icmp type 0x23").