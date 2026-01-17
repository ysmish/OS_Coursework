#ifndef EX3_H
#define EX3_H

#include <sys/stat.h>
#include <unistd.h>
#include <string.h> 
#include <sys/sem.h> 
#include <pthread.h>  
#include <random> 
#include <iostream>
using namespace std;
#define NEWS_TYPES 4 // number of news types is 3 in this assignment plus 1 for "DONE"
#define EMPTY 0 // count of number of empty slots
#define FULL 1 // count of number of filled slots
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
    string str; 
} news_data;
#endif