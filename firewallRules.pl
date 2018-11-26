% ----------------- ADAPTER CLAUSE ----------------- %
mainStr(["A", "B", "C", "D", "E", "F", "G", "H"]).

% ----------------- Utilities ----------------- %
last(X,[X]).
last(X,[_|Z]) :- last(X,Z).

member(X, [X|_]).
member(X, [_|Z]) :- member(X, Z).


getSubStr([], _, F, F, _).
getSubStr([H|Main], [H|Ends], Fin, Acc, 0) :-
  getSubStr(Main, [H|Ends], Fin, [H|Acc], 1), !.

getSubStr([T|Main], Ends, Fin, Acc, 1) :-
  last(T, Ends),
  getSubStr(Main, Ends, Fin, [T|Acc], 0), !.

getSubStr([X|Main], Ends, Fin, Acc, 1) :-
  getSubStr(Main, Ends, Fin, [X|Acc], 1), !.

getSubStr([_|Main], Ends, Fin, Acc, 0) :-
  getSubStr(Main, Ends, Fin, Acc, 0), !.

% ----------------- Rules ----------------- %
% rule('accept adapter any').
rule('accept adapter F-H').
% rule('reject adapter B').
rule('reject adapter D-F').
% rule('drop adapter C').
rule('drop adapter D,F').
rule('drop adapter A-C').

% ----------------- Parsing Rules ----------------- %

adapter(IdList, accept) :-
  rule(Rule),
  split_string(Rule, ' ', '', ["accept"|SplitText]),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member(',', IdChars),
  split_string(Ids, ',', '', IdList).

adapter(IdList, reject) :-
  rule(Rule),
  split_string(Rule, ' ', '', ["reject"|SplitText]),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member(',', IdChars),
  split_string(Ids, ',', '', IdList).

adapter(IdList, drop) :-
  rule(Rule),
  split_string(Rule, ' ', '', ["drop"|SplitText]),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member(',', IdChars),
  split_string(Ids, ',', '', IdList).

adapter(IdList, accept) :-
  rule(Rule),
  split_string(Rule, ' ', '', ["accept"|SplitText]),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member('-', IdChars),
  split_string(Ids, '-', '', IdEnds),
  mainStr(MainStr),
  getSubStr(MainStr, IdEnds, IdList, [], 0).

adapter(IdList, reject) :-
  rule(Rule),
  split_string(Rule, ' ', '', ["reject"|SplitText]),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member('-', IdChars),
  split_string(Ids, '-', '', IdEnds),
  mainStr(MainStr),
  getSubStr(MainStr, IdEnds, IdList, [], 0).

adapter(IdList, drop) :-
  rule(Rule),
  split_string(Rule, ' ', '', ["drop"|SplitText]),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member('-', IdChars),
  split_string(Ids, '-', '', IdEnds),
  mainStr(MainStr),
  getSubStr(MainStr, IdEnds, IdList, [], 0).
