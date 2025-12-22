#include "Producer.h"

Producer::Producer(int id, BoundedBuffer& pq, int num) : producer_queue(pq) {
    this->id = id;
    this->num = num;
}
void Producer::produce() {
    for (int i = 0; i < num; i ++) {
        string s;
        event_type n = random_event();
        produce_one(n);
    }
    produce_one(DONE);
}
void Producer::produce_one(event_type n) {
    news_data to_add = {n, 
        "Producer " +
        to_string(id) +
        " " +
        produce_names[n] +
        " " +
        to_string(counters[n])};
    producer_queue.produce(to_add);
    counters[n] ++;
}
event_type Producer::random_event() {
    // set random
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dist(0, 2);
    return (event_type)(dist(gen));
}