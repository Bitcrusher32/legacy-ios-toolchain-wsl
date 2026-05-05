export THEOS=/home/bitcrusher32/theos

ARCHS = armv7
TARGET = iphone:clang:9.3:6.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CoreFoundationTest

CoreFoundationTest_FILES = Tweak.xm

CoreFoundationTest_LDFLAGS += -L$(THEOS)/sdks/iPhoneOS9.3.sdk/usr/lib
CoreFoundationTest_LDFLAGS += -L$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/usr/lib
CoreFoundationTest_LDFLAGS += -F$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/System/Library/Frameworks
CoreFoundationTest_LDFLAGS += -nostdlib++

include $(THEOS_MAKE_PATH)/tweak.mk
