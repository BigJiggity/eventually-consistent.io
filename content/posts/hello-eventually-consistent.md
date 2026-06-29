+++
title = "Hello World! Welcome to Eventually Consistent"
date = 2026-06-19T00:00:00Z
draft = false
tags = ["meta"]
summary = "Why this blog exists and what I'll write about here."
+++

Welcome — glad you're here.

I'm John Reed, and I've spent 28 years building and running infrastructure —
SysAdmin to Cloud Architect, by way of a lot of 2 a.m. pages. A good chunk of
those years went to getting distributed databases to *agree* with each other:
Galera clusters, sharded MariaDB, replication that has to heal itself. So when I
named this blog **Eventually Consistent**, it wasn't only a cute distributed-
systems joke. It's the actual shape of the work — given enough time and enough
writes, the nodes converge. Opinions do too. So, it turns out, does good
engineering.

This is where I write up what I build and the tech worth explaining —
cryptography, distributed systems, infrastructure-as-code, and the agentic
tooling I now lean on every day. That last part is the throughline: after nearly
three decades doing this by hand, I'm all-in on building *with* AI — not as a
party trick, but on real Terraform, real architecture, real production. I'll show
you what that looks like up close, the wins and the faceplants both.

## What to expect

- **Project write-ups** — what I built, why, and what broke.
- **Deep dives** — Zen & the art of technology, people and tech, architecture, IaC patterns, other nerdery.
- **Tooling** — the small things that make the work faster (including plugins I've shipped, like [Cairn](https://github.com/BigJiggity/claude-plugins)).

## It supports the things I need

Code, with copy buttons and syntax highlighting:

```go
// low-S normalization: half the malleability problem, gone.
if s.Cmp(halfN) == 1 {
    s = new(big.Int).Sub(order, s)
}
```

Inline `code`, callouts, tables, and a table of contents on longer posts.

More to come...
