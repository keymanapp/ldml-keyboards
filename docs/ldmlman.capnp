# Note that any o- prefixed field indicates a memory-address offset.
# E.g: In the Rule struct, oAfter = offset within table to the 'after' field.

# Annotations

annotation len16(field) :UInt16;
annotation len8(field) :UInt8;
annotation if(field) :UInt16;

# Basic types
using FourCC = UInt32;
using offset = UInt32;
using char = UInt32;

struct string32 {
    len :UInt16;
    c :List(char);
}

struct string8 {
    c :List(Uint8);
    z :UInt8 = 0;
}

# Directory
struct DirEntry {
    name :FourCC;
    offset :offset;
    length :UInt32;
    version :UInt32;
}

struct Directory {
    entries :List(DirEntry);
}

# Trie
struct Trie {
    type :UInt8;
    reserved :UInt8;
    numEntries :UInt16;
    oResult :UInt16; # Offset to string, magic value (for string match success) or to rule (depending upon contextual use).
                     # 0 indicates transition node (no rule here)
    trieData :union {
        ordered :List(orderedTrie) $len16(numentries);
        segmented :List(segmentedTrie) $len16(numentries);
    }
}

struct orderedTrie {
    c :char;
    o :offset; # Offset to next Trie node

struct segmentedTrie {  # Run-length encoding style
    length :UInt16; # Number of subsequent chars.
    c :char; # First char
    offsets :List(offset) $len16(length); # Offset to next Trie node.
}

# Simple Transform
struct Rule {
    error :Bool;
	oBefore :UInt16;
    oAfter :UInt16;  
	to :string32;
    before :Trie;
    after :Trie;
}

struct trns {
    settings :UInt16;
    numRules :UInt16;
	oOutputs :UInt16;
    t :Trie;
    outputs :List(Rule) $len16(numRules);
}

# Final Transform
struct trnf {
    numRules :UInt16;
	oOutputs :UInt16;
    t :Trie;
    outputs :List(Rule) $len16(numRules);
}

# Backspace Transform
struct trnb {
    numRules :UInt16;
	oOutputs :UInt16;
    t :Trie;
    outputs :List(Rule) $len16(numRules);
}

# Reorder
struct OrderRule {
    struct info {
        prebase :Bool;
        tertiary_base :Bool;
        order :Int8;
    }
    error :Bool;
    iLen :UInt8;
	oAfter :UInt16;
    order :List(info) $len8(iLen);
    before :Trie;
    after :Trie;
}

struct trnr {
    numRules :UInt16;
	oOutputs :UInt16;
    t :Trie;
    outputs :List(OrderRule) $len16(numRules);
}

# KeyMaps
struct KeyMap {
    eModLen :UInt8;
    modifiers :UInt16;
    oEntries :UInt16;
    entriesLen :UInt16;
    eModifiers :Data $len8(eModLen);
    t :Trie;
    entries :List(kmapEntry);
}

struct kmapEntry {
    to :string32;
    multiLen :UInt8;
    oLong :UInt16;
    longLen :UInt8;
    oFlick :UInt16;
    multiTap :List(string32) $len8(multiLen);
    longPress :List(string32) $len8(longLen);
    flicks :List(string32) $len8(8) $if(oFlick);
}

struct kmap {
    klen :UInt8;
    maps :List(KeyMap);
}

