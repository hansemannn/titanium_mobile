#
# Appcelerator Titanium Mobile
# Copyright (c) 2011-2016 by Appcelerator, Inc. All Rights Reserved.
# Licensed under the terms of the Apache Public License
# Please see the LICENSE included with this distribution for details.
#
#
# Top level kroll-v8 runtime Makefile

LOCAL_PATH := $(call my-dir)
THIS_DIR = $(LOCAL_PATH)

include $(CLEAR_VARS)

include $(LOCAL_PATH)/genSources.mk
include $(LOCAL_PATH)/common.mk

# https://jira.appcelerator.org/browse/TIMOB-15263
LOCAL_DISABLE_FORMAT_STRING_CHECKS=true

LOCAL_MODULE := kroll-v8
LOCAL_CFLAGS := $(CFLAGS)
LOCAL_LDLIBS := $(LDLIBS)
LOCAL_SRC_FILES := $(SRC_FILES)

LOCAL_JS_FILES := $(JS_FILES)

# When setting v8_enable_i18n_support=0
LOCAL_WHOLE_STATIC_LIBRARIES := libv8_libbase libv8_libplatform libv8_base libv8_nosnapshot libv8_builtins_generators libv8_builtins_setup

include $(BUILD_SHARED_LIBRARY)

NDK_MODULE_PATH := $(LOCAL_PATH)/../ndk-modules
$(call import-module,libv8)
