//
//  KnownMetadata.c
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

#include "include/KnownMetadata.h"

// Grab the metadata pointer that's appropriate for Swift. By default,
// getting the address of the reference type metadata points to the full
// metadata which points to the value witness table rather than the kind.
// Move the pointer down one word to be correct.
#define BUILTIN(NAME, SYMBOL) \
void *getBuiltin##NAME##Metadata() { \
  return &$s##SYMBOL##N + sizeof(void*); \
}
#include "include/Builtins.def"

#undef BUILTIN
