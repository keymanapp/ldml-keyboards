@0xe0c33bb359ddae62; # Unique file ID generated by `capnp id`

# Note that any o- prefixed field indicates a memory-address offset.
# E.g: In the Rule struct, oAfter = offset within table to the 'after' field.
#
# Additionally, List implies a managed corresponding 'length' element for the representation.
# Cap'n Proto automanages this.
#
# It also automanages offsets to each entry within a structure, which would need to be implemented
# if this turns more into a specification reference file for a different implementation.

# Annotations

annotation fixedLen(field) :UInt8;
annotation if(field) :Text;

# Basic types
using FourCC = UInt32; # Denotes a four-character code in ASCII, compressed into a single 32-bit value.  
                       # TODO: Is FourCC Little-endian or Big-endian?
using Char = UInt32; # Denotes a UTF-32 character.
using BitFlags16 = UInt16;  # Denotes a set of bit flags representing multiple booleans.
using VkeyCode = UInt16;    # Denotes a VKey value.

struct String32 { # Denotes a UTF-32-based string.
    len @0 :UInt16;
    c @1 :List(Char);
}

# struct String8 { 
#     c @0 :List(UInt8);
#     z @1 :UInt8 = 0;
# }

# Directory
struct DirEntry(Table) {
    name @0 :FourCC;
    table @1 :Table;  # Reference to the represented table.
    length @2 :UInt32;
    version @3 :UInt32;
}

struct Directory {
    entries @0 :List(DirEntry);
}

# Trie
annotation key(field) :Text;    # Denotes the type of the key in the trie.

struct Trie(Result) {
    result @0 :Result;

    trieData :union {
        ordered @1 :List(OrderedTrie);
        segmented @2 :List(SegmentedTrie);
    }
}

struct OrderedTrie(Result) {
    c @0 :Char;
    t @1 :Trie(Result); # Reference to next Trie node
}

struct SegmentedTrie(Result) {  # Run-length encoding style
    c @0 :Char; # First char
    t @1 :List(Trie(Result)); # Reference to next Trie node for each char in run.
}

struct BoolTrie {
    result @0 :Bool; # Offset to string, magic value (for string match success) or to rule (depending upon contextual use).
                       # 0 indicates transition node (no rule here)
    trieData :union {
        ordered @1 :List(BoolOrderedTrie);
        segmented @2 :List(BoolSegmentedTrie);
    }
}

struct BoolOrderedTrie {
    c @0 :Char;
    t @1 :BoolTrie; # Reference to next Trie node
}

struct BoolSegmentedTrie {  # Run-length encoding style
    c @0 :Char; # First char
    t @1 :List(BoolTrie); # Reference to next Trie node for each char in run.
}

# trns table - Simple Transform
struct Rule {
    error @0 :Bool;
    next @1 :Rule; # To the next 'Rule' with the same 'from'.
	to @2 :String32;
    before @3 :BoolTrie;
    after @4 :BoolTrie;
}

struct TableTrns {
    settings @0 :UInt16;
    t @1 :Trie(Rule) $key("Char");
    #outputs @2 :List(Rule);  # Would be a master list of the contained Rule objects.
}

# trnf table - Final transforms
struct TableTrnf {
    t @0 :Trie(Rule) $key("Char"); # Rule index into outputs.
    #outputs @1 :List(Rule);
}

# trnb table - backspace transforms
struct TableTrnb {
    t @0 :Trie(Rule) $key("Char"); # Rule index into outputs.
    #outputs @1 :List(Rule);
}

# trnr table - reorders
struct OrderRule {
    struct Info {
        prebase @0 :Bool;
        tertiaryBase @1 :Bool;
        order @2 :Int8;
        tertiary @3 :Int8;
    }
    error @0 :Bool;
    next @1 :OrderRule; # To the 'next' OrderRule with the same 'from'.
    order @2 :List(Info);
    before @3 :BoolTrie;
    after @4 :BoolTrie;
}

struct TableTrnr {
    t @0 :Trie(OrderRule) $key("Char"); # Rule
    #outputs @1 :List(OrderRule);
}

# kmap table - KeyMaps
struct KeyMap {
    modifiers @0 :UInt16;
    eModifiers @1 :List(UInt8);
    t @2 :Trie(KmapEntry) $key("FourCC");
    entries @3 :List(KmapEntry);
}

struct KmapEntry {
    to @0 :String32;
    #hint: :String32; #  Displayed as minor text element on key
    multiTap @1 :List(String32);
    longPress @2 :List(String32);
    flicks @3 :List(String32) $fixedLen(8) $if("oFlick");
}

struct TableKmap {
    maps @0 :List(KeyMap);
}

# layr table
struct LayerKey {
    #width :UInt16; # or should it be Float32? # Denotes the width of a key.
    iso @0 :FourCC; # The represented key ISO code.
    cap @1 :String32; # The displayed key cap.
    hint @2 :String32; # The longpress hint, if it exists.
}

struct LayerRow {
    keys @0 :List(LayerKey);
}

struct LayerSwitch {
    iso @0 :FourCC;
    layer @1 :String32;
}

struct Layer {
    modifier @0 :BitFlags16; # A set of bitflags corresponding to the modifier represented by the layer.
    eModifiers @1 :List(UInt8);
    rows @2 :List(LayerRow);
    switches @3 :List(LayerSwitch);
}

struct TableLayr {
    layers @0 :List(Layer);
}

struct NameEntry {
    id @0 :FourCC;
    name @1 :Text;
}

struct TableName {
    entries @0 :List(NameEntry);
}

struct TableHead {
    publishDate @0 :UInt64;
}

# vkey table
struct VkeyEntry {
    vkeyCode @0: VkeyCode;
    modifiers @1: BitFlags16;
}

struct PlatformVkeys {
    platId @0 :FourCC; # 'windows', 'macosx'
    parent @1 :FourCC;  # The 'platId' version of this struct to use for default values.
    t @2: Trie(VkeyEntry) $key("FourCC"); # to VkeyEntry
}

struct TableVkey { # The main Vkey table.  Implicitly based on Windows 'en-us', with further defs here overriding said base.
    platforms @0 :List(PlatformVkeys);
}

struct CordEntry { # Or, just a UInt16 to be unpacked, if we need that optimization.
    struct CordVal {
        hasRule @0 :Bool;
        isTertiary @1 :Bool;
        tertiaryBase @2 :Bool;
        preBase @3 :Bool;
        order @4 :UInt8;
    }
    c @0 :Char;
    v @1 :CordVal;
}

struct TableCord { # Character ordering
    entries @0: List(CordEntry);
}
