:- include('main.pl').
:- include('rulesDatabase.pl').

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

% check for all values in a list, in a list
checkListInList([], _).
checkListInList([Val|ListOfVal], List) :-
  checkListInList(ListOfVal, List),
  member(Val, List).

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
checkParamRange(Param, RangeStart, RangeStop) :-
  string_chars(Param, ParamChars),
  member('-', ParamChars),
  split_string(Param, '-', '', [ParamStart, ParamStop]),
  checkValInRange(ParamStart, RangeStart, RangeStop),
  checkValInRange(ParamStop, RangeStart, RangeStop),
  !.

checkParamRange(Param, RangeStart, RangeStop) :-
  string_chars(Param, ParamChars),
  member(',', ParamChars),
  split_string(Param, ',', '', ParamList),
  checkListInRange(ParamList, RangeStart, RangeStop),
  !.

checkParamRange(Param, RangeStart, RangeStop) :-
  checkValInRange(Param, RangeStart, RangeStop).

% ----------------- ADAPTER CLAUSE ----------------- %
mainStr(["A", "B", "C", "D", "E", "F", "G", "H"]).

% ----------------- Parsing Rules ----------------- %

checkRangeAdapter(Param) :-
  string_chars(Param, ParamChars),
  member('-', ParamChars),
  split_string(Param, '-', '', [ParamStart, ParamStop]),
  mainStr(MainStr),
  member(ParamStart, MainStr),
  member(ParamStop, MainStr),
  !.

checkRangeAdapter(Param) :-
  string_chars(Param, ParamChars),
  member(',', ParamChars),
  split_string(Param, ',', '', ParamList),
  mainStr(MainStr),
  checkListInList(ParamList, MainStr),
  !.

checkRangeAdapter(Param) :-
  mainStr(MainStr),
  member(Param, MainStr).

adapter(Id, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  adapterHandle(Ids, Id),
  !.

% wrong rule / wrong package / no rule matched
adapter(_, accept).

% not expression
adapterHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member('!', ParamChars),
  member('(', ParamChars),
  member(')', ParamChars),
  split_string(ParamPart, "!()", "", [_, _, MainParamPart, _]),
  checkRangeAdapter(MainParamPart),
  checkRangeAdapter(Param),
  not(adapterHandle(MainParamPart, Param)).

% normal
adapterHandle(ParamPart, Param) :-
  checkRangeAdapter(ParamPart),
  checkRangeAdapter(Param),
  split_string(ParamPart, ',', '', ParamPartList),
  member(Param, ParamPartList).

% comma separated
adapterHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  checkRangeAdapter(ParamPart),
  checkRangeAdapter(Param),
  split_string(ParamPart, ',', '', ParamList),
  member(Param, ParamList).

% range type
adapterHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member('-', ParamChars),
  split_string(ParamPart, '-', '', ParamEnds),
  checkRangeAdapter(ParamPart),
  checkRangeAdapter(Param),
  mainStr(MainStr),
  getSubList(MainStr, ParamEnds, ParamList, [], 0),
  member(Param, ParamList).

% any
adapterHandle("any", Param) :-
  not(Param = "").

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
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoIdPart, ProtoId, 0),
  !.

% wrong rule / wrong package / no rule matched
etherProto(_, accept).

etherVlan(VId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "vid", VIdPart]),
  term_string(ResponseTerm, ResponseString),
  etherHandle(VIdPart, VId, 1),
  !.

% wrong rule / wrong package / no rule matched
etherVlan(_, accept).

