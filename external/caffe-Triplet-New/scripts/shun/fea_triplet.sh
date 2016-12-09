#!/usr/bin/env sh
# args for EXTRACT_FEATURE
TOOL=./build/tools
MODEL=./examples/mnist_triplet/caffemodel/mnist_triplet_iter_50000.caffemodel
PROTOTXT=./examples/mnist_triplet/mnist_triplet_train_test.prototxt # 网络定义
LAYER=sim 					# 提取层的名字，如提取fc7等
LEVELDB=./examples/mnist_triplet/label 		# 保存的leveldb路径
BATCHSIZE=10

# args for LEVELDB to MAT
DIM=1 				# 需要手工计算feature长度
OUT=./examples/mnist_triplet/label.mat 	#.mat文件保存路径
BATCHNUM=100 			# 有多少哥batch， 本例只有两张图， 所以只有一个batch

$TOOL/extract_features  $MODEL $PROTOTXT $LAYER $LEVELDB $BATCHSIZE 'leveldb' GPU
python ./scripts/shun/leveldb2mat.py $LEVELDB $BATCHNUM  $BATCHSIZE $DIM $OUT
