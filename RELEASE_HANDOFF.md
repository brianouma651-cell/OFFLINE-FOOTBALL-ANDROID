# Offline Football Android — consolidated source handoff

This ZIP is laid out as a Git repository root: `project.godot`, `scripts/`, `scenes/`, tests, Windows CMD helpers, and `.github/workflows/android.yml` are at the top level.

## Included game systems

- Godot 4.3 project, 3D match scene and cumulative gameplay source through Stage 26.
- Offline exhibition and career play, club/squad management, transfers, local save/load, league fixtures and results, standings, and season honours archive.
- Four local clubs and the existing match controls and tactics systems.
- Fourteen stage source-regression scripts (`tests_stage13.py` through `tests_stage26.py`).
- `VERIFY_SOURCE.cmd` for Windows source checks.
- `BUILD_ANDROID_DEBUG.cmd` for local Godot import/startup and Android debug export.
- GitHub Actions workflow that runs source tests, installs Java 17 and Android SDK components, imports and starts the Godot project headlessly, exports an Android debug APK, and uploads it as a workflow artifact.

## Windows CMD: verify source

From this extracted folder:

```cmd
VERIFY_SOURCE.cmd
```

Or run the tests directly:

```cmd
for %f in (tests_stage*.py) do @python "%f" || exit /b 1
```

## GitHub: push the project

Create or use an empty GitHub repository. Open CMD in this folder and run:

```cmd
git init
git branch -M main
git add .
git commit -m "Import consolidated offline football project"
git remote add origin https://github.com/USERNAME/REPOSITORY.git
git push -u origin main
```

Replace the remote URL with the actual repository URL. If this folder is already a clone, do not run `git init` or add a second remote; use `git add .`, `git commit`, and `git push` as appropriate.

## Android APK build

A push to `main`/`master`, or manual `workflow_dispatch`, starts `.github/workflows/android.yml`. On success, download `Offline-Football-Android-debug-APK` from the run's Artifacts section. The workflow must complete successfully before an APK can be claimed as built.

For local Windows export, install Godot 4.3, matching Android export templates, Android SDK command-line tools/platform/build-tools/NDK/CMake, and Java 17; configure the SDK and JDK paths in Godot Editor Settings, then run `BUILD_ANDROID_DEBUG.cmd`.

## Validation honesty

The fourteen Python source-regression scripts passed when this archive was assembled. ZIP integrity and the workflow's YAML structure are checked during packaging. This environment has not executed the Windows CMD scripts, run the Godot editor/runtime, exported the APK, or installed it on a phone. GitHub Actions is configured to perform the Godot import/startup and APK export checks; those results remain pending until the workflow runs successfully. Passing source tests alone does not prove that every gameplay feature behaves correctly in-engine.

The game itself is designed for offline play and does not require a game server, online account, or internet connection after installation. Internet access is needed to download development tools and GitHub artifacts during the build process.
