+++
title = "Hello World! Welcome to Eventually Consistent"
date = 2026-06-19T00:00:00Z
draft = false
tags = ["meta"]
summary = "Why this blog exists and what I'll write about here."
+++

Welcome — glad you're here. Short version: this is where I write up what I
build and the tech worth explaining — cryptography, distributed systems,
infrastructure-as-code, and the agentic tooling I lean on day to day.

The name is a distributed-systems joke, and a bit of a promise: the opinions
here converge over time.

## What to expect

- **Project write-ups** — what I built, why, and what broke.
- **Deep dives** — Zen & the art of Technology, People and Tech, Architecture, IAC patterns, other Nerdery.
- **Tooling** — the small things that make the work faster.

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
