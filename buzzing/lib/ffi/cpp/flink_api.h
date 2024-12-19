#ifndef EXTERNC
#define EXTERNC
#endif

#ifndef DLLEXPORT
#define DLLEXPORT
#endif

typedef unsigned long long uint64_t;

typedef void (*BuzzingPushHandler)(const char *param, size_t len);

typedef void (*ResultCallback)(const char *data, size_t len);

EXTERNC DLLEXPORT void buzzing_init(const char *param, size_t len,
                                  BuzzingPushHandler handler,
                                  ResultCallback callback);
EXTERNC DLLEXPORT void buzzing_invoke(const char *param, size_t len);
EXTERNC DLLEXPORT void buzzing_uninit();
EXTERNC DLLEXPORT void buzzing_release(const char* ptr, int type);
