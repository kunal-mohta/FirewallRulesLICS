packet(AdapterId, EtherProtoId, EtherVId, X) :-
  adapter(AdapterIds, X),
  member(AdapterId, AdapterIds),
  etherProto(X).

packet(EtherProtoId, X) :-
  etherNet(EtherProtoId, X).

% packet(EtherProtoId, X) :-
  % etherNet(EtherProtoId, X).

packet(EtherProtoId, EtherVId, X) :-
  etherNet(EtherProtoId, EtherVId, X).