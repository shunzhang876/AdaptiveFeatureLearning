cp _FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/train*.txt external/caffe-Triplet-New/examples/faceVideoTriplet/
cp _FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/val*.txt external/caffe-Triplet-New/examples/faceVideoTriplet/

cd external/caffe-Triplet-New/
mkdir examples/faceVideoTriplet/caffemodel
sh examples/faceVideoTriplet/run.sh
mv examples/faceVideoTriplet/caffemodel examples/faceVideoTriplet/caffemodel0_1_Tara
mv examples/faceVideoTriplet/log_xx.log examples/faceVideoTriplet/log_Tara.txt
