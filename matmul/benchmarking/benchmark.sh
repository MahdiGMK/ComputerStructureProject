nasm -felf64 ../src/matmul.S -o matmul.o
gcc -O3 -no-pie -fno-pie ../src/main.c matmul.o -o asm_exec

nasm -felf64 ../src/matmul_sisd.S -o matmul_sisd.o
gcc -O3 -no-pie -fno-pie ../src/main.c matmul_sisd.o -o asm_sisd_exec

nasm -felf64 ../src/matmul_dotprod.S -o matmul_dotprod.o
gcc -O3 -no-pie -fno-pie ../src/main.c matmul_dotprod.o -o asm_dotprod_exec

nasm -felf64 ../src/matmul_dotprod_sisd.S -o matmul_dotprod_sisd.o
gcc -O3 -no-pie -fno-pie ../src/main.c matmul_dotprod_sisd.o -o asm_dotprod_sisd_exec

gcc -O3 ../src/matmul_samealgo.c -o c_same_exec

gcc -O3 ../src/matmul_normalalgo.c -o c_normal_exec

gcc -O0 ../src/matmul_samealgo.c -o c_same0_exec

gcc -O0 ../src/matmul_normalalgo.c -o c_normal0_exec

gcc -O3 diffchecker.c -o diffchecker

flag=0


python testgen.py

declare -A asmTimer
declare -A asmsisdTimer
declare -A asmdotTimer
declare -A asmdotsisdTimer
declare -A csameTimer
declare -A cnormalTimer
declare -A csame0Timer
declare -A cnormal0Timer
for t in test_*.in
do
    asmTimer["$t"]=0.0;
    asmsisdTimer["$t"]=0.0;
    asmdotTimer["$t"]=0.0;
    asmdotsisdTimer["$t"]=0.0;
    csameTimer["$t"]=0.0;
    cnormalTimer["$t"]=0.0;
    csame0Timer["$t"]=0.0;
    cnormal0Timer["$t"]=0.0;
done


for i in $(seq 10)
do
    echo "TEST $i"
    python testgen.py
    for t in test_*.in
    do
        time1=$(date +%s.%N)
        ./asm_exec < $t > /dev/null
        time2=$(date +%s.%N)
        ./c_same_exec < $t > /dev/null
        time3=$(date +%s.%N)
        ./c_normal_exec < $t > c_same.out
        time4=$(date +%s.%N)
        ./asm_dotprod_exec < $t > /dev/null
        time5=$(date +%s.%N)
        ./c_same0_exec < $t > /dev/null
        time6=$(date +%s.%N)
        ./c_normal0_exec < $t > /dev/null
        time7=$(date +%s.%N)
        ./asm_sisd_exec < $t > /dev/null
        time8=$(date +%s.%N)
        ./asm_dotprod_sisd_exec < $t > asm.out
        time9=$(date +%s.%N)
        
        

        asmTimer["$t"]=$(echo "$time2 - $time1 + "${asmTimer["$t"]} | bc)
        csameTimer["$t"]=$(echo "$time3 - $time2 + "${csameTimer["$t"]} | bc)
        cnormalTimer["$t"]=$(echo "$time4 - $time3 + "${cnormalTimer["$t"]} | bc)
        asmdotTimer["$t"]=$(echo "$time5 - $time4 + "${asmdotTimer["$t"]} | bc)
        csame0Timer["$t"]=$(echo "$time6 - $time5 + "${csame0Timer["$t"]} | bc)
        cnormal0Timer["$t"]=$(echo "$time7 - $time6 + "${cnormal0Timer["$t"]} | bc)
        asmsisdTimer["$t"]=$(echo "$time8 - $time7 + "${asmsisdTimer["$t"]} | bc)
        asmdotsisdTimer["$t"]=$(echo "$time9 - $time8 + "${asmdotsisdTimer["$t"]} | bc)
        
        ./diffchecker $t asm.out c_same.out
        if [[ $? -eq 1 ]]; then
            echo "ERROR IN TEST $t"
            flag=1
            break 
        fi
        
    done

    if [[ $flag -eq 1 ]]; then
        break 
    fi
done

echo "Code\t\t\t1<=n<=16\t\t16<n<=64\t\t64<n<=256\t\t256<n<=384\t\t384<n<=512\t\tn=512"
echo 'assembly(normal simd)\t'${asmTimer["test_1.in"]}"\t\t"${asmTimer["test_2.in"]}"\t\t"${asmTimer["test_3.in"]}"\t\t"${asmTimer["test_4.in"]}"\t\t"${asmTimer["test_5.in"]}"\t\t"${asmTimer["test_6.in"]}
echo 'assembly(normal sisd)\t'${asmsisdTimer["test_1.in"]}"\t\t"${asmsisdTimer["test_2.in"]}"\t\t"${asmsisdTimer["test_3.in"]}"\t\t"${asmsisdTimer["test_4.in"]}"\t\t"${asmsisdTimer["test_5.in"]}"\t\t"${asmsisdTimer["test_6.in"]}
echo 'assembly(dotprod simd)\t'${asmdotTimer["test_1.in"]}"\t\t"${asmdotTimer["test_2.in"]}"\t\t"${asmdotTimer["test_3.in"]}"\t\t"${asmdotTimer["test_4.in"]}"\t\t"${asmdotTimer["test_5.in"]}"\t\t"${asmdotTimer["test_6.in"]}
echo 'assembly(dotprod sisd)\t'${asmdotsisdTimer["test_1.in"]}"\t\t"${asmdotsisdTimer["test_2.in"]}"\t\t"${asmdotsisdTimer["test_3.in"]}"\t\t"${asmdotsisdTimer["test_4.in"]}"\t\t"${asmdotsisdTimer["test_5.in"]}"\t\t"${asmdotsisdTimer["test_6.in"]}
echo 'c(normal gcc -O3)\t'${cnormalTimer["test_1.in"]}"\t\t"${cnormalTimer["test_2.in"]}"\t\t"${cnormalTimer["test_3.in"]}"\t\t"${cnormalTimer["test_4.in"]}"\t\t"${cnormalTimer["test_5.in"]}"\t\t"${cnormalTimer["test_6.in"]}
echo 'c(normal gcc -O0)\t'${cnormal0Timer["test_1.in"]}"\t\t"${cnormal0Timer["test_2.in"]}"\t\t"${cnormal0Timer["test_3.in"]}"\t\t"${cnormal0Timer["test_4.in"]}"\t\t"${cnormal0Timer["test_5.in"]}"\t\t"${cnormal0Timer["test_6.in"]}
echo 'c(dotprod gcc -O3)\t'${csameTimer["test_1.in"]}"\t\t"${csameTimer["test_2.in"]}"\t\t"${csameTimer["test_3.in"]}"\t\t"${csameTimer["test_4.in"]}"\t\t"${csameTimer["test_5.in"]}"\t\t"${csameTimer["test_6.in"]}
echo 'c(dotprod gcc -O0)\t'${csame0Timer["test_1.in"]}"\t\t"${csame0Timer["test_2.in"]}"\t\t"${csame0Timer["test_3.in"]}"\t\t"${csame0Timer["test_4.in"]}"\t\t"${csame0Timer["test_5.in"]}"\t\t"${csame0Timer["test_6.in"]}
