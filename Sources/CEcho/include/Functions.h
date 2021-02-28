//
//  Functions.h
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

#ifndef SWIFT_RUNTIME_FUNCTIONS_H
#define SWIFT_RUNTIME_FUNCTIONS_H

#include <stdbool.h>
#include <stddef.h>

//===----------------------------------------------------------------------===//
// Pointer Authentication
//===----------------------------------------------------------------------===//

#if defined(__arm64e__)
const void *__ptrauth_strip_asda(const void *ptr);
#endif

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

// HeapObject *swift_weakLoadStrong(WeakReference *weakRef);
extern void *swift_weakLoadStrong(void *weakRef);

//===----------------------------------------------------------------------===//
// Protocol Conformances
//===----------------------------------------------------------------------===//

// WitnessTable *swift_conformsToProtocol(Metadata *type,
//                                        ProtocolDescriptor *protocol);
extern void *swift_conformsToProtocol(const void *type, const void *protocol);

//===----------------------------------------------------------------------===//
// Casting
//===----------------------------------------------------------------------===//

// bool swift_dynamicCast(OpaqueValue *dest, OpaqueValue *src,
//                        const Metadata *srcType, const Metadata *targetType,
//                        DynamicCastFlags flags);
extern bool swift_dynamicCast(void *dest, void *src, const void *srcType,
                              const void *targetType, size_t flags);

//===----------------------------------------------------------------------===//
// Obj-C Support
//===----------------------------------------------------------------------===//

#if defined(__OBJC__)
#include <objc/runtime.h>

extern Class swift_getInitializedObjCClass(Class c);
#endif // defined(__OBJC__)

#endif /* SWIFT_RUNTIME_FUNCTIONS_H */
