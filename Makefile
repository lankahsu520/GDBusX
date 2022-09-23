PWD=$(shell pwd)
-include $(SDK_CONFIG_CONFIG)

#** include *.mk **
-include define.mk

#[major].[minor].[revision].[build]
VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_REVISION = 0
VERSION_FULL = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_REVISION)
LIBNAME_A =
LIBNAME_SO = gdbusx
LIBNAME_MOD =

LIBGDBUSX_VERSION="0x$(shell printf "%02X" $(VERSION_MAJOR))$(shell printf "%03X" $(VERSION_MINOR))$(shell printf "%03X" $(VERSION_REVISION))"

#** CFLAGS & LDFLAGS **
CFLAGS += $(CFLAGS_OTHERS) $(CFLAGS_CUSTOMER)

CFLAGS += \
					-I./
LDFLAGS += \
					-L./
ARFLAGS = rcs

#** LIBXXX_OBJS **
LIBXXX_OBJS += \
							$(GDBUSX_C_FILENAME).o \
							gdbusx.o

#** LIBXXX_yes **
ifneq ("$(LIBNAME_A)", "")
LIBXXX_A = lib$(LIBNAME_A).a
LIBXXXS_yes += $(LIBXXX_A)
endif
ifneq ("$(LIBNAME_SO)", "")
LIBXXX_SO = lib$(LIBNAME_SO).so
LIBXXXS_yes += -l$(LIBNAME_SO)
endif
ifneq ("$(LIBNAME_MOD)", "")
LIBXXX_MOD = $(LIBNAME_MOD).so
endif

#** HEADER_FILES **
HEADER_FILES = \
							gdbusx.h

#** librarys **
LIBS_yes = $(LIBXXXS_yes)
#** LIBS_yes, CLEAN_BINS, DUMMY_BINS  **
-include ./library.mk

LIBS += $(LIBS_yes)

#** Clean **
CLEAN_OBJS = $(LIBXXX_OBJS)
CLEAN_LIBS = $(LIBXXX_A) $(LIBXXX_SO) $(LIBXXX_MOD)

#** Target (CLEAN_BINS) **
CLEAN_BINS += \
							gdbusx_123

#** Target (DUMMY_BINS) **
DUMMY_BINS += \

CLEAN_BINS += $(DUMMY_BINS)
CLEAN_OBJS += $(addsuffix .o, $(CLEAN_BINS))

#** Target (SHELL_SBINS) **
SHELL_SBINS = \

DUMMY_SBINS = $(SHELL_SBINS)

