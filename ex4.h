#ifndef EX4_H
#define EX4_H

#include <sys/stat.h>
#include <unistd.h>
#include <string.h> // for the strings
#include <sys/sem.h> // for semaphores
#include <pthread.h>  // for threads and mutex
#include <random> // for random numbers
#include <iostream>
using namespace std;


union semun {
    int val;
    struct semid_ds* buf;
    unsigned short* array;
};

enum event_type {
    SPORTS = 0, NEWS = 1, WEATHER = 2, DONE = 3
};

typedef struct {
    event_type type;
    string str; // event name
} news_data;

// the number of news types is 3 in this assignment plus 1 for "DONE"
#define NEWS_TYPES 4
#define SCREEN_MANAGER_QUEUE_SIZE 100

#define EMPTY 0 // first  count is for the number of empty slots
#define FULL 1 // second count is for the number of filled slots

#endif