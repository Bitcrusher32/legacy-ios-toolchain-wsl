export THEOS=/home/bitcrusher32/theos

ARCHS = armv7
TARGET = iphone:clang:9.3:6.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ObjCRuntimeTest

ObjCRuntimeTest_FILES = Tweak.xm

# Current known temporary overlay paths.
# These are diagnostic only, not a real SDK solution.
ObjCRuntimeTest_LDFLAGS += -L$(THEOS)/sdks/iPhoneOS9.3.sdk/usr/lib
ObjCRuntimeTest_LDFLAGS += -L$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/usr/lib
ObjCRuntimeTest_LDFLAGS += -F$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/System/Library/Frameworks

# Keep this out for now because this test does not need C++ stdlib yet.
ObjCRuntimeTest_LDFLAGS += -nostdlib++

include $(THEOS_MAKE_PATH)/tweak.mk

# Experimental real Mach-O stub path for libobjc.
ObjCRuntimeTest_LDFLAGS += -L$(HOME)/ios-sdk-machostubs/iPhoneOS9.3/usr/lib
