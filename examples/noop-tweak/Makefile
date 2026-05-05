export THEOS=/home/bitcrusher32/theos

ARCHS = armv7
TARGET = iphone:clang:9.3:6.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoOpTweak

NoOpTweak_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

# Explicit SDK lib path for legacy ld64/toolchain handoff.
NoOpTweak_LDFLAGS += -L$(THEOS)/sdks/iPhoneOS9.3.sdk/usr/lib

# Temporary linker overlay experiment.
NoOpTweak_LDFLAGS += -L$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/usr/lib

# Temporary framework overlay experiment.
NoOpTweak_LDFLAGS += -F$(HOME)/ios-sdk-lib-overlay/iPhoneOS9.3/System/Library/Frameworks

# No-op smoke test does not need C++ runtime.
NoOpTweak_LDFLAGS += -nostdlib++
