rule('accept icmp type 0123,0124').
rule('reject icmp code 321-555').
rule('drop icmp type 111 code 100').

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