#!/bin/sh

SCRIPT="$(dirname "$0")/../gcd.sh"

pass=0
fail=0

record_pass() {
  pass=$((pass + 1))
}

record_fail() {
  fail=$((fail + 1))
}

test_success() {
  expected="$1"
  shift

  actual=$("$SCRIPT" "$@" 2>/dev/null)
  status=$?

  if [ "$status" -eq 0 ] && [ "$actual" = "$expected" ]; then
    printf 'PASS: %s\n' "$*"
    record_pass
  else
    printf 'FAIL: %s\n' "$*"
    printf '  expected: %s\n' "$expected"
    printf '  actual:   %s\n' "$actual"
    printf '  status:   %s\n' "$status"
    record_fail
  fi
}

test_failure() {
  "$SCRIPT" "$@" >/dev/null 2>&1
  status=$?

  if [ "$status" -ne 0 ]; then
    printf 'PASS: error: %s\n' "$*"
    record_pass
  else
    printf 'FAIL: expected error: %s\n' "$*"
    record_fail
  fi
}

run_success_tests() {
  test_success "GCD: 1" 7 13
  test_success "GCD: 6" 12 18
  test_success "GCD: 10" 20 30
  test_success "GCD: 100" 100 100
  test_success "GCD: 1" 1 1
  test_success "GCD: 12" 123456 789012
}

run_failure_tests() {
  test_failure
  test_failure 10
  test_failure 10 20 30

  test_failure abc 10
  test_failure 10 abc

  test_failure 0 10
  test_failure 10 0

  test_failure -1 10
  test_failure 10 -1

  test_failure 1.5 10
  test_failure 10 2.5

  test_failure "" 10
  test_failure 10 ""
}

test_error_message() {
  expected="$1"
  shift

  actual=$("$SCRIPT" "$@" 2>&1 >/dev/null)
  status=$?

  if [ "$status" -ne 0 ] && echo "$actual" | grep -Fq "$expected"; then
    printf 'PASS: error message: %s\n' "$*"
    record_pass
  else
    printf 'FAIL: error message: %s\n' "$*"
    printf '  expected message: %s\n' "$expected"
    printf '  actual output:\n%s\n' "$actual"
    printf '  status: %s\n' "$status"
    record_fail
  fi
}

run_error_message_tests() {
  test_error_message "Wrong number of arguments." 
  test_error_message "Wrong number of arguments." 10
  test_error_message "Wrong number of arguments." 10 20 30

  test_error_message "Arguments must be positive integers." abc 10
  test_error_message "Arguments must be positive integers." 10 abc

  test_error_message "Arguments must be positive integers." 0 10
  test_error_message "Arguments must be positive integers." 10 0

  test_error_message "Arguments must be positive integers." -1 10
  test_error_message "Arguments must be positive integers." 10 -1

  test_error_message "Arguments must be positive integers." 1.5 10
  test_error_message "Arguments must be positive integers." 10 2.5

  test_error_message "Arguments must be positive integers." "" 10
  test_error_message "Arguments must be positive integers." 10 ""
}

main() {
  run_success_tests
  run_failure_tests
  run_error_message_tests

  printf '\n'
  printf 'PASS=%s FAIL=%s\n' "$pass" "$fail"

  [ "$fail" -eq 0 ]
}

main "$@"