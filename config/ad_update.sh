#!/bin/bash

curl -s https://raw.githubusercontent.com/d3ward/toolz/master/src/d3host.txt > d3host.txt
curl -s https://schakal.ru/hosts/alive_hosts.txt > alive_hosts.txt
cat d3host.txt alive_hosts.txt > full.txt
sed -e '/^\s*#.*$/d' -e '/^\s*$/d' full.txt > ad.hosts.lst

rm d3host.txt
rm alive_hosts.txt
rm full.txt
