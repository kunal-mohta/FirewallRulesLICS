packet(AdapterId, EtherProtoId, EtherVId, TCPsrcport, TCPdstport, UDPsrcport, UDPdstport, ICMPtype, ICMPcode, IPsrcAddr, IPdstAddr, IPAddr, IPProtoId, X) :-
  adapter(AdapterIds, X),
  ethernet(EtherProtoId, EtherVId, X),
  tcp(TCPsrcport, TCPdstport, X),
  udp(UDPsrcport, UDPdstport, X),
  icmp(ICMPtype, ICMPcode, X),
  ip(IPsrcAddr, IPdstAddr, IPAddr, IPProtoId, X),
  member(AdapterId, AdapterIds).

ethernet(EtherProtoId, "", X) :-
  etherProto(EtherProtoId, X),
  !.

ethernet("", EtherVId, X) :-
  etherVlan(EtherVId, X),
  !.

ethernet(EtherProtoId, EtherVId, X) :-
  etherProtoVlan(EtherProtoId, EtherVId, X),
  !.

tcp(TCPsrcport, "", X) :-
  tcpSrc(TCPsrcport, X),
  !.

tcp("", TCPdstport, X) :-
  tcpDst(TCPdstport, X),
  !.

tcp(TCPsrcport, TCPdstport, X) :-
  tcpSrcDst(TCPsrcport, TCPdstport, X),
  !.

udp(UDPsrcport, "", X) :-
  udpSrc(UDPsrcport, X),
  !.

udp("", UDPdstport, X) :-
  udpDst(UDPdstport, X),
  !.

udp(UDPsrcport, UDPdstport, X) :-
  udpSrcDst(UDPsrcport, UDPdstport, X),
  !.

icmp(ICMPtype, "", X) :-
  icmpType(ICMPtype, X),
  !.

icmp("", ICMPcode, X) :-
  icmpCode(ICMPcode, X),
  !.

icmp(ICMPtype, ICMPcode, X) :-
  icmpTypeCode(ICMPtype, ICMPcode, X),
  !.

ip(IPsrcAddr, "", "", "", X) :-
  ipSrc(IPsrcAddr, X),
  !.

ip("", IPdstAddr, "", "", X) :-
  ipDst(IPdstAddr, X),
  !.

ip("", "", IPAddr, "", X) :-
  ipAddr(IPAddr, X),
  !.

ip(IPsrcAddr, IPdstAddr, "", "", X) :-
  ipSrcDst(IPsrcAddr, IPdstAddr, X),
  !.

ip("", "", "", IPProtoId, X) :-
  ipProto(IPProtoId, X),
  !.

ip(IPsrcAddr, IPdstAddr, "", IPProtoId, X) :-
  ipSrcDstProto(IPsrcAddr, IPdstAddr, IPProtoId, X),
  !.