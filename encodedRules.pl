% ----------------- Adapter Clause Rules ----------------- %
% rule('accept adapter any').
rule('accept adapter F-H').
rule('reject adapter E').
rule('drop adapter A-C').

% ----------------- EtherNet Clause Rules ----------------- %
% rule('drop ether vid 0x0801 proto 0x0800,0x0802').
% rule('drop ether vid 0x0801 proto ipx').
% rule('reject ether proto 0x0800,0x0802').
% rule('reject ether vid 0x0803-0x0807').
% rule('accept ether proto 0x0808').
% rule('accept ether proto arp').
rule('reject ether proto any').

% ----------------- TCP-UDP Condition Rules ----------------- %
rule('drop tcp src port 100').
rule('accept tcp src port 123-321').
rule('reject tcp src port 101,103').
rule('drop tcp dst port 100').
rule('accept tcp dst port 123-321').
rule('reject tcp dst port 101,103').
rule('drop tcp dst port 100 src port 600').
rule('accept tcp dst port 123-321 src port 222').
rule('reject tcp dst port 101,103 src port 1-10').
% rule('reject udp dst port any').

rule('drop udp src port 0100').
rule('accept udp src port 0x123,0x321').
rule('reject udp src port 0123-0321').
rule('reject udp src port 101,103').
rule('drop udp dst port 100').
rule('accept udp dst port 123-321').
rule('reject udp dst port 101,103').
rule('drop udp dst port 100 src port 600').
rule('accept udp dst port 123-321 src port 222').
rule('reject udp dst port 101,103 src port 1-10').

% ----------------- ICMP Clause Rules ----------------- %
rule('accept icmp type 0123,0124').
rule('reject icmp code 221-255').
rule('drop icmp type 111 code 100').
% rule('drop icmp type any').

% ----------------- IPv4 Clause Rules ----------------- %
rule('accept ip src addr 192.167.10.1').
rule('accept ip src addr 192.167.10.1-192.167.10.3').
rule('reject ip dst addr 192.167.10.33').
rule('drop ip addr 192.167.10.123').
rule('accept ip proto 123').
rule('accept ip src addr 192.167.10.1 dst addr 192.167.10.33').
rule('drop ip src addr 192.167.10.1 dst addr 192.167.10.255 proto 123').