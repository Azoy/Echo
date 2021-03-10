//
//  ValueWitnessTable.h
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

#ifndef VALUE_WITNESS_TABLE_H
#define VALUE_WITNESS_TABLE_H

#if defined(__arm64e__)

#include <stddef.h>
#include <ptrauth.h>

#define VWT_FP(key) __ptrauth_swift_value_witness_function_pointer(key)

// VWT

typedef struct ValueWitnessTable {
  void *(* VWT_FP(0xda4a) initializeBufferWithCopyOfBuffer)(void *, void *,
                                                            const void *);
  void (* VWT_FP(0x04f8) destroy)(void *, const void *);
  void *(* VWT_FP(0xe3ba) initializeWithCopy)(void *, void *, const void *);
  void *(* VWT_FP(0x8751) assignWithCopy)(void *, void *, const void *);
  void *(* VWT_FP(0x48d8) initializeWithTake)(void *, void *, const void *);
  void *(* VWT_FP(0xefda) assignWithTake)(void *, void *, const void *);
  unsigned (* VWT_FP(0x60f0) getEnumTagSinglePayload)(const void *, unsigned,
                                                      const void *);
  void (* VWT_FP(0xa0d1) storeEnumTagSinglePayload)(void *, unsigned, unsigned,
                                                    const void *);
  
  size_t size;
  size_t stride;
  unsigned flags;
  unsigned extraInhabitantCount;
} ValueWitnessTable;

// Enum VWT

typedef struct EnumValueWitnessTable {
  ValueWitnessTable base;
  
  int (* VWT_FP(0xa3b5) getEnumTag)(const void *, const void *);
  void (* VWT_FP(0x041d) destructiveProjectEnumData)(void *, const void *);
  void (* VWT_FP(0xb2e4) destructiveInjectEnumTag)(void *, unsigned,
                                                   const void *);
} EnumValueWitnessTable;

// A note for the following: All of these functions are required for platforms
// that utilize pointer authentication because we need to sign the vwt function
// pointers. We can't import these structs in Swift due to the clang importer
// not importing members who have ptrauth qualifiers. Define these stubs that
// call these functions. The first parameter for all of these stubs is a pointer
// to the VWT.

// VWT functions.

void *echo_vwt_initializeBufferWithCopyOfBuffer(const void *, void *, void *,
                                                const void *);
void echo_vwt_destroy(const void *, void *, const void *);
void *echo_vwt_initializeWithCopy(const void *, void *, void *, const void *);
void *echo_vwt_assignWithCopy(const void *, void *, void *, const void *);
void *echo_vwt_initializeWithTake(const void *, void *, void *, const void *);
void *echo_vwt_assignWithTake(const void *, void *, void *, const void *);
unsigned echo_vwt_getEnumTagSinglePayload(const void *, const void *, unsigned,
                                          const void *);
void echo_vwt_storeEnumTagSinglePayload(const void *, void *, unsigned, unsigned,
                                        const void *);

// Enum VWT functions

unsigned echo_vwt_getEnumTag(const void *, const void *, const void *);
void echo_vwt_destructiveProjectEnumData(const void *, void *, const void *);
void echo_vwt_destructiveInjectEnumTag(const void *, void *, unsigned,
                                       const void *);

#endif // defined(__arm64e__)

#endif /* VALUE_WITNESS_TABLE_H */
