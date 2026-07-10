# E2 SEALED ANSWERS — judge only. Resuming session must NOT read this file.

1. Validate (via pre-registered eval) and then package the conductor
   brain/hands delegation skill for team sharing / possible open-sourcing —
   proving token tiering + lossless spec-tracked handoff.
2. dispatch/01 (references/routing.md, 152-line channel ops manual, accepted)
   and dispatch/02 (dispatch-gate hook prototype + tests, accepted).
3. hooks/dispatch-gate.sh (88 L) + tests/dispatch-gate.test.sh (87 L);
   11/11 tests PASS (brain independently re-ran; also settings.json grep = 0).
4. NO. v1 decision (user-confirmed) = skill-flow enforcement only; hook is a
   v2 PROTOTYPE, deliberately unregistered pending friction review; also
   stdin shape was structurally confirmed, not live-captured — capture a real
   Agent-tool payload before registering.
5. FAIL direction on the naive primary metric (C-brain 26,174 > S-brain
   20,308 output tokens; ≥40% reduction not met). Structural lesson: dispatch
   carries a fixed brain cost (dispatch file + adjudication + narration) that
   dominates at 60–175-line task scale; the savings thesis must be tested on
   larger, code-reading-heavy tasks (pair 2 requirement). Size-normalized
   (post-hoc, non-binding): C ~150 vs S ~226 tok/line.
6. int1 [08:59:07–08:59:43] (user mid-turn "ensure hands are not Fable" —
   model verification + routing-tree edit, 6,327 out) inside arm C; int2
   [09:02:17–09:02:44] (capability-first protocol revision, 2,009 out) inside
   arm S. Both are user-instruction handling, not arm work.
7. Capability-first: prefer the strongest available hand (Opus 4.8 default,
   1M-context class; pool includes Sonnet 5 / GLM 5.2) because a rework round
   costs more than the model-price delta; downshift only when rework risk ≈ 0;
   model param REQUIRED on every dispatch (omitted = silently inherits Fable).
8. None (no live blockers; pending user actions: /sync apply for ~/.claude
   changes; repo creation deferred until eval passes).
9. (a) Run eval pair 2 — a larger code-reading-heavy task pair (candidates:
   repo-A utility + product-app/product-app-2 backlog task), arms
   crossed S/C per pre-registration; (b) run E3 blind quality judging for
   BOTH pairs via provenance-stripped codex review.
10. Direct edits only for trivial ≤5-line changes (config value/typo/one-line
    fix); read-only consultations (reviews, second opinions, investigation
    sweeps) may use inline prompts without a DISPATCH file but their
    conclusions MUST be recorded in STATE.md or the relevant dispatch's
    Adjudication.
