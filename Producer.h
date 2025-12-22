#ifndef PROD_H
#define PROD_H
#include "ex4.h"
#include "BoundedBuffer.h"

const string produce_names[NEWS_TYPES] = {"SPORTS", "NEWS", "WEATHER"};

class Producer {
public:
    Producer(int id, BoundedBuffer& pq, int num);
    void produce();
private:
    int counters[NEWS_TYPES] = {0};
    int id;
    BoundedBuffer& producer_queue;
    int num;
    void produce_one(event_type n);
    event_type random_event();
};
#endif