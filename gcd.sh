#!/bin/sh

if [ -t 2 ]; then
  RED=$(printf '\033[0;31m')
  NC=$(printf '\033[0m')
else
  RED=''
  NC=''
fi

print_usage() {
  printf 'Usage: %s <positive-int1> <positive-int2>\n' "${0##*/}" >&2
}

print_error() {
  printf '%s %s\n' "${RED}[ERROR]${NC}" "$1" >&2
}

die() {
  print_error "$1"
  print_usage
  exit 1
}

is_positive_int() {
  case "$1" in
    ''|0|*[!0-9]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}


gcd() {
  _gcd_a=$1
  _gcd_b=$2

  while [ "$_gcd_b" -ne 0 ]; do
    _gcd_r=$((_gcd_a % _gcd_b))
    _gcd_a=$_gcd_b
    _gcd_b=$_gcd_r
  done

  printf '%s\n' "$_gcd_a"
}


main() {
  if [ "$#" -ne 2 ]; then
    die "Wrong number of arguments."
  fi

  if ! is_positive_int "$1" || ! is_positive_int "$2"; then
    die "Arguments must be positive integers."
  fi

  result=$(gcd "$1" "$2")
  printf 'GCD: %s\n' "$result"
}

main "$@"