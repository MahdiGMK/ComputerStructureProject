nasm -felf64 ../src/convolution.S -o convolution.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution.o -o asm_exec

nasm -felf64 ../src/convolution_sisd.S -o convolution_sisd.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution_sisd.o -o asm_sisd_exec

nasm -felf64 ../src/convolution_matmul_sisd.S -o convolution_matmul_sisd.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution_matmul_sisd.o -o asmmatmulsisd_exec

nasm -felf64 ../src/convolution_matmul_simd.S -o convolution_matmul_simd.o
gcc -O3 -no-pie -fno-pie ../src/main.c convolution_matmul_simd.o -o asmmatmulsimd_exec

gcc -O3 ../src/convolution.c -o c_same_exec

gcc -O0 ../src/convolution.c -o c_same0_exec

gcc -O3 diffchecker.c -o diffchecker -lm

flag=0


python testgen.py

declare -A asmTimer
declare -A asmsisdTimer
declare -A asmmatmulsisdTimer
declare -A asmmatmulsimdTimer
# declare -A asmdotTimer
declare -A csameTimer
# declare -A cnormalTimer
declare -A csame0Timer
# declare -A cnormal0Timer
for t in test_*.in
do
    asmTimer["$t"]=0.0;
    asmsisdTimer["$t"]=0.0;
    # asmdotTimer["$t"]=0.0;
    csameTimer["$t"]=0.0;
    # cnormalTimer["$t"]=0.0;
    csame0Timer["$t"]=0.0;
    asmmatmulsisdTimer["$t"]="    DNF\t";
    asmmatmulsimdTimer["$t"]="    DNF\t";
    # cnormal0Timer["$t"]=0.0;
done
asmmatmulsisdTimer["test_1.in"]=0.0;
asmmatmulsimdTimer["test_1.in"]=0.0;


for i in $(seq 10)
do
    echo "TEST $i"
    python testgen.py
    for t in test_*.in
    do
        time1=$(date +%s.%N)
        ./asm_exec < $t > /dev/null
        time2=$(date +%s.%N)
        ./c_same_exec < $t > c_same.out
        time3=$(date +%s.%N)
        ./asm_sisd_exec < $t > /dev/null
        time4=$(date +%s.%N)
        ./c_same0_exec < $t > /dev/null
        time5=$(date +%s.%N)
        if [[ $t == "test_1.in" ]]; then
            ./asmmatmulsisd_exec < $t > asm.out
            time6=$(date +%s.%N)
            ./asmmatmulsimd_exec < $t > asm.out
            time7=$(date +%s.%N)

            ./diffchecker $t asm.out c_same.out
            if [[ $? -eq 1 ]]; then
                echo "ERROR IN TEST $t"
                flag=1
                break 
            fi
        fi
        # ./c_normal_exec < $t > /dev/null
        # time4=$(date +%s.%N)
        # ./asm_dotprod_exec < $t > /dev/null
        # time5=$(date +%s.%N)
        # ./c_same0_exec < $t > /dev/null
        # time6=$(date +%s.%N)
        # ./c_normal0_exec < $t > /dev/null
        # time7=$(date +%s.%N)
        

        asmTimer["$t"]=$(echo "$time2 - $time1 + "${asmTimer["$t"]} | bc)
        csameTimer["$t"]=$(echo "$time3 - $time2 + "${csameTimer["$t"]} | bc)
        asmsisdTimer["$t"]=$(echo "$time4 - $time3 + "${asmsisdTimer["$t"]} | bc)
        csame0Timer["$t"]=$(echo "$time5 - $time4 + "${csame0Timer["$t"]} | bc)
        if [[ $t == "test_1.in" ]]; then
            asmmatmulsisdTimer["$t"]=$(echo "$time6 - $time5 + "${asmmatmulsisdTimer["$t"]} | bc)
            asmmatmulsimdTimer["$t"]=$(echo "$time7 - $time6 + "${asmmatmulsimdTimer["$t"]} | bc)
        fi
        # cnormalTimer["$t"]=$(echo "$time4 - $time3 + "${cnormalTimer["$t"]} | bc)
        # asmdotTimer["$t"]=$(echo "$time5 - $time4 + "${asmdotTimer["$t"]} | bc)
        # csame0Timer["$t"]=$(echo "$time6 - $time5 + "${csame0Timer["$t"]} | bc)
        # cnormal0Timer["$t"]=$(echo "$time7 - $time6 + "${cnormal0Timer["$t"]} | bc)
        
        
    done

    if [[ $flag -eq 1 ]]; then
        break 
    fi
