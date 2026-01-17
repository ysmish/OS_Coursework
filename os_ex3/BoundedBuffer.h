#ifndef BB_H
#define BB_H
#include "ex3.h"
class BoundedBuffer {
public:
    BoundedBuffer(int size, bool dont_block = false);
    int produce(news_data src);
    void print();
    int consume(news_data *dst);
    ~BoundedBuffer();
private:
    int size;
    news_data *buffer;
    int write_pos;      // or write_index, write_ptr
    int read_pos;       // or read_index, read_ptr
    short int flags;
    pthread_mutex_t lock;
    int semid;
    void init_semaphore();
};
#endif