#!/usr/bin/env python3
"""Add/update/sync a localized key across every NFC-Tools/<lang>.lproj/Main.strings file.

Used by the `/localize` skill. Run from the repository root.

Commands:
  langs                       List the target language codes (one per line).
  check <key>                 Print languages whose Main.strings is MISSING <key>.
  get <key>                   Print the current value of <key> in every language.
  set <key> --json <file>     Write <key>=value into each language's Main.strings,
                              taking values from a JSON map {"<lang>": "<value>", ...}.
                              Overwrites if the key exists, appends otherwise.

Notes:
  - All Main.strings files are UTF-8.
  - Entries are written as:  "key" = "value";
  - Double quotes / backslashes in values are escaped automatically.
"""

import argparse
import glob
import json
import os
import re
import sys

STRINGS_GLOB = "NFC-Tools/*.lproj/Main.strings"


def lang_files():
    """Return {lang_code: path} for every Main.strings, excluding Base.lproj."""
    out = {}
    for path in sorted(glob.glob(STRINGS_GLOB)):
        lproj = os.path.basename(os.path.dirname(path))  # e.g. "ja.lproj"
        lang = lproj[:-len(".lproj")] if lproj.endswith(".lproj") else lproj
        if lang == "Base":
            continue
        out[lang] = path
    return out


def escape(value):
    return value.replace("\\", "\\\\").replace('"', '\\"')


# Matches:  "key" = "value";   (value may contain escaped quotes)
def key_pattern(key):
    return re.compile(
        r'^[ \t]*"' + re.escape(key) + r'"[ \t]*=[ \t]*"(?:[^"\\]|\\.)*"[ \t]*;[ \t]*$',
        re.MULTILINE,
    )


def read_value(text, key):
    m = re.search(
        r'"' + re.escape(key) + r'"[ \t]*=[ \t]*"((?:[^"\\]|\\.)*)"[ \t]*;',
        text,
    )
    return m.group(1) if m else None


def cmd_langs(_args):
    for lang in lang_files():
        print(lang)


def cmd_check(args):
    missing = []
    for lang, path in lang_files().items():
        with open(path, encoding="utf-8") as f:
            text = f.read()
        if not key_pattern(args.key).search(text):
            missing.append(lang)
    if missing:
        print("MISSING '%s' in: %s" % (args.key, ", ".join(missing)))
        sys.exit(1)
    print("OK: '%s' present in all %d languages." % (args.key, len(lang_files())))


def cmd_get(args):
    for lang, path in lang_files().items():
        with open(path, encoding="utf-8") as f:
            val = read_value(f.read(), args.key)
        print("%-8s %s" % (lang, "<missing>" if val is None else '"%s"' % val))


def cmd_set(args):
    with open(args.json, encoding="utf-8") as f:
        values = json.load(f)
    files = lang_files()

    unknown = [k for k in values if k not in files]
    if unknown:
        print("ERROR: JSON has unknown language codes: %s" % ", ".join(unknown),
              file=sys.stderr)
        print("Run 'langs' to see valid codes.", file=sys.stderr)
        sys.exit(2)

    missing_from_json = [l for l in files if l not in values]
    if missing_from_json:
        print("WARNING: JSON missing translations for: %s"
              % ", ".join(missing_from_json), file=sys.stderr)

    updated, added = 0, 0
    for lang, value in values.items():
        path = files[lang]
        with open(path, encoding="utf-8") as f:
            text = f.read()
        entry = '"%s" = "%s";' % (args.key, escape(value))
        pat = key_pattern(args.key)
        if pat.search(text):
            text = pat.sub(entry, text, count=1)
            updated += 1
        else:
            if text and not text.endswith("\n"):
                text += "\n"
            text += entry + "\n"
            added += 1
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)

    print("Done '%s': %d updated, %d added across %d languages."
          % (args.key, updated, added, len(values)))


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("langs").set_defaults(func=cmd_langs)

    p = sub.add_parser("check")
    p.add_argument("key")
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("get")
    p.add_argument("key")
    p.set_defaults(func=cmd_get)

    p = sub.add_parser("set")
    p.add_argument("key")
    p.add_argument("--json", required=True, help="JSON map {lang: value}")
    p.set_defaults(func=cmd_set)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
