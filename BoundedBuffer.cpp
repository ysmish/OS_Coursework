#include "BoundedBuffer.h"

BoundedBuffer::BoundedBuffer(int capacity, bool nonBlocking) {
    // initialize indices and storage
    write_pos = 0;
    read_pos = 0;
    this->size = capacity;
    buffer = new news_data[capacity];

    init_semaphore();
    flags = nonBlocking ? IPC_NOWAIT : 0;
}

int BoundedBuffer::produce(news_data src) {
    struct sembuf ops[1];

    // wait for an empty slot
    ops[0].sem_num = EMPTY;
    ops[0].sem_flg = 0;
    ops[0].sem_op  = -1;
    if (semop(semid, ops, 1) == -1) {
        return -1;
    }

    pthread_mutex_lock(&lock);
    buffer[write_pos] = src;
    write_pos = (write_pos + 1) % size;
    pthread_mutex_unlock(&lock);

    // signal one more full slot
    ops[0].sem_num = FULL;
    ops[0].sem_flg = 0;
    ops[0].sem_op  = 1;
    semop(semid, ops, 1);

    return 0;
}

void BoundedBuffer::print() {
    union semun arg;
    unsigned short vals[2] = {0, 0};
    arg.array = vals;
    semctl(semid, 0, GETALL, arg);
    printf("%p buffer - sem values: %d %d\n", this, arg.array[0], arg.array[1]);
}

int BoundedBuffer::consume(news_data *dst) {
    struct sembuf ops[1];

    // wait for a filled slot (respect flags for non-blocking)
    ops[0].sem_num = FULL;
    ops[0].sem_flg = flags;
    ops[0].sem_op  = -1;
    if (semop(semid, ops, 1) == -1) {
        return -1;
    }

    pthread_mutex_lock(&lock);
    *dst = buffer[read_pos];
    read_pos = (read_pos + 1) % size;
    pthread_mutex_unlock(&lock);

    // signal one more empty slot
    ops[0].sem_num = EMPTY;
    ops[0].sem_flg = flags;
    ops[0].sem_op  = 1;
    semop(semid, ops, 1);

    return 0;
}

BoundedBuffer::~BoundedBuffer() {
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