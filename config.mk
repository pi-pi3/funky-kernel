
IMAGE:=funky.img
ARCH?=x86
OS:=funky
USERSPACE:=funky

SRCDIR:=src
INCLUDE:=-Iinclude/ -I$(SRCDIR)/
BUILD:=target/$(ARCH)-$(OS)-$(USERSPACE)
LIBDIR:=lib
OBJDIR:=$(BUILD)/obj
LINKER:=linker.ld
KERNEL:=$(BUILD)/kernel.bin

CC:=gcc
CXX:=g++
AS:=nasm
LD:=ld

ifeq ($(ARCH),x86_64)
EXEFORMAT:=elf64
BITS:=64
LDEMU:=elf_x86_64
QEMU:=qemu-system-x86_64
else ifeq ($(ARCH),x86)
EXEFORMAT:=elf32
BITS:=32
LDEMU:=elf_i386
QEMU:=qemu-system-i386
else
$(error invalid arch \"$(ARCH)\")
endif

CFLAGS+=-Wall -nostdlib -m$(BITS)
CXXFLAGS+=
ASFLAGS+=-f $(EXEFORMAT) 
LDFLAGS+=-n -T $(LINKER) -m $(LDEMU)

ifdef NDEBUG
CFLAGS+=-Os -DNDEBUG
CXXFLAGS+=$(CFLAGS)
ASFLAGS+=
LDFLAGS+=
else
CFLAGS+=-O0 -DDEBUG
CXXFLAGS+=$(CFLAGS)
ASFLAGS+=
LDFLAGS+=
endif

ifdef DRYRUN
RUN:=@echo
else
RUN:=
endif
