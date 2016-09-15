from PIL import Image
import glob
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
import matplotlib.gridspec as gridspec
from operator import itemgetter, attrgetter
from sys import exit
import sys

class Score_Image(object):
    name = ""
    score = 0

    def __init__(self, name, score):
        self.name = name
        self.score = score

    def __repr__(self):
        return repr((self.name, self.score))

    def __str__(self):
        return str(self.name) + ' ' + str(self.score)

arg_list=sys.argv
directory=str(arg_list[1])
image_list = []
num_files = 0;
for filename in glob.glob(directory+'*.jpg'):
    image_list.append(filename)
    num_files = num_files + 1

some_list = []
with open(directory+'result_score.txt','r') as f:
    for line in f:
        words = line.split()
        ims = Score_Image(words[0], words[1])
        some_list.append(ims)

some_list = sorted(some_list, key=attrgetter('score'), reverse=True)
for i in some_list:
    print(i.name + ' ' + i.score)

fig = plt.figure()

for i in range(min(num_files, 16)):
    a = fig.add_subplot(4,4,i+1)
    a.xaxis.set_visible(False)
    a.yaxis.set_visible(False)
    img = mpimg.imread(image_list[i])
    imgplot = plt.imshow(img)

plt.show()
exit(0)
