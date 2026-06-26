+++
title = "Building Cairn: Wiring GSD, Beads, and Context-Mode Together"
date = 2026-06-19T00:00:00Z
draft = false
tags = ["claude", "tooling", "beads", "gsd", "cairn", "context-mode", "workflow"]
flashUpdated = true   # home-list "Updated" badge + pulse; clear when no longer fresh
summary = "How working with Claude reshaped my workflow, the two plugins I can't work without, and the plugin I built — now called Cairn — to make them, every issue tracker I touch, and my context-mode memory agree on one source of truth."
+++

> **Update — June 2026:** Since I first wrote this, the plugin got a real name —
> **[Cairn](https://github.com/BigJiggity/claude-plugins)** — and a third
> integration: it now makes [context-mode](https://github.com/mksglu/context-mode)'s
> memory *intent-aware*, not just GSD and Beads. The walkthrough below is the
> original; skip to [**Update: meet Cairn**](#update-meet-cairn) for what's new.
>
> **Newer still:** installing Cairn now pulls the *whole stack* — GSD and
> context-mode come with it as dependencies, and it bootstraps Beads on first
> run — and everything is driven from one `/cairn:` command surface. There's a
> full worked demo, too. Jump to
> [**Batteries included, one door in**](#update-batteries-included-one-door-in).

## Working with Claude changed how I work

I've been doing this for 28 years. I've watched a lot of "this changes everything"
tools come and go. Most didn't. Working with Claude did.

The shift wasn't that it writes code for me — it's that the *unit of work*
changed. I stopped thinking in keystrokes and started thinking in intent. I
describe what I want, Claude drafts it, I review and steer, and the loop is
fast enough that I stay in flow instead of context-switching into a dozen
tools. Speed went up, but more importantly the *friction* went down — the
tax I used to pay just to keep a project organized mostly disappeared.

As I leaned in, I started exploring the plugin ecosystem. Most plugins are
nice-to-haves. Two of them changed the way I run projects entirely:
**Beads** and **GSD**.

I needed both because I'm working solo right now. There's no team to hold the
shape of a project in their heads, no standup to surface what's half-finished,
no second set of eyes to catch the thread I dropped three days ago. When you're
the only one on a project, *you* are the single point of failure for keeping it
all straight — the plan, the open work, the decisions you made and why. That's
exactly the kind of bookkeeping that quietly eats a solo developer alive. I
didn't want a manager; I wanted the structure a good team gives you, without
the team. Beads became my memory for the work, and GSD became the discipline
that kept me from wandering — together they hold the project so I don't have to.

## Beads — issues that live where the work lives

[Beads](https://github.com/gastownhall/beads) (`bd`) is a local-first issue
tracker. No web app, no tab to babysit — issues live in a database right next
to your code and sync over your git remote. You drive it from the CLI (and so
does Claude):

```bash
bd ready              # what's available to work on
bd create "…"         # file an issue
bd update <id> --claim   # claim + mark in-progress
bd close <id>            # done
bd prime                 # full workflow context for an agent
```

What made it click for me: because the issues are *local and structured*,
Claude can read and write them directly as part of doing the work. The tracker
stops being a place I go to update status and becomes a byproduct of the work
itself. It even keeps a persistent memory (`bd remember`) so context survives
across sessions.

## GSD — turning intent into a plan, then into commits

[GSD](https://github.com/gsd-build/get-shit-done) ("Get Shit Done") is a planning workflow. Where
Beads tracks *what*, GSD structures *how*. It breaks a project into a roadmap
of phases and walks each phase through a disciplined loop:

```
discuss → plan → execute → verify → ship
```

Each phase gets its own context, a researched plan, and a verification pass
before anything is called done. The commands (`/gsd:new-project`,
`/gsd:plan-phase`, `/gsd:execute-phase`, `/gsd:ship`) gave me something I'd
never had consistently: a repeatable, spec-driven cadence that doesn't fall
apart the moment a project gets big. Decisions get captured. Plans get
checked. Work gets verified instead of just marked complete.

## The premise: make them work together — and with everyone else's tracker

Here's the thing. I had **two** great tools that didn't know about each other,
and a third problem on top: not everyone I work with lives in Beads. They live
in GitHub Issues. In Jira. In Asana. In Azure Boards.

So I had three jobs to reconcile:

1. GSD owned the *plan*. Beads owned the *work items*. They didn't talk.
2. Beads was my source of truth, but stakeholders needed to see status in the
   tool **they** already use.
3. I refused to double-enter anything. Updating an issue in three places by
   hand is exactly the friction Claude had just removed.

## How I got here

I started with Beads alone. It was great locally — but I kept wanting those
issues mirrored into **GitHub** so collaborators could follow along without me
narrating progress in Slack. So I started wiring Beads to GitHub by hand:
create an issue, also open a GitHub issue; close one, close the other. It
worked, and it was tedious, and tedious is a smell.

Then I found GSD, and the picture got bigger. Now I had real *phases* and real
*plans* — and it was obvious that each plan should close out the tracked work
it advanced. The plan and the issues wanted to be the same thing. That's when
the idea landed: stop hand-wiring this. Build a plugin that makes GSD and Beads
work together natively, and while I'm at it, make Beads mirror to *any* tracker
— not just GitHub.

## The plugin: `gsd-beads`

The result is a Claude Code plugin called **gsd-beads**. It's deliberately
*thin glue* — it doesn't fork or replace Beads or GSD, it just makes them
agree.

**Linking GSD to Beads.** Each GSD phase maps its requirements to bd issues
in a small map file; every issue carries a `phase-N` label; every plan declares
the bd IDs it advances in its frontmatter. So when a phase is executed, the
work it completes is claimed and closed in Beads automatically. The plan and
the tracker stay in lockstep.

**Mirroring Beads to everything else.** This is the part I'm happiest with.
The design is **hub-and-spoke**: Beads is the single source of truth, and every
external tool syncs to Beads — never tool-to-tool. That keeps the whole thing
sane no matter how many trackers you add.

```
            push  (on create / claim / close)
   bd  ───────────────────────────────────►  GitHub · GitLab · Jira · Asana · Azure
  (hub)                                              (spokes)
    ▲                                                   │
    └───────────────────────────────────────────────────┘
            pull  (on demand) — reconcile back into bd,
            last-writer-wins by timestamp, conflicts logged
```

Two directions:

- **Push** fires on Beads lifecycle events — create an issue, claim it, close
  it, and the matching item is created/updated/closed in every enabled tool.
- **Pull** runs on demand and reconciles edits made *in* those tools back into
  Beads, using last-writer-wins by timestamp. Genuine both-sides-changed cases
  get logged as conflicts for me to review instead of silently clobbered.

Each tool is a small **adapter** behind a uniform contract, so adding a new
tracker (Linear, Trello, whatever) is one file plus a config block — no changes
to the core. Five ship today: GitHub, GitLab, Jira, Asana, and Azure Boards.

Configuration lives in a committed `sync.json`, and — this matters — it only
ever stores the **names** of the environment variables that hold your API
tokens. No secrets on disk, ever:

```json
{
  "type": "jira", "enabled": true, "adapter": "jira",
  "config": {
    "base_url": "https://yourorg.atlassian.net",
    "project_key": "PROJ",
    "email_env": "JIRA_EMAIL",
    "token_env": "JIRA_API_TOKEN"
  }
}
```

Day to day, I barely think about it. I work in Beads (or let Claude do it as it
executes a GSD phase), and the right things show up in GitHub or Jira on their
own. When someone edits an issue on their end, a single `pull` brings it home.

## Where to get it

The plugin is open source (MIT) and lives here:

- **GitHub:** [github.com/BigJiggity/claude-plugins](https://github.com/BigJiggity/claude-plugins)
  (the `cairn` plugin under `cairn/` — see the update below on the rename)

Install it as a Claude Code marketplace:

```text
/plugin marketplace add BigJiggity/claude-plugins
/plugin marketplace add mksglu/context-mode    # cairn pulls context-mode from here
/plugin install cairn@bigjiggity               # GSD + context-mode install with it
```

> Installing Cairn now brings GSD and context-mode along automatically (they're
> declared dependencies) and bootstraps Beads on first run — see
> [**Batteries included**](#update-batteries-included-one-door-in) below. I'm also
> working on a one-click marketplace listing; until then, the commands above work
> today.

Full docs — architecture, the reconciliation algorithm, per-tool setup, and the
adapter contract for adding your own — are in
[`docs/sync.md`](https://github.com/BigJiggity/claude-plugins/blob/main/cairn/docs/sync.md).

## It works solo — and it scales to a team

I built this for a solo workflow, but the more I used it the more I realized the
design is *better* for teams, not just tolerable for them. The same properties
that keep one person straight are the ones that keep a group aligned.

Because Beads syncs over your git remote, a team already shares it the moment
they share the repo — no server to stand up, no SaaS seat to buy. Everyone
works locally, `bd ready` shows each person what's open, and claiming an issue
sets the assignee so two people don't grab the same thing. The tracker rides
along with the code instead of living in a separate tab nobody updates.

GSD gives the team the part that's hardest to maintain by hand: a *shared
cadence*. The roadmap and per-phase plans are the same artifact everyone works
from, decisions get captured in context instead of evaporating in chat, and
because each plan declares the bd issues it advances, the work that ships is the
work that gets closed. New teammates run `bd prime` and read the phase context
to get up to speed in minutes instead of pestering whoever has the project in
their head.

And the hub-and-spoke sync is where it really pays off for a group, because no
team lives entirely in one tool:

- Engineers stay in Beads (or let Claude drive it as it executes a phase).
- PMs and stakeholders watch **GitHub / Jira / Asana / Azure Boards** — whatever
  they already use — and never have to learn Beads.
- When someone updates a ticket on their side, a `pull` reconciles it back into
  Beads, so the canonical record stays correct without anyone double-entering.
- Mixed shops work too: front-end on a GitHub Project, the rest of the org on
  Jira — Beads is the hub, both are spokes, and they don't fight.

The net effect is the same thing it does for me solo, scaled up: nobody has to
be the human integration layer between the plan, the work, and whatever tracker
their teammates happen to prefer.

## Update: meet Cairn

A few weeks of living with this taught me two things, and both are now shipped.

**It earned a name.** `gsd-beads` described the wiring, not the idea. The idea is
a marker you stack as you go — one that both shows the trail *and* remembers the
path you took. So I renamed it **Cairn**. Plan → work → memory, stacked into one
marker; the metaphor wrote itself. The install id, the commands, and the state
dir moved with it:

```text
/plugin install cairn@bigjiggity
/cairn:init        # was /gsd-beads:init
```

**It learned to manage memory.** This is the part I'm most excited about. I'd
been leaning hard on [context-mode](https://github.com/mksglu/context-mode) — a
plugin that keeps raw tool output *out* of the conversation by compressing it
into a local, searchable knowledge base. Brilliant at compression, but
architecturally blind: it decides what to keep by size and age, not by what the
work actually needs. It'll just as happily surface a stale log as the one
compiler error that explains the bug in front of you.

Cairn already knew two things context-mode didn't — which Beads issue is active,
and which GSD phase you're in. So I wired them together. Now the compressed
memory is **scoped to intent**:

- Everything indexed while an issue is active gets labeled with that issue and
  phase (`gb/<bd_id>/<phase>`), so recall is filtered to the task in front of
  you instead of the whole session's noise.
- On a phase boundary — Execute → Verify, say — the active scope switches to the
  new phase, and the previous phase's noise drops out of the lens. Nothing is
  *deleted*: context-mode can only purge by whole session or whole project, so I
  never let it. Isolation is by label, not by destruction.
- When token usage crosses a threshold, Cairn nudges me to split the active
  issue into smaller sub-tasks — a natural context reset before the window
  starts to degrade.

So the stack is three deep now: **GSD** holds the phase, **Beads** holds the
task, and **context-mode** holds the memory of doing it — and Cairn is the
thread that makes the third one aware of the first two. It stays *thin glue*:
opt in per repo, scope by label, never delete.

The full write-up of the memory layer — the convention, the capability
boundaries, and an honest list of what context-mode can and can't do — is in
[`docs/context.md`](https://github.com/BigJiggity/claude-plugins/blob/main/cairn/docs/context.md).

## Update: batteries included, one door in

Two more rounds of polish since the rename, and they're the ones that change the
day-to-day most.

### One install, the whole stack

For a while, getting started meant a chore list: install GSD, install Beads,
install context-mode, *then* wire them. That's exactly the friction this whole
project exists to kill — so I killed it. Cairn now **declares GSD and
context-mode as dependencies**. Install Cairn and Claude pulls them in for you;
the first time you open a project it offers to install the `bd` binary too. Then
one command does the rest:

```text
/plugin marketplace add mksglu/context-mode   # one-time: where context-mode lives
/plugin install cairn@bigjiggity              # GSD + context-mode come with it
/cairn:init                                   # git + beads + first project, soup to nuts
```

While I was in there, context-mode graduated from an opt-in extra to a
**default**. Intent-aware memory used to be a per-repo switch; now it's just on.
The whole triad — plan, work, memory — comes alive the moment Cairn is installed.

### One door in: the `/cairn:` interface

The other thing that nagged me: I was still juggling three vocabularies. `bd`
for tickets, `/gsd:*` for planning, `ctx_*` for memory. My fingers had to know
which tool owned which verb. So I put one door in front of all of it.

Everything now lives under `/cairn:`. The workflow verbs each drive the
*combined* lifecycle, so you think in the work, not the tooling:

```text
/cairn:new          # plan the project + file every requirement as a ticket
/cairn:plan 1       # plan a phase
/cairn:work 1       # claim its tickets, execute, close them on success
/cairn:status       # what's ready, what's blocked, where the roadmap stands
/cairn:remember …   # …and /cairn:recall … — memory, scoped to the active task
/cairn:ship         # won't ship with open tickets on a finished phase
```

A curated set of verbs can't cover *everything* three tools do, so there are
escape hatches — `/cairn:bd`, `/cairn:gsd`, `/cairn:ctx` pass straight through to
the raw tool. Nothing's locked away, and Cairn doesn't drift every time one of
them grows a new command. `/cairn:help` prints the whole map.

### A demo you can actually read

Talking about a workflow only goes so far, so I built a real thing with it and
wrote down every step. **wedding-register** is a small 3-tier AWS app — a React
front end, a Node/Express API, MySQL, with the infrastructure as OpenTofu modules
wired by Terragrunt (WAF, an ALB, an EC2 auto-scaling group, RDS). Nothing fancy;
the *point* is the workflow around it.

Every requirement became a Beads ticket across three phases, with real
dependencies — you can't stand up the load balancer before the network, security
groups, and database exist, and Beads knows it. Each ticket is mirrored to a
public GitHub repo's Issues, carrying its phase label, so the hub-and-spoke sync
isn't a diagram in a blog post — it's ten live issues you can click.

- **The repo:** [github.com/BigJiggity/wedding-register](https://github.com/BigJiggity/wedding-register)
- **The walkthrough:** [`HOWTO-CAIRN.md`](https://github.com/BigJiggity/wedding-register/blob/main/HOWTO-CAIRN.md) — the exact commands, start to ship.

### So what does this actually buy you?

**If you're a solo dev:** one install, one command surface, and the
plan-work-memory triad on by default. You stop being the integration layer
between your planner, your tracker, and your own memory — and you stop paying a
setup tax every time you start something new. `/cairn:init` to a planned, tracked
project in about a minute.

**If you're on a team:** the same, plus the part teams actually feel. Beads rides
along in the repo, so cloning *is* onboarding — one install brings the whole
stack, and `bd prime` plus the phase context gets a new teammate productive
without a single "can you walk me through the project?" The GitHub linking lets
your PM watch real issues move without ever learning Beads, and nobody
double-enters status. The plan everyone works from, the work that ships, and the
issues that close are the *same* artifacts — which is the alignment a team
usually pays a process tax to fake.

It's still thin glue. It still doesn't fork or replace anything. It just means
the trail is marked, the path is remembered, and there's one marker to follow —
whether it's just you out there or the whole crew.

## Why this matters to me

The whole reason Claude changed my workflow is that it removed friction between
*intent* and *done*. GSD and Beads each remove a different slice of that
friction. Wiring them together — and out to wherever my collaborators
actually live — removed the last bit I was still paying by hand.

Opinions converge over time. So, apparently, do issue trackers.
