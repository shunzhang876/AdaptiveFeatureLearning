#include <vector>

#include "caffe/layer.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/common_layers.hpp"

namespace caffe {

template <typename Dtype>
void PSLayer<Dtype>::LayerSetUp(const vector<Blob<Dtype>*>& bottom,
      const vector<Blob<Dtype>*>& top) {
  //const PSParameter& fs_param = this->layer_param_.fs_param();
}

template <typename Dtype>
void PSLayer<Dtype>::Reshape(const vector<Blob<Dtype>*>& bottom,
      const vector<Blob<Dtype>*>& top) {
  CHECK_EQ(4, bottom[0]->num_axes()) << "Input must have 4 axes, "
      << "corresponding to (num, channels, height, width)";
  num_ = bottom[0]->num();
  channels_ = bottom[0]->channels();
  bottom_h_ = bottom[0]->height();
  bottom_w_ = bottom[0]->width();
  //CHECK_EQ(0, bottom_h_%2) << "Input height must be even";
  //CHECK_EQ(0, bottom_w_%2) << "Input width must be even";
  bin_h_=floor(bottom_h_/4);
  bin_w_=bottom_w_;
  bin_h_4_ = bottom_h_-3*bin_h_;
  for (int i=0; i<4; i++){
    if(i < 3){
    top[i]->Reshape(num_,channels_,bin_h_,bin_w_);
    }
    if (i == 3){
    top[i]->Reshape(num_,channels_,bin_h_4_,bin_w_);
    }
  }
}

template <typename Dtype>
void PSLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
      const vector<Blob<Dtype>*>& top) {
  const Dtype* bottom_data = bottom[0]->cpu_data();
  int offset[4];
  offset[0]=0;
  offset[1]=1*bin_h_*bottom_w_;
  offset[2]=2*bin_h_*bottom_w_;
  offset[3]=3*bin_h_*bottom_w_;
  for (int i=0; i<4; i++){
    Dtype* top_data = top[i]->mutable_cpu_data();
      for (int j=0; j<num_ ;j++){
        for (int k=0; k<channels_;k++){
         if (i < 3) {
          for (int l=0; l<bin_h_; l++){
          //int count_=bin_h_*bin_w_;
          caffe_copy(bin_w_,bottom_data+((j*channels_)+k)*bottom_h_*bottom_w_+l*bin_w_+offset[i],top_data+((j*channels_)+k)*bin_h_*bin_w_+bin_w_*l);
          }
	 }
	  if (i == 3)
	 {
	  for (int l=0; l<bin_h_4_; l++){
	  caffe_copy(bin_w_,bottom_data+((j*channels_)+k)*bottom_h_*bottom_w_+l*bin_w_+offset[i],top_data+((j*channels_)+k)*bin_h_*bin_w_+bin_w_*l);
	  }
	 }
        }
      }
  }
}

template <typename Dtype>
void PSLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
      const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
  if (!propagate_down[0]) { return; }
  int offset[4];
  offset[0]=0;
  offset[1]=1*bin_h_*bottom_w_;
  offset[2]=2*bin_h_*bottom_w_;
  offset[3]=3*bin_h_*bottom_w_;
  Dtype* bottom_diff = bottom[0]->mutable_cpu_diff();
  for (int i=0; i<4; i++){
    const Dtype* top_diff = top[i]->cpu_diff();
    for (int j=0; j<num_ ;j++){
        for (int k=0; k<channels_; k++){
	 if (i < 3){
          for (int l=0; l<bin_h_; l++){
          //int count_=bin_h_*bin_w_;
          caffe_copy(bin_w_,top_diff+((j*channels_)+k)*bin_h_*bin_w_+bin_w_*l,bottom_diff+((j*channels_)+k)*bottom_h_*bottom_w_+l*bin_w_+offset[i]);
	 }
	 if (i == 3) {
          for (int l=0; l<bin_h_4_; l++){
	  caffe_copy(bin_w_,top_diff+((j*channels_)+k)*bin_h_*bin_w_+bin_w_*l,bottom_diff+((j*channels_)+k)*bottom_h_*bottom_w_+l*bin_w_+offset[i]);
	 }	 
 	 }
          }
        }
      }
  }
}


INSTANTIATE_CLASS(PSLayer);
REGISTER_LAYER_CLASS(PS);

}  // namespace caffe
