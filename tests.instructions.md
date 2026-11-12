---
name: Tests Standard
description: "Use when writing, naming, reviewing or restructuring any test suite. Defines what a test is for, the test-first workflow, what has to be covered, and the determinism and cleanup rules that hold in every language."
applyTo: "**/tests/**"
---
# Tests

This file holds the rules that hold whatever the suite is written in. Two
files carry the rest, and the suite's language decides which one applies:

| File | Owns |
|---|---|
| `tests-backend.instructions.md` | Python suites, `tests/test_*.py` |
| `tests-frontend.instructions.md` | ESM suites, `tests/<Name>.test.mjs` |

Read this file and the one for the language. Where they disagree, the
language file wins, because it is the more specific of the two.

## 1) What a suite is for

A test records a decision, so that the decision survives the next change. It
is not a transcript of what the code currently does: a suite written by
reading the implementation passes on the day it is written and guarantees
nothing afterwards.

One file per subject under test, named after that subject. A test that covers
several modules is named for the primary one.

## 2) Writing the test first

- Take the expectation from the rule as decided — the specification, the
  decision log, the issue — and not from the behaviour you observe.
- Write the test, run it, and read the failure. A new test that passes before
  the change was made is testing something other than the change.
- Then write the change, and run the test again.

When an existing test fails after a change, decide which of the two is wrong
before touching either. A test that encoded a defect as its expectation is
corrected, and the correction states in the test itself why the expectation
moved. A test that is right stays, and the change is fixed.

## 3) Naming

A test name states the rule it holds, so that a failing run names the rule
that broke without anyone opening the file. `test_case_3` and
`test_<function>_works` name nothing.

The two language files each define a grammar for their suites. Follow the
grammar of the family you are writing in rather than inventing a third.

## 4) What has to be covered

- The happy path.
- The negative path: the refusal, the invalid input, the error response.
- The edge cases that the rule actually turns on, not every input that exists.

A rule is covered when both of its sides are. One test proving that something
is allowed says nothing about who is refused, and a rule with several
independent legs needs one test per leg, because a single passing test never
says which leg carried it.

## 5) Determinism

A suite that fails sometimes is worse than no suite, because its failures stop
being read.

- No dependence on the current time, the timezone, randomness or network
  availability, unless the test controls that input itself.
- No timing workarounds. A sleep added to stabilize a test hides a race rather
  than proving its absence.
- No dependence on data another suite created, on data that happens to be in
  the environment, or on a count of records the test did not create.
- Tests pass in any order, and a single test passes when run alone.

## 6) Fixtures and mocks

Every fixture is created by the suite that uses it and removed when that suite
ends, whether it passed or failed. Mocks are local to the suite and are torn
down with it; a mock that outlives its suite changes the result of the next
one.

Where a suite runs against a shared or live environment, the cleanup rule is
not tidiness but safety: a fixture that outlives its run is left-over
production data. The language file states what that means for its runtime.

## 7) Commands

Run suites by name rather than running everything, and name in the commit
message which suites were added or changed, with the numbers any claim rests
on. The language file gives the commands for its runtime.
