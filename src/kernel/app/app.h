#ifndef __KLIBAPP_H__
#define __KLIBAPP_H__

//#define STD_DEBUG

#include "../klib/string.h"

#ifndef STD_DEBUG
#include "../mm/mm.h"
//#include "../klib/stdio.h"
#endif // STD_DEBUG

int eval(const char* express);

#endif
