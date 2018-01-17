addr = 0xc400

all:img

asm:
	nasm -felf32 haribote.nas -o haribote.o
	nasm -o ipl ipl.nas
	gcc -m32 -c bootpack.c -o bootpack.o
	ld -m elf_i386 -N   -Ttext 0xc400 -o haribote  haribote.o bootpack.o
	objcopy -S -O binary -j .text haribote
img:asm
	dd if=ipl of=os.img count=1 bs=512
	dd if=/dev/zero of=os.img bs=512 seek=1 skip=1 count=2879
copy:
	mkdir -p /tmp/floppy
	mount -o loop os.img /tmp/floppy -o fat=12
	sleep 1
	cp haribote /tmp/floppy
	sleep 1
	umount /tmp/floppy
run:
	qemu-system-i386 -fda os.img  
	
clean:
	rm *.o
