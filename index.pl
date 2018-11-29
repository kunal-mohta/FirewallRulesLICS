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

% check value in range
checkValInRange(Value, Start, Stop) :-
  convertToDecimal(Value, ConvertedValue),
  convertToDecimal(Start, ConvertedStart),
  convertToDecimal(Stop, ConvertedStop),
  number_string(NumValue, ConvertedValue),
  number_string(NumStart, ConvertedStart),
  number_string(NumStop, ConvertedStop),
  NumValue >= NumStart,
  NumValue =< NumStop.

% check list in range
checkListInRange([], _, _).
checkListInRange([Input|InputList], Start, Stop) :-
  checkListInRange(InputList, Start, Stop),
  checkValInRange(Input, Start, Stop).

% check range values of rules
checkParamRange(ProtoParam, RangeStart, RangeStop) :-
  string_chars(ProtoParam, ParamChars),
  member('-', ParamChars),
  split_string(ProtoParam, '-', '', [ParamStart, ParamStop]),
  checkValInRange(ParamStart, RangeStart, RangeStop),
  checkValInRange(ParamStop, RangeStart, RangeStop),
  !.

checkParamRange(ProtoParam, RangeStart, RangeStop) :-
  string_chars(ProtoParam, ParamChars),
  member(',', ParamChars),
  split_string(ProtoParam, ',', '', ParamList),
  checkListInRange(ParamList, RangeStart, RangeStop),
  !.

checkParamRange(ProtoParam, RangeStart, RangeStop) :-
  checkValInRange(ProtoParam, RangeStart, RangeStop).

% ----------------- ADAPTER CLAUSE ----------------- %
mainStr(["A", "B", "C", "D", "E", "F", "G", "H"]).

% ----------------- Parsing Rules ----------------- %

adapter(Id, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  adapterHandle(Ids, Id).

% wrong rule / wrong package / no rule matched
adapter(_, _).

% normal
adapterHandle(ParamPart, Param) :-
  split_string(ParamPart, ',', '', ParamPartList),
  member(Param, ParamPartList).

% comma separated
adapterHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  member(Param, ParamList).

% range type
adapterHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member('-', ParamChars),
  split_string(ParamPart, '-', '', ParamEnds),
  mainStr(MainStr),
  getSubList(MainStr, ParamEnds, ParamList, [], 0),
  member(Param, ParamList).

% any
adapterHandle("any", _).

% ----------------- ETHERNET CLAUSE ----------------- %
aliasList(["arp", "aarp", "atalk", "ipx", "mlps", "netbui", "pppoe", "rarp", "sna", "xns"]).

% ----------------- Parsing Rules ----------------- %

checkRangeEtherProto(Param) :-
  checkParamRange(Param, "0", "65535").

checkRangeEtherVlan(Param) :-
  checkParamRange(Param, "0", "4095").

% % % %

etherProto(ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "proto", ProtoIdPart]),
  checkRangeEtherProto(ProtoIdPart),
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoIdPart, ProtoId, 0).

etherProto(ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoId, ProtoIdPart, 1).

% wrong rule / wrong package / no rule matched
etherProto(_, _).

etherVlan(VId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "vid", VIdPart]),
  checkRangeEtherVlan(VIdPart),
  term_string(ResponseTerm, ResponseString),
  etherHandle(VIdPart, VId, 0).

% wrong rule / wrong package / no rule matched
etherVlan(_, _).

etherProtoVlan(ProtoId, VId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "vid", VIdPart, "proto", ProtoIdPart]),
  checkRangeEtherProto(ProtoIdPart),
  checkRangeEtherVlan(VIdPart),
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoIdPart, ProtoId, 1),
  etherHandle(VIdPart, VId, 0).

% wrong rule / wrong package / no rule matched
etherProtoVlan(_, _, _).

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

% any
etherHandle(_, "any", _).

etherHandle(ProtoAlias, _, 1) :-
  aliasList(AliasList),
  member(ProtoAlias, AliasList).

% ----------------- TCP & UDP CONDITIONS ----------------- %

% ----------------- Parsing Rules ----------------- %
checkRangeTcpUdpPort(Param) :-
  checkParamRange(Param, "0", "65535").

% % % %

