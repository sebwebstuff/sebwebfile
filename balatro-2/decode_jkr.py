import argparse
import json
import re
import sys
import zlib
from pathlib import Path


class LuaParseError(Exception):
    pass


class LuaParser:
    def __init__(self, text: str):
        self.text = text
        self.length = len(text)
        self.index = 0

    def parse(self):
        self._skip_ws()
        value = self._parse_value()
        self._skip_ws()
        if self.index != self.length:
            raise LuaParseError(f"Unexpected trailing data at index {self.index}")
        return value

    def _peek(self):
        if self.index >= self.length:
            return ""
        return self.text[self.index]

    def _consume(self, expected=None):
        if self.index >= self.length:
            raise LuaParseError("Unexpected end of input")
        char = self.text[self.index]
        if expected is not None and char != expected:
            raise LuaParseError(f"Expected '{expected}' but got '{char}' at index {self.index}")
        self.index += 1
        return char

    def _skip_ws(self):
        while self.index < self.length and self.text[self.index].isspace():
            self.index += 1

    def _parse_value(self):
        self._skip_ws()
        char = self._peek()
        if char == "{":
            return self._parse_table()
        if char == '"':
            return self._parse_string()
        if char == "-" or char.isdigit():
            return self._parse_number()

        identifier = self._parse_identifier()
        if identifier == "true":
            return True
        if identifier == "false":
            return False
        if identifier == "nil":
            return None
        return identifier

    def _parse_table(self):
        self._consume("{")
        self._skip_ws()
        mapping = {}
        list_values = []
        has_mapping = False

        while self._peek() != "}":
            self._skip_ws()
            if self._peek() == "[":
                has_mapping = True
                key = self._parse_bracket_key()
                self._skip_ws()
                self._consume("=")
                value = self._parse_value()
                mapping[key] = value
            else:
                list_values.append(self._parse_value())

            self._skip_ws()
            if self._peek() == ",":
                self._consume(",")
                self._skip_ws()
                if self._peek() == "}":
                    break
            elif self._peek() != "}":
                raise LuaParseError(f"Expected ',' or '}}' at index {self.index}")

        self._consume("}")

        if has_mapping:
            if list_values:
                for i, value in enumerate(list_values, start=1):
                    mapping[i] = value
            return mapping
        return list_values

    def _parse_bracket_key(self):
        self._consume("[")
        self._skip_ws()
        char = self._peek()
        if char == '"':
            key = self._parse_string()
        elif char == "-" or char.isdigit():
            key = self._parse_number()
        else:
            key = self._parse_identifier()
        self._skip_ws()
        self._consume("]")
        return key

    def _parse_string(self):
        self._consume('"')
        result = []
        while True:
            if self.index >= self.length:
                raise LuaParseError("Unterminated string")
            char = self._consume()
            if char == '"':
                break
            if char == "\\":
                if self.index >= self.length:
                    raise LuaParseError("Unterminated escape sequence")
                esc = self._consume()
                if esc == "n":
                    result.append("\n")
                elif esc == "r":
                    result.append("\r")
                elif esc == "t":
                    result.append("\t")
                elif esc == "\\":
                    result.append("\\")
                elif esc == '"':
                    result.append('"')
                else:
                    result.append(esc)
            else:
                result.append(char)
        return "".join(result)

    def _parse_number(self):
        match = re.match(r"-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?", self.text[self.index :])
        if not match:
            raise LuaParseError(f"Invalid number at index {self.index}")
        token = match.group(0)
        self.index += len(token)
        if any(ch in token for ch in ".eE"):
            return float(token)
        return int(token)

    def _parse_identifier(self):
        match = re.match(r"[A-Za-z_][A-Za-z0-9_]*", self.text[self.index :])
        if not match:
            raise LuaParseError(f"Expected identifier at index {self.index}")
        token = match.group(0)
        self.index += len(token)
        return token


def try_decompress(raw: bytes):
    attempts = [
        ("raw-deflate", -zlib.MAX_WBITS),
        ("zlib", zlib.MAX_WBITS),
        ("gzip-or-zlib", zlib.MAX_WBITS | 32),
    ]
    errors = []
    for label, wbits in attempts:
        try:
            return zlib.decompress(raw, wbits), label
        except Exception as exc:
            errors.append(f"{label}: {exc}")
    raise ValueError("Failed to decompress .jkr data:\n  " + "\n  ".join(errors))


def decode_lua_blob(raw: bytes):
    text = None
    mode = "plain"
    if raw.startswith(b"return"):
        text = raw.decode("utf-8", errors="replace")
    else:
        decomp, mode = try_decompress(raw)
        text = decomp.decode("utf-8", errors="replace")

    stripped = text.strip()
    if stripped.startswith("return"):
        stripped = stripped[6:].strip()

    parsed = LuaParser(stripped).parse()
    return parsed, mode


def summary_lines(data):
    lines = []
    if isinstance(data, dict) and data.get("kind") == "profile_bundle_v1":
        lines.append("Type: profile bundle")
        lines.append(f"Contains profile blob: {'yes' if data.get('profile') else 'no'}")
        lines.append(f"Contains meta blob: {'yes' if data.get('meta') else 'no'}")
        lines.append(f"Contains run save blob: {'yes' if data.get('save') else 'no'}")
        return lines

    if isinstance(data, dict):
        hs = data.get("high_scores")
        if isinstance(hs, dict):
            coll = hs.get("collection")
            if isinstance(coll, dict):
                amt = coll.get("amt")
                total = coll.get("tot")
                if isinstance(amt, (int, float)) and isinstance(total, (int, float)) and total:
                    pct = (amt / total) * 100
                    lines.append(f"Collection: {amt}/{total} ({pct:.2f}%)")
                else:
                    lines.append(f"Collection raw: {coll}")

        progress = data.get("progress")
        if isinstance(progress, dict):
            discovered = progress.get("discovered")
            if isinstance(discovered, dict):
                tally = discovered.get("tally")
                total = discovered.get("of")
                if isinstance(tally, (int, float)) and isinstance(total, (int, float)) and total:
                    pct = (tally / total) * 100
                    lines.append(f"Progress.discovered: {tally}/{total} ({pct:.2f}%)")

        if not lines:
            lines.append("Parsed Lua table successfully (no known profile summary fields found).")
    else:
        lines.append(f"Parsed value type: {type(data).__name__}")
    return lines


def main():
    parser = argparse.ArgumentParser(description="Decode Balatro .jkr save files to readable JSON.")
    parser.add_argument("input", help="Path to .jkr file")
    parser.add_argument("-o", "--output", help="Optional JSON output file path")
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    raw = input_path.read_bytes()
    try:
        parsed, mode = decode_lua_blob(raw)
    except Exception as exc:
        print(f"Decode failed: {exc}", file=sys.stderr)
        sys.exit(2)

    print(f"Decoded: {input_path.name}")
    print(f"Mode: {mode}")
    for line in summary_lines(parsed):
        print(f"- {line}")

    text = json.dumps(parsed, indent=2, ensure_ascii=False)
    if args.output:
        out = Path(args.output)
        out.write_text(text, encoding="utf-8")
        print(f"Wrote JSON: {out}")
    else:
        print("\nJSON:")
        print(text)


if __name__ == "__main__":
    main()
