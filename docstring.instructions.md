---
description: "Global Python docstring/documentation standard for LivaRava."
applyTo: "**/*.py"
---
# Python documentation style

## Python module headers

Start every Python module with the following header, in this order:

- The encoding declaration: `# coding=utf-8`.
- A module docstring with opening and closing `"""` delimiters on their own
  lines. Indent every nonblank line of its body by four spaces.
- The full dotted module path, derived from its location in the project
  (for example, `livarava.calendar.providers.google` or
  `tests.test_calendar_sync`), as the first line of the docstring body.
- A line of `~` characters matching the length of the dotted module path,
  followed by a blank line.
- The human-readable module title on its own line, followed by a blank line.
  It is the same string as the `__title__` assignment below the docstring,
  character for character, so that the two never drift apart. A module named
  `livarava.navigation` carries `LivaRava Navigation` here and
  `__title__ = 'LivaRava Navigation'` below it.
- A short summary of the module's purpose, followed by a blank line and a
  description of its responsibilities, relevant interactions and behavior.
  Keep the description accurate and proportional to the module; do not copy
  responsibilities from another module.
- The copyright and license fields at the end of the docstring, separated
  from the description by a blank line:
  `:copyright: (c) <year> by Artem Kariavka, LivaRava` and
  `:license: LivaRava License`.
- Immediately after the module docstring, set `__title__` to a human-readable
  module title and `__author__` to `'Artem Kariavka'`. These are module-level
  assignments, not docstring fields. Preserve any required `from __future__`
  imports before these assignments, as Python requires.

Preserve an existing copyright year or year range; use the current year for
new module headers. Keep existing module metadata accurate when updating a
header. Place ordinary imports after the header and module metadata.

```python
# coding=utf-8
"""
    livarava.calendar.providers.google
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    LivaRava Google Calendar Provider

    The Google Calendar adapter of LivaRava Calendar.

    Translate Calendar Core operations into Google Calendar API calls and
    convert Google event resources into Calendar domain models. Reuse the
    existing Google Calendar bridge for authorization and credentials.

    :copyright: (c) 2026 by Artem Kariavka, LivaRava
    :license: LivaRava License
"""
__title__ = 'LivaRava Google Calendar Provider'
__author__ = 'Artem Kariavka'
```

## Class and function docstrings

For Python class and function docstrings, follow the existing LivaRava layout:

- Put the opening and closing `"""` delimiters on their own lines.
- Indent the docstring body to the same level as the docstring statement.
- Write the summary first, followed by a blank line.
- List all `:param` descriptions before any `:type` declarations; group all
  `:type` declarations together after the parameters.
- Put return documentation (`:return:`, `:rtype:`) and then exceptions
  (`:raises:`) after the parameter and type sections.
- Use this layout for short docstrings too; do not use a one-line docstring
  when documenting Python classes or functions.

```python
    @classmethod
    def create(cls, data, user_id=None):
        """
        Create new Neuron

        :param data: Neuron Data
        :param user_id: User ID
        :type data: dict
        :type user_id: int
        :return: Created Neuron
        :rtype: Neuron
        """
```
