% rule('drop tcp src port 100').
% rule('accept tcp src port 123-321').
% rule('reject tcp src port 101,103').
% rule('drop tcp dst port 100').
% rule('accept tcp dst port 123-321').
% rule('reject tcp dst port 101,103').
% rule('drop tcp src port 600 dst port 100').
% rule('accept tcp src port 222 dst port 123-321').
% rule('reject tcp src port 1-10 dst port 101,103').

rule('drop udp src port 100').
rule('accept udp src port 123-321').
rule('reject udp src port 101,103').
rule('drop udp dst port 100').
rule('accept udp dst port 123-321').
rule('reject udp dst port 101,103').
rule('drop udp src port 600 dst port 100').
rule('accept udp src port 222 dst port 123-321').
rule('reject udp src port 1-10 dst port 101,103').

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
  Final is Decimal.

% hex to decimal
hexToDecimal(Hex, Final) :-
  string_chars(Hex, HexChars),
  hexLetterToDecimal(HexChars, [], RevHexChars),
  con(RevHexChars, 0, 16, 0, Decimal),
  Final is Decimal.

% handling letters
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

%%%%%%%%%%%%%%%%%%%%%%%%

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
  split_string(Rule, " ", "", [ResponseString, "tcp", "src", "port", SrcPortPart, "dst", "port", DstPortPart]),
  term_string(ResponseTerm, ResponseString),
  tcpHandle(SrcPortPart, SrcPort),
  tcpHandle(DstPortPart, DstPort).

tcpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member('-', PortChars),
  split_string(PortPart, '-', '', [Start, Stop]),
  number_string(RangeStart, Start),
  number_string(RangeStop, Stop),
  number_string(PortNumber, Port),
  PortNumber >= RangeStart,
  PortNumber =< RangeStop.

tcpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  member(Port, PortList).

tcpHandle(PortPart, PortPart).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  split_string(Rule, " ", "", [ResponseString, "udp", "src", "port", SrcPortPart, "dst", "port", DstPortPart]),
  term_string(ResponseTerm, ResponseString),
  udpHandle(SrcPortPart, SrcPort),
  udpHandle(DstPortPart, DstPort).

udpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member('-', PortChars),
  split_string(PortPart, '-', '', [Start, Stop]),
  number_string(RangeStart, Start),
  number_string(RangeStop, Stop),
  number_string(PortNumber, Port),
  PortNumber >= RangeStart,
  PortNumber =< RangeStop.

udpHandle(PortPart, Port) :-
  string_chars(PortPart, PortChars),
  member(',', PortChars),
  split_string(PortPart, ',', '', PortList),
  member(Port, PortList).

udpHandle(PortPart, PortPart).
