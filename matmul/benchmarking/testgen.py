import random as rand


def generate_test(n, file):
    file.write('%u\n' % n)
    for i in range(n):
        file.write(''.join(['%0.4f ' % rand.random() for j in range(n)]))
        file.write('\n')
    for i in range(n):
        file.write(''.join(['%0.4f ' % rand.random() for j in range(n)]))
        file.write('\n')


with open("test_1.in", "w") as file:
    n = rand.randint(1, 16)
    generate_test(n, file)

with open("test_2.in", "w") as file:
    n = rand.randint(17, 64)
    generate_test(n, file)

with open("test_3.in", "w") as file:
    n = rand.randint(65, 256)
    generate_test(n, file)

with open("test_4.in", "w") as file:
    n = rand.randint(257, 384)
    generate_test(n, file)

with open("test_5.in", "w") as file:
    n = rand.randint(385, 512)
    generate_test(n, file)

with open("test_6.in", "w") as file:
    n = 512
    generate_test(n, file)
