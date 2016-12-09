#cd /home/shun/tools/caffe-triplet-master/
cp ./_FaceRes/Tara_HeadHunter/imgs_list.txt ./external/caffe-Triplet-New/models/bvlc_reference_caffenet/_fea_vis/
#mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP
mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet
if [ ! -d ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7 ]; then
  mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7
else
  rm -rf ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7
  mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7
fi
cd ./external/caffe-Triplet-New/
./build/tools/extract_features ./models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel ./models/bvlc_reference_caffenet/_fea_vis/val_IMData.prototxt fc7 ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7 93 leveldb GPU 0
python ./scripts/shun/leveldb2mat.py ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7 100 93 4096 ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AlexNet/fc7.mat
cd ../../
