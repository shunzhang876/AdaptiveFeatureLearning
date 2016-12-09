#include <vector>

#include "caffe/layer.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"
#include "math.h"
#include "iostream"

namespace caffe {

template <typename Dtype>
void L2NormLayer<Dtype>::LayerSetUp(const vector<Blob<Dtype>*>& bottom,
      const vector<Blob<Dtype>*>& top) {

	  CHECK_EQ(bottom[0]->height(), 1);
	  CHECK_EQ(bottom[0]->width(), 1);
	  //int count = bottom[0]->count();
	  top[0]->Reshape(bottom[0]->num(), bottom[0]->channels(), 1, 1);
	  //memset(top[0]->mutable_cpu_data(), Dtype(0.0), count*sizeof(Dtype));
}

template <typename Dtype>
void L2NormLayer<Dtype>::Reshape(const vector<Blob<Dtype>*>& bottom,
      const vector<Blob<Dtype>*>& top) {

}

template <typename Dtype>
void L2NormLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {

	const int channels = bottom[0]->channels();
	int num = bottom[0]->num();
	for (int i = 0; i<num;  i++)
	{
		//Dtype* bottom_data = bottom[0]->cpu_data() + i*channels;
		Dtype dot = caffe_cpu_dot(channels,bottom[0]->cpu_data() + i*channels,bottom[0]->cpu_data() + i*channels);
		Dtype base = (Dtype) (1 /  (Dtype)sqrt(dot));
		//std::cout<<base<<dot<<std::endl;
		//Dtype* top_data = top[0]->mutable_cpu_data() + i*channels;
		//caffe_cpu_axpby(channels, base, bottom[0]->cpu_data() + i*channels,  Dtype(0.0), top[0]->mutable_cpu_data() + i*channels);
		//memset(top[0]->mutable_cpu_data() + i*channels, Dtype(0.0), channels*sizeof(Dtype));

		Blob<Dtype> temp_bottom_data_p;
        	temp_bottom_data_p.Reshape(1, bottom[0]->channels(), bottom[0]->height(),bottom[0]->width());
        	Dtype* temp_bottom_p = temp_bottom_data_p.mutable_cpu_data();
		caffe_set(channels, Dtype(0),temp_bottom_p);
		//memset(temp_bottom_p, 0, channels*sizeof(Dtype));
		caffe_axpy(channels, base, bottom[0]->cpu_data() + i*channels, temp_bottom_p);
		caffe_copy(channels, temp_bottom_p, top[0]->mutable_cpu_data() + i*channels); 
		//caffe_axpy(channels, base, bottom[0]->cpu_data() + i*channels, top[0]->mutable_cpu_data() + i*channels);
	}
}

template <typename Dtype>
void L2NormLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {

	const int channels = bottom[0]->channels();
	int num = bottom[0]->num();
	for (int i = 0; i<num; i++)
	{
		//Dtype* bottom_data = bottom[0]->cpu_data() + i*channels;
		Dtype sum2 = caffe_cpu_dot(channels, bottom[0]->cpu_data() + i*channels, bottom[0]->cpu_data() + i*channels);
		Dtype sumsqrt = (Dtype) sqrt(sum2);
		Dtype sumsqrtbase = 1 / sumsqrt;
		Dtype base = - 1 / (sum2 * sumsqrt);
		
		//std::cout<<base<<sum2<<std::endl;

       		Blob<Dtype> temp_bottom_diff;
        	temp_bottom_diff.Reshape(1, channels, 1, 1);
        	Dtype* temp_diff = temp_bottom_diff.mutable_cpu_data();
		caffe_set(channels, Dtype(0), temp_diff);

		Blob<Dtype> temp_top_diff;
        	temp_top_diff.Reshape(1, channels, 1, 1);
        	Dtype* top_diff = temp_top_diff.mutable_cpu_data();
		caffe_set(channels, Dtype(0), top_diff);

		caffe_copy(channels, top[0]->cpu_diff()+ i*channels,top_diff);

		Blob<Dtype> temp_top_diff_;
        	temp_top_diff_.Reshape(1, channels, 1, 1);
        	Dtype* top_diff_ = temp_top_diff_.mutable_cpu_data();
		caffe_set(channels, Dtype(0), top_diff_);
		

		for(int j = 0; j<channels; j++)
		{	
       			Blob<Dtype> temp_bottom_data;
        		temp_bottom_data.Reshape(1, channels, 1, 1);
        		Dtype* temp_bottom = temp_bottom_data.mutable_cpu_data();
			caffe_set(channels, Dtype(1.0), temp_bottom);

      			Blob<Dtype> temp_bottom_data1;
        		temp_bottom_data1.Reshape(1, channels, 1, 1);
        		Dtype* temp_bottom1 = temp_bottom_data1.mutable_cpu_data();
			caffe_set(channels, Dtype(0), temp_bottom1);
			
			Dtype outj = (bottom[0]->cpu_data() + i*channels)[j];
			caffe_axpy(channels, outj, temp_bottom, temp_bottom1);

			caffe_mul(channels,bottom[0]->cpu_data() + i*channels,top_diff, top_diff_);
			//caffe_axpy(channels,Dtype(1.0),bottom[0]->cpu_data() + i*channels,top_diff);
			Dtype doutj = caffe_cpu_dot(channels,temp_bottom1,top_diff_);
                        //std::cout<<doutj<<std::endl;
			temp_diff[j] = doutj*base + sumsqrtbase*top_diff[j];
		}

		

        	/*Blob<Dtype> temp_top_data;
        	temp_top_data.Reshape(1, bottom[0]->channels(), bottom[0]->height(),bottom[0]->width());
        	Dtype* temp_top = temp_top_data.mutable_cpu_data();
		//memset(temp_top, 1, channels*sizeof(Dtype));
		caffe_set(channels, Dtype(1.0), temp_top);

        	caffe_mul(channels,bottom[0]->cpu_data() + i*channels, bottom[0]->cpu_data() + i*channels, temp_bottom);
	    	caffe_cpu_axpby(channels, base,  temp_bottom, sumsqrtbase, temp_top);
        	//caffe_cpu_axpby(count, base,  temp_bottom, sumsqrtbase, bottom[0]->mutable_cpu_diff());
		*/
		caffe_copy(channels, temp_diff, bottom[0]->mutable_cpu_diff()+i*channels); 
        	//caffe_mul(channels,temp_diff,top[0]->cpu_diff()+ i*channels, bottom[0]->mutable_cpu_diff()+i*channels);
	}

}



#ifdef CPU_ONLY
STUB_GPU(L2NormLayer);
#endif

INSTANTIATE_CLASS(L2NormLayer);
REGISTER_LAYER_CLASS(L2Norm);

}  // namespace caffe

