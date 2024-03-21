nasm -felf64 ../src/convolution.S -o convolution.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution.o -o convolution

python imagereader_rgb.py "$1" "$2" "R" | ./convolution > inp
python imagereader_rgb.py "$1" "$2" "G" | ./convolution >> inp
python imagereader_rgb.py "$1" "$2" "B" | ./convolution >> inp

python imagewriter_rgb.py "$3" < inp
rm inp
