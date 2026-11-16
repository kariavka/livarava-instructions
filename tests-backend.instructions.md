---
name: Backend Tests Standard
description: "Use when writing, naming or reviewing a Python test suite under tests/. Defines the two suite families, the naming grammar, the role vocabulary and the fixture discipline."
applyTo: "**/tests/test_*.py"
---
# Python test suites

Read `tests.instructions.md` first; it carries the rules that hold in every
language, including the test-first workflow and what has to be covered. This
file adds what is specific to Python suites, `tests/test_*.py`.

Every suite runs under `unittest`, is executed by name, and ends with:

```python
if __name__ == '__main__':
    unittest.main()
```

Do not introduce `pytest` fixtures, parametrization or plugins into a suite.
`pytest` may be used as a runner, which is why a suite must also work when
collected by it, but the suite itself is written against `unittest`.

Commands:

```bash
.env/bin/python3 -m pytest tests/test_<subject>.py -q
```

## 1) The two families

Decide the family first, because everything else follows from it.

| Family | Base class | What it proves | Touches |
|---|---|---|---|
| API suite | `TestAbstractAPI` | an endpoint's behaviour and its access rules, over HTTP | the API server |
| Offline suite | `unittest.TestCase` | a function, a rule or a parser, in process | nothing |
| Storage suite | `unittest.TestCase` | a property that belongs to the database rather than to the code | PostgreSQL or Neo4j |

An access rule belongs in an API suite: the rule is only worth what the
endpoint actually answers, and a direct call to `Security.can` proves the
branch, not the response. A value validator, a query builder or a mapper
belongs in an offline suite, where it runs in milliseconds and needs no
fixtures.

A storage suite is the exception, not the fallback. Use it only where the
behaviour under test is the storage's own — that a unique constraint rejects
the second row, that an advisory lock refuses a second holder, that a
statement the builder produced is one the server accepts. A stub cannot prove
any of those, because the thing being tested is the server's answer. Anything
the code decides by itself belongs in an offline suite, where it costs
milliseconds and no cleanup.

A storage suite carries two obligations the others do not:

- **Name what it creates uniquely per run**, with `uuid.uuid4().hex` or the
  equivalent, so that two runs, or two suites running together, never meet on
  the same row or the same key.
- **Remove what it created**, in `tearDown` or `tearDownClass`, whether the
  test passed or failed. These suites run against the same database the
  platform uses, so a row left behind is production data, and 183 user
  fixtures once stayed in the graph because this was left to each suite to
  remember.

It asserts on nothing it did not create: never on a count of rows, never on
the first row of a table, never on what another suite left.

Do not mix the families in one file.

## 2) Module header

Follow `docstring.instructions.md`. The dotted path is the test module's own
(`tests.test_project`), and the title is `LivaRava Test <Subject>`, repeated in
`__title__`. The description says what the suite exercises, not what the
subject does.

## 3) API suites

### File, class and attributes

One file per resource, `tests/test_<resource>.py`, one class,
`Test<Resource>API(TestAbstractAPI)`. The class declares `instances = []` and
one attribute per role it uses, set to `None`.

### Naming grammar

```
test_<resource>_<scope>_<action>_<role>
```

- `<resource>` is the model, singular and lowercase: `project`, `neuron`.
- `<scope>` is `list`, `item` or `functions`.
- `<action>` is the HTTP verb for `list` and `item` (`get`, `post`, `patch`,
  `delete`), or the method name for `functions` (`set_role`, `click`).
- `<role>` is who makes the request. It is the subject of the test, so it comes
  last and is never abbreviated.

A test that varies one more dimension appends it after the role, as
`..._authorized_user_private` does for `display`. Nothing else is appended: a
name is a sentence in this grammar or it is in the wrong family.

### The role vocabulary

These names carry an expectation. Using one for a different kind of principal
is how a suite comes to assert the opposite of the rule it is named for.

| Role | Who that is | Default expectation for a write |
|---|---|---|
| `anonymous` | no token at all | refused |
| `authorized_user` | a signed-in stranger, holding **no** role on the record or its parent | refused |
| `authorized_author` | the user who created the record, or its parent | allowed |
| `authorized_admin` | a global administrator, `admin=True` | allowed |
| `authorized_<parent>_<role>` | a role on the parent, as `authorized_site_editor` | per the rule |
| `authorized_member` | a member of the project or site that owns the record | per the rule |

A `*_on` flag is a frontend switch and grants nothing. A fixture may set one,
because the endpoint under test may read it for its payload, but no test may
rely on one for access. When a test needs a principal who may write, give that
principal a role, not a flag.

### Fixtures and cleanup

`setUpClass` creates the users and the records the whole class shares, and
appends every one of them to `cls.instances` as it goes. `tearDownClass` calls
`clean(cls.instances)` and does nothing else. A record created inside a single
test is appended to `self.instances` in that test, so the same teardown
collects it.

