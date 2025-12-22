#ifndef BB_H
#define BB_H
#include "ex4.h"
class BB {
public:
    BB(int size, bool dont_block = false);
    int produce(news_data src);
    void print_all();
    int consume(news_data *dst);
    ~BB();
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