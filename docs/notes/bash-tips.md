# Bash Tips

## Printf

```bash
printf "%s\n" print arguments on "separate lines"
```

```output
print
arguments
on
separate
lines
```

```bash
printf "%b\n" "Hello\nWorld" "12\twords"
```

```output
Hello
World
12      words
```

```bash
printf "%d\n" 23 45 56.78 0xff 011
```

```output
23
45
-bash: printf: 56.78: invalid number
56
255
9
```

!!! Note
    Using a leading 0 is going to be octal. Using a lead 0x is going to be hexadecimal.

```bash
printf "%f\n" 12.24 23 56.789 1.2345678
```

```output
12.240000
23.000000
56.789000
1.234568
```

```bash
printf "%e\n" 12.34 23
```

```output
1.234000e+01
2.300000e+01
```

### Width

!!! Note
    `-` here in output means space.

```bash
printf "%8s %10s\n" nima saed
```

```output
----nima ------saed
```

```bash
printf "%8s %-10s\n" nima saed
```

```output
----nima saed------
```

```bash
printf "%8.2s %-10s\n" nima saed
```

```output
------ni saed------

```

```bash
printf "%4d\n" 23 54
```

```output
--23
--54
```

```bash
printf "%04d\n" 23 54
```

```output
0023
0054
```

```bash
printf "%10.4d\n" 23 54
```

```output
------0023
------0054
```

```bash
printf "%10.4f\n" 23 54
```

```output
---23.0000
---54.0000
```

## read command


```bash
read a b "test test1 test2"

echo $a
echo $b
```

```output
test
test1 test2
```

## while loop

```bash
while
	command lists
do
	command lists
done
```

### examples

```bash
while
	((x<10))
do
	echo loop $x;
	date > date.$x;
	((x=x+1))
done
```

```bash
while
	read a b
do
	echo a is $a b is $b
done <data_file
```

```bash
ls -l | while read a b c d; do echo owner is $c; done
```

## For Loops

```bash
for <var> in <list>
do
	comand lists
done
```

### Examples

```bash
for i in dog cat elephant
do
	echo i is $i
done
```

```bash
for i in dog cat elephant; do echo i is $i; done
```

## seq

```bash
seq 1 5
```

```output
1
2
3
4
5
```

```bash
for num in `seq 1 5`; do echo $num; done
```

```output
1
2
3
4
5
```

!!! Note
    You can also use `{A..Z}`, `{a..f}` or `{1..10}` in for loops.

```bash
for i in {a..f}; do echo $i; done
```

```output
a
b
c
d
e
f
```

### Dealing with files
```bash
for d in $(<data_file); do echo $d; done
```

```bash
for j in *.c
# making a list with file globbing
do
	command
done
```

```bash
for f in $(find . -name *.c)
do
 command
done
```

### List/Array

```bash
for n in ${list[@]}; do echo $n; done
```

## Functions

```bash
function name{
    command list
}
```

```bash
function myfunc {
    echo starting
    return
    echo this will not be executed
}
```

### Export functions

```bash
export -f myfunc
```

## Case Statement

```bash
case expression in
pattern 1 )
    command list ;;
pattern 2 )
    command list ;;
esac
```

```bash
case $ans in
yes|YES|y|Y|y.x) echo "Will do!";;
n*|N*) echo "Will NOT do!";;
*) echo "Oops!";;
esac
```

## If-Then-Else Statement

```bash
if
    command list # last result is used
    then
    command list
    [else
    command list]
fi
```

## Example

```bash
if
grep -q important myfile
then
    echo myfile has important stuff
else
    echo myfile does not have important stuff
fi
```


## Extra

### File name and path

!!! Note
    This code is inside the script file.

#### To get name of script file

```bash
echo $0
```

#### To get full path of the file

```bash
echo $(readlink -f $0)
```

#### To get full path but move one directory up

```bash
echo $(dirname "$(readlink -f $0)")
```

### Progress bar

```bash
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
```

### Bash parsing and expansion

1. Brace expansion

```bash
{one,two,three}
{1..10} or {a..z}
pre{d,l}ate
{{1..3},{a..c}} => 1,2,3,a,b,c
{1..3}{a..c} => 1a,1b,1c,2a,...,3c
{01..13..3} => 01,04,07,10,13
{a..h..3} => a,d,g
```

2. Tilde expansion

```bash
~ => /home/nima
~someone => /home/someone
~noUser => ~noUser
```

3. Parameter and variable expansion

```bash
var=whatever
$var or ${var} => whatever
echo $var “$var” #are having different result  if there are white spaces
```

4. Arithmetic expansion

```bash
$(( expression ))
```

5. Command substitution

```bash
wc -l $( date +%Y-%m-%d).log
```

!!! Note
    If command substitution is not quoted, word splitting and pathname expansion are performed on the result.

6. Word splitting

The result of parameter and arithmetic expansion, as well as command substitution, are subject to word splitting if the were **NOT QUETED**

```bash
var="this is a multi-word value"
printf ":%s:\n" $var
```

```output
:this:
:is:
:a:
:multi-word:
:value:
```

```bash
var="this is a multi-word value"
printf ":%s:\n" $var
```

```output
:this is a multi-word value:
```

!!! Note
    Word splitting is based on value of IFS (Internal Field Separator). IFS default value is space, tab, and newline. (IFS=$' \t\n'). You can change IFS value to any value.

7. Pathname expansion

Char in use are \*, ?, and []

```bash
echo D*
```

list files starting with capital D.

```bash
echo ?a*
```

list files which the second char is a.

```bash
echo *[0-9]*
```

list files which there is at least one number in there name.


8. Process substitution

```bash
<(command)
>(command)
```

### Parameter Expansion

**empty or unset variable**

1. Default

    - echo {var:-default} => default if it is not set and empty string
    - echo {var-default}  => default if it is not set

2. Alternative

    - echo {var:+alter}   => alter if it is set and not empty string
    - echo {var+alter}    => alter if it is set

3. Default with assignment

    - echo {var:=default} => default if it is not set and empty string, assign default to var as well
    - echo {var=default}  => default if it is not set, assign default to var as well.

4. Message

    - echo {var:?message} => display error message if it is not set and empty string
    - echo {var?message}  => display error message if it is not set

** Length of var

```bash
var=test
echo ${#var}
```

```output
4
```

**Remove Pattern**

- Short from end

```bash
var=Toronto
echo ${var%o*}
```
```output
Toront
```

- Long from end

```bash
var=Toronto
echo ${var%%o*}
```

```output
T
```

- Short from beginning

```bash
var=Toronto
echo ${var#*o}
```

```output
ronto
```

- Long from beginning

```bash
scriptname=${0##*/} ## /home/user/script.sh => script.sh
```

**Replace pattern**

```bash
password=reretrgfdsgdhdt
echo "${password//?/*}"
```

```output
*************
```

**Substring** var:offset:length

```bash
var=Toronto
echo "${var:3:2}"
```

```output
on
```

```bash
var=Toronto
echo "${var:1}"
```

```output
oronto
```

*Negative offset*

```bash
var=Toronto
echo "${var: -3}" # Do not forget about space betwen : and -
```

```output
nto
```
