import random as rand


def generate_test(n, file):
    file.write('%u ' % n)
    m = rand.randint(1, n)
    file.write('%u\n' % m)
    for i in range(n):
        file.write(''.join(['%0.4f ' % rand.random() for j in range(n)]))
        file.write('\n')
    for i in range(m):
        file.write(''.join(['%0.4f ' % rand.random() for j in range(m)]))
        file.write('\n')


with open("test_1.in", "w") as file:
    n = rand.randint(1, 32)
    generate_test(n, file)

with open("test_2.in", "w") as file:
    n = rand.randint(33, 128)
    generate_test(n, file)

with open("test_3.in", "w") as file:
    n = rand.randint(129, 512)
    generate_test(n, file)

with open("test_4.in", "w") as file:
    n = rand.randint(513, 768)
    generate_test(n, file)

with open("test_5.in", "w") as file:
    n = rand.randint(768, 1024)
    generate_test(n, file)

with open("test_6.in", "w") as file:
    n = 1024
    generate_test(n, file)
