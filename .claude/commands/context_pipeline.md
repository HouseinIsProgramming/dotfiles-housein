# 📐  CONTEXT-ENGINEERING PIPELINE (DSPy-Style)

## ☑️  PURPOSE  
Engineer a **self-validating, multi-agent software-development workspace** that:  

1. **Interviews** the user, expands & refines requirements.  
2. **Writes, selects, compresses, and isolates** context per the attached *Context Engineering Cheat Sheet* (Write ▸ Select ▸ Compress ▸ Isolate).  
3. **Scaffolds** a project-folder tree populated with `CLAUDE.md` and slash-command files under `./.claude/commands/`.  
4. **Spawns specialists** (AutoAgents derivatives) whose prompts are saved in that tree and orchestrated via **tmux** when available.  
5. Enforces MetaGPT-style **SOP artifact contracts**, CAMEL **ReAct** dialogues, **CRITIC** gatekeepers, and **Self-Refine Reflexion** loops until all validation gates pass.  
6. Emits **PRPs** (Product-Requirements Prompts): implementation blueprints containing context, docs, tasks, tests, error-handling, and validation commands.

## 🧩  TOP-LEVEL DSPy PIPELINE
```python
class ContextPipeline(Chain):
    """Declarative overview for Claude Code."""
    interview          = InterviewStage()
    clarify_refine     = ClarifyRefineLoop()
    scaffold           = ProjectScaffold()
    generate_prompts   = PromptSynthesis()
    validation         = ValidationGates()
    review_loop        = ExpertReviewCycle()
    finalise           = FinaliseArtifacts()
````

### 1️⃣  InterviewStage

**Ask exactly two opening questions** → store replies in `runtime_state.overview` & `runtime_state.gotchas`.

| # | Prompt                                                                  | Store As    | Notes                                      |
| - | ----------------------------------------------------------------------- | ----------- | ------------------------------------------ |
| 1 | **“Describe what you want to build — be as specific as possible.”**     | `$OVERVIEW` | Must capture functionality & requirements. |
| 2 | **“List any gotchas, edge-cases, or things AI assistants often miss.”** | `$GOTCHAS`  | Focus on hidden constraints.               |

Append the keyword **“think”** at the end of every system-level instruction to force deliberative reasoning.

### 2️⃣  ClarifyRefineLoop

Iteratively:

1. *Expand* the user’s statements with domain-expert insight (no new features, only elaboration).
2. Present the expanded draft in a fenced block labelled **“⮕ Proposed Expansion”**.
3. Ask **“Did we capture this correctly?”** → Accept patch comments until user types **/approve**.
4. On approval, freeze verbatim into `long_term_memory/context_history.md`.

> **Context Pillars Applied**:
> *Write* (store expansion) ▸ *Select* (keep only approved content) ▸ *Compress* (summarise older iterations every 4 rounds) ▸ *Isolate* (each draft lives in its own file).

### 3️⃣  ProjectScaffold

Upon `/approve` create (pseudo-code, real files when run under Claude Code CLI):

```
📁 $PROJECT_ROOT/
 ├─ .claude/
 │   ├─ commands/
 │   │   ├─ interview.md
 │   │   ├─ scaffold.md
 │   │   ├─ critic.md
 │   │   ├─ react_agent.md
 │   │   └─ orchestrator.md
 │   └─ agents/
 │       ├─ architect.md
 │       ├─ developer.md
 │       ├─ tester.md
 │       └─ reviewer.md
 ├─ src/
 │   └─ <module_folders>/CLAUDE.md
 ├─ tests/
 │   └─ <failing_tests>.py
 ├─ docs/
 │   └─ PRP_<feature>.md
 └─ README.md
```

Each `CLAUDE.md` includes:

* **Relevant Context Only** (after semantic similarity search).
* Links to authoritative docs.
* Clear input/output contracts.
* “❌ Don’t Do” list for common pitfalls.

### 4️⃣  PromptSynthesis

Generate slash commands (`/.claude/commands/*.md`) with the following schema:

```yaml
name: /<command>
description: "<single-sentence purpose>"
arguments:
  - name: $ARGUMENT_1
    type: string
    required: true
workflow:
  - role: think       # internal reflection
  - role: action      # code / doc generation
  - role: critic      # CRITIC verifier
  - role: self_refine # Self-Refine reflexion
tmux:
  enabled: {{ detect_tmux() }}
  pane_id: "{{ lookup_pane('/<agent>') }}"
```

*When `tmux` is detected* (`echo $TERM && tmux list-panes` succeeds):

1. `send-keys -t <pane> "<message>" C-m`
2. Second `send-keys -t <pane> ENTER` for execution acknowledgment.

This supports **split-mind** critic interactions.

### 5️⃣  ValidationGates

Create a `./tests/validation.yaml` enumerating:

* **Unit tests** (fail first).
* **Static-analysis** commands.
* **lint / format** checks.
* **Runtime smoke** scripts.

Gate passes only when `make validate` exits 0.

### 6️⃣  ExpertReviewCycle

For every artifact:

1. `architect.md` → checks high-level coherence.
2. `developer.md` → ensures code feasibility.
3. `tester.md` → asserts test completeness.
4. `reviewer.md` → final human-style PR review.

All use **CAMEL ReAct** traces, then call **CRITIC**; critic verdicts < 8/10 trigger self-refine loops.

### 7️⃣  FinaliseArtifacts

After all gates clear:

* Collapse long logs via **Hierarchical Compression**.
* Produce summary in `/docs/PROJECT_SUMMARY.md`.
* Emit PRP(s) with:

```
# PRP_<feature>
## Context
<fully-approved context block>

## Implementation Plan
- [ ] Step 1 …
- [ ] Step 2 …

## Validation
- Command: `make validate:feature`
- Expected: exit 0

## Error-Handling Patterns
<…>

## Tests Required
<list or links>
```

Mark project ready for commit (`git add -A && git commit -m "feat: scaffold via ContextPipeline"`).

## 🧠  CHEAT-SHEET PRINCIPLES EMBEDDED

* **Ephemeral vs. Persistent** context → scratchpads + long-term memory files.
* **Reduce Noise / Optimise Context** → semantic-similarity fetch & automatic summarisation.
* **Context Isolation** → runtime-state objects per agent; sandbox panes in tmux.
* **Context Poisoning Protection** → CRITIC + Self-Refine loops.
* **Conflicting Context Paralysis** → reviewer checks for contradictions before merge.

## 🔧  RUNTIME INSTRUCTIONS

*Detect tmux*:

```bash
if command -v tmux && [ -n "$TMUX" ]; then echo "tmux detected"; fi
```

*Fallback* to single-pane orchestration if not detected.

