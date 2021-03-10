//
//  ValueWitnessTable.c
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

#if defined(__arm64e__)

#include "ValueWitnessTable.h"

// VWT functions.

void *echo_vwt_initializeBufferWithCopyOfBuffer(const void *ptr, void *dest,
                                                void *src,
                                                const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->initializeBufferWithCopyOfBuffer(dest, src, metadata);
}

void echo_vwt_destroy(const void *ptr, void *value, const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->destroy(value, metadata);
}

void *echo_vwt_initializeWithCopy(const void *ptr, void *dest, void *src,
                                  const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->initializeWithCopy(dest, src, metadata);
}

void *echo_vwt_assignWithCopy(const void *ptr, void *dest, void *src,
                              const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->assignWithCopy(dest, src, metadata);
}

void *echo_vwt_initializeWithTake(const void *ptr, void *dest, void *src,
                                  const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->initializeWithTake(dest, src, metadata);
}

void *echo_vwt_assignWithTake(const void *ptr, void *dest, void *src,
                              const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->assignWithTake(dest, src, metadata);
}

unsigned echo_vwt_getEnumTagSinglePayload(const void *ptr, const void *instance,
                                          unsigned numEmptyCases,
                                          const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->getEnumTagSinglePayload(instance, numEmptyCases, metadata);
}

void echo_vwt_storeEnumTagSinglePayload(const void *ptr, void *instance,
                                        unsigned tag, unsigned numEmptyCases,
                                        const void *metadata) {
  const ValueWitnessTable *vwt = (const ValueWitnessTable *)ptr;
  return vwt->storeEnumTagSinglePayload(instance, tag, numEmptyCases, metadata);
}

// Enum VWT functions

unsigned echo_vwt_getEnumTag(const void *ptr, const void *instance,
                             const void *metadata) {
  const EnumValueWitnessTable *vwt = (const EnumValueWitnessTable *)ptr;
  return vwt->getEnumTag(instance, metadata);
}

void echo_vwt_destructiveProjectEnumData(const void *ptr, void *instance,
                                         const void *metadata) {
  const EnumValueWitnessTable *vwt = (const EnumValueWitnessTable *)ptr;
  return vwt->destructiveProjectEnumData(instance, metadata);
}

void echo_vwt_destructiveInjectEnumTag(const void *ptr, void *instance,
                                       unsigned tag,
                                       const void *metadata) {
  const EnumValueWitnessTable *vwt = (const EnumValueWitnessTable *)ptr;
  return vwt->destructiveInjectEnumTag(instance, tag, metadata);
}

#endif // defined(__arm64e__)
