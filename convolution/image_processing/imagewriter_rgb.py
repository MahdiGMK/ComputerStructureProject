import sys
from PIL import Image
import numpy as np


def create_rgb_image(r, g, b, image_filename):
    sz = len(r)
    image = Image.new('RGB', (sz, sz))
    for y in range(sz):
        for x in range(sz):
            image.putpixel(
                (x, y),
                (int(255 * r[y][x]), int(255 * g[y][x]), int(255 * b[y][x])))
    image.save(image_filename)


# # BOX_BLUR
# matrix = [
#     [1/9, 1/9, 1/9],
#     [1/9, 1/9, 1/9],
#     [1/9, 1/9, 1/9]
# ]
# # GAUSSIAN_BLUR
# matrix = [
#     [0.003765, 0.015019, 0.023792, 0.015019, 0.003765],
#     [0.015019, 0.059912, 0.094907, 0.059912, 0.015019],
#     [0.023792, 0.094907, 0.150342, 0.094907, 0.023792],
#     [0.015019, 0.059912, 0.094907, 0.059912, 0.015019],
#     [0.003765, 0.015019, 0.023792, 0.015019, 0.003765]
# ]
# # SOBEL_EDGE
# matrix = [  # X_EDGE
#     [-1, 0, 1],
#     [-2, 0, 2],
#     [-1, 0, 1]
# ]
# matrix = np.transpose(matrix)  # Y_EDGE
# # SHARPEN
# matrix = [
#     [-0.00391, -0.01563, -0.02344, -0.01563, -0.00391],
#     [-0.01563, -0.06250, -0.09375, -0.06250, -0.01563],
#     [-0.02344, -0.09375,  1.85980, -0.09375, -0.02344],
#     [-0.01563, -0.06250, -0.09375, -0.06250, -0.01563],
#     [-0.00391, -0.01563, -0.02344, -0.01563, -0.00391]
# ]
#
# matrix = np.add(matrix, 2) / 4
sz = int(input())
r = []
for i in range(sz):
    r.append([float(x) for x in input().split()])
input()
g = []
for i in range(sz):
    g.append([float(x) for x in input().split()])
input()
b = []
for i in range(sz):
    b.append([float(x) for x in input().split()])
create_rgb_image(r, g, b, sys.argv[1])
