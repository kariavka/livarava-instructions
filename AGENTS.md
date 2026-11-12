# Global instructions

Shared instruction files live in `/home/smart/livarava-instructions/`. Read the relevant
`*.instructions.md` files for the work being performed; each file declares its
scope in its front matter. Update the canonical files here.

# Assistant message formatting

Use Markdown in assistant responses when it improves readability: emphasize key recommendations and labels with bold, and use paragraphs, lists, links, tables, and code blocks as appropriate. When implementing assistant/chat interfaces, render assistant message Markdown with a maintained parser and safe defaults, preserving paragraph breaks and tables. Keep user messages literal and preserve the original Markdown when copying. If an API requires JSON, keep the envelope valid and put Markdown only inside the response content string.
