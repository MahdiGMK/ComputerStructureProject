nasm -felf64 ../src/matmul.S -o matmul.o
gcc -no-pie -fno-pie matmul.o ../src/main.c -o exec
cargo run | ./exec
