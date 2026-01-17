#ifndef COE_H
#define COE_H
#include "ex3.h"
#include "BoundedBuffer.h"
class Co_Editor {
public:
    Co_Editor(BoundedBuffer& coeq, BoundedBuffer& smq);    // co-editors queue and screen manager queue
    void edit();
private:
    BoundedBuffer& coeq;
    BoundedBuffer& smq;
};
#endif