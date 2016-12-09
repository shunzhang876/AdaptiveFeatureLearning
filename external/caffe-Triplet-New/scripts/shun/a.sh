#!/usr/bin/env sh
# args for EXTRACT_FEATURE
TOOL=../../build/tools
MODEL=../../examples/siamese_s256c3/caffemodel_8layers/mnist_siamese_iter_25000.caffemodel
PROTOTXT=../../examples/siamese_s256c3/_temp/val.prototxt 	# 网络定义
LAYER=fc7						# 提取层的名字，如提取fc7等
LEVELDB=../../examples/siamese_s256c3/_temp/features_fc7		# 保存的leveldb路径
BATCHSIZE=64

# args for LEVELDB to MAT
DIM=4096     #290400  	#4096 			# 需要手工计算feature长度
OUT=../../examples/siamese_s256c3/_temp/fc7.mat 	#.mat文件保存路径
BATCHNUM=94			# 有多少哥batch， 本例只有两张图， 所以只有一个batch

rm -rf $LEVELDB
$TOOL/extract_features.bin  $MODEL $PROTOTXT $LAYER $LEVELDB $BATCHSIZE GPU
python leveldb2mat.py $LEVELDB $BATCHNUM $BATCHSIZE $DIM $OUT
