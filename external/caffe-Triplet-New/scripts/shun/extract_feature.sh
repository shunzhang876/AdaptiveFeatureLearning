#!/usr/bin/env sh
# args for EXTRACT_FEATURE
TOOL=./build/tools
MODEL=./models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel
PROTOTXT=./examples/_temp/imagenet_val.prototxt # 网络定义
LAYER=fc7 					# 提取层的名字，如提取fc7等
LEVELDB=./examples/_temp/features_fc7 		# 保存的leveldb路径
BATCHSIZE=10

# args for LEVELDB to MAT
DIM=4096 			# 需要手工计算feature长度
OUT=./examples/_temp/fc7.mat 	#.mat文件保存路径
BATCHNUM=1 			# 有多少哥batch， 本例只有两张图， 所以只有一个batch

$TOOL/extract_features  $MODEL $PROTOTXT $LAYER $LEVELDB $BATCHSIZE 'leveldb' GPU
python ./scripts/shun/leveldb2mat.py $LEVELDB $BATCHNUM  $BATCHSIZE $DIM $OUT
