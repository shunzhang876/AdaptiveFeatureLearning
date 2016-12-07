# Tracking Persons-of-Interest via Adaptive Discriminative Features (ECCV 2016)

This is the research code for the paper:

[Shun Zhang](http://shunzhang.me.pn/), [Yihong Gong](http://gr.xjtu.edu.cn/web/ygong/home), [Jia-Bin Huang](https://filebox.ece.vt.edu/~jbhuang/), [Jongwoo Lim](https://filebox.ece.vt.edu/~jbhuang/), [Jinjun Wang](http://gr.xjtu.edu.cn/web/jinjun/english), [Narendra Ahuja](http://vision.ai.illinois.edu/ahuja.html) and [Ming-Hsuan Yang](http://faculty.ucmerced.edu/mhyang/). 
"Tracking Persons-of-Interest via Adaptive Discriminative Features", in Proceedings of European Conference on Computer Vision (ECCV), 2016.

We take the T-ara sequence as an example to evaluate our adaptive feature learning approach in this code. Our learned model on the T-ara sequence can be found here:

[T-ara_model]()

[Project page](http://shunzhang.me.pn/papers/eccv2016/)

### Citation

If you find the code and pre-trained models useful in your research, please consider citing:

     @inproceedings{Zhang-ECCV-2016,
	       author = {Zhang, Shun and Gong, Yihong and Huang, Jia-Bin and Lim, Jongwoo and Wang, Jinjun and Ahuja, Narendra and Yang, Ming-Hsuan},
	       title = {Tracking Persons-of-Interest via Adaptive Discriminative Features},
	       booktitle = {European Conference on Computer Vision},
	       year = {2016},
	       pages = {415-433}
	   }
            
### System Requirements

- MATLAB (tested with R2014b on 64-bit Linux)
- Caffe

### Installation

1. Download and unzip the project code.

2. Install Caffe. Please follow the [Caffe installation instructions](http://caffe.berkeleyvision.org/installation.html) to install dependencies and then compile Caffe:

	```
	# We call the root directory of the project code `AFL_ROOT`.
	cd $AFL_ROOT/external/caffe-Triplet-New
	make all -j8
	make pycaffe
	make matcaffe
	```
	
3. Download the T-ara images and extract all images into `AFL/data`.

4. Download the AlexNet model:

	```
	cd $AFL_ROOT/external/caffe-Triplet-New
	scripts/download_model_binary.py models/bvlc_reference_caffenet
	```
	
5. Download the [VGG-Face Model](http://www.robots.ox.ac.uk/~vgg/software/vgg_face/src/vgg_face_caffe.tar.gz) and put it in `$AFL_ROOT/external/caffe-Triplet-New/models/VGG`. Download the [pre-trained face model]() and put it in `$AFL_ROOT/external/caffe-Triplet-New/models/pretrained_web_face`.

### Usage

Directly run the script `run_Tara_example.sh`. 

Or run the following commands step by step:

1. Mine constraints:

	```
	cd $AFL_ROOT
	# Start MATLAB
	matlab
	>> genTracklet('Tara')
	```

2. Learn adaptive discriminative features:

	```
	cd $AFL_ROOT
	sh shell_scripts/Tara/adapt_Triplet.sh
	```
	
3. Extract features:

	```
	sh shell_scripts/Tara/extract_All_Feas.sh
	```
	
4. Perform hierarchical agglomerative clustering algorithm:

	```
	matlab
	>> clustering_tracklets(‘Tara')
	```
	
