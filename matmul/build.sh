nasm -felf64 src/matmul.S -o matmul.o
gcc -no-pie -fno-pie src/main.c matmul.o -o exec

nasm -felf64 src/playground.S -o playground.o
gcc -no-pie -fno-pie src/main.c playground.o -o play

