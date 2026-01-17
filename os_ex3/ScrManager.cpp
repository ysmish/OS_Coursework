#include "ScrManager.h"
// co-editors queue and screen manager queue
ScrManager::ScrManager(BoundedBuffer& smq) : smq(smq) {}
void ScrManager::display() {
    news_data nd;       
    int num_of_dones = 0; // counts the number of DONEs
    while (num_of_dones < 3) {
        smq.consume(&nd);
        if(nd.type == DONE) {
            num_of_dones++;
        }
        else {
            cout << nd.str << endl; 
        }
    }
    cout << "DONE" << endl;
}
