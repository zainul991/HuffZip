# HuffZip — Lossless File Compression Engine

A C++ implementation of Huffman coding for lossless compression and decompression of text files. It builds a Huffman tree with a min-heap priority queue, derives optimal prefix codes via binary tree traversal, and packs the resulting bitstream into bytes for compact storage.

> Adapted and extended from an earlier open-source Huffman coding reference implementation. Fixed a modern-compiler build error, fixed a crash on single-character-alphabet input, tightened error handling, and added compression-ratio reporting.

## Features

- **Min-heap priority queue** (`std::priority_queue` with a custom comparator) to repeatedly combine the two lowest-frequency nodes when building the Huffman tree
- **Binary tree traversal** to generate optimal, variable-length prefix codes (frequent characters get shorter codes)
- **Bit-level packing** — codes are packed 8 bits per byte for the compressed output, and unpacked bit-by-bit during decoding
- **Exact reconstruction** — the encoded file embeds the code table, so decoding needs no external state
- **Compression stats** printed after encoding (original size, compressed size, % space saved)
- **Basic error handling** for missing/unreadable input files instead of silent failure

## How It Works

1. **Frequency count** — read the input file and tally how often each of the 128 ASCII characters appears.
2. **Build the priority queue** — push every character that actually occurs into a min-heap ordered by frequency.
3. **Build the Huffman tree** — repeatedly pop the two lowest-frequency nodes, merge them under a new parent node whose frequency is their sum, and push the parent back in. This continues until one node (the root) remains.
4. **Assign codes** — traverse the tree from the root; each left branch appends `0`, each right branch appends `1`. Leaves (original characters) end up with a unique prefix code — shorter for common characters, longer for rare ones.
5. **Encode** — write the code table (character + code) into the output file, then replace every character in the input with its code and pack the resulting bit stream into bytes.
6. **Decode** — read the code table back to rebuild the same tree, then walk the tree bit-by-bit through the encoded stream, emitting a character every time a leaf is reached.

## Build

```bash
make
```

This produces two binaries: `huffmanCoding` and `huffmanDecoding`.

Or compile manually:

```bash
g++ -std=c++11 -Wall -O2 -o huffmanCoding huffmanCoding.cpp huffman.cpp
g++ -std=c++11 -Wall -O2 -o huffmanDecoding huffmanDecoding.cpp huffman.cpp
```

## Usage

```bash
# Compress
./huffmanCoding <input_file> <output_file>

# Decompress
./huffmanDecoding <compressed_file> <output_file>
```

### Example

```bash
./huffmanCoding original/OriginalFile.txt encoded/EncodedFile.huf
./huffmanDecoding encoded/EncodedFile.huf decoded/DecodedFile.txt
diff original/OriginalFile.txt decoded/DecodedFile.txt   # no output = identical
```

Sample output:

```
Original size:   9086 bytes
Compressed size: 6046 bytes
Space saved:     33.46%
```

## Compressed File Format

```
[1 byte]  number of distinct characters (N)
[N x 17 bytes]  for each character: 1 byte for the character itself,
                16 bytes encoding its Huffman code (padded to a fixed
                128-bit slot, with a leading '1' marking where the
                real code starts)
[remaining bytes]  the encoded text, packed 8 bits per byte
[last byte]  number of padding zero-bits appended to the final byte
```

## Known Limitations

- Designed for standard 7-bit ASCII text files (0–127), not arbitrary binary or UTF-8 input.
- No archive/multi-file support — one input file per run.

## Project Structure

```
huffman.h            class + struct definitions
huffman.cpp           core Huffman logic (tree building, encode/decode)
huffmanCoding.cpp      CLI entry point for compression
huffmanDecoding.cpp    CLI entry point for decompression
Makefile               build script
original/              sample input
encoded/                sample compressed output
decoded/                sample decompressed output (verifies lossless round-trip)
```
