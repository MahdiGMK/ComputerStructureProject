b i
display { ((float[512]*)&mat3)[0][0] , ((float[512]*)&mat3)[0][1] }
display { ((float[512]*)&mat3)[1][0] , ((float[512]*)&mat3)[1][1] }
display {$rsi / 512 , $rsi % 512}
display {$rdx / 512 , $rdx % 512}
display {$rdi / 512 , $rdi % 512}
display $ymm0.v8_float
display $ymm1.v8_float
display $ymm2.v8_float
