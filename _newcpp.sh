filename="$1.cpp"
editor="konsole -e vim"
makefiletemplate="CXXFLAGS=-Wall -Wextra -Werror=format -Werror=return-type -Werror=uninitialized -fsanitize=undefined -g
CXXFLAGS+=-O2
CXXFLAGS+=-D_GLIBCXX_DEBUG

bin: $filename Makefile
	\$(CXX) \$(CXXFLAGS) -o bin $filename
"
template='#include <cstdio>
#include <vector>
#define eprintf(...) fprintf(stderr, __VA_ARGS__)

using namespace std;

typedef long long ll;
typedef unsigned long long ull;


int main() {
	return 0;
}
'
checktemplate='#!/bin/bash
shopt -s globstar
if [[ ! -x bin ]]; then
	echo "No executable. Did you compile it?"
	exit
fi
for test in tests/**/*.in; do
	out=${test%.*}.out
	if [[ -e $out ]]; then
		./bin < ${test} | diff -w ${out} -
		if [[ ${PIPESTATUS[1]} -eq 1 ]]; then
			echo -e "\033[1;31mMismatch in ${test}\033[0m"
		else
			echo -e "\033[1;32m${test} OK\033[0m"
		fi
	else
		echo -e "\033[1;34m$test:\033[0m"
		head -30 $test | cut -c -`tput cols`
		if [[ $(wc -l < $test) -gt 30 ]]; then
			echo -e "\033[0;33m*snip*\033[0m"
		fi
		echo -e "\033[0;34mprogram output:\033[0m"
		./bin < $test
	fi
done
'

gentemplate="#!/usr/bin/env python3
import sys
from random import choice, randint, randrange, choices, shuffle, random, uniform

n = int(sys.argv[1])
print(n)
for _ in range(n):
	print(randint(1, 100))
"

xchecktemplate='#!/bin/bash
while true; do
	IN=`tests/gen.py $1`;
	diff <(./bin <<< "$IN") <(./brute <<< "$IN")
done
'

cat > ${filename} << END
${template}
END

cat > check << END
${checktemplate}
END

cat > Makefile << END
${makefiletemplate}
END

cat > xcheck << END
${xchecktemplate}
END

mkdir tests

cat > tests/gen.py << END
${gentemplate}
END

chmod +x check
chmod +x tests/gen.py
chmod +x xcheck

${editor} ${filename} &
