:- include('main.pl').
:- include('encodedRules.pl').

% ----------------- Utilities ----------------- %

% last member of list
last(X,[X]).
last(X,[_|Z]) :- last(X,Z).

% for the range types - e.g. B-D
getSubList([], _, F, F, _).
getSubList([H|Main], [H|Ends], Fin, Acc, 0) :-
  getSubList(Main, [H|Ends], Fin, [H|Acc], 1), !.

getSubList([T|Main], Ends, Fin, Acc, 1) :-
  last(T, Ends),
  getSubList(Main, Ends, Fin, [T|Acc], 0), !.

getSubList([X|Main], Ends, Fin, Acc, 1) :-
  getSubList(Main, Ends, Fin, [X|Acc], 1), !.

getSubList([_|Main], Ends, Fin, Acc, 0) :-
  getSubList(Main, Ends, Fin, Acc, 0), !.

% converting from any base to decimal when digit array is given in reverse order
con([], Final, _, _, Final).
con([CurrNumAtom|RevNumList], Decimal, Base, Count, Final):-
  atom_string(CurrNumAtom, CurrNumString),
  number_string(CurrNum, CurrNumString),
  con(RevNumList, Decimal + (CurrNum*(Base^Count)), Base, Count+1, Final).


% octal to decimal
octalToDecimal(Octal, Final) :-
  string_chars(Octal, OctalChars),
  reverse(OctalChars, RevOctalChars),
  con(RevOctalChars, 0, 8, 0, Decimal),
  Computed is Decimal,
  number_string(Computed, Final).

% hex to decimal
hexToDecimal(Hex, Final) :-
  string_chars(Hex, HexChars),
  hexLetterToDecimal(HexChars, [], RevHexChars),
  con(RevHexChars, 0, 16, 0, Decimal),
  Computed is Decimal,
  number_string(Computed, Final).

% handling letters - for hexToDecimal
hexLetterToDecimal([], Final, Final).

hexLetterToDecimal([Letter|HexList], DecimalList, Final) :-
  string_codes(Letter, LetterCode),
  LetterCode >= 65,
  LetterCode =< 70,
  NumHexCode is LetterCode - 55,
  number_string(NumHexCode, HexCode),
  hexLetterToDecimal(HexList, [HexCode|DecimalList], Final).

hexLetterToDecimal([Letter|HexList], DecimalList, Final) :-
  string_codes(Letter, LetterCode),
  LetterCode >= 48,
  LetterCode =< 57,
  NumHexCode is LetterCode - 48,
  number_string(NumHexCode, HexCode),
  hexLetterToDecimal(HexList, [HexCode|DecimalList], Final).

% convert according to the string entered
convertToDecimal(Input, Output) :-
  string_chars(Input, ['0'|Chars]),
  string_chars(StrWithoutPre, Chars),
  octalToDecimal(StrWithoutPre, Output),
  !.

convertToDecimal(Input, Output) :-
  string_chars(Input, ['0', 'x'|Chars]),
  string_chars(StrWithoutPre, Chars),
  hexToDecimal(StrWithoutPre, Output),
  !.

convertToDecimal(Input, Input).

% convertToDecimal for a list
convertListToDecimal([], OutputList, OutputList).
convertListToDecimal([Input|InputList], AccList, OutputList) :-
  convertListToDecimal(InputList, [ConvertedInput|AccList], OutputList),
  convertToDecimal(Input, ConvertedInput).

% ip to decimal
convertIpToDecimal(Input, Output) :-
  split_string(Input, ".", "", SepInputList),
  convertListToDecimal(SepInputList, [], SepOutputList),
  reverse(SepOutputList, RevSepOutputList),
  atomics_to_string(RevSepOutputList, ".", Output).

% ip to decimal - list
convertIpListToDecimal([], OutputList, OutputList).
convertIpListToDecimal([Input|InputList], AccList, OutputList) :-
  convertIpListToDecimal(InputList, [ConvertedInput|AccList], OutputList),
  convertIpToDecimal(Input, ConvertedInput).

% ip in range
ipInRange(IP, Start, Stop) :-
  split_string(IP, ".", "", SepIP),
  atomics_to_string(SepIP, "", StringIP),
  split_string(Start, ".", "", SepStart),
  atomics_to_string(SepStart, "", StringStart),
  split_string(Stop, ".", "", SepStop),
  atomics_to_string(SepStop, "", StringStop),
  number_string(NumIP, StringIP),
  number_string(NumStart, StringStart),
  number_string(NumStop, StringStop),
  NumIP >= NumStart,
  NumIP =< NumStop.

% ----------------- ADAPTER CLAUSE ----------------- %
mainStr(["A", "B", "C", "D", "E", "F", "G", "H"]).

% ----------------- Parsing Rules ----------------- %

