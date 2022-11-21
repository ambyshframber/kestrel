#!/bin/sh

basedir=$(pwd)/$(dirname $0)
echo $basedir
cat $basedir/pijFORTHos/jonesforth.f $basedir/kestrel/kestrel.f $basedir/kestrel/gpio.f $basedir/kestrel/timer.f > $basedir/libs.f
screen -S forth -X readreg l $basedir/libs.f
screen -S forth -X slowpaste 2
screen -S forth -X paste l
rm $basedir/libs.f
