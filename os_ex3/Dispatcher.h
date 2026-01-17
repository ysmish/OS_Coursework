#ifndef DISP_H
#define DISP_H
#include "ex3.h"
#include "BoundedBuffer.h"

class Dispatcher {
public:
    Dispatcher(vector<BoundedBuffer*> pq, vector<BoundedBuffer*> coeq);
    void redirect();
    ~Dispatcher();
private:
    vector<BoundedBuffer*> pq;
    vector<BoundedBuffer*> coeq;
};
#endif