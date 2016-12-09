import leveldb
import feat_helper_pb2
import numpy as np
import scipy.io as sio
import time
#leveldb_name = '../../examples/siamese_s256c3/_temp/features_fc7'
#batch_num = 94
#batch_size = 64

def main(argv):
    leveldb_name = sys.argv[1]
    print "%s" % sys.argv[1]
    batch_num = int(sys.argv[2]);
    batch_size = int(sys.argv[3]);
    window_num = batch_num*batch_size;

    start = time.time()
    if 'db' not in locals().keys():
        db = leveldb.LevelDB(leveldb_name)
        datum = feat_helper_pb2.Datum()

    ft = np.zeros((window_num, int(sys.argv[4])))
    print window_num;
    for im_idx in range(window_num):
	#print im_idx
        datum.ParseFromString(db.Get('%d' %(im_idx)))
        ft[im_idx, :] = datum.float_data

    print 'time 1: %f' %(time.time() - start)
    sio.savemat(sys.argv[5], {'feats':ft})
    print 'time 2: %f' %(time.time() - start)
    print 'done!'

    #leveldb.DestroyDB(leveldb_name)

if __name__ == '__main__':
    import sys
    main(sys.argv)
