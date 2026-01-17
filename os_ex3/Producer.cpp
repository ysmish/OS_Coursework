#include "Producer.h"

Producer::Producer(int id, BoundedBuffer& pq, int num) : producer_queue(pq) {
    this->id = id;
    this->num = num;
}

void Producer::produce() {
    int i;
    for (i = 0; i < num; i ++) {
        string s;
        //generate random event
        random_device rd;
        mt19937 gen(rd());
        uniform_int_distribution<> dist(0, 2);
        event_type event = (event_type)(dist(gen));
        //produce event
        producer_queue.produce({event, "Producer " + to_string(id) + " " + produce_names[event] + " " +to_string(counters[event])});
        counters[event] ++;
    }
    producer_queue.produce({DONE, "Producer " + to_string(id) + " " + produce_names[DONE] + " " +to_string(counters[DONE])});
    counters[DONE] ++;
}
