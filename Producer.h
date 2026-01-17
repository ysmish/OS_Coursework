#ifndef PROD_H
#define PROD_H
#include "ex3.h"
#include "BoundedBuffer.h"

const string produce_names[NEWS_TYPES] = {"WEATHER", "SPORTS", "NEWS"};

class Producer {
public:
    Producer(int id, BoundedBuffer& pq, int num);
    void produce();
private:
    int id;
    int num;
    int counters[NEWS_TYPES] = {0};
    BoundedBuffer& producer_queue;
};
#endif