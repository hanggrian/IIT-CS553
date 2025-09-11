# AI prompts

In this homework, the model that answered my prompts was *ChatGPT* using
*GPT-4o.*

## Prompt 1

> How to pass a callable as a function parameter in Bash? What if the callable
  is a predicate, that is, an invokable with a return value.

Bash doesn’t have "first-class functions" like Python or JavaScript, but you can
still **pass callables** around in a few different ways. The most common
patterns are:

#### Passing by function name

```sh
foo() {
  echo "foo called with: $*"
}

bar() {
  local func=$1  # name of callable
  shift
  $func "$@"     # invoke it
}

bar foo hello world
# → foo called with: hello world
```

#### Passing by command string

```sh
runner() {
  local cmd=$1
  shift
  eval "$cmd" "$@"
}

runner "echo hi"   # → hi
runner "ls -1"     # executes ls
```

#### Passing by predicates

```sh
is_even() {
  local n=$1
  (( n % 2 == 0 ))
}

check_predicate() {
  local pred=$1
  shift
  if $pred "$@"; then
    echo "Predicate true"
  else
    echo "Predicate false"
  fi
}

check_predicate is_even 4   # → Predicate true
check_predicate is_even 5   # → Predicate false
```

## Prompt 2

> I know that `eval` executes a string as a command. What if the commands are a
  list of strings?

In Bash, `eval` takes a single string, concatenates it, and executes it as a
command. If you already have **a list of strings,** you don’t usually need
eval—you can just execute them directly.

#### Running a list of commands stored in an array

```sh
commands=("ls -l" "echo hello" "date")

for cmd in "${commands[@]}"; do
  eval "$cmd"
done
```

#### Running without `eval` (preferred if possible)

If your commands are simple (command + arguments, no extra shell syntax), you
can store them as arrays and execute safely without `eval`:

```sh
commands=(
  "ls -l"
  "echo hello"
  "date"
)

for cmd in "${commands[@]}"; do
  # split into words safely
  bash -c "$cmd"
done
```

or, if you store them as arrays of arrays:

```sh
cmd1=(ls -l)
cmd2=(echo hello)
cmd3=(date)

commands=(cmd1[@] cmd2[@] cmd3[@])

for c in "${commands[@]}"; do
  "${!c}"
done
```
