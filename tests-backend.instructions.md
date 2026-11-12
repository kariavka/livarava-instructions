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

| Family | Base class | What it proves | Needs a server |
|---|---|---|---|
| API suite | `TestAbstractAPI` | an endpoint's behaviour and its access rules, over HTTP | yes |
| Offline suite | `unittest.TestCase` | a function, a rule or a parser, in process | no |

An access rule belongs in an API suite: the rule is only worth what the
endpoint actually answers, and a direct call to `Security.can` proves the
branch, not the response. A value validator, a query builder or a mapper
belongs in an offline suite, where it runs in milliseconds and needs no
fixtures.

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
- Request bodies come from `livarava.mocks.<resource>.v2_valid_data`. A suite
  that needs a payload the mock does not produce extends the mock.
- Assert the status first, always with `assertStatus`, and only then read the
  body. A test that reads `response.json()` before asserting the status reports
  a `KeyError` instead of the status it actually got.

## 4) Offline suites

One file per subject, `tests/test_<subject>.py`. One class per unit of
behaviour, named `<Subject>Test` — not `TestCase`, not `Test<Subject>`. A file
may hold several such classes, and the stubs they share are module-level
classes named `Stub<Thing>` or `Fake<Thing>`.

Method names are sentences about the behaviour, lowercase, with no grammar to
parse:

```python
test_an_item_keeps_its_position
test_a_numeric_id_becomes_a_string
test_context_must_be_an_array
```

An offline suite touches no network, no graph and no Redis. A dependency it
cannot avoid is replaced by a stub defined in the file.
