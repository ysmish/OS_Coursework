#include "Dispatcher.h"
Dispatcher::Dispatcher(vector<BoundedBuffer*> pq, vector<BoundedBuffer*> coeq) {
    this->pq = pq; // producer queues and co-editors queues
    this->coeq = coeq;
}
void Dispatcher::redirect() {
    size_t len = pq.size();   
    vector<bool> working_queues(len, false);
    size_t num_working_queues = len;
    size_t idx = 0;
    news_data nd;
    while (num_working_queues > 0) {   //until all report DONE
        if (pq[idx]->consume(&nd) == -1) {
            idx = (idx + 1) % len;
            continue;
        }
        if (nd.type == DONE) {
            if (!working_queues[idx]) {
                working_queues[idx] = true;
                --num_working_queues;
            }
        } else {
            coeq[nd.type]->produce(nd);
        }
        idx = (idx + 1) % len;
    }
    for (BoundedBuffer* cb : coeq) {//notify co-editors of DONE
        cb->produce({DONE, "DONE"});
    }
}

Dispatcher::~Dispatcher() {
    // dispatcher owns and frees the allocated queues
    for (BoundedBuffer *bb : pq) {
        delete bb;
    }
    for (BoundedBuffer *bb : coeq) {
        delete bb;
    }
}
