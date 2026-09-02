#!/usr/bin/env python3
"""Format QML via the same qmlls binary the VS Code Qt/QML extension uses,
so CLI formatting and editor format-on-save can never disagree.

Usage: qmlformat.py [--check] file.qml ...
    default: rewrite files in place
    --check: report only, exit 1 if any file would change
"""
import json
import os
import subprocess
import sys

QMLLS_CANDIDATES = [
    "~/.config/Code/User/globalStorage/theqtcompany.qt-qml/qmlls/files/qmlls",
    "~/.config/Code - OSS/User/globalStorage/theqtcompany.qt-qml/qmlls/files/qmlls",
    "~/.config/VSCodium/User/globalStorage/theqtcompany.qt-qml/qmlls/files/qmlls",
]


def find_qmlls():
    """QMLLS env wins; otherwise first editor-bundled binary found."""
    env = os.environ.get("QMLLS")
    if env:
        return env
    for cand in QMLLS_CANDIDATES:
        path = os.path.expanduser(cand)
        if os.path.isfile(path):
            return path
    sys.exit(
        "qmlls not found in VS Code, Code - OSS or VSCodium extension storage "
        "(set QMLLS env to point at a qmlls binary)"
    )

GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
BOLD = "\033[1m"
RESET = "\033[0m"


class QmlsClient:
    def __init__(self, binary):
        if not os.path.isfile(binary):
            sys.exit(f"qmlls not found at {binary}")
        self.proc = subprocess.Popen(
            [binary],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        self._id = 0

    def send(self, method, params, notification=False):
        msg = {"jsonrpc": "2.0", "method": method, "params": params}
        if not notification:
            self._id += 1
            msg["id"] = self._id
        data = json.dumps(msg).encode()
        self.proc.stdin.write(b"Content-Length: %d\r\n\r\n" % len(data) + data)
        self.proc.stdin.flush()
        return None if notification else self._id

    def read(self):
        length = 0
        while True:
            line = self.proc.stdout.readline()
            if not line:
                raise RuntimeError("qmlls exited unexpectedly")
            if line in (b"\r\n", b"\n"):
                break
            key, _, value = line.decode().partition(":")
            if key.strip().lower() == "content-length":
                length = int(value.strip())
        return json.loads(self.proc.stdout.read(length))

    def request(self, method, params):
        rid = self.send(method, params)
        while True:
            msg = self.read()
            if msg.get("id") == rid:
                return msg


def apply_edits(text, edits):
    lines = text.split("\n")
    starts = [0]
    for line in lines:
        starts.append(starts[-1] + len(line.encode("utf-16-le")) // 2 + 1)

    def pos(p):
        return (starts[p["line"]] + p["character"]) * 2

    buf = text.encode("utf-16-le")
    for e in sorted(edits, key=lambda e: pos(e["range"]["start"]), reverse=True):
        buf = buf[: pos(e["range"]["start"])] + e["newText"].encode("utf-16-le") + buf[pos(e["range"]["end"]) :]
    return buf.decode("utf-16-le")


def start_client():
    client = QmlsClient(find_qmlls())
    client.request("initialize", {"processId": os.getpid(), "rootUri": None, "capabilities": {}})
    client.send("initialized", {}, notification=True)
    return client


def format_file(client, path, text):
    """Returns formatted text, original text if no edits, or None if qmlls died."""
    uri = "file://" + path
    client.send(
        "textDocument/didOpen",
        {"textDocument": {"uri": uri, "languageId": "qml", "version": 1, "text": text}},
        notification=True,
    )
    try:
        resp = client.request(
            "textDocument/formatting",
            {"textDocument": {"uri": uri}, "options": {"tabSize": 4, "insertSpaces": True}},
        )
    except RuntimeError:
        return None
    client.send("textDocument/didClose", {"textDocument": {"uri": uri}}, notification=True)
    if resp.get("error") or not resp.get("result"):
        return text
    return apply_edits(text, resp["result"])


def main():
    check = "--check" in sys.argv
    files = [os.path.abspath(f) for f in sys.argv[1:] if not f.startswith("-")]
    if not files:
        sys.exit(__doc__)

    client = start_client()
    changed = []
    for path in files:
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
        rel = os.path.relpath(path)

        new = format_file(client, path, text)
        if new is None:
            print(f"  {YELLOW}SKIPPED{RESET}: {rel} (qmlls died mid-session, exit {client.proc.poll()}; retrying)")
            client = start_client()
            new = format_file(client, path, text)
            if new is None:
                print(f"  {YELLOW}SKIPPED{RESET}: {rel} (qmlls died again, exit {client.proc.poll()})")
                client = start_client()
                continue
        if new != text:
            changed.append(rel)
            if check:
                print(f"  {YELLOW}FORMAT DIFF{RESET}: {rel}")
            else:
                with open(path, "w", encoding="utf-8") as fh:
                    fh.write(new)
                print(f"  {GREEN}Formatted{RESET}: {rel}")

    if check:
        if changed:
            print(f"{BOLD}{len(changed)} file(s) need formatting; run scripts/dev/format.sh{RESET}")
            sys.exit(1)
        print(f"  {GREEN}All files formatted correctly.{RESET}")


if __name__ == "__main__":
    main()
