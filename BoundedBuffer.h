#ifndef BB_H
#define BB_H
#include "ass4.h"
class BoundedBuffer {
public:
    BoundedBuffer(int size, bool dont_block = false);
    int produce(news_data src);
    void print_all();
    int consume(news_data *dst);
    ~BoundedBuffer();
private:
    int size;
    news_data *buffer;
    int in;
    int out;
    short int flags;
    pthread_mutex_t lock;
    int semid;
    void init_semaphore();
};
#endif