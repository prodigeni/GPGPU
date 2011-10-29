#
# We validate the assembler by first assembling the test file 'assembler-test.asm'
# then disassembling it and comparing the results.  assembler-test.asm
# is manually generated to hit all of the major instruction forms
#
../../tools/Assembler/assemble -o assembler-test.hex assembler-test.asm
../../tools/disassemble/disassemble assembler-test.hex > assembler-test.dis

# Strip comments out of our test program, since the disassembler won't reproduce 
# them
sed -e 's/;.*//' assembler-test.asm | diff -w -B -  assembler-test.dis
