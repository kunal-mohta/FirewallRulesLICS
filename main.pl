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

packet(TCPsrcport, X) :- tcpSrc(TCPsrcport, X).
packet(TCPdstport, X) :- tcpDst(TCPdstport, X).
packet(TCPsrcport, TCPdstport, X) :- tcpSrcDst(TCPsrcport, TCPdstport, X).

% packet(UDPsrcport, X) :- udpSrc(UDPsrcport, X).
% packet(UDPdstport, X) :- udpDst(UDPdstport, X).
% packet(UDPsrcport, UDPdstport, X) :- udpSrcDst(UDPsrcport, UDPdstport, X).