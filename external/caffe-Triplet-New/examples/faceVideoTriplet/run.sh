./build/tools/caffe train \
       --solver=examples/faceVideoTriplet/solver.prototxt -gpu 7 \
       2>examples/faceVideoTriplet/log_xx.log \
       --weights=models/pretrained_web_face/pretrained_web_face_iter_100000.caffemodel \
