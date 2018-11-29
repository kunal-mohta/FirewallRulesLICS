packet(AdapterId, EtherProtoId, EtherVId, TCPsrcport, TCPdstport, UDPsrcport, UDPdstport, ICMPtype, ICMPcode, IPsrcAddr, IPdstAddr, IPAddr, IPProtoId, X) :-
  adapter(AdapterId, A),
  ethernet(EtherProtoId, EtherVId, B),
  tcp(TCPsrcport, TCPdstport, C),
  udp(UDPsrcport, UDPdstport, D),
  icmp(ICMPtype, ICMPcode, E),
  ip(IPsrcAddr, IPdstAddr, IPAddr, IPProtoId, F),
  Actions = [A, B, C, D, E, F],
  finalAction(Actions, X).

finalAction(Actions, X) :-
  member(reject, Actions),
  X = reject,
  !.

finalAction(Actions, X) :-
  member(drop, Actions),
  X = drop,
  !.

finalAction(Actions, X) :-
  member(accept, Actions),
  X = accept,
  !.

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
  not(TCPsrcport = ""),
  tcpSrc(TCPsrcport, X),
  !.

tcp("", TCPdstport, X) :-
  not(TCPdstport = ""),
  tcpDst(TCPdstport, X),
  !.

tcp(TCPsrcport, TCPdstport, X) :-
  tcpSrcDst(TCPsrcport, TCPdstport, X),
  !.

udp(UDPsrcport, "", X) :-
  not(UDPsrcport = ""),
  udpSrc(UDPsrcport, X),
  !.

udp("", UDPdstport, X) :-
  not(UDPdstport = ""),
  udpDst(UDPdstport, X),
  !.

udp(UDPsrcport, UDPdstport, X) :-
  udpSrcDst(UDPsrcport, UDPdstport, X),
  !.

icmp(ICMPtype, "", X) :-
  not(ICMPtype = ""),
  icmpType(ICMPtype, X),
  !.

icmp("", ICMPcode, X) :-
  not(ICMPcode = ""),
  icmpCode(ICMPcode, X),
  !.

icmp(ICMPtype, ICMPcode, X) :-
  icmpTypeCode(ICMPtype, ICMPcode, X),
  !.

ip(IPsrcAddr, "", "", "", X) :-
  not(IPsrcAddr = ""),
  ipSrc(IPsrcAddr, X),
  !.

ip("", IPdstAddr, "", "", X) :-
  not(IPdstAddr = ""),
  ipDst(IPdstAddr, X),
  !.

ip("", "", IPAddr, "", X) :-
  not(IPAddr = ""),
  ipAddr(IPAddr, X),
  !.

ip(IPsrcAddr, IPdstAddr, "", "", X) :-
  not(IPsrcAddr = ""),
  not(IPdstAddr = ""),
  ipSrcDst(IPsrcAddr, IPdstAddr, X),
  !.

ip("", "", "", IPProtoId, X) :-
  not(IPProtoId = ""),
  ipProto(IPProtoId, X),
  !.

ip(IPsrcAddr, IPdstAddr, "", IPProtoId, X) :-
  % not(ICMPcode = ""),
  % not(ICMPcode = ""),
  % not(ICMPcode = ""),
  ipSrcDstProto(IPsrcAddr, IPdstAddr, IPProtoId, X),
  !.