//
//  Functions.h
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

#ifndef SWIFT_RUNTIME_FUNCTIONS
#define SWIFT_RUNTIME_FUNCTIONS

#include <stddef.h>

//===----------------------------------------------------------------------===//
// Box Functions
//===----------------------------------------------------------------------===//

// void swift_deallocBox(HeapObject *obj);
extern void swift_deallocBox(void *heapObj);

// OpaqueValue *swift_projectBox(HeapObject *obj);
extern void *swift_projectBox(void *heapObj);

// HeapObject *swift_allocEmptyBox();
extern void *swift_allocEmptyBox();

//===----------------------------------------------------------------------===//
// Object Functions
//===----------------------------------------------------------------------===//

// HeapObject *swift_allocObject(Metadata *type, size_t size, size_t alignMask);
extern void *swift_allocObject(void *type, size_t size, size_t alignMask);

// HeapObject *swift_initStackObject(HeapMetadata *metadata,
//                                   HeapObject *obj);
extern void *swift_initStackObject(void *metadata, void *obj);

// void swift_verifyEndOfLifetime(HeapObject *obj);
extern void swift_verifyEndOfLifetime(void *obj);

// void swift_deallocObject(HeapObject *obj, size_t size, size_t alignMask);
extern void swift_deallocObject(void *obj, size_t size, size_t alignMask);

// void swift_deallocUninitializedObject(HeapObject *obj, size_t size,
//                                       size_t alignMask);
extern void swift_deallocUninitializedObject(void *obj, size_t size,
                                             size_t alignMask);

// void swift_release(HeapObject *obj);
extern void swift_release(void *heapObj);

#endif
