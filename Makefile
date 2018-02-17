
include config.mk

CXX_SRC:=$(wildcard $(SRCDIR)/*.cpp)
C_SRC:=$(wildcard $(SRCDIR)/*.c)
ASM_SRC:=$(wildcard arch/$(ARCH)/*.asm)

SRC+=$(CXX_SRC) $(C_SRC) $(ASM_SRC)
OBJ+=$(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.cpp.o,$(CXX_SRC)) \
 	$(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.c.o,$(C_SRC)) \
	$(patsubst arch/$(ARCH)/%.asm,$(OBJDIR)/%.asm.o,$(ASM_SRC))
LIB+=$(LIBDIR)/crtbegin.o $(LIBDIR)/crtend.o
IMAGE:=funky.iso
ISO:=isofiles

.PHONY: all run clean mrproper

all: $(IMAGE)

run: $(IMAGE)
	$(RUN) $(QEMU) -cdrom $(IMAGE)

$(IMAGE): $(BUILD) $(OBJDIR) $(ISO) $(GRUB) $(KERNEL)
	$(RUN) cp grub.cfg $(ISO)/boot/grub/
	$(RUN) cp $(KERNEL) $(ISO)/boot/
	$(RUN) grub-mkrescue -o $(IMAGE) $(ISO)

$(LIBDIR)/crtbegin.o $(LIBDIR)/crtend.o:
	$(RUN) OBJ=`$(CC) $(CFLAGS) -print-file-name=$(@F)` && cp "$$OBJ" $@

$(OBJDIR)/%.cpp.o: $(SRCDIR)/%.cpp
	$(RUN) $(CXX) $(CXXLAGS) $(INCLUDE) -c -o $@ $^

$(OBJDIR)/%.c.o: $(SRCDIR)/%.c
	$(RUN) $(CC) $(CFLAGS) $(INCLUDE) -c -o $@ $^

$(OBJDIR)/%.asm.o: arch/$(ARCH)/%.asm
	$(RUN) $(AS) $(ASFLAGS) $(INCLUDE) -o $@ $^

$(KERNEL): $(LINKER) $(OBJ) $(LIB)
	$(RUN) $(LD) $(LDFLAGS) -o $@ $(OBJ) $(LIB)

$(BUILD):
	$(RUN) mkdir -p $(BUILD)

$(OBJDIR):
	$(RUN) mkdir -p $(OBJDIR)

$(ISO):
	$(RUN) mkdir -p $(ISO)/boot/grub

clean:
	$(RUN) rm -rf target
	$(RUN) rm -rf $(ISO)
	$(RUN) rm -f $(LIBDIR)/crtbegin.o
	$(RUN) rm -f $(LIBDIR)/crtend.o

mrproper: clean
	$(RUN) rm -f $(IMAGE)
