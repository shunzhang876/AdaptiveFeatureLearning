import numpy as np
import matplotlib.pyplot as plt
caffe_root = '/home/shun/work/caffe-triplet-master/'
import sys
sys.path.insert(0, caffe_root + 'python/')
import caffe

MODEL_FILE = caffe_root + 'examples/mnist_triplet/mnist_triplet.prototxt'
PRETRAINED = caffe_root + 'examples/mnist_triplet/caffemodel/mnist_triplet_iter_50000.caffemodel'
#MODEL_FILE = '/home/vision/tools/caffe-master/models/face_verify/deploy.prototxt'
#PRETRAINED = '/home/vision/tools/caffe-master/models/face_verify/finetune_face_verify_iter_5000.caffemodel'

caffe.set_mode_gpu()
net = caffe.Net(MODEL_FILE, PRETRAINED,caffe.TEST)
#net = caffe.Classifier(MODEL_FILE, PRETRAINED)
#net.set_raw_scale('data',255)
#net.set_channel_swap('data',(2,1,0))
#net.set_mean('data',np.load(caffe_root + 'python/caffe/imagenet/ilsvrc_2012_mean.npy'))

#IMAGE_FILE = '/home/vision/tools/caffe-master/data/web_face/CASIA-WebFace/0552509/049.jpg'
TEST_DATA_FILE = caffe_root + 'data/mnist/t10k-images-idx3-ubyte'
TEST_LABEL_FILE = caffe_root + 'data/mnist/t10k-labels-idx1-ubyte'
n = 10000

with open(TEST_DATA_FILE, 'rb') as f:
    f.read(16) # skip the header
    raw_data = np.fromstring(f.read(n * 28*28), dtype=np.uint8)

with open(TEST_LABEL_FILE, 'rb') as f:
    f.read(8) # skip the header
    labels = np.fromstring(f.read(n), dtype=np.uint8)
print labels

# reshape and preprocess
caffe_in = raw_data.reshape(n, 1, 28, 28) * 0.00390625 # manually scale data instead of using `caffe.io.Transformer`
out = net.forward_all(data=caffe_in)

feat = out['feat']
f = plt.figure(figsize=(16,9))
c = ['#ff0000', '#ffff00', '#00ff00', '#00ffff', '#0000ff', 
     '#ff00ff', '#990000', '#999900', '#009900', '#009999']
for i in range(10):
    plt.plot(feat[labels==i,0].flatten(), feat[labels==i,1].flatten(), '.', c=c[i])
plt.legend(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'])
plt.grid()
#plt.show()
plt.savefig(caffe_root + 'examples/mnist_triplet/mnist_triplet.png')
print feat
print labels

#res_list = '/home/vision/tools/caffe-master/models/face_verify/mnist_siamese_clsRes1.txt'
#fwrite = open(res_list,"w")
#for i in range(0,n-1):
	#fwrite.write("%s " %IMAGE_FILE)
#	fwrite.write("%s " %str(float(labels[i])))
#	fwrite.write("%s " %str(float(feat[i,0].flatten())))
#	fwrite.write("%s\n" %str(float(feat[i,1].flatten())))
#	#fwrite.write("\n")
#fwrite.close

print 'done'


