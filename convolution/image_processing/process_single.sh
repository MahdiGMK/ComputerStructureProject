nasm -felf64 ../src/convolution.S -o convolution.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution.o -o convolution
python imagereader.py "$1" "$2" | ./convolution  | python imagewriter.py "$3"
