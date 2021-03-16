//
//  ImageInspectionELF.c
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

#if defined(__ELF__)

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include "ImageInspection.h"
#include <fcntl.h>
#include <elf.h>
#include <link.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Callback used when iterating the shared objects loaded in this program's
// current memory. At the moment we only care about Swift's protocol
// conformances.
static int imageCallback(struct dl_phdr_info *info, size_t size, void *data) {
  // Before doing anything here, check our cache to see if we've already added
  // this image's information. If not, this will cache our image name for future
  // iterations.
  if (!cacheSharedObject(info->dlpi_name)) {
    return 0;
  }
  
  // Our personal shared object in memory that isn't mapped into the process.
  void *so = NULL;
  const ElfW(Ehdr) *soHeader = NULL;
  
  // Open the full shared object file into memory so that we can inspect the
  // section header table. This is somewhat unfortunate, but is required
  // because ELF doesn't need the section header table at runtime, so it's
  // most likely stripped from the object currently in memory.
  FILE *file = fopen(info->dlpi_name, "rb");
  
  if (file == NULL) {
    return 0;
  }
  
  // Figure out the size of the file.
  fseek(file, 0, SEEK_END);
  size_t fileSize = ftell(file);
  rewind(file);
  
  so = malloc(fileSize);
  soHeader = (ElfW(Ehdr) *)so;
  
  if (so == NULL) {
    return 0;
  }
  
  // Read the whole shared object and close our file handle now that we're done
  // with the file.
  fread(so, fileSize, 1, file);
  fclose(file);
  
  // The section header table is located at the section header table offset
  // from the base address.
  const ElfW(Shdr) *sections = so + soHeader->e_shoff;
  // Our string table section, i.e. the section that provides all the names for
  // the object's sections, is the shstrdx'th index into the section header
  // table.
  const ElfW(Shdr) *stringTableSection = &sections[soHeader->e_shstrndx];
  // The actual string table is located at the section offset from the base
  // address
  const char *const stringTable = so + stringTableSection->sh_offset;
  
  // Loop through every section header looking for the one that describes any
  // Swift section that we may be interested in.
  for (int i = 0; i != soHeader->e_shnum; i += 1) {
    int sectionNameIdx = sections[i].sh_name;
    // Our actual section name is in the string table at our index.
    const char *sectionName = stringTable + sectionNameIdx;
    
    // We found Swift's protocol section!
    if (!strcmp(sectionName, "swift5_protocols")) {
      size_t sectionAddr = sections[i].sh_addr;
      // The actual conformances section within the program's memory is located
      // at the base address of this shared object's memory plus the vaddr
      // provided by the section header.
      const void *protos = (const void *)(info->dlpi_addr + sectionAddr);
      
      registerProtocols(protos, sections[i].sh_size);
      continue;
    }
    
    // We found Swift's protocol conformances section!
    if (!strcmp(sectionName, "swift5_protocol_conformances")) {
      size_t sectionAddr = sections[i].sh_addr;
      // The actual conformances section within the program's memory is located
      // at the base address of this shared object's memory plus the vaddr
      // provided by the section header.
      const void *conformances = (const void *)(info->dlpi_addr + sectionAddr);
      
      registerProtocolConformances(conformances, sections[i].sh_size);
      continue;
    }
    
    // We found Swift's type metadata section!
    if (!strcmp(sectionName, "swift5_type_metadata")) {
      size_t sectionAddr = sections[i].sh_addr;
      // The actual conformances section within the program's memory is located
      // at the base address of this shared object's memory plus the vaddr
      // provided by the section header.
      const void *types = (const void *)(info->dlpi_addr + sectionAddr);
      
      registerTypeMetadata(types, sections[i].sh_size);
      continue;
    }
  }
  
  // And finally, free the memory we allocated for our shared object :)
  free(so);
  
  return 0;
}

// Iterate through all of the current shared objects loaded into this
// program's memory.
void iterateSharedObjects() {
  dl_iterate_phdr(imageCallback, NULL);
}

#define SWIFT_REGISTER_SECTION(name, handle) \
  handle(&__start_##name, &__stop_##name - &__start_##name);

__attribute__((__constructor__))
static void loadImages() {
  // This will register the executable's protocol list.
  SWIFT_REGISTER_SECTION(swift5_protocols, registerProtocols)
  
  // This will register the executable's protocol conformance list.
  SWIFT_REGISTER_SECTION(swift5_protocol_conformances, registerProtocolConformances)
  
  // This will register the executable's type metadata list.
  SWIFT_REGISTER_SECTION(swift5_type_metadata, registerTypeMetadata)
}

#undef SWIFT_REGISTER_SECTION

#endif // defined(__ELF__)
