#include <iostream>
#include "ldmlman.capnp.h"
#include <capnp/message.h>
#include <capnp/serialize.h>

int main(int argc, char* argv[]) {
	::capnp::MallocMessageBuilder message;

	::Trie<Rule>::Builder trie = message.initRoot<Trie<Rule>>();

    std::cout << "Hello" << std::endl;
}