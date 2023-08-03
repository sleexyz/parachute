# Development Setup

## First steps

Install git hooks:
```
git config --local include.path ../.gitconfig
```

This is necessary since half of CI currently runs locally.


For post-commit artifact upload to work:

```
gcloud init
gcloud auth login
```
