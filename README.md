# eventually-consistent.io

Source for **Eventually Consistent** — a blog on cryptography, distributed
systems, infrastructure-as-code, and agentic tooling. Built with
[Hugo](https://gohugo.io/) + the [PaperMod](https://github.com/adityatelange/hugo-PaperMod)
theme, deployed to GitHub Pages via GitHub Actions.

## Publishing a post

```bash
# 1. create a draft (archetype pre-fills frontmatter)
hugo new posts/my-post-title.md

# 2. write it in content/posts/my-post-title.md, then flip draft to false
#    +++  draft = false  +++

# 3. preview locally (drafts included)
hugo serve -D            # http://localhost:1313

# 4. publish
git add content/posts/my-post-title.md
git commit -m "post: my post title"
git push                 # Actions builds + deploys automatically
```

Every push to `main` triggers `.github/workflows/hugo.yml`, which builds the
site and deploys it to Pages. No manual build step.

## Local setup

```bash
brew install hugo        # extended version (PaperMod needs it)
git clone --recurse-submodules git@github.com:BigJiggity/eventually-consistent.io.git
# already cloned without submodules?
git submodule update --init --recursive
```

## Structure

| Path | Purpose |
|---|---|
| `hugo.toml` | site config (title, menu, params, theme settings) |
| `content/posts/` | blog posts (one Markdown file each) |
| `content/about.md` · `archives.md` · `search.md` | static pages |
| `archetypes/default.md` | frontmatter template for `hugo new` |
| `themes/PaperMod/` | theme (git submodule — don't edit; override in `layouts/`) |
| `.github/workflows/hugo.yml` | build + deploy to Pages |

## Custom domain (optional)

The site currently publishes at
`https://bigjiggity.github.io/eventually-consistent.io/`. To use
`eventually-consistent.io`:

1. Add `static/CNAME` containing `eventually-consistent.io`.
2. Point DNS at GitHub Pages (A/AAAA records or a `CNAME` to
   `bigjiggity.github.io`).
3. Set the custom domain in repo **Settings → Pages**.
4. Update `baseURL` in `hugo.toml` to `https://eventually-consistent.io/`.

See `docs/writing-posts.md` for the full authoring guide (frontmatter, code,
images, tags).
