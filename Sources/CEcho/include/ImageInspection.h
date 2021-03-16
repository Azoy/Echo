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

extern void registerProtocols(const char *section, size_t size);
extern void registerProtocolConformances(const char *section, size_t size);
extern void registerTypeMetadata(const char *section, size_t size);

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
  
  lookupSection(header, "__TEXT", "__swift5_protos",
                registerProtocols);
  
  lookupSection(header, "__TEXT", "__swift5_types",
                registerTypeMetadata);
}

__attribute((__constructor__))
void loadImages() {
  _dyld_register_func_for_add_image(_loadImageFunc);
}

#endif // defined(__MACH__)

//===----------------------------------------------------------------------===//
// ELF Image Inspection
//===----------------------------------------------------------------------===//

#if defined(__ELF__)

#include <stdbool.h>

// The Swift runtime solely uses the trick below to get all of the protocol
// conformance sections whenever an image is loaded into. We can't do that for
// Echo because there are plenty of conformances defined in libraries like the
// standard library that we need to search through. Thus the need for the work
// found in ImageInspectionELF.c

// Create an empty section with the same name as one passed in to generate the
// start and stop variables for that section. We do this in addition to
// iterating through program headers to get the executable's sections.
#define SWIFT_SECTION(name) \
  __asm__("\t.section " #name ", \"a\"\n"); \
  __attribute((__visibility__("hidden"), aligned(1))) extern const char __start_##name; \
  __attribute((__visibility__("hidden"), aligned(1))) extern const char __stop_##name;

#if defined(__cplusplus)
extern "C" {
#endif

SWIFT_SECTION(swift5_protocols)
SWIFT_SECTION(swift5_protocol_conformances)
SWIFT_SECTION(swift5_type_metadata)

#if defined(__cplusplus)
} // extern "C"
#endif

#undef SWIFT_SECTION

void iterateSharedObjects();

extern bool cacheSharedObject(const char *name);

#endif // defined(__ELF)

//===----------------------------------------------------------------------===//
// COFF Image Inspection
//===----------------------------------------------------------------------===//

#if !defined(__ELF__) && !defined(__MACH__)
#endif

#endif /* IMAGE_INSPECTION_H */
