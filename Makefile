ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = TheWorldPatcher
TheWorldPatcher_FILES = Tweak.xm
TheWorldPatcher_FRAMEWORKS = UIKit Social

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