etherProtoVlan(ProtoId, VId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ether", "vid", VIdPart, "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  etherHandle(ProtoIdPart, ProtoId, 0),
  etherHandle(VIdPart, VId, 1),
  !.

% wrong rule / wrong package / no rule matched
etherProtoVlan(_, _, accept).

rangeCheckEtherHandle(RangeCheckIndex, ParamPart, Param) :-
  RangeCheckIndex = 0,
  checkRangeEtherProto(ParamPart),
  checkRangeEtherProto(Param).

rangeCheckEtherHandle(RangeCheckIndex, ParamPart, Param) :-
  RangeCheckIndex = 1,
  checkRangeEtherVlan(ParamPart),
  checkRangeEtherVlan(Param).

% not expression
etherHandle(ParamPart, Param, RangeCheckIndex) :-
  string_chars(ParamPart, ParamChars),
  member('!', ParamChars),
  member('(', ParamChars),
  member(')', ParamChars),
  split_string(ParamPart, "!()", "", [_, _, MainParamPart, _]),
  rangeCheckEtherHandle(RangeCheckIndex, MainParamPart, Param),
  not(etherHandle(MainParamPart, Param, RangeCheckIndex)).

% range
etherHandle(ParamPart, Param, RangeCheckIndex) :-
  rangeCheckEtherHandle(RangeCheckIndex, ParamPart, Param),
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

% comma-separated
etherHandle(ParamPart, Param, RangeCheckIndex) :-
  rangeCheckEtherHandle(RangeCheckIndex, ParamPart, Param),
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertListToDecimal(ParamList, [], ConvertedParamList),
  convertToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

% normal
etherHandle(ParamPart, Param, RangeCheckIndex) :-
  rangeCheckEtherHandle(RangeCheckIndex, ParamPart, Param),
  convertToDecimal(ParamPart, X),
  convertToDecimal(Param, X).

% any
etherHandle("any", Param, _) :-
  not(Param = "").

% aliases
etherHandle(_, ProtoAlias, _) :-
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
tcpSrc(_, accept).

tcpDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "dst", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
tcpDst(_, accept).

tcpSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "tcp", "dst", "port", DstPortPart, "src", "port", SrcPortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(SrcPortPart, SrcPort),
  tcpHandle(DstPortPart, DstPort).

% wrong rule / wrong package / no rule matched
tcpSrcDst(_, _, accept).

% not expression
tcpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member('!', PortChars),
  member('(', PortChars),
  member(')', PortChars),
  split_string(PortPart, "!()", "", [_, _, MainPortPart, _]),
  checkRangeTcpUdpPort(MainPortPart),
  checkRangeTcpUdpPort(Port),
  not(tcpHandle(MainPortPart, Port)).

% range
tcpHandle(PortPart, Port) :-
  checkRangeTcpUdpPort(PortPart),
  checkRangeTcpUdpPort(Port),
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

% comma-separated
tcpHandle(PortPart, Port) :-
  checkRangeTcpUdpPort(PortPart),
  checkRangeTcpUdpPort(Port),
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

% normal
tcpHandle(PortPart, ConvertedPortPart) :-
  checkRangeTcpUdpPort(PortPart),
  checkRangeTcpUdpPort(ConvertedPortPart),
  convertToDecimal(PortPart, ConvertedPortPart).

% any
tcpHandle("any", Param) :-
  not(Param = "").

udpSrc(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "src", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
udpSrc(_, accept).

udpDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "dst", "port", PortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(PortPart, Port).

% wrong rule / wrong package / no rule matched
udpDst(_, accept).

udpSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "udp", "dst", "port", DstPortPart, "src", "port", SrcPortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(SrcPortPart, SrcPort),
  udpHandle(DstPortPart, DstPort).

% wrong rule / wrong package / no rule matched
udpSrcDst(_, _, accept).

% not expression
udpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member('!', PortChars),
  member('(', PortChars),
  member(')', PortChars),
  split_string(PortPart, "!()", "", [_, _, MainPortPart, _]),
  checkRangeTcpUdpPort(MainPortPart),
  checkRangeTcpUdpPort(Port),
  not(udpHandle(MainPortPart, Port)).

% range
udpHandle(PortPart, Port) :-
  checkRangeTcpUdpPort(PortPart),
  checkRangeTcpUdpPort(Port),
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

% comma-separated
udpHandle(PortPart, Port) :-
  checkRangeTcpUdpPort(PortPart),
  checkRangeTcpUdpPort(Port),
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

% normal
udpHandle(PortPart, ConvertedPortPart) :-
  checkRangeTcpUdpPort(PortPart),
  checkRangeTcpUdpPort(ConvertedPortPart),
  convertToDecimal(PortPart, ConvertedPortPart).

% any
udpHandle("any", Param) :-
  not(Param = "").

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
icmpType(_, accept).

icmpCode(Code, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "code", CodePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(CodePart, Code).

% wrong rule / wrong package / no rule matched
icmpCode(_, accept).

icmpTypeCode(Type, Code, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "icmp", "type", TypePart, "code", CodePart]),
  term_string(ResponseTerm, ResponseString),
  icmpHandle(TypePart, Type),
  icmpHandle(CodePart, Code).

% wrong rule / wrong package / no rule matched
icmpTypeCode(_, _, accept).

% not expression
icmpHandle(ParamPart, Param) :-
  string_chars(ParamPart, ParamChars),
  member('!', ParamChars),
  member('(', ParamChars),
  member(')', ParamChars),
  split_string(ParamPart, "!()", "", [_, _, MainParamPart, _]),
  checkRangeTypeCode(MainParamPart),
  checkRangeTypeCode(Param),
  not(icmpHandle(MainParamPart, Param)).

% range
icmpHandle(ParamPart, Param) :-
  checkRangeTypeCode(ParamPart),
  checkRangeTypeCode(Param),
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

% comma-separated
icmpHandle(ParamPart, Param) :-
  checkRangeTypeCode(ParamPart),
  checkRangeTypeCode(Param),
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertListToDecimal(ParamList, [], ConvertedParamList),
  convertToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

% normal
icmpHandle(ParamPart, ConvertedParamPart) :-
  checkRangeTypeCode(ParamPart),
  checkRangeTypeCode(ConvertedParamPart),
  convertToDecimal(ParamPart, ConvertedParamPart).

% any
icmpHandle("any", Param) :-
  not(Param = "").

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
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr, 0).

% wrong rule / wrong package / no rule matched
ipSrc(_, accept).

ipDst(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "dst", "addr", AddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr, 0).

% wrong rule / wrong package / no rule matched
ipDst(_, accept).

ipAddr(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "addr", AddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(AddrPart, Addr, 0).

% wrong rule / wrong package / no rule matched
ipAddr(_, accept).

ipProto(Addr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "proto", ProtoId]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(ProtoId, Addr, 1).

% wrong rule / wrong package / no rule matched
ipProto(_, accept).

ipSrcDst(SrcAddr, DstAddr, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcAddrPart, "dst", "addr", DstAddrPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcAddrPart, SrcAddr, 0),
  ipHandle(DstAddrPart, DstAddr, 0).

% wrong rule / wrong package / no rule matched
ipSrcDst(_, _, accept).

ipSrcDstProto(SrcAddr, DstAddr, ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcAddrPart, "dst", "addr", DstAddrPart, "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcAddrPart, SrcAddr, 0),
  ipHandle(DstAddrPart, DstAddr, 0),
  ipHandle(ProtoIdPart, ProtoId, 1).

% wrong rule / wrong package / no rule matched
ipSrcDstProto(_, _, _, accept).

% range checking predicate
rangeCheckIpHandle(RangeCheckIndex, ParamPart, Param) :-
  RangeCheckIndex = 0,
  checkRangeIPAddr(ParamPart),
  checkRangeIPAddr(Param).

rangeCheckIpHandle(RangeCheckIndex, ParamPart, Param) :-
  RangeCheckIndex = 1,
  checkRangeIPProtoId(ParamPart),
  checkRangeIPProtoId(Param).

% not expression
ipHandle(ParamPart, Param, RangeCheckIndex) :-
  string_chars(ParamPart, ParamChars),
  member('!', ParamChars),
  member('(', ParamChars),
  member(')', ParamChars),
  split_string(ParamPart, "!()", "", [_, _, MainParamPart, _]),
  rangeCheckIpHandle(RangeCheckIndex, MainParamPart, Param),
  not(ipHandle(MainParamPart, Param, RangeCheckIndex)).

% range
ipHandle(ParamPart, Param, RangeCheckIndex) :-
  rangeCheckIpHandle(RangeCheckIndex, ParamPart, Param),
  string_chars(ParamPart, ParamChars),
  member('-', ParamChars),
  split_string(ParamPart, '-', '', [Start, Stop]),
  convertIpToDecimal(Start, DecimalStart),
  convertIpToDecimal(Stop, DecimalStop),
  convertIpToDecimal(Param, ConvertedParam),
  ipInRange(ConvertedParam, DecimalStart, DecimalStop).

% comma-separated
ipHandle(ParamPart, Param, RangeCheckIndex) :-
  rangeCheckIpHandle(RangeCheckIndex, ParamPart, Param),
  string_chars(ParamPart, ParamChars),
  member(',', ParamChars),
  split_string(ParamPart, ',', '', ParamList),
  convertIpListToDecimal(ParamList, [], ConvertedParamList),
  convertIpToDecimal(Param, ConvertedParam),
  member(ConvertedParam, ConvertedParamList).

% normal
ipHandle(ParamPart, Param, RangeCheckIndex) :-
  rangeCheckIpHandle(RangeCheckIndex, ParamPart, Param),
  convertIpToDecimal(ParamPart, X),
  convertIpToDecimal(Param, X).

% any
ipHandle("any", Param, _) :-
  not(Param = "").


% ----------------- END ----------------- %
