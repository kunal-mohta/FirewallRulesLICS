% packet(AdapterId, EtherProtoId, EtherVId, X) :-
%   adapter(AdapterIds, X),
%   member(AdapterId, AdapterIds),
%   etherProto(X).

% packet(EtherProtoId, X) :-
%   etherNet(EtherProtoIds, X),
%   member(EtherProtoId, EtherProtoIds).

% packet(EtherProtoId, X) :-
%   etherNet(EtherProtoRangeStart, EtherProtoRangeStop, X),
%   number_string(NumProtoId, EtherProtoId),
%   NumProtoId >= EtherProtoRangeStart,
%   NumProtoId =< EtherProtoRangeStop.

% packet(EtherProtoId, EtherVId, X) :-
%   etherNet(EtherProtoIds, EtherVIds, X),
%   member(EtherProtoId, EtherProtoIds),
%   member(EtherVId, EtherVIds).

% packet(ProtoId, X) :- etherProto(ProtoId, X).
% packet(VId, X) :- etherVlan(VId, X).
% packet(ProtoId, VId, X) :- etherProtoVlan(ProtoId, VId, X).

% packet(TCPsrcport, X) :- tcpSrc(TCPsrcport, X).
% packet(TCPdstport, X) :- tcpDst(TCPdstport, X).
% packet(TCPsrcport, TCPdstport, X) :- tcpSrcDst(TCPsrcport, TCPdstport, X).

% packet(UDPsrcport, X) :- udpSrc(UDPsrcport, X).
% packet(UDPdstport, X) :- udpDst(UDPdstport, X).
% packet(UDPsrcport, UDPdstport, X) :- udpSrcDst(UDPsrcport, UDPdstport, X).

% packet(ICMPtype, X) :- icmpType(ICMPtype, X).
% packet(ICMPcode, X) :- icmpCode(ICMPcode, X).
% packet(ICMPtype, ICMPcode, X) :- icmpTypeCode(ICMPtype, ICMPcode, X).

% packet(IPsrcAddr, X) :- ipSrc(IPsrcAddr, X).
% packet(IPdstAddr, X) :- ipDst(IPdstAddr, X).
% packet(IPAddr, X) :- ipAddr(IPAddr, X).
packet(ProtoId, X) :- ipProto(ProtoId, X).
packet(IPsrcAddr, IPdstAddr, X) :- ipSrcDst(IPsrcAddr, IPdstAddr, X).
packet(IPsrcAddr, IPdstAddr, ProtoId, X) :- ipSrcDstProto(IPsrcAddr, IPdstAddr, ProtoId, X).