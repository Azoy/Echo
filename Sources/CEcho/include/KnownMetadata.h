//
//  KnownMetadata.h
//
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

#ifndef KNOWNMETADATA
#define KNOWNMETADATA

// The mangling scheme for builtin metadata is:
// $s SYMBOL N
// $s = Swift mangling prefix
// SYMBOL = The builtin type mangling
// N = Metadata
// Example: Builtin.NativeObject Metadata is $sBoN
//
// Reference the runtime defined metadata variable for builtin types.
#define BUILTIN(NAME, SYMBOL) \
extern void $s##SYMBOL##N;
#include "Builtins.def"

#undef BUILTIN

// Define this utility function because you can't see variables that start with
// $ in Swift.
#define BUILTIN(NAME, SYMBOL) \
void *getBuiltin##NAME##Metadata();
#include "Builtins.def"

#undef BUILTIN

#endif
