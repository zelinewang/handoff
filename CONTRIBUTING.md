# Contributing to Handoff

Handoff is a delegation *protocol*, not a framework — mostly Markdown (the
`skill/`), an installer (`install.sh`), and a pre-registered eval bundle under
`eval/`. Contributions are usually docs, templates, or shell.

## Setup

```bash
git clone https://github.com/zelinewang/handoff.git
cd handoff
bash install.sh --dry-run    # shows what an install would do; changes nothing
```

`install.sh` is idempotent and never edits your `CLAUDE.md` or `settings.json` —
it copies `skill/` and prints snippets for you to paste. Please keep that
property.

## Expectations

- The protocol's claims are backed by the eval in `eval/`. If you change a claim
  in `skill/SKILL.md` or `README.md`, say in the PR how the evidence still holds — and
  don't overstate results (the eval deliberately includes the run where dispatch
  *lost*).
- Shell should pass `shellcheck`.

## Pull requests

- Branch off `master`; open one focused PR per change.
- Conventional-ish commit subjects (`fix:`, `feat:`, `docs:`…). PRs are
  squash-merged.

## License

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
