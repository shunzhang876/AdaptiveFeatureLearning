#!/bin/bash

echo '-------- Generate constraints... --------'
matlab -nosplash -nodesktop -r "genTracklet('Tara'),exit"

echo '-------- Learn adaptive CNN features... --------'
sh shell_scripts/Tara/adapt_Triplet.sh

echo '-------- Feature clustering... --------'
sh shell_scripts/Tara/extract_All_Feas.sh
matlab -nosplash -nodesktop -r "clustering_tracklets('Tara'),exit"

echo '-------- Multi-face tracking... --------'
matlab -nosplash -nodesktop -r "facetracking('Tara'),exit"

echo '-------- Mission completed! --------’
