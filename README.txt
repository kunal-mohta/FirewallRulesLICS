FIREWALL RULES IN PROLOG - LOGIN IN COMPUTER SCIENCE

This is project is the Prolog Assignment, for Logic in Computer Science (CS F214) course, at BITS Pilani.

It was made by group of 2 students -
- Kunal Mohta - 2017A7PS0148P
- Prateek Sharma - 2017A7PS0171P

To run this, you will need SWI Prolog, which can be downloaded at (http://www.swi-prolog.org/download/stable).

***********************************************************************

INSTRUCTIONS TO RUN THE PROGRAM

- Run the `index.pl` file with `swipl`
```
$ swipl index.pl
```

- Sample rules are preloaded, and can be found in `rulesDatabase.pl` file. You can edit the rules (add / delete / modify) in the same file.
Please find format to write rules under the `RULES FORMAT` heading in this file.

- You are ready to use the program. Please find the format to write input packages under the `INPUT FORMAT` heading in this file.
```
?- package(...).
```

***********************************************************************

RULES FROMAT

- Rules are to be written using the `rule/1` predicate
```
rule("...").
```

- The string inside the `rule/1` predicate will be of the following format
```
rule("[accept / reject / drop] [clause / condition]").
```
- Please see the `CLAUSES.txt` file for format followed by different Clauses/Conditions.

Examples -
```
rule("accept adapter A").
rule("reject ether proto 123-230").
rule("drop ip src addr 192.168.10.1,192.168.10.10").
```
***********************************************************************

INPUT FORMAT

Inputs are given in the form of packets having properties related to the clauses/conditions.

For this program, inputs are given by `packet/14` predicates, following the following format -

```
packet(
  <adapter-id>,
  <ethernet-protocol-id>,
  <ethernet-vlan-number>,
  <tcp-src-port>,
  <tcp-dst-port>,
  <udp-src-port>,
  <udp-dst-port>,
  <icmp-type>,
  <icmp-code>,
  <ip-src-addr>,
  <ip-dst-addr>,
  <ip-addr>,
  <ip-protocol-type>,
  Output).
```

The first 13 parameters should be strings, representing the mentioned clause/condition parameter (e.g. <tcp-src-port> refers to the src port number for the TCP condition), and the last parameter gives the Action taken for the package, i.e. `accept / reject / drop`.

If you want a clause/condition parameter to be not specified in the packet, just put an empty string ("") in its place.

**Note** that the Clause/Condition parameters here can have only a single value, i.e. no range/comma-separated lists, like the ones mentioned in `CLAUSES.txt` file.

Examples for input packets -
```
?- packet("A", "0x0800", "0x0801", "600", "100", "64", "", "111", "100", "192.167.10.1", "192.167.10.255", "", "123", Output).
Output = drop

?- packet("E", "", "0x0804", "101", "", "9", "101", "", "225", "", "192.167.10.33", "", "", Output).
Output = accept

?- packet("G", "0x0808", "", "130", "", "0x321", "", "0123", "", "192.167.10.2", "", "", "", Output).
Output = reject


**IMPORTANT**
In the above syntax, please take care of where the spaces are. Using them at wrong places might lead to faulty results.
For example,
'ip src addr 192.168.10.1, 192.168.10.10' is not a valid syntax, because of the space after the comma.

```

***********************************************************************

IMPORTANT INFORMATION RELATED TO THE FUNCTIONALITY OF THE PROGRAM

- Clauses having multiple optional parameters should be dealt with carefully. Their permutation follow a strict fashion.
For Example -
The 2 separate rules - 'accept tcp src addr 192.168.17.10' and 'accept tcp dst addr 192.168.17.15'
are NOT THE SAME as the single rule 'accept tcp src addr 192.168.17.10 dst addr 192.168.17.15'
Both are treated differently.

- There might be situations where multiple rules apply to the given package.
These rules might collide with each other's result. In such situations, the following convention is followed -
    (i) If the colliding rules are of the same Clause/Condition, then the rule APPEARING FIRST in the order of rules will be give higher priority, i.e. its output action will be considered.
    (ii) If the colliding rules are of different Clauses/Conditions, then priority will be decided based on the output actions of the rules.
    The priority order in this case is - Reject > Drop > Accept.

- The 'any' keyword will be applied to any value of the parameter, i.e. even if the parameter is left empty (empty string ""), then too the rule will apply to it.

***********************************************************************

Sample rules and package inputs are available in `Sample` folder.