The suites run against a live graph. A fixture that outlives its run is
left-over production data, and a user fixture that outlives its run is a live
API key.

Give every fixture a value that cannot collide: `email=f"john.doe.{time()}@..."`
and `api_key=str(uuid.uuid1())`. A fixture the endpoint identifies by another
unique field sets that field the same way.

### The body

Each test reads top to bottom in the same shape, with the comment lines that
mark its parts:

```python
    def test_project_item_patch_authorized_user(self):
        """
        PATCH Test Project Item Authorized User

        """
        # Get instances
        user = self.user

        # Imports
        from livarava.mocks.project import v2_valid_data

        # Get Request JSON data
        json_request = v2_valid_data(item_id=project.id)

        # Try to patch Project
        response = requests.patch(
            get_api_url('projects', project.id),
            headers=get_headers(key=user.api_key, json=True),
            json=json_request,
        )

        # Asserts
        self.assertStatus(response, 403)
```

- The docstring is one line, `<METHOD> Test <Resource> <Scope> <Role>`, with a
  blank line before the closing delimiter.
- Add a paragraph to that docstring when the expectation is not obvious from
  the name: say which leg of the rule decides it. A reader who finds a `200`
  where they expected a `403` must find the reason in the test, not in
  `security.py`.
- Requests go through `get_api_url`, `get_headers` and `requests`. Do not build
  a URL or a header by hand.
- Request bodies come from the resource's mock, never from a dict written in
  the test. Section 4 states what a mock looks like.
- Assert the status first, always with `assertStatus`, and only then read the
  body. A test that reads `response.json()` before asserting the status reports
  a `KeyError` instead of the status it actually got.

## 4) Request payloads

A request body comes from a mock, never from a dict built inside the test.
The mock is the one place that knows the shape of the resource, so a member
that changes is corrected once rather than in every suite that sends it.

- One module per resource, `livarava/mocks/<resource>.py`, with the module
  header `docstring.instructions.md` requires.
- The builder is `v2_valid_data(**kwargs)` and returns a whole JSON:API
  document: `data` carrying `attributes`, `relationships` and the model's own
  `JSON_TYPE`. Older modules use names like `get_<resource>_valid_data`; they
  are legacy, not a pattern to follow.
- Values that must not collide between runs are generated in the builder, with
  `uuid.uuid1()`, not passed in by the caller.
- `item_id` adds `data.id`, which a PATCH needs and a POST must not carry.
- A relationship is offered as `<name>_id` and expands to
  `{"data": {"id": ..., "type": "<json type>"}}`. Offer every relationship an
  access rule reads: a rule decided by the project is untestable while the
  mock cannot send one.
- Keep the builder valid. A suite that needs an invalid document takes the
  valid one and breaks the one member under test, in the test, so that the
  reader sees what makes it invalid. An invalid shape that several suites need
  earns its own `v2_invalid_<reason>_data` beside it.

Adding a resource to the suites means adding its mock in the same change.

## 5) Offline suites

One file per subject, named for the module under test: take the path
segments that distinguish it, drop `livarava`, and join them with
underscores. `livarava/pg/model.py` is `tests/test_pg_model.py`,
`livarava/ai/chat/context.py` is `tests/test_chat_context.py`. Do not run
words together to shorten the name.

One class per unit of behaviour, named `Test<Subject>`, as every class in
these suites is: `TestPgModelParse`, `TestPgModelSerialize`. The prefix is
the convention across both families, so `TestPostAPI` and `TestPgModelParse`
read alike and a suite sorts with its siblings. Not `<Subject>Test`, not
`<Subject>TestCase`. Its docstring is one sentence stating the rule the class
holds, ending with a full stop. The test methods carry no docstring: the name is the
statement, and a method that needs a sentence of its own is named wrongly or
tests two things.

A file may hold several such classes, and the stubs they share are
module-level classes named `Stub<Thing>` or `Fake<Thing>`.

Method names say exactly what the method tests, in as few words as carry it.
They are descriptions, not prose: drop the articles and the connectives, keep
the subject and the outcome, and let the words run in the order
`test_<subject>_<condition>_<outcome>`.

```python
test_unknown_attribute_refused
test_default_applied_on_create
test_numeric_string_becomes_int
```

Not `test_an_unknown_attribute_is_refused`, which reads as a sentence, and not
`test_parse_works` or `test_case_3`, which say nothing. A method that cannot
be named this way tests two things.

A method carries a docstring only where it has something the name cannot hold,
such as the audit finding a test closes. A docstring that restates the name is
noise.

An offline suite touches no network, no graph and no Redis. A dependency it
cannot avoid is replaced by a stub defined in the file.
