#!/bin/bash
mkdir ./_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP
sh shell_scripts/Tara/extract_Adaptive_Triplet_fc8.sh
sh shell_scripts/Tara/extract_PreTrain_fc7.sh
sh shell_scripts/Tara/extract_AlexNet_fc7.sh
sh shell_scripts/Tara/extract_VGGFace_fc7.sh
matlab -nosplash -nodesktop -r "extractFea_HOG,exit"
