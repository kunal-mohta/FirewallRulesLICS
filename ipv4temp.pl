rule('accept ip src addr 192.167.10.1').
rule('reject ip dst addr 192.167.10.33').
rule('drop ip addr 192.167.10.123').
rule('accept ip proto 123').
rule('accept ip src addr 192.167.10.1 dst addr 192.167.10.33').
rule('accept ip src addr 192.167.10.1 dst addr 192.167.10.33 proto 123').

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

%%%%%%%%%%%%%%%%%%%%%%%%

ipSrc(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", PortPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(PortPart, Port).

ipDst(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "dst", "addr", PortPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(PortPart, Port).

ipAddr(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "addr", PortPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(PortPart, Port).

ipProto(Port, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "proto", PortPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(PortPart, Port).

ipSrcDst(SrcPort, DstPort, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcPortPart, "dst", "addr", DstPortPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcPortPart, SrcPort),
  ipHandle(DstPortPart, DstPort).

ipSrcDstProto(SrcPort, DstPort, ProtoId, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, " ", "", [ResponseString, "ip", "src", "addr", SrcPortPart, "dst", "addr", DstPortPart, "proto", ProtoIdPart]),
  term_string(ResponseTerm, ResponseString),
  ipHandle(SrcPortPart, SrcPort),
  ipHandle(DstPortPart, DstPort),
  ipHandle(ProtoIdPart, ProtoId).

ipHandle(PortPart, Port) :-
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

ipHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  convertListToDecimal(PortList, [], ConvertedPortList),
  convertToDecimal(Port, ConvertedPort),
  member(ConvertedPort, ConvertedPortList).

ipHandle(PortPart, ConvertedPortPart) :-
  convertToDecimal(PortPart, ConvertedPortPart).
