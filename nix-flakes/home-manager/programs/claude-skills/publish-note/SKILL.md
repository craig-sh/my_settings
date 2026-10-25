---
name: publish-note
description: Write a summary, research write-up, or reference page into the personal notes repo and push it so it appears on https://notes.localdomain. Use when the user asks to save, publish, write up, or add something to their notes / notes site, or to update an existing note.
---

# Publish a note

The notes site is a Zensical static site built from the `craig-sh/notes` repo
on the local Forgejo. beelink pulls `main` every ~2 minutes and rebuilds, so a
push is all it takes to publish.

## 1. Get an up-to-date clone

```bash
NOTES_DIR="$HOME/.local/share/notes-repo"
if [ -d "$NOTES_DIR/.git" ]; then
  git -C "$NOTES_DIR" pull --rebase --quiet
else
  git clone ssh://git@git.localdomain:2222/craig-sh/notes.git "$NOTES_DIR"
fi
```

## 2. Follow the repo's conventions

Read `$NOTES_DIR/AGENTS.md` before writing anything. It is the source of truth
for where pages go, required front matter, supported markdown, and commit
message format, and it may have changed since this skill was written.

Then look at what already exists (`find "$NOTES_DIR/docs" -name '*.md'`):

- If a page on the same topic exists, update it instead of adding a near-duplicate.
- Otherwise reuse the closest existing section folder; only create a new one if nothing fits.
- If the right section or whether to update vs. create is genuinely unclear, ask the user.

## 3. Write the page

- Write for a future reader with no access to this conversation: state the
  question or context up front, then the findings or decisions, then details.
- Never include secrets, tokens, passwords, or private keys, even if they
  appeared in the conversation.
- Cite web sources in a `## Sources` section as markdown links.

## 4. Check the build (when the page uses anything beyond plain markdown)

```bash
podman run --rm -v "$NOTES_DIR:/docs" docker.io/zensical/zensical build
```

Fix any warnings that mention the new or changed page. `site/` and `.cache/`
are gitignored, so leave them.

## 5. Commit and push

```bash
git -C "$NOTES_DIR" add docs/
git -C "$NOTES_DIR" commit -m "<section>: <what changed>"
git -C "$NOTES_DIR" push
```

If the push is rejected because the remote moved, `git pull --rebase` and push
again. Do not force-push.

## 6. Report back

Give the user the page URL. With directory URLs, `docs/research/foo.md` is
served at `https://notes.localdomain/research/foo/` (and `docs/x/index.md` at
`https://notes.localdomain/x/`). Mention it will be live within a couple of
minutes.
