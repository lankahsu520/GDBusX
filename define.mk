
export GDBUSX_C_FILENAME=gdbusx_ifac
#export GDBUSX_PREFIXNAME=lankahsu520
#export GDBUSX_IFAC_NAME=com.lankahsu520.www.
export GDBUSX_XML_FILENAME=Interface-com.github.lankahsu520.xml

$(GDBUSX_C_FILENAME).c: $(GDBUSX_XML_FILENAME)
	#https://www.freedesktop.org/software/gstreamer-sdk/data/docs/latest/gio/gdbus-codegen.html
	gdbus-codegen \
		--generate-c-code $(GDBUSX_C_FILENAME) \
		$(GDBUSX_XML_FILENAME)
	#	--c-namespace $(GDBUSX_PREFIXNAME)
	#	--interface-prefix $(GDBUSX_IFAC_NAME)

.patched:
	sed -i "s|#define LIBGDBUSX_VERSION.*|#define LIBGDBUSX_VERSION $(LIBGDBUSX_VERSION)|g" gdbusx.h

	touch $@

.configured: .patched $(GDBUSX_C_FILENAME).c

	touch $@

