# Stage 20 — Focused squad development

## Additions
- Adds six selectable training focuses: Balanced, Fitness, Attacking, Passing, Defending, and Goalkeeping.
- Specialist sessions spend KSh 10,000 and improve the selected team attribute by two points, capped at 99.
- Fitness sessions restore 20 fitness points to each squad member, capped at 100.
- Balanced sessions retain broad one-point attribute development and modest fitness recovery.
- The selected focus is displayed in Club Management and saved in the local career file.
- Older career saves safely default to Balanced; invalid saved focus values are normalized.
- Career reset returns the training focus to Balanced.

## Validation
- `tests_stage13.py` through `tests_stage20.py` all pass as source-level regression checks.
- ZIP archive integrity is checked during packaging.
- Godot 4 parsing, runtime gameplay, Android export, and physical-device testing remain pending. This is a cumulative source package, not an APK.
