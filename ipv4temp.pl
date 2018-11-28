% rule('accept ip src addr 192.167.10.1').
rule('accept ip src addr 192.167.10.1-192.167.10.3').
% rule('reject ip dst addr 192.167.10.33').
% rule('drop ip addr 192.167.10.123').
% rule('accept ip proto 123').
% rule('accept ip src addr 192.167.10.1 dst addr 192.167.10.33').
% rule('accept ip src addr 192.167.10.1 dst addr 192.167.10.33 proto 123').

%%%%%%%%%%%%%%%%%%%%%%%%

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

convertIpToDecimal(Input, Output) :-
  split_string(Input, ".", "", SepInputList),
  convertListToDecimal(SepInputList, [], SepOutputList),
  reverse(SepOutputList, RevSepOutputList),
  atomics_to_string(RevSepOutputList, ".", Output).

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

%%%%%%%%%%%%%%%%%%%%%%%%

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
  ipInRange(ConvertedParam, Start, Stop).

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
