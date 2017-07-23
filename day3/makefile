all:img

asm:
	nasm -o haribote.sys haribote.nas
	nasm -o ipl ipl.nas
img:asm
	dd if=ipl of=os.img count=1 bs=512
	dd if=/dev/zero of=os.img bs=512 seek=1 skip=1 count=2879
copy:
	sudo mkdir -p /tmp/floppy
	sudo mount -o loop os.img /tmp/floppy -o fat=12
	sleep 1
	sudo cp haribote.sys /tmp/floppy
	sleep 1
	sudo umount /tmp/floppy
run:
	qemu-system-i386 -fda os.img  
