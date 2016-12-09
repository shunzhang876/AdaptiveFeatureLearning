#cd /home/shun/tools/caffe-triplet-master/
cp ./_FaceRes/Tara_HeadHunter/imgs_list.txt ./external/caffe-Triplet-New/models/pretrained_web_face/_fea_vis/
#mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP
mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain
if [ ! -d ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7 ]; then
  mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7
else
  rm -rf ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7
  mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7
fi
cd ./external/caffe-Triplet-New/
./build/tools/extract_features ./models/pretrained_web_face/pretrained_web_face_iter_100000.caffemodel ./models/pretrained_web_face/_fea_vis/val_IMData.prototxt fc7 ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7 93 leveldb GPU 0
python ./scripts/shun/leveldb2mat.py ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7 100 93 4096 ./../../_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/PreTrain/fc7.mat
cd ../../
