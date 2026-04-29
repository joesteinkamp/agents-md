#!/usr/bin/env bash
set -euo pipefail
cat >script.py <<'PY'
def compute(n):
    out = []
    for i in range(n):
        out.append(i * i)
    return out

def main():
    for x in compute(5):
        print(x)

if __name__ == "__main__":
    main()
PY
