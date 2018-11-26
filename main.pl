packet(AdapterId, EtherProtoId, EtherVId, X) :-
  adapter(AdapterIds, X),
  member(AdapterId, AdapterIds),
  etherProto(X).

packet(EtherProtoId, X) :-
  etherNet(EtherProtoIds, X),
  member(EtherProtoId, EtherProtoIds).

% packet(EtherProtoId, X) :-
  % etherNet(EtherProtoId, X).

packet(EtherProtoId, EtherVId, X) :-
  etherNet(EtherProtoIds, EtherVIds, X),
  member(EtherProtoId, EtherProtoIds),
  member(EtherVId, EtherVIds).