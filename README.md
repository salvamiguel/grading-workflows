# Grading Workflows

Reusable GitHub Actions for automated grading of DevOps exercises. These composite actions provide validation checks that run inside CI, producing tamper-resistant official grades while giving students clear, actionable feedback.

## Architecture

This repo is the **professor's private grading infrastructure**. Student repos contain thin caller workflows that reference these reusable actions. Students cannot modify the grading logic since it lives here.

```
grading-workflows/
├── .github/actions/
│   ├── tf_check_fmt.yaml        # Terraform formatting check
│   ├── tf_check_validity.yaml   # Terraform init + validate
│   ├── tf_check_lint.yaml       # TFLint best practices
│   └── gh_action_lint.yaml      # GitHub Actions workflow linting
└── config/
    └── .tflint.hcl              # TFLint rules (copied to student repo at runtime)
```

## Available Actions

### Terraform

| Action | Stage | What it checks |
|--------|-------|----------------|
| `tf_check_fmt` | 1 - Format | Canonical HCL formatting via `terraform fmt -check` |
| `tf_check_validity` | 2 - Validity | Syntax, types, and internal consistency via `terraform init -backend=false` + `terraform validate` |
| `tf_check_lint` | 3 - Best Practices | Naming conventions, documented/typed variables, and recommended rules via TFLint |

### GitHub Actions

| Action | What it checks |
|--------|----------------|
| `gh_action_lint` | YAML syntax (yamllint) and workflow-specific validation — expression types, action I/O, shell scripts, cron syntax, security issues (actionlint) |

## Usage

Reference these actions from a student repo's caller workflow:

```yaml
name: Autograding
on:
  push:
    branches: [main]

jobs:
  grade-terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v4

      - name: Check Formatting
        uses: professor-org/grading-workflows/.github/actions/tf_check_fmt@main

      - name: Check Validity
        uses: professor-org/grading-workflows/.github/actions/tf_check_validity@main

      - name: Check Lint
        uses: professor-org/grading-workflows/.github/actions/tf_check_lint@main

  grade-workflow:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint Workflow
        uses: professor-org/grading-workflows/.github/actions/gh_action_lint@main
        with:
          workflow_path: .github/workflows/ci.yml
```

> **Note:** Terraform setup is done once in the workflow job, not inside each action.

## Anti-Cheating

- **Branch protection** with required status checks prevents bypassing CI.
- **API verification** confirms student repos actually called the correct reusable workflow.
- **Post-deadline re-grading** as a final backstop catches any evasion.

See the full architecture in [.claude/CLAUDE.md](.claude/CLAUDE.md).
