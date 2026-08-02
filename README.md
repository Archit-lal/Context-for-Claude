# Context for Claude

Static site for Context for Claude. Plain HTML, no build step.

- `index.html` — the landing page
- `download.html` — post-download setup steps
- `thesis.html` — standalone essay, not linked from the site
- `favicon.svg` — the mark
- `.github/workflows/deploy.yml` — deploys to GitHub Pages on every push to `main`

Preview locally:

```sh
python3 -m http.server 8000
```
