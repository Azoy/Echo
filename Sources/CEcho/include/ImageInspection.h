//
//  ImageInspection.h
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

#ifndef IMAGE_INSPECTION_H
#define IMAGE_INSPECTION_H

#include <stddef.h>

extern void registerProtocolConformances(const char *section, size_t size);

//===----------------------------------------------------------------------===//
// Mach-O Image Inspection
//===----------------------------------------------------------------------===//

#if defined(__MACH__)

#include <mach-o/dyld.h>
#include <mach-o/getsect.h>

extern void lookupSection(const struct mach_header *header, const char *segment,
                          const char *section,
                          void (*registerFunc)(const char *, size_t));

void _loadImageFunc(const struct mach_header *header, intptr_t size) {
  lookupSection(header, "__TEXT", "__swift5_proto",
                registerProtocolConformances);
}

__attribute((__constructor__))
void loadImages() {
  _dyld_register_func_for_add_image(_loadImageFunc);
}

#endif

//===----------------------------------------------------------------------===//
// ELF Image Inspection
//===----------------------------------------------------------------------===//

#if defined(__ELF__)
 
#define SWIFT_SECTION(name) \
  __asm__("\t.section " #name ", \"a\"\n"); \
  __attribute((__visibility__("hidden"), aligned(1))) extern const char __start_##name; \
  __attribute((__visibility__("hidden"), aligned(1))) extern const char __stop_##name;

#if defined(__cplusplus)
extern "C" {
#endif

SWIFT_SECTION(swift5_protocol_conformances)

#if defined(__cplusplus)
} // extern "C"
#endif

#undef SWIFT_SECTION

#define SWIFT_REGISTER_SECTION(name, handle) \
  handle(&__start_##name, &__stop_##name - &__start_##name);

__attribute__((__constructor__))
void addImage() {
  SWIFT_REGISTER_SECTION(swift5_protocol_conformances, registerProtocolConformances)
}

#undef SWIFT_REGISTER_SECTION

#endif

//===----------------------------------------------------------------------===//
// COFF Image Inspection
//===----------------------------------------------------------------------===//

#if !defined(__ELF__) && !defined(__MACH__)
#endif

#endif /* IMAGE_INSPECTION_H */
