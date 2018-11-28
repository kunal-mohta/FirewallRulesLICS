## Instruction on writing rules for the program

- Create a prolog file to write down rules into.

- Rules are to be written using the `rule/1` predicate
```
rule("...").
```

- The string inside the `rule/1` predicate will be of the following format
```
rule("[accept / reject / drop] [clause / condition]").
```

Examples -
```
rule("accept adapter A").
rule("reject ether proto 123-230").
rule("drop ip src addr 192.168.10.1,192.168.10.10").
```

**Note** For more information on Clauses/Conditions and what format do they follow, please refer `Clauses` file in this folder (both md and pdf available).