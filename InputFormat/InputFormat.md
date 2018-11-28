## Input Format

After running the program (find instructions to run the program in `Instructions` folder), you'll need to give inputs for the rules to run on.

Inputs are given in the form of packets having certain properties related to the clauses/conditions.

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

The first 13 parameters should be strings, representing the mentioned clause/condition parameter (refer `RulesInstruction/Clauses`), and the last one gives the Action taken for the package, i.e. `accept / reject / drop`.

If you want a clause/condition parameter to be not specified in the packet, just put an empty string `""` in its place.

**Note** that the Clause/Condition parameters here can have only a single value, i.e. no range/comma-separated lists, like the ones mentioned in `RulesInstruction/Clauses`

Examples for input packets -
```
?- packet("A", "0x0800", "0x0801", "600", "100", "64", "", "111", "100", "192.167.10.1", "192.167.10.255", "", "123", Output).
Output = drop

?- packet("E", "", "0x0804", "101", "", "9", "101", "", "225", "", "192.167.10.33", "", "", Output).
Output = accept

?- packet("G", "0x0808", "", "130", "", "0x321", "", "0123", "", "192.167.10.2", "", "", "", Output).
Output = reject

```