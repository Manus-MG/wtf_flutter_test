# AI Ledger

Record every meaningful AI-assisted step here.

## Entry format

- Prompt #
- Tool/model used
- Intent
- Output summary or snippet
- Commit/branch reference
- Notes about how the output was adapted

## Starter entries

1. Initial assessment analysis and scaffold planning
   - Tool/model: Copilot planning + workspace exploration
   - Intent: identify the required repo structure and first implementation steps
   - Output: mono-repo layout, shared package, token server, docs, and app shells
   - Commit: _pending_
   - Notes: used to define the starter workspace

2. Repository scaffold implementation
   - Tool/model: Copilot workspace editing
   - Intent: create the initial mono-repo folder structure and starter files
   - Output: `wtf_flutter_test/` with root docs, shared package, both app shells, and token server scaffold
   - Commit: _pending_
   - Notes: aligned the folder layout to the assessment brief and removed accidental top-level duplicates

3. Shared package validation
   - Tool/model: Copilot + Flutter test run
   - Intent: verify serialization helpers and date validation
   - Output: shared package tests passed after adding `flutter_test` to dev dependencies
   - Commit: _pending_
   - Notes: confirmed the shared model scaffold is runnable

4. App smoke validation
   - Tool/model: Copilot + Flutter test run
   - Intent: verify the Guru and Trainer app shells boot cleanly
   - Output: both app smoke tests passed
   - Commit: _pending_
   - Notes: confirms the initial app skeleton is stable
