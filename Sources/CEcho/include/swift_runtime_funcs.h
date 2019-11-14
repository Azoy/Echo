//
//  swift_runtime_funcs.h
//  
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

#ifndef SWIFT_RUNTIME_FUNCS
#define SWIFT_RUNTIME_FUNCS

// The paths for these functions are all found within the swift repository

// include/swift/Runtime/HeapObject.h#L187
//
// void swift_release(HeapObject *obj);
extern void swift_release(void *heapObj);

// include/swift/Runtime/HeapObject.h#L344
//
// OpaqueValue *swift_projectBox(HeapObject *obj);
extern void* swift_projectBox(void *heapObj);

#endif
