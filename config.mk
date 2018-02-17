
IMAGE:=funky.img
ARCH?=x86
OS:=funky
USERSPACE:=funky

SRCDIR:=src
INCLUDE:=-Iinclude/ -I$(SRCDIR)/
LIBDIR:=lib
LINKER:=linker.ld
GRUB:=grub.cfg

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

CFLAGS+=-Wall -Wextra -nostdlib -m$(BITS) --std=c99
CXXFLAGS+=
ASFLAGS+=-f $(EXEFORMAT) 
LDFLAGS+=-n -T $(LINKER) -m $(LDEMU)

ifdef NDEBUG
CFLAGS+=-Os -DNDEBUG
CXXFLAGS+=$(CFLAGS)
ASFLAGS+=
LDFLAGS+=
RELEASE:=release
else
CFLAGS+=-O0 -DDEBUG
CXXFLAGS+=$(CFLAGS)
ASFLAGS+=
LDFLAGS+=
RELEASE:=debug
endif

ifdef DRYRUN
RUN:=@echo
else
RUN:=
endif

BUILD:=target/$(RELEASE)/$(ARCH)-$(OS)-$(USERSPACE)
OBJDIR:=$(BUILD)/obj
KERNEL:=$(BUILD)/kernel.bin
