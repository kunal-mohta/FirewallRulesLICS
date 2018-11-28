## Instructions

Find here the instructions to run and use the program

- Run the `index.pl` file with `swipl`
```
swipl index.pl
```

- Include the file in which you have written the rules for the firewall (refer `RulesInstruction` folder for help with writing rules)\
If the name of your rules file is `rules.pl`, then do
```
?- [rules]
```
**Note** Make sure the `rules.pl` file is in the same directory

- You are ready to use the program. For help on giving input, refer `InputFormat` folder.
```
?- package(...).
```