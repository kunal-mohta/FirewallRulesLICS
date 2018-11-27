% ----------------- ETHERNET CLAUSE ----------------- %

% ----------------- Rules ----------------- %
rule('accept ether proto 0x0801').
rule('reject ether proto 0x0800,0x0802').
rule('drop ether proto 22-26').
rule('accept ether vid 2').
rule('reject ether vid 2,3').
rule('reject ether vid 2-30').
rule('reject ether vid 2 proto 0x0800').
rule('drop ether vid 2,3 proto 0x0800').

% ----------------- Parsing Rules ----------------- %

% Proto - single
etherNet(ProtoIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "proto", ProtoId]),
  term_string(ResponseTerm, ResponseString),
  split_string(ProtoId, ',', '', ProtoIdList).

% Proto - comma separated
etherNet(ProtoIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "proto", ProtoIds]),
  term_string(ResponseTerm, ResponseString),
  string_chars(ProtoIds, ProtoIdChars),
  member(',', ProtoIdChars),
  split_string(ProtoIds, ',', '', ProtoIdList).

% Proto - range type
etherNet(RangeStart, RangeStop, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "proto", ProtoIdRange]),
  term_string(ResponseTerm, ResponseString),
  string_chars(ProtoIdRange, ProtoIdChars),
  member('-', ProtoIdChars),
  split_string(ProtoIdRange, '-', '', [Start, Stop]),
  number_string(RangeStart, Start),
  number_string(RangeStop, Stop).

% VLAN - single
etherNet(VIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "vid", VId]),
  term_string(ResponseTerm, ResponseString),
  split_string(VId, ',', '', VIdList).

% VLAN - comma separated
etherNet(VIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "vid", VIds]),
  term_string(ResponseTerm, ResponseString),
  string_chars(VIds, VIdChars),
  member(',', VIdChars),
  split_string(VIds, ',', '', VIdList).

% VLAN - range type
etherNet(RangeStart, RangeStop, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "vid", VIdRange]),
  term_string(ResponseTerm, ResponseString),
  string_chars(VIdRange, VIdChars),
  member('-', VIdChars),
  split_string(VIdRange, '-', '', [Start, Stop]),
  number_string(RangeStart, Start),
  number_string(RangeStop, Stop).

% Proto + VLAN - single
etherNet(ProtoIdList, VIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "vid", VId, "proto", ProtoId]),
  term_string(ResponseTerm, ResponseString),
  split_string(VId, ',', '', VIdList),
  split_string(ProtoId, ',', '', ProtoIdList).

% Proto + VLAN - comma separated
etherNet(ProtoIdList, VIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "vid", VId, "proto", ProtoId]),
  term_string(ResponseTerm, ResponseString),
  split_string(VId, ',', '', VIdList),
  split_string(ProtoId, ',', '', ProtoIdList).

% Proto + VLAN - range type
etherNet(ProtoIdList, VIdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "ether", "vid", VId, "proto", ProtoId]),
  term_string(ResponseTerm, ResponseString),
  split_string(VId, '-', '', VIdList),
  split_string(ProtoId, '-', '', ProtoIdList).