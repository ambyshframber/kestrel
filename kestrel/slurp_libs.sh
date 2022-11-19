#!/bin/sh

cat pijFORTHos/jonesforth.f lib.f libgpio.f > libs.f
screen -S forth -X readreg l libs.f
screen -S forth -X slowpaste 2
screen -S forth -X paste l
#rm libs.f
