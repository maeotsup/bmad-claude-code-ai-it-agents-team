# Python — Stack Knowledge

## Detection Signals

| Signal | Pattern |
|--------|---------|
| Primary | `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py`, `setup.cfg` |
| Files | `*.py` in project root or `src/` |
| Virtual env | `.venv/`, `venv/`, `.python-version` |
| Package manager | `pip`, `poetry`, `pipenv`, `uv` |

## Build

| Tool | Command | Detection |
|------|---------|-----------|
| Docker | `docker compose build` | `Dockerfile` or `docker-compose.yml` present |
| pip install | `pip install -e .` | `setup.py` or `pyproject.toml` with `[build-system]` |
| Poetry | `poetry build` | `poetry.lock` present |
| None | Many Python projects have no explicit build step | No build config found |

## Test

| Runner | Command | Detection |
|--------|---------|-----------|
| pytest | `python -m pytest tests/ -v --tb=short` | `pytest.ini`, `conftest.py`, or `[tool.pytest]` in pyproject.toml |
| unittest | `python -m unittest discover -s tests` | `tests/test_*.py` without pytest config |
| tox | `tox` | `tox.ini` present |

### Markers / Tags
- Skip slow tests: `python -m pytest -m "not slow"`
- Integration only: `python -m pytest -m integration`
- Single file: `python -m pytest tests/test_<module>.py -v`

## Lint

| Tool | Command | Detection | Auto-fix |
|------|---------|-----------|----------|
| ruff | `ruff check .` | `[tool.ruff]` in pyproject.toml, `ruff.toml` | `ruff check . --fix` |
| flake8 | `flake8 .` | `.flake8`, `[flake8]` in setup.cfg | N/A |
| pylint | `pylint src/` | `.pylintrc`, `[tool.pylint]` | N/A |
| black (formatter) | `black --check .` | `[tool.black]` in pyproject.toml | `black .` |
| mypy (types) | `mypy .` | `[tool.mypy]` or `mypy.ini` | N/A |

**Preferred**: ruff (fast, replaces flake8 + isort + many others)

## Security

| Tool | Command | Detection |
|------|---------|-----------|
| bandit | `bandit -r . --exclude ./tests,./.venv -ll` | Common for Python projects |
| safety | `safety check` | `requirements.txt` present |
| pip-audit | `pip-audit` | Any pip-based project |

**Preferred**: bandit (code analysis) + pip-audit (dependency vulnerabilities)

## Code Conventions

### Style
- Python 3.10+ unless project specifies otherwise
- Use `match` statements where appropriate (3.10+)
- Type hints on public function signatures encouraged
- Docstrings on all public functions and classes
- Imports ordered: stdlib → third-party → project modules (one blank line between groups)
- No circular imports; use late imports inside functions if necessary

### Database Patterns
- Always close connections in `finally` blocks or use context managers
- SQL queries use `?` or `%s` parameterized placeholders — NEVER f-strings with user input
- Schema migrations should be idempotent (try/except around ALTER TABLE, CREATE IF NOT EXISTS)
- Include indexes on columns used in WHERE, JOIN, or ORDER BY

### Error Handling
- Catch specific exceptions, never bare `except:`
- Log errors with context (module, operation, relevant IDs)
- HTTP endpoints return proper status codes (400, 404, 500)
- Never silently swallow exceptions

## Hook Configuration

### pre_bash_guard — Additional Patterns
```python
(r"\bpip\s+install\s+(?!-r\b)(?!-e\b).*--", "Blocked: pip install with suspicious flags"),
```

### post_edit_lint
```python
LINT_COMMAND = ["ruff", "check", "--select", "E,F,W", "--quiet"]  # Adjust if project uses flake8/pylint
FILE_EXTENSIONS = [".py"]
```

## Permission Whitelist
```json
[
  "Bash(python -m pytest:*)",
  "Bash(ruff check:*)",
  "Bash(bandit:*)",
  "Bash(pip install -r:*)",
  "Bash(pip install -e:*)"
]
```

## Common Frameworks

| Framework | Type | Detection |
|-----------|------|-----------|
| FastAPI | Backend API | `fastapi` in requirements, `from fastapi import` |
| Django | Full-stack | `django` in requirements, `manage.py`, `settings.py` |
| Flask | Backend | `flask` in requirements, `from flask import` |
| SQLAlchemy | ORM | `sqlalchemy` in requirements |
| Celery | Task queue | `celery` in requirements |
