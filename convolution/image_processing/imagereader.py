import sys
from PIL import Image


def get_grayscale_matrix(image_filename):
    image = Image.open(image_filename)
    image = image.convert('L')
    width, height = image.size
    if width >= height and width > 1024:
        height = int(height * 1024 / width)
        width = 1024
    elif height > 1024:
        width = int(width * 1024 / height)
        height = 1024
    image = image.resize((width, height))
    pixels = list(image.getdata())
    width, height = image.size
    sz = max(width, height)
    grayscale_matrix = [[0 for x in range(sz)] for y in range(sz)]
    for y in range(height):
        for x in range(width):
            grayscale_matrix[y][x] = pixels[y * width + x]

    return grayscale_matrix


grayscale_matrix = get_grayscale_matrix(sys.argv[1])
kernel_matrix = get_grayscale_matrix(sys.argv[2])

print(len(grayscale_matrix), len(kernel_matrix))
for row in grayscale_matrix:
    for x in row:
        print(x / 255, end=' ')
    print()
for row in kernel_matrix:
    for x in row:
        print((4 * x / 255) - 2, end=' ')
    print()
