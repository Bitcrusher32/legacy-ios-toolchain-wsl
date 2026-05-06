export THEOS=/home/bitcrusher32/theos

ARCHS = armv7
TARGET = iphone:clang:9.3:6.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LogosLoggingTest

LogosLoggingTest_FILES = Tweak.xm

LogosLoggingTest_LDFLAGS += -L$(THEOS)/sdks/iPhoneOS9.3.sdk/usr/lib
LogosLoggingTest_LDFLAGS += -L$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/usr/lib
LogosLoggingTest_LDFLAGS += -F$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/System/Library/Frameworks
LogosLoggingTest_LDFLAGS += -nostdlib++

include $(THEOS_MAKE_PATH)/tweak.mk
