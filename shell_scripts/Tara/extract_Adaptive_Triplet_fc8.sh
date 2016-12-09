#cd /home/shun/tools/caffe-triplet-master/
cp ./_FaceRes/Tara_HeadHunter/imgs_list.txt ./external/caffe-Triplet-New/examples/faceVideoTriplet/_fea_vis/
#mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP
mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet
if [ ! -d ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8 ]; then
  mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8
else
  rm -rf ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8
  mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8
fi
cd ./external/caffe-Triplet-New/
./build/tools/extract_features ./examples/faceVideoTriplet/caffemodel0_1_Tara/face_veri_iter_5000.caffemodel ./examples/faceVideoTriplet/_fea_vis/val_IMData.prototxt fc8 ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8 93 leveldb GPU 0
python ./scripts/shun/leveldb2mat.py ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8 100 93 64 ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/AdaptTriplet/fc8.mat
cd ../../
