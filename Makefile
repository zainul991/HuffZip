CXX = g++
CXXFLAGS = -std=c++11 -Wall -O2

all: huffmanCoding huffmanDecoding

huffmanCoding: huffmanCoding.cpp huffman.cpp huffman.h
	$(CXX) $(CXXFLAGS) -o huffmanCoding huffmanCoding.cpp huffman.cpp

huffmanDecoding: huffmanDecoding.cpp huffman.cpp huffman.h
	$(CXX) $(CXXFLAGS) -o huffmanDecoding huffmanDecoding.cpp huffman.cpp

clean:
	rm -f huffmanCoding huffmanDecoding

.PHONY: all clean
