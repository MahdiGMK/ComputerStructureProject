nasm -felf64 ../src/convolution.S -o convolution.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution.o -o convolution

for src in srcimg/*
do
    for krn in kernels/*
    do
# filename=$(basename -- "$fullfile")
        dst="dstimg/$(basename --suffix=.png "$src")_$(basename "$krn")"
        echo "$src + $krn => $dst"
        python imagereader.py "$src" "$krn" | ./convolution  | python imagewriter.py "$dst"
    done
done
