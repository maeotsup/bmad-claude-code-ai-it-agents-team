# Django — Framework Knowledge

**Applies to**: Python projects with `django` in requirements
**Type**: Full-stack web framework

## Detection Signals

- `django` in requirements.txt, pyproject.toml, or Pipfile
- `manage.py` in project root
- `settings.py` or `settings/` directory
- `urls.py`, `views.py`, `models.py` file patterns

## Run

| Action | Command |
|--------|---------|
| Dev | `python manage.py runserver` |
| Migrations | `python manage.py makemigrations` → `python manage.py migrate` |
| Shell | `python manage.py shell` |
| Static | `python manage.py collectstatic` |

## Additional Rules (extend Python rules)

### Project Structure
- App-based architecture: one app per domain concern
- `models.py` for data models, `views.py` for handlers, `urls.py` for routing
- `serializers.py` for API serialization (Django REST Framework)
- `forms.py` for HTML form handling
- `admin.py` for admin interface registration
- Keep apps focused — split when they grow beyond a single concern

### Models
- All models inherit from `models.Model`
- Use explicit `related_name` on ForeignKey and M2M fields
- Add `__str__` method for admin/debug readability
- Add `class Meta` for ordering, constraints, verbose names
- Index fields used in filters: `db_index=True` or `class Meta: indexes`

### Views
- Class-based views (CBV) for CRUD: `ListView`, `DetailView`, `CreateView`
- Function-based views (FBV) for custom logic
- Django REST Framework: `ViewSet` and `Serializer` for APIs
- Use `@login_required` or `LoginRequiredMixin` for auth
- Return `JsonResponse` for API endpoints, `render()` for templates

### Migrations
- Always run `makemigrations` after model changes
- Never edit migration files unless resolving conflicts
- Migrations are sequential and must be committed to version control
- Use `RunPython` for data migrations (separate from schema migrations)
- Test that `migrate` runs forward and backward cleanly

### Templates
- Django template language (DTL) with auto-escaping by default
- Template inheritance: `{% extends "base.html" %}` + `{% block content %}`
- Never use `{{ value|safe }}` with user-provided content
- Static files: `{% load static %}` → `{% static 'path/to/file' %}`

### Security
- CSRF protection is enabled by default — include `{% csrf_token %}` in all forms
- Use Django's ORM — it parameterizes queries automatically
- `SECRET_KEY` must never be committed; use environment variables
- `ALLOWED_HOSTS` must be configured for production
- Set `SECURE_SSL_REDIRECT`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE` in production
- Never use `extra()` or `raw()` with unsanitized user input

### Testing
- `django.test.TestCase` for database-backed tests (auto transaction rollback)
- `django.test.Client` for view/endpoint testing
- `pytest-django` for pytest-style tests (recommended)
- Factory Boy for test data generation
- Test models, views, and serializers separately

### Settings
- Base settings in `settings.py`, environment overrides via `environ` or `django-environ`
- `DEBUG = False` in production (always)
- Separate `DATABASES` config for test vs production