done

echo "Code\t\t\t1<=n<=32\t\t32<n<=128\t\t128<n<=512\t\t512<n<=768\t\t768<n<=1024\t\tn=1024"
echo 'assembly(normal)\t'${asmTimer["test_1.in"]}"\t\t"${asmTimer["test_2.in"]}"\t\t"${asmTimer["test_3.in"]}"\t\t"${asmTimer["test_4.in"]}"\t\t"${asmTimer["test_5.in"]}"\t\t"${asmTimer["test_6.in"]}
echo 'assembly(normal sisd)\t'${asmsisdTimer["test_1.in"]}"\t\t"${asmsisdTimer["test_2.in"]}"\t\t"${asmsisdTimer["test_3.in"]}"\t\t"${asmsisdTimer["test_4.in"]}"\t\t"${asmsisdTimer["test_5.in"]}"\t\t"${asmsisdTimer["test_6.in"]}
echo 'assembly(matmul)\t'${asmmatmulsimdTimer["test_1.in"]}"\t\t"${asmmatmulsimdTimer["test_2.in"]}"\t\t"${asmmatmulsimdTimer["test_3.in"]}"\t\t"${asmmatmulsimdTimer["test_4.in"]}"\t\t"${asmmatmulsimdTimer["test_5.in"]}"\t\t"${asmmatmulsimdTimer["test_6.in"]}
echo 'assembly(matmul sisd)\t'${asmmatmulsisdTimer["test_1.in"]}"\t\t"${asmmatmulsisdTimer["test_2.in"]}"\t\t"${asmmatmulsisdTimer["test_3.in"]}"\t\t"${asmmatmulsisdTimer["test_4.in"]}"\t\t"${asmmatmulsisdTimer["test_5.in"]}"\t\t"${asmmatmulsisdTimer["test_6.in"]}
echo 'c(normal gcc -O3)\t'${csameTimer["test_1.in"]}"\t\t"${csameTimer["test_2.in"]}"\t\t"${csameTimer["test_3.in"]}"\t\t"${csameTimer["test_4.in"]}"\t\t"${csameTimer["test_5.in"]}"\t\t"${csameTimer["test_6.in"]}
# echo 'c(normal gcc -O3)\t'${cnormalTimer["test_1.in"]}"\t\t"${cnormalTimer["test_2.in"]}"\t\t"${cnormalTimer["test_3.in"]}"\t\t"${cnormalTimer["test_4.in"]}"\t\t"${cnormalTimer["test_5.in"]}"\t\t"${cnormalTimer["test_6.in"]}
echo 'c(normal gcc -O0)\t'${csame0Timer["test_1.in"]}"\t\t"${csame0Timer["test_2.in"]}"\t\t"${csame0Timer["test_3.in"]}"\t\t"${csame0Timer["test_4.in"]}"\t\t"${csame0Timer["test_5.in"]}"\t\t"${csame0Timer["test_6.in"]}
# echo 'c(normal gcc -O0)\t'${cnormal0Timer["test_1.in"]}"\t\t"${cnormal0Timer["test_2.in"]}"\t\t"${cnormal0Timer["test_3.in"]}"\t\t"${cnormal0Timer["test_4.in"]}"\t\t"${cnormal0Timer["test_5.in"]}"\t\t"${cnormal0Timer["test_6.in"]}