% normal
adapter(IdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  split_string(Ids, ',', '', IdList).

% comma separated
adapter(IdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member(',', IdChars),
  split_string(Ids, ',', '', IdList).

% range type
adapter(IdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member('-', IdChars),
  split_string(Ids, '-', '', IdEnds),
  mainStr(MainStr),
  getSubList(MainStr, IdEnds, IdList, [], 0).


% ----------------- ETHERNET CLAUSE ----------------- %
aliasList(["arp", "aarp", "atalk", "ipx", "mlps", "netbui", "pppoe", "rarp", "sna", "xns"]).

% ----------------- Parsing Rules ----------------- %

etherProto(ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoIdPart, ProtoId, 1).

etherVlan(VId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "vid", VIdPart]),
  term_string(ResponseTerm, ResponseString),
  etherHandle(VIdPart, VId, 0).

etherProtoVlan(ProtoId, VId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "vid", VIdPart, "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoIdPart, ProtoId, 1),
  etherHandle(VIdPart, VId, 0).

etherHandle(ParamPart, Param, _) :-
  string_chars(ParamPart, ParamChars),
  member('-', ParamChars),
  split_string(ParamPart, '-', '', [Start, Stop]),
  convertToDecimal(Start, DecimalStart),
  convertToDecimal(Stop, DecimalStop),
  number_string(RangeStart, DecimalStart),
  number_string(RangeStop, DecimalStop),
  convertToDecimal(Param, ConvertedParam),
  number_string(ConvertedParamNumber, ConvertedParam),
  ConvertedParamNumber >= RangeStart,
  ConvertedParamNumber =< RangeStop.

etherHandle(ParamPart, Param, _) :-
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertListToDecimal(ParamList, [], ConvertedParamList),
  convertToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

etherHandle(ParamPart, ConvertedParamPart, _) :-
  convertToDecimal(ParamPart, ConvertedParamPart).

etherHandle(ProtoAlias, _, 1) :-
  aliasList(AliasList),
  member(ProtoAlias, AliasList).

% ----------------- TCP & UDP CONDITIONS ----------------- %

% ----------------- Parsing Rules ----------------- %

tcpSrc(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "src", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(PortPart, Port).

tcpDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "dst", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(PortPart, Port).

tcpSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "dst", "port", DstPortPart, "src", "port", SrcPortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(SrcPortPart, SrcPort),
  tcpHandle(DstPortPart, DstPort).

tcpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member('-', PortChars),
  split_string(PortPart, '-', '', [Start, Stop]),
  convertToDecimal(Start, DecimalStart),
  convertToDecimal(Stop, DecimalStop),
  number_string(RangeStart, DecimalStart),
  number_string(RangeStop, DecimalStop),
  convertToDecimal(Port, ConvertedPort),
  number_string(ConvertedPortNumber, ConvertedPort),
  ConvertedPortNumber >= RangeStart,
  ConvertedPortNumber =< RangeStop.

tcpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

tcpHandle(PortPart, ConvertedPortPart) :-
  convertToDecimal(PortPart, ConvertedPortPart).


udpSrc(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "src", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(PortPart, Port).

udpDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "dst", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(PortPart, Port).

udpSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "dst", "port", DstPortPart, "src", "port", SrcPortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(SrcPortPart, SrcPort),
  udpHandle(DstPortPart, DstPort).

udpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member('-', PortChars),
  split_string(PortPart, '-', '', [Start, Stop]),
  convertToDecimal(Start, DecimalStart),
  convertToDecimal(Stop, DecimalStop),
  number_string(RangeStart, DecimalStart),
  number_string(RangeStop, DecimalStop),
  convertToDecimal(Port, ConvertedPort),
  number_string(ConvertedPortNumber, ConvertedPort),
  ConvertedPortNumber >= RangeStart,
  ConvertedPortNumber =< RangeStop.

udpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

udpHandle(PortPart, ConvertedPortPart) :-
  convertToDecimal(PortPart, ConvertedPortPart).


% ----------------- ICMP CLAUSE ----------------- %

% ----------------- Parsing Rules ----------------- %

icmpType(Type, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "type", TypePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(TypePart, Type).

icmpCode(Code, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "code", CodePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(CodePart, Code).

icmpTypeCode(Type, Code, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "type", TypePart, "code", CodePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(TypePart, Type),
  icmpHandle(CodePart, Code).

icmpHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member('-', ParamChars),
  split_string(ParamPart, '-', '', [Start, Stop]),
  convertToDecimal(Start, DecimalStart),
  convertToDecimal(Stop, DecimalStop),
  number_string(RangeStart, DecimalStart),
  number_string(RangeStop, DecimalStop),
  convertToDecimal(Param, ConvertedParam),
  number_string(ConvertedParamNumber, ConvertedParam),
  ConvertedParamNumber >= RangeStart,
  ConvertedParamNumber =< RangeStop.

icmpHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertListToDecimal(ParamList, [], ConvertedParamList),
  convertToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

icmpHandle(ParamPart, ConvertedParamPart) :-
  convertToDecimal(ParamPart, ConvertedParamPart).

% ----------------- IPv4 CLAUSE ----------------- %

% ----------------- Parsing Rules ----------------- %
ipSrc(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", AddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

ipDst(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "dst", "addr", AddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

ipAddr(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "addr", AddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

ipProto(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "proto", AddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

ipSrcDst(SrcAddr, DstAddr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcAddrPart, "dst", "addr", DstAddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcAddrPart, SrcAddr),
  ipHandle(DstAddrPart, DstAddr).

ipSrcDstProto(SrcAddr, DstAddr, ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcAddrPart, "dst", "addr", DstAddrPart, "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcAddrPart, SrcAddr),
  ipHandle(DstAddrPart, DstAddr),
  ipHandle(ProtoIdPart, ProtoId).

ipHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member('-', ParamChars),
  split_string(ParamPart, '-', '', [Start, Stop]),
  convertIpToDecimal(Start, DecimalStart),
  convertIpToDecimal(Stop, DecimalStop),
  convertIpToDecimal(Param, ConvertedParam),
  ipInRange(ConvertedParam, DecimalStart, DecimalStop).

ipHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertIpListToDecimal(ParamList, [], ConvertedParamList),
  convertIpToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

ipHandle(ParamPart, Param) :-
  convertIpToDecimal(ParamPart, X),
  convertIpToDecimal(Param, X).