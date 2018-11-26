% ----------------- ADAPTER CLAUSE ----------------- %

% ----------------- Utilities ----------------- %
last(X,[X]).
last(X,[_|Z]) :- last(X,Z).

member(X, [X|_]).
member(X, [_|Z]) :- member(X, Z).

% ----------------- Rules ----------------- %
% rule('accept adapter any').
% rule('accept adapter A,H').
% rule('reject adapter B').
% rule('reject adapter E,G').
% rule('drop adapter C').
% rule('drop adapter D,F').
rule('accept adapter A-H').

% ----------------- Parsing Rules ----------------- %

adapter(IdList, accept) :-
  rule(Rule),
  split_string(Rule, " ", "", ["accept"|SplitText]),
  last(Ids, SplitText),
  split_string(Ids, ",", "", IdList).

adapter(IdList, reject) :-
  rule(Rule),
  split_string(Rule, " ", "", ["reject"|SplitText]),
  last(Ids, SplitText),
  split_string(Ids, ",", "", IdList).

adapter(IdList, drop) :-
  rule(Rule),
  split_string(Rule, " ", "", ["drop"|SplitText]),
  last(Ids, SplitText),
  split_string(Ids, ",", "", IdList).
