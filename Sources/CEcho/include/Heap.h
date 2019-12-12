//
//  Heap.h
//  
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

#ifndef HEAP
#define HEAP

// The paths for these functions are all found within the swift repository

// include/swift/Runtime/HeapObject.h
//
// void swift_release(HeapObject *obj);
extern void swift_release(void *heapObj);

// include/swift/Runtime/HeapObject.h
//
// OpaqueValue *swift_projectBox(HeapObject *obj);
extern void* swift_projectBox(void *heapObj);

#endif
