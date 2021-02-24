//
//  Functions.c
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

#include "include/Functions.h"

#if defined(__arm64e__)
#include <ptrauth.h>

const void *__ptrauth_strip_asda(const void *ptr) {
  return ptrauth_strip(ptr, ptrauth_key_asda);
}

#endif
