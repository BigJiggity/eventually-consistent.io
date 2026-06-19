# Writing posts

A practical guide to authoring on Eventually Consistent.

## Create a post

```bash
hugo new posts/nullifiers-explained.md
```

This copies `archetypes/default.md` and pre-fills the date. Edit the file under
`content/posts/`.

## Frontmatter

TOML frontmatter sits between `+++` fences at the top:

```toml
+++
title = "Nullifiers, explained"
date = 2026-06-19T00:00:00Z
draft = false                       # true = hidden from the published site
tags = ["zk", "cryptography"]
summary = "What a nullifier is and why double-voting can't happen."
+++
```

| Field | Notes |
|---|---|
| `title` | post heading + browser title |
| `date` | publish date; controls ordering |
| `draft` | `true` keeps it out of production builds; flip to `false` to publish |
| `tags` | drive the `/tags/` index; reuse existing tags where possible |
| `summary` | shown in post lists and meta description; write one |
| `cover` | optional image — `[cover]` table with `image = "img.png"` |
| `ShowToc` | per-post override of the table of contents (default on) |

## Body

Standard Markdown. Useful extras enabled in this site:

### Code

Fenced blocks get syntax highlighting + a copy button:

````markdown
```rust
fn nullifier(secret: Fr, election_id: Fr) -> Fr {
    poseidon([secret, election_id])
}
```
````

Specify the language after the opening fence for correct highlighting.

### Images

Put files in `static/` and reference them from root:

```markdown
![QBFT round](/img/qbft-round.png)
```

`static/img/qbft-round.png` → `/img/qbft-round.png`.

### Tables, quotes, lists

All standard Markdown. Raw HTML is allowed (`unsafe` rendering is on) for the
occasional `<details>` block or embed.

## Preview

```bash
hugo serve -D        # -D includes drafts; http://localhost:1313, live reload
```

## Publish

```bash
git add content/posts/nullifiers-explained.md static/img/...
git commit -m "post: nullifiers explained"
git push
```

The push triggers the Actions workflow, which builds and deploys to Pages in
about a minute. Watch it under the repo's **Actions** tab.

## Conventions

- One post per file, kebab-case filename → becomes the URL slug.
- Always set `summary` and at least one `tag`.
- Keep drafts as `draft = true` until ready; they won't leak to production.
- Prefer reusing existing tags over inventing near-duplicates.
