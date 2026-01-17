#include "CoEditor.h"

Co_Editor::Co_Editor(BoundedBuffer& coeq, BoundedBuffer& smq) : coeq(coeq), smq(smq) {} // co-editors queue and screen manager queue

void Co_Editor::edit() {
    news_data nd;
    while (true) {
        if (coeq.consume(&nd) == -1) { // non-blocking: nothing to consume
            usleep(50000);
            continue;
        }

        if (nd.type != DONE) {
            usleep(100000); // simulate editing work
        }

        smq.produce(nd);

        if (nd.type == DONE) break;
    }
}
