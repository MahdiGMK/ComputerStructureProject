# nasm -felf64 src/convolution.S -o convolution.o
# gcc -no-pie -fno-pie src/main.c convolution.o -o exec
#
# nasm -felf64 src/playground.S -o playground.o
# gcc -no-pie -fno-pie src/main.c playground.o -o play

nasm -felf64 src/convolution_matmul_simd.S -o convolution.o
gcc -no-pie -fno-pie src/main.c convolution.o -o exec
