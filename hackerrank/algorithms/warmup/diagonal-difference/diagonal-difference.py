#!/bin/python

import sys

n = int(raw_input().strip())
a = []
e = []
for a_i in xrange(n):
   a_temp = map(int,raw_input().strip().split(' '))
   a.append(a_temp)
   e.extend(a_temp)

print e

slr = 0
for i in xrange(n*n):
    if (i % (n +1) == 0):
        slr = slr + e[i]

srl = 0
for i in xrange(1, n+1):
    srl = srl + e[i*(n-1)]

print abs(slr - srl)
