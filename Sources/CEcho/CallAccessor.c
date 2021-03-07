//
//  CallAccessor.c
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

#include "CallAccessor.h"

#if defined(__arm64e__)
#include <ptrauth.h>
#endif

#define SWIFTCC __attribute__((swiftcall))

const MetadataResponse echo_callAccessor0(const void *ptr, size_t request) {
#if defined(__arm64e__)
  ptr = ptrauth_sign_unauthenticated(ptr, ptrauth_key_function_pointer, 0);
#endif
  
  typedef SWIFTCC MetadataResponse(MetadataAccess)(size_t);
  
  return ((MetadataAccess *)ptr)(request);
}

const MetadataResponse echo_callAccessor1(const void *ptr, size_t request,
                                          const void *arg0) {
#if defined(__arm64e__)
  ptr = ptrauth_sign_unauthenticated(ptr, ptrauth_key_function_pointer, 0);
#endif
  
  typedef SWIFTCC MetadataResponse(MetadataAccess)(size_t, const void*);
  
  return ((MetadataAccess *)ptr)(request, arg0);
}

const MetadataResponse echo_callAccessor2(const void *ptr, size_t request,
                                          const void *arg0, const void *arg1) {
#if defined(__arm64e__)
  ptr = ptrauth_sign_unauthenticated(ptr, ptrauth_key_function_pointer, 0);
#endif
  
  typedef SWIFTCC MetadataResponse(MetadataAccess)(size_t, const void*,
                                                   const void*);
  
  return ((MetadataAccess *)ptr)(request, arg0, arg1);
}

const MetadataResponse echo_callAccessor3(const void *ptr, size_t request,
                                          const void *arg0, const void *arg1,
                                          const void *arg2) {
#if defined(__arm64e__)
  ptr = ptrauth_sign_unauthenticated(ptr, ptrauth_key_function_pointer, 0);
#endif
  
  typedef SWIFTCC MetadataResponse(MetadataAccess)(size_t, const void*,
                                                   const void*, const void*);
  
  return ((MetadataAccess *)ptr)(request, arg0, arg1, arg2);
}

const MetadataResponse echo_callAccessor(const void *ptr, size_t request,
                                         const void *args) {
#if defined(__arm64e__)
  ptr = ptrauth_sign_unauthenticated(ptr, ptrauth_key_function_pointer, 0);
#endif
  
  typedef SWIFTCC MetadataResponse(MetadataAccess)(size_t, const void*);
  
  return ((MetadataAccess *)ptr)(request, args);
}
