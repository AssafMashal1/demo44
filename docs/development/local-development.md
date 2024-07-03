# Local Development

This document gives tips and tricks on how to run the project locally, to add features or fix bugs. If you think anything is unclear, or you think something needs to be added — then you can improve this documentation by opening a pull request.

## Tests

Install pre-commit with `pre-commit install`

## Linting and formatting

We use [Prettier] to format our code. You usually don't need to fix any Prettier errors by hand, just execute

```shell
pre-commit run -a prettier --hook-stage manual
```

<!-- References -->

[Prettier]: https://github.com/prettier/prettier
