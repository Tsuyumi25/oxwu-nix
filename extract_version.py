#!/usr/bin/env python3
"""從 AppImage 的 squashfs 裡提取版本號，輸出到指定路徑。

Usage: extract_version.py <appimage> <squashfs_out>
"""
import sys

SEARCH_START = 0x2A000
SEARCH_LIMIT = 32 * 1024 * 1024
COPY_CHUNK  = 8  * 1024 * 1024

def find_squashfs_offset(path: str) -> int:
    with open(path, 'rb') as f:
        f.seek(SEARCH_START)
        data = f.read(SEARCH_LIMIT)
    pos = data.find(b'hsqs')
    if pos == -1:
        raise RuntimeError('squashfs magic not found in AppImage')
    return SEARCH_START + pos

def extract_squashfs(appimage: str, out: str) -> None:
    offset = find_squashfs_offset(appimage)
    with open(appimage, 'rb') as f:
        f.seek(offset)
        with open(out, 'wb') as o:
            while chunk := f.read(COPY_CHUNK):
                o.write(chunk)

if __name__ == '__main__':
    appimage, out = sys.argv[1], sys.argv[2]
    extract_squashfs(appimage, out)
