extern "C" void *objc_getClass(const char *name);

extern "C" void ObjCRuntimeTestMarker(void) {
    volatile void *cls = objc_getClass("NSObject");
    (void)cls;
}
