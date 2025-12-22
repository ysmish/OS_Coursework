#include "BoundedBuffer.h"

BoundedBuffer::BoundedBuffer(int size, bool dont_block) {
    // string *buffer - the buffer
    // int size - the size of the buffer
    // bool dont_block - if true, then the consume function does not block.
    this->size = size;
    buffer = new news_data[size];
    this->buffer = buffer;
    in = 0;
    out = 0;
    init_semaphore();
    if (dont_block) {
        flags = IPC_NOWAIT;
    } else {
        flags = 0;
    }
}
// buffer write
int BoundedBuffer::produce(news_data src) {
    struct sembuf sops[1];
    sops[0].sem_num = EMPTY;
    sops[0].sem_flg = 0;
    sops[0].sem_op = -1; // produce one - one less empty
    semop(semid, sops, 1);
    pthread_mutex_lock(&lock);
    buffer[in] = src;
    in = (in + 1) % size;
    pthread_mutex_unlock(&lock);
    sops[0].sem_num = FULL;
    sops[0].sem_flg = 0;
    sops[0].sem_op = 1; // produce one - one more filled
    semop(semid, sops, 1);
    return 0;
}
void BoundedBuffer::print_all() {
    union semun arg;
    unsigned short values[2] = {0, 0};
    arg.array = values;
    semctl(semid, 0, GETALL, arg);
    printf("%p buffer - sem values: %d %d\n", this, arg.array[0], arg.array[1]);
}
// buffer read
int BoundedBuffer::consume(news_data *dst) {
    struct sembuf sops[1];
    sops[0].sem_num = FULL;
    sops[0].sem_flg = flags;
    sops[0].sem_op = -1; // consume one - one less filled
    if (semop(semid, sops, 1) == -1) {
        // the buffer is empty
        return -1;
    }
    pthread_mutex_lock(&lock);
    *dst = buffer[out];
    out = (out + 1) % size;
    pthread_mutex_unlock(&lock);
    sops[0].sem_num = EMPTY;
    sops[0].sem_flg = flags;
    sops[0].sem_op = 1; // consume one - one more empty
    semop(semid, sops, 1);
    return 0;
}

BoundedBuffer::~BoundedBuffer() {
    // delete the mutex and the semaphore.
    pthread_mutex_destroy(&lock);
    if (semctl(semid, 0, IPC_RMID, NULL) == -1) {
        printf("semaphore delete error\n");
    }
    delete[] buffer;
}
void BoundedBuffer::init_semaphore() {
    if (pthread_mutex_init(&lock, nullptr) != 0) {
        printf("Unable to create a mutex\n");
        exit(-1);
    }
    if ((semid = semget(IPC_PRIVATE, 2, 0666)) == -1) {
        printf("Unable to create a semaphore\n");
        exit(-1);
    }
    union semun semarg;

    semarg.val = size;
    semctl(semid, EMPTY, SETVAL, semarg);
    semarg.val = 0;
    semctl(semid, FULL, SETVAL, semarg);
}
