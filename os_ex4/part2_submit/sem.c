#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

extern struct proc proc[NPROC];

struct sem {
  struct spinlock lock;    // Protects this semaphore's value
  int value;               // Number of resources available
  int used;                // Is this slot currently allocated?
};

static struct sem sems[MAX_SEMS];
static struct spinlock sem_array_lock;

void
seminit(void)
{
  int i;
  initlock(&sem_array_lock, "sem_array_lock");
  for(i = 0; i < MAX_SEMS; i++){
    initlock(&sems[i].lock, "sem");
    sems[i].used = 0;
  }
}

int
sem_create(int init_value)
{
  int i;
  acquire(&sem_array_lock);
  for(i = 0; i < MAX_SEMS; i++){
    if(sems[i].used == 0){
      sems[i].used = 1;
      sems[i].value = init_value;
      release(&sem_array_lock);
      return i;
    }
  }
  release(&sem_array_lock);
  return -1;
}

int
sem_free(int id)
{
  if(id < 0 || id >= MAX_SEMS){
    return -1;
  }
  
  acquire(&sem_array_lock);
  
  if(sems[id].used == 0){
    release(&sem_array_lock);
    return -1;
  }
  
  // SAFETY CHECK: Verify no processes are sleeping on this semaphore
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == SLEEPING && p->chan == (void*)&sems[id]) {
      // A process is still sleeping on this semaphore
      release(&p->lock);
      release(&sem_array_lock);
      return -1;
    }
    release(&p->lock);
  }
  
  acquire(&sems[id].lock);
  sems[id].used = 0;
  release(&sems[id].lock);
  
  release(&sem_array_lock);
  return 0;
}

int
sem_down(int id)
{
  if(id < 0 || id >= MAX_SEMS){
    return -1;
  }
  
  acquire(&sems[id].lock);
  
  while(sems[id].value == 0){
    sleep(&sems[id], &sems[id].lock);
  }
  
  sems[id].value--;
  release(&sems[id].lock);
  
  return 0;
}

int
sem_up(int id)
{
  if(id < 0 || id >= MAX_SEMS){
    return -1;
  }
  
  acquire(&sems[id].lock);
  
  sems[id].value++;
  wakeup(&sems[id]);
  
  release(&sems[id].lock);
  
  return 0;
}

uint64
sys_sem_create(void)
{
  int init_value;
  argint(0, &init_value);
  return sem_create(init_value);
}

uint64
sys_sem_free(void)
{
  int sem_id;
  argint(0, &sem_id);
  return sem_free(sem_id);
}

uint64
sys_sem_down(void)
{
  int sem_id;
  argint(0, &sem_id);
  return sem_down(sem_id);
}

uint64
sys_sem_up(void)
{
  int sem_id;
  argint(0, &sem_id);
  return sem_up(sem_id);
}