#** Target (CONFS) **
CONFS = \
				$(wildcard conf/*.conf)

#** Target (AUTO_GENERATEDS) **
AUTO_GENERATEDS = \
									$(GDBUSX_C_FILENAME).c \
									$(GDBUSX_C_FILENAME).h

TO_FOLDER =

.DEFAULT_GOAL = all
.SUFFIXES: .c .o

.PHONY: all clean distclean install romfs
all: .configured $(CLEAN_BINS) $(CLEAN_LIBS)

%.o: %.c $(HEADER_FILES)
	@echo 'Compiling file: $<'
	$(CC) $(CFLAGS) -c -o"$@" "$<"
	@echo 'Finished compiling: $<'
	@echo ' '

$(CLEAN_BINS): $(CLEAN_OBJS) $(CLEAN_LIBS)
	@echo 'Building target: $@'
	$(CC) -o $@ $@.o $(LDFLAGS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

clean:
	$(PJ_SH_RM) Makefile.bak $(CLEAN_BINS) $(CLEAN_BINS:=.elf) $(CLEAN_BINS:=.gdb) $(AUTO_GENERATEDS)
	$(PJ_SH_RM) .configured .patched $(addsuffix *, $(CLEAN_LIBS)) $(CLEAN_OBJS) $(CLEAN_OBJS:%.o=%.c.bak) $(CLEAN_OBJS:%.o=%.h.bak)
	@for subbin in $(CLEAN_BINS); do \
		($(PJ_SH_RM) $(SDK_BIN_DIR)/$$subbin;); \
	done
	@for sublib in $(CLEAN_LIBS); do \
		($(PJ_SH_RM) $(SDK_LIB_DIR)/$$sublib*;); \
	done
	@for subheader in $(HEADER_FILES); do \
		($(PJ_SH_RM) $(SDK_INC_DIR)/$$subheader;); \
	done
	@for subshell in $(SHELL_SBINS); do \
		($(PJ_SH_RM) $(SDK_SBIN_DIR)/$$subshell;); \
	done

distclean: clean
	[ -L meson_public ] && ($(PJ_SH_RMDIR) meson_public; ) || true
	[ -d ./subprojects ] && [ -f meson.build ] && (meson subprojects purge --confirm;) || true
	$(PJ_SH_RMDIR) build_xxx .meson_config build.meson meson_options.txt
	[ -f ".customer" ] && ($(PJ_SH_RM) .customer $(CONFIG_CUSTOMER) $(CONFIG_CUSTOMER).export $(CONFIG_CUSTOMER_DEF_H) $(CONFIG_MESON); ) || true
	[ -d "install" ] && ($(PJ_SH_RMDIR) install; ) || true

%.a: $(LIBXXX_OBJS)
	@echo 'Building lib (static): $@'
	$(AR) $(ARFLAGS) $@ $(LIBXXX_OBJS)
	@echo 'Finished building lib (static): $@'
	@echo ' '

%.so: $(LIBXXX_OBJS)
	@echo 'Building lib (shared): $@'
	$(CC) -shared $(LDFLAGS) -Wl,-soname,$@.$(VERSION_MAJOR) -o $@.$(VERSION_FULL) $(LIBXXX_OBJS)
	ln -sf $@.$(VERSION_FULL) $@.$(VERSION_MAJOR)
	ln -sf $@.$(VERSION_MAJOR) $@
	@echo 'Finished building lib (shared): $@'
	@echo ' '

install: all
	[ "$(CLEAN_BINS)" = "" ] || $(PJ_SH_MKDIR) $(SDK_BIN_DIR)
	@for subbin in $(CLEAN_BINS); do \
		$(PJ_SH_CP) $$subbin $(SDK_BIN_DIR); \
		$(STRIP) $(SDK_BIN_DIR)/`basename $$subbin`; \
	done
	[ "$(LIBXXX_SO)" = "" ] || $(PJ_SH_MKDIR) $(SDK_LIB_DIR)
	@for sublib in $(LIBXXX_SO); do \
		$(PJ_SH_CP) $$sublib* $(SDK_LIB_DIR); \
		$(STRIP) $(SDK_LIB_DIR)/$$sublib.$(VERSION_FULL); \
	done
	[ "$(HEADER_FILES)" = "" ] || $(PJ_SH_MKDIR) $(SDK_INC_DIR)
	@for subheader in $(HEADER_FILES); do \
		$(PJ_SH_CP) $$subheader $(SDK_INC_DIR); \
	done
	[ "$(SHELL_SBINS)" = "" ] || $(PJ_SH_MKDIR) $(SDK_SBIN_DIR)
	@for subshell in $(SHELL_SBINS); do \
		$(PJ_SH_CP) $$subshell $(SDK_SBIN_DIR); \
	done
	[ "$(CONFS)" = "" ] || $(PJ_SH_MKDIR) $(SDK_IOT_DIR)/$(TO_FOLDER)
	@for conf in $(CONFS); do \
		$(PJ_SH_CP) $$conf $(SDK_IOT_DIR)/$(TO_FOLDER); \
	done

romfs: install
ifneq ("$(HOMEX_ROOT_DIR)", "")
	[ "$(DUMMY_BINS)" = "" ] || $(PJ_SH_MKDIR) $(HOMEX_BIN_DIR)
	@for subbin in $(DUMMY_BINS); do \
		$(PJ_SH_CP) $$subbin $(HOMEX_BIN_DIR); \
		$(STRIP) $(HOMEX_BIN_DIR)/`basename $$subbin`; \
	done
	[ "$(LIBXXX_SO)" = "" ] || $(PJ_SH_MKDIR) $(HOMEX_LIB_DIR)
	@for sublib in $(LIBXXX_SO); do \
		$(PJ_SH_CP) $$sublib* $(HOMEX_LIB_DIR); \
		$(STRIP) $(HOMEX_LIB_DIR)/$$sublib.$(VERSION_FULL); \
	done
	#[ "$(HEADER_FILES)" = "" ] || $(PJ_SH_MKDIR) $(HOMEX_INC_DIR)
	#@for subheader in $(HEADER_FILES); do \
	#	$(PJ_SH_CP) $$subheader $(HOMEX_INC_DIR); \
	#done
	[ "$(DUMMY_SBINS)" = "" ] || $(PJ_SH_MKDIR) $(HOMEX_SBIN_DIR)
	@for subshell in $(DUMMY_SBINS); do \
		$(PJ_SH_CP) $$subshell $(HOMEX_SBIN_DIR); \
	done
	[ "$(CONFS)" = "" ] || $(PJ_SH_MKDIR) $(HOMEX_IOT_DIR)/$(TO_FOLDER)
	@for conf in $(CONFS); do \
		$(PJ_SH_CP) $$conf $(HOMEX_IOT_DIR)/$(TO_FOLDER); \
	done
endif
