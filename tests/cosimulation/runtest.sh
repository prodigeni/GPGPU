# 
# Copyright (C) 2011-2014 Jeff Bush
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
# 
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
# Boston, MA  02110-1301, USA.
# 

# Default version if not set in environment
: ${UARCH_VERSION=v1}

TOOLCHAIN_DIR='/usr/local/llvm-vectorproc/bin/'
COMPILE=$TOOLCHAIN_DIR/clang
ELF2HEX=$TOOLCHAIN_DIR/elf2hex
SIMULATOR=../../tools/simulator/simulator
VERILATOR_MODEL=../../rtl/$UARCH_VERSION/obj_dir/Vverilator_tb

mkdir -p WORK

for test in "$@"
do
	if [ "${test##*.}" != 'hex' ]
	then
		echo "Building $test"
		PROGRAM=WORK/test.hex
		$COMPILE -o WORK/test.elf $test
		if [ $? -ne 0 ]
		then
			exit 1
		fi

    	$ELF2HEX -o $PROGRAM WORK/test.elf
		if [ $? -ne 0 ]
		then
			exit 1
		fi
	else
		echo "Executing $test"
		PROGRAM=$test
	fi

	$VERILATOR_MODEL +regtrace=1 +bin=$PROGRAM +simcycles=2000000 +memdumpfile=WORK/vmem.bin +memdumpbase=0 +memdumplen=A0000 +autoflushl2=1 | $SIMULATOR $SIMULATOR_DEBUG_ARGS -m cosim -d WORK/mmem.bin,0,A0000 $PROGRAM

	if [ $? -eq 0 ]
	then
		diff WORK/vmem.bin WORK/mmem.bin
		if [ $? -eq 0 ]
		then
			echo "PASS"
		else
			echo "FAIL: final memory contents do not match"
			exit 1
		fi
	else
		echo "FAIL: simulator flagged error"
		exit 1
	fi
done

