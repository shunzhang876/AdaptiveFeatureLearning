import os
import numpy as np
import matplotlib.pyplot as plt

import caffe

def vis_square(data, save=None, padsize=1, padval=0):
    
    data -= data.min()
    data /= data.max()

    n = int(np.ceil(np.sqrt(data.shape[0])))
    padding = ((0, n ** 2 - data.shape[0]), (0, padsize), (0, padsize)) + ((0, 0),) * (data.ndim - 3)
    data = np.pad(data, padding, mode='constant', constant_values=(padval, padval))

    data = data.reshape((n, n) + data.shape[1:]).transpose((0, 2, 1, 3) + tuple(range(4, data.ndim + 1)))
    data = data.reshape((n * data.shape[1], n * data.shape[3]) + data.shape[4:])

    plt.imshow(data)
    if save is not None:
        plt.savefig(save)
    plt.clf()

DEPLOY_PATH = 'test_triplet_part_c_VIPeR.prototxt'
MODEL_PATH = 'personReID_VIPeR_Triplet_Part_3_C_iter_8000.caffemodel'
IMAGE_PATH = '4.bmp'
FEATURE_PATH = '4'

plt.rcParams['figure.figsize'] = (14, 14)
plt.rcParams['image.interpolation'] = 'nearest'
plt.rcParams['image.cmap'] = 'jet'

net = caffe.Classifier(DEPLOY_PATH, MODEL_PATH,
                       mean=None,
                       channel_swap=(2,1,0),
                       raw_scale=255,
                       image_dims=(230, 80))

input_image = [caffe.io.load_image(IMAGE_PATH)]
scores = net.predict(input_image)

conv1data = net.blobs['conv22'].data[4,:]
vis_square(conv1data, os.path.join(FEATURE_PATH, 'conv2fm.jpg'))

conv21filter = net.params['conv21'][0].data[10,:]
vis_square(conv21filter, os.path.join(FEATURE_PATH, 'conv21filter.jpg'))

conv22filter = net.params['conv22'][0].data[10,:]
vis_square(conv22filter, os.path.join(FEATURE_PATH, 'conv22filter.jpg'))

conv23filter = net.params['conv23'][0].data[10,:]
vis_square(conv23filter, os.path.join(FEATURE_PATH, 'conv23filter.jpg'))

conv24filter = net.params['conv24'][0].data[10,:]
vis_square(conv24filter, os.path.join(FEATURE_PATH, 'conv24filter.jpg'))

#fc7data = net.blobs['fc_8_triplet'].data[4,:]
#plt.subplot(2, 1, 1)
#plt.plot(fc7data.flat)
#plt.subplot(2, 1, 2)
#_ = plt.hist(fc7data.flat[fc7data.flat > 0], bins=40)
#plt.savefig(os.path.join(FEATURE_PATH, 'fc7hist.jpg'))
#plt.clf()