tcpSrc(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "src", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
tcpSrc(_, _).

tcpDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "dst", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
tcpDst(_, _).

tcpSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "dst", "port", DstPortPart, "src", "port", SrcPortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(SrcPortPart, SrcPort),
  tcpHandle(DstPortPart, DstPort).

% wrong rule / wrong package / no rule matched
tcpSrcDst(_, _, _).

tcpHandle(PortPart, Port) :-
  checkRangeTcpUdpPort(PortPart),
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
  checkRangeTcpUdpPort(PortPart),
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

tcpHandle(PortPart, ConvertedPortPart) :-
  checkRangeTcpUdpPort(PortPart),
  convertToDecimal(PortPart, ConvertedPortPart).

% any
tcpHandle("any", _).

udpSrc(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "src", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
udpSrc(_, _).

udpDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "dst", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
udpDst(_, _).

udpSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "dst", "port", DstPortPart, "src", "port", SrcPortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(SrcPortPart, SrcPort),
  udpHandle(DstPortPart, DstPort).

% wrong rule / wrong package / no rule matched
udpSrcDst(_, _, _).

udpHandle(PortPart, Port) :-
  checkRangeTcpUdpPort(PortPart),
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
  checkRangeTcpUdpPort(PortPart),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

udpHandle(PortPart, ConvertedPortPart) :-
  checkRangeTcpUdpPort(PortPart),
  convertToDecimal(PortPart, ConvertedPortPart).

% any
udpHandle("any", _).

% ----------------- ICMP CLAUSE ----------------- %

% ----------------- Parsing Rules ----------------- %

checkRangeTypeCode(Param) :-
  checkParamRange(Param, "0", "255").

% % % %

icmpType(Type, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "type", TypePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(TypePart, Type).

% wrong rule / wrong package / no rule matched
icmpType(_, _).

icmpCode(Code, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "code", CodePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(CodePart, Code).

% wrong rule / wrong package / no rule matched
icmpCode(_, _).

icmpTypeCode(Type, Code, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "type", TypePart, "code", CodePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(TypePart, Type),
  icmpHandle(CodePart, Code).

% wrong rule / wrong package / no rule matched
icmpTypeCode(_, _, _).

icmpHandle(ParamPart, Param) :-
  checkRangeTypeCode(ParamPart),
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
  checkRangeTypeCode(ParamPart),
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertListToDecimal(ParamList, [], ConvertedParamList),
  convertToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

icmpHandle(ParamPart, ConvertedParamPart) :-
  checkRangeTypeCode(ParamPart),
  convertToDecimal(ParamPart, ConvertedParamPart).

% any
icmpHandle("any", _).

% ----------------- IPv4 CLAUSE ----------------- %

% ----------------- Parsing Rules ----------------- %
checkRangeIPProtoId(Param) :-
  checkParamRange(Param, "0", "255").

checkRangeIPAddr(Param) :-
  split_string(Param, ",.-", "", SepIpParamList),
  checkListInRange(SepIpParamList, "0", "255").

% % % %

ipSrc(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", AddrPart]),
  checkRangeIPAddr(AddrPart),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

% wrong rule / wrong package / no rule matched
ipSrc(_, _).

ipDst(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "dst", "addr", AddrPart]),
  checkRangeIPAddr(AddrPart),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

% wrong rule / wrong package / no rule matched
ipDst(_, _).

ipAddr(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "addr", AddrPart]),
  checkRangeIPAddr(AddrPart),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr).

% wrong rule / wrong package / no rule matched
ipAddr(_, _).

ipProto(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "proto", ProtoId]),
  checkRangeIPProtoId(ProtoId),
  term_string(ResponseTerm, ResponseString),
  ipHandle(ProtoId, Addr).

% wrong rule / wrong package / no rule matched
ipProto(_, _).

ipSrcDst(SrcAddr, DstAddr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcAddrPart, "dst", "addr", DstAddrPart]),
  checkRangeIPAddr(SrcAddrPart),
  checkRangeIPAddr(DstAddrPart),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcAddrPart, SrcAddr),
  ipHandle(DstAddrPart, DstAddr).

% wrong rule / wrong package / no rule matched
ipSrcDst(_, _, _).

ipSrcDstProto(SrcAddr, DstAddr, ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcAddrPart, "dst", "addr", DstAddrPart, "proto", ProtoIdPart]),
  checkRangeIPAddr(SrcAddrPart),
  checkRangeIPAddr(DstAddrPart),
  checkRangeIPProtoId(ProtoIdPart),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcAddrPart, SrcAddr),
  ipHandle(DstAddrPart, DstAddr),
  ipHandle(ProtoIdPart, ProtoId).

% wrong rule / wrong package / no rule matched
ipSrcDstProto(_, _, _, _).

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

% any
ipHandle("any", _).