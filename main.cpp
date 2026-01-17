#include "ex3.h"
#include "BoundedBuffer.h"
#include "Dispatcher.h"
#include "CoEditor.h"
#include "Producer.h"
#include "ScrManager.h"

vector<int*> parse_config(char *name) {
    vector<int*> ret;
    // the last pair in the vector represents the co editors.
    FILE* file = fopen(name, "r");
    int id;  //id of the producer.
    int n;  //number of products to produce.
    int size; //queue size of the producer.
    while (true) {
        int a = fscanf(file, "PRODUCER %d\n", &id);
        int b = fscanf(file, "%d\n", &n);
        int c = fscanf(file, "queue size = %d\n\n", &size);
        if (a==0 || b==0 or c==0) {
            break;
        }
        int *to_be_freed = new int[3]; 
        to_be_freed[0] = id;
        to_be_freed[1] = n;
        to_be_freed[2] = size;
        ret.push_back(to_be_freed);
    }
    fscanf(file, "Co-Editor queue size = %d", &size);
    int *to_be_freed = new int[3];
    to_be_freed[0] = -1;
    to_be_freed[1] = -1;
    to_be_freed[2] = size;
    ret.push_back(to_be_freed);
    fclose(file);
    return ret;
}
// returns an array of pointers to producers
vector<Producer*> init_producers(vector<int*> vec, vector<BoundedBuffer*> *pq) {
    vector<Producer*> ret;
    for (long unsigned int i = 0; i < vec.size(); i++) {
        int *c = vec[i];
        BoundedBuffer *bb = new BoundedBuffer(c[2], true);
        (*pq).push_back(bb);
        Producer *p = new Producer(c[0], *bb, c[1]);
        ret.push_back(p);
    }
    return ret;
}
vector<Co_Editor*> init_co_editors(int queue_size, BoundedBuffer *smbb, vector<BoundedBuffer*> *cobb) {
    vector<Co_Editor*> ret;     // array of pointers to co editors
    for (int i = 0; i < NEWS_TYPES - 1; i++) {
        BoundedBuffer *bb = new BoundedBuffer(queue_size);
        (*cobb).push_back(bb);
        Co_Editor *ce = new Co_Editor(*bb, *smbb);
        ret.push_back(ce);
    }
    return ret;
}
void *handle_producer(void *arg) {
    Producer *p = (Producer *)arg;
    p->produce();
    return nullptr;
}
void *handle_dispatcher(void *arg) {
    Dispatcher *d = (Dispatcher *)arg;
    d->redirect();
    return nullptr;
}
void *handle_co_editor(void *arg) {
    Co_Editor *ce = (Co_Editor *)arg;
    ce->edit();
    return nullptr;
}
void *handle_scrmanager(void *arg) {
    ScrManager *sm = (ScrManager *)arg;
    sm->display();
    return nullptr;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        cout << "Usage: " << string(argv[0]) << " <config.txt>" << endl;
        exit(1);
    }
    vector<int*> vec = parse_config(argv[1]);

    int co_editor_size = (vec.back())[2];
    vec.pop_back();
    vector<BoundedBuffer*> pq;
    vector<BoundedBuffer*> co;
    vector<Producer*> producers = init_producers(vec, &pq);
    BoundedBuffer smbb(100); // screen manager queue size =100
    vector<Co_Editor*> co_editors = init_co_editors(co_editor_size, &smbb, &co);
    ScrManager sm(smbb);
    Dispatcher d(pq, co);
    for (int *integ : vec) {
        delete integ;
    }
    vector<pthread_t> threads;
    pthread_t pt;
    for (Producer *prod : producers) {
        pthread_create(&pt, nullptr, handle_producer, (void *)prod);
        threads.push_back(pt);
    }
    pthread_create(&pt, nullptr, handle_dispatcher, (void *)&d);
    threads.push_back(pt);
    for (Co_Editor *coed : co_editors) {
        pthread_create(&pt, nullptr, handle_co_editor, (void *)coed);
        threads.push_back(pt);
    }
    pthread_create(&pt, nullptr, handle_scrmanager, (void *)&sm);
    threads.push_back(pt);
    // wait before cleaning
    void *ignore;
    for (pthread_t x : threads) {
        pthread_join(x, &ignore);
    }
    for (Producer *pr : producers) {
        delete pr;
    }
    for (Co_Editor *co_ed : co_editors) {
        delete co_ed;
    }
    return 0;
}
