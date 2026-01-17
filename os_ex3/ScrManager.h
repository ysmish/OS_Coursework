#ifndef SCRMEN_H
#define SCRMEN_H
#include "ex3.h"
#include "BoundedBuffer.h"

class ScrManager {
public:
    ScrManager(BoundedBuffer& smq);    // co-editors queue and screen manager queue
    void display();
private:
    BoundedBuffer& smq;
};
#endif