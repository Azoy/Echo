//
//  CallAccessor.h
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

#ifndef CALL_ACCESSOR_H
#define CALL_ACCESSOR_H

#include <stddef.h>

typedef struct MetadataResponse {
  const void *Metadata;
  size_t State;
} MetadataResponse;

const MetadataResponse echo_callAccessor0(const void *ptr, size_t request);

const MetadataResponse echo_callAccessor1(const void *ptr, size_t request,
                                          const void *arg0);

const MetadataResponse echo_callAccessor2(const void *ptr, size_t request,
                                          const void *arg0, const void *arg1);

const MetadataResponse echo_callAccessor3(const void *ptr, size_t request,
                                          const void *arg0, const void *arg1,
                                          const void *arg2);

// Where args is a list of pointers.
const MetadataResponse echo_callAccessor(const void *ptr, size_t request,
                                         const void *args);

#endif /* CALL_ACCESSOR_H */
