
include config.mk

CXX_SRC:=$(wildcard $(SRCDIR)/*.cpp)
C_SRC:=$(wildcard $(SRCDIR)/*.c)
ASM_SRC:=$(wildcard arch/$(ARCH)/*.asm)

SRC+=$(CXX_SRC) $(C_SRC) $(ASM_SRC)
OBJ+=$(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.cpp.o,$(CXX_SRC)) \
 	$(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.c.o,$(C_SRC)) \
	$(patsubst arch/$(ARCH)/%.asm,$(OBJDIR)/%.asm.o,$(ASM_SRC))
LIB+=
IMAGE:=funky.iso
ISO:=isofiles

.PHONY: all run clean mrproper

all: $(IMAGE)

run: $(IMAGE)
	$(RUN) $(QEMU) -cdrom $(IMAGE)

$(IMAGE): $(KERNEL)
	$(RUN) mkdir -p $(ISO)/boot/grub
	$(RUN) cp grub.cfg $(ISO)/boot/grub/
	$(RUN) cp $(KERNEL) $(ISO)/boot/
	$(RUN) grub-mkrescue -o $(IMAGE) $(ISO)

$(OBJDIR)/%.cpp.o: $(SRCDIR)/%.cpp
	$(RUN) mkdir -p $(OBJDIR)
	$(RUN) $(CXX) $(CXXLAGS) $(INCLUDE) -c -o $@ $^

$(OBJDIR)/%.c.o: $(SRCDIR)/%.c
	$(RUN) mkdir -p $(OBJDIR)
	$(RUN) $(CC) $(CFLAGS) $(INCLUDE) -c -o $@ $^

$(OBJDIR)/%.asm.o: arch/$(ARCH)/%.asm
	$(RUN) mkdir -p $(OBJDIR)
	$(RUN) $(AS) $(ASFLAGS) $(INCLUDE) -o $@ $^

$(KERNEL): $(OBJ) $(LIB)
	$(RUN) mkdir -p $(BUILD)
	$(RUN) $(LD) $(LDFLAGS) -o $@ $^

clean:
	$(RUN) rm -rf target
	$(RUN) rm -rf $(ISO)

mrproper: clean
	$(RUN) rm -f $(IMAGE)
