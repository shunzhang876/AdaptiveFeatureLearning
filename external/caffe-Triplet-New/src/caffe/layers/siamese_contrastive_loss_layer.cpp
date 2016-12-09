#include <algorithm>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/loss_layers.hpp"
#include "caffe/util/io.hpp"
#include "caffe/util/math_functions.hpp"

namespace caffe {

template <typename Dtype>
void SiameseContrastiveLossLayer<Dtype>::LayerSetUp(
  const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  LossLayer<Dtype>::LayerSetUp(bottom, top);
  CHECK_EQ(bottom[0]->num(), bottom[1]->num());
  CHECK_EQ(bottom[0]->channels(), bottom[1]->channels());
  CHECK_EQ(bottom[0]->height(), 1);
  CHECK_EQ(bottom[0]->width(), 1);
  CHECK_EQ(bottom[1]->height(), 1);
  CHECK_EQ(bottom[1]->width(), 1);
  CHECK_EQ(bottom[2]->channels(), 1);
  CHECK_EQ(bottom[2]->height(), 1);
  CHECK_EQ(bottom[2]->width(), 1);

  Dtype numberi = this->layer_param_.siamese_contrastive_loss_param().numberi();
  diff_.Reshape(bottom[0]->num(), bottom[0]->channels(), 1, 1);
  dist_sq_pp_.Reshape(numberi, 1, 1, 1);
  dist_sq_ab_.Reshape(bottom[0]->num(), 1, 1, 1);  
}

template <typename Dtype>
void SiameseContrastiveLossLayer<Dtype>::Forward_cpu(
    const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
 Dtype margin = this->layer_param_.siamese_contrastive_loss_param().margin();
 Dtype lamda = this->layer_param_.siamese_contrastive_loss_param().lamda();
 Dtype numbers = this->layer_param_.siamese_contrastive_loss_param().numbers();
 Dtype numberp = this->layer_param_.siamese_contrastive_loss_param().numberp();
 Dtype numberi = this->layer_param_.siamese_contrastive_loss_param().numberi();
 
 int count = bottom[0]->count();
 int channels = bottom[0]->channels();
 caffe_sub(
      count,
      bottom[0]->cpu_data(),  // a
      bottom[1]->cpu_data(),  // b
      diff_.mutable_cpu_data());  // a_i-b_i
 
 Dtype loss(0.0);
 caffe_set(numberi, Dtype(0), dist_sq_pp_.mutable_cpu_data());
 for (int i = 0; i < bottom[0]->num(); ++i) {
    dist_sq_ab_.mutable_cpu_data()[i] = caffe_cpu_dot(channels,
        diff_.cpu_data() + (i*channels), diff_.cpu_data() + (i*channels));
    int count = int(i/numbers);
    if (static_cast<int>(bottom[2]->cpu_data()[i])) {  // similar pairs
      loss += (1 - lamda)*dist_sq_ab_.cpu_data()[i];
      dist_sq_pp_.mutable_cpu_data()[count] += dist_sq_ab_.cpu_data()[i];
    } 
    else {  // dissimilar pairs
        if (dist_sq_pp_.mutable_cpu_data()[count]/numberp > dist_sq_ab_.cpu_data()[i]) {
            // dist_sq_pp_.mutable_cpu_data()[count] = dist_sq_ab_.cpu_data()[i] * numbers;
            dist_sq_pp_.mutable_cpu_data()[count] = 0;
        }
        Dtype mdist = std::max(margin + dist_sq_pp_.mutable_cpu_data()[count]/numbers - dist_sq_ab_.cpu_data()[i], Dtype(0.0));
        if (mdist == Dtype(0.0)) {
          caffe_set(channels, Dtype(0), diff_.mutable_cpu_data() + (i*channels)); 
        }
        loss += lamda*mdist;
    }
  }
  loss = loss / static_cast<Dtype>(bottom[0]->num()) / Dtype(2);
  top[0]->mutable_cpu_data()[0] = loss;
}

template <typename Dtype>
void SiameseContrastiveLossLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
  Dtype lamda = this->layer_param_.siamese_contrastive_loss_param().lamda();
  for (int i = 0; i < 2; ++i) {
    if (propagate_down[i]) {
      const Dtype sign = (i == 0) ? 1 : -1;
      const Dtype alpha = sign * top[0]->cpu_diff()[0] /
          static_cast<Dtype>(bottom[i]->num());
      int num = bottom[i]->num();
      int channels = bottom[i]->channels();
      for (int j = 0; j < num; ++j) {
        Dtype* bout = bottom[i]->mutable_cpu_diff();
        if (static_cast<int>(bottom[2]->cpu_data()[j])) {  // similar pairs
          caffe_cpu_axpby(
              channels,
              alpha*(1 - lamda),
              diff_.cpu_data() + (j*channels),
              Dtype(0.0),
              bout + (j*channels));
        } 
        else {  // dissimilar pairs
          Dtype beta(0.0);
          beta = -alpha;
          caffe_cpu_axpby(
              channels,
              beta*lamda,
              diff_.cpu_data() + (j*channels),
              Dtype(0.0),
              bout + (j*channels));
       }
      }
    }
  }
}

#ifdef CPU_ONLY
STUB_GPU(SiameseContrastiveLossLayer);
#endif

INSTANTIATE_CLASS(SiameseContrastiveLossLayer);
REGISTER_LAYER_CLASS(SiameseContrastiveLoss);

}  // namespace caffe
