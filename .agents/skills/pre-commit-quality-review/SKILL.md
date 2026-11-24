---
name: pre-commit-quality-review
description: Use before committing substantial code changes to review structural quality, layering, duplication, and verification gaps.
---

# Pre-commit Quality Review

- Review the intended commit snapshot, not unrelated dirty work.
- Check boundaries: UI vs state vs data, feature ownership, manager/bootstrap responsibilities.
- Report only concrete issues introduced or worsened by the change.
- Verify with required checks before claiming done: `flutter pub get` when needed, `flutter analyze`, covering `flutter test`.
- Do not add `Co-authored-by` agent trailers.
