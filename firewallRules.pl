% ----------------- ADAPTER CLAUSE ----------------- %
mainStr(["A", "B", "C", "D", "E", "F", "G", "H"]).

% ----------------- Utilities ----------------- %
last(X,[X]).
last(X,[_|Z]) :- last(X,Z).

member(X, [X|_]).
member(X, [_|Z]) :- member(X, Z).


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

% ----------------- Rules ----------------- %
rule('accept adapter any').
rule('accept adapter F-H').
rule('reject adapter B').
rule('reject adapter D-F').
rule('drop adapter C').
rule('drop adapter D,F').
rule('drop adapter A-C').

% ----------------- Parsing Rules ----------------- %

adapter(IdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  split_string(Ids, ',', '', IdList).

adapter(IdList, ResponseTerm) :-
  rule(Rule),
  split_string(Rule, ' ', '', [ResponseString, "adapter"|SplitText]),
  term_string(ResponseTerm, ResponseString),
  last(Ids, SplitText),
  string_chars(Ids, IdChars),
  member(',', IdChars),
  split_string(Ids, ',', '', IdList).

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