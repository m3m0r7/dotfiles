# IMAP Search Reference

Use server-side IMAP SEARCH to reduce the amount of private mail fetched. Terms
on the same level are combined with implicit AND.

## Common keys

| Intent | Query form |
| --- | --- |
| Every message | `ALL` |
| Unread messages | `UNSEEN` |
| Sender contains text | `FROM "<sender>"` |
| Recipient contains text | `TO "<recipient>"` |
| Subject contains text | `SUBJECT "<keywords>"` |
| Header or body contains text | `TEXT "<keywords>"` |
| Body contains text | `BODY "<keywords>"` |
| On or after a date | `SINCE <DD-Mon-YYYY>` |
| Before a date | `BEFORE <DD-Mon-YYYY>` |
| Exclude a condition | `NOT <search-key>` |
| Either condition | `OR <search-key-1> <search-key-2>` |

`BEFORE` is exclusive and `SINCE` is inclusive. Use English month names such as
`Jan`, `Feb`, and `Dec`. To search one calendar day, combine `SINCE` with the
following day's `BEFORE`.

Examples without identity-specific values:

```text
FROM "<sender>" SINCE <DD-Mon-YYYY>
SUBJECT "<keywords>" SINCE <DD-Mon-YYYY> BEFORE <DD-Mon-YYYY>
OR SUBJECT "<first term>" SUBJECT "<second term>"
TEXT "<keywords>" NOT FROM "<excluded sender>"
```

## Non-ASCII and provider extensions

For standard IMAP servers, prefix a non-ASCII query with `CHARSET UTF-8`, for
example `CHARSET UTF-8 TEXT "<non-ASCII keywords>"`. Server support varies.

Gmail-compatible servers may support `X-GM-RAW "<web search expression>"`.
Use it only when the configured server supports that extension. Prefer standard
keys when they express the request because they are portable.

## Quoting rules

- Pass the entire query as one shell argument after `--query`.
- Wrap the shell argument in single quotes and IMAP string values in double
  quotes.
- Escape a literal double quote or backslash inside an IMAP quoted string.
- Never add a newline, carriage return, or NUL byte to a query.
- Start with a selective date or identity term rather than `ALL` when possible.

The local CLI returns the highest matching UIDs first and applies the limit per
account and mailbox. UID order usually follows arrival order; use message dates
from the manifest when exact chronology matters.
