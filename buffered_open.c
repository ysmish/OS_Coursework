#include "buffered_open.h"
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

buffered_file_t *buffered_open(const char *pathname, int flags, ...) {
    buffered_file_t *buf = malloc(sizeof(buffered_file_t));//im recently single so bf is a hard word to see
    if(buf == NULL) {
        return NULL;
    }
    char* rb = malloc(BUFFER_SIZE);
    char* wb = malloc(BUFFER_SIZE);
    if(rb == NULL || wb == NULL) {//if one of the buffers didnt allocate
        printf("malloc error'\n'");
        free(buf);
        free(rb);
        free(wb);
        return NULL;
    }
    buf->read_buffer = rb;//too many things to init...
    buf->write_buffer = wb;
    buf->read_buffer_size = BUFFER_SIZE;
    buf->write_buffer_size = BUFFER_SIZE;
    buf->read_buffer_pos = 0;
    buf->write_buffer_pos = 0;
    buf->flags = flags & ~O_PREAPPEND; //remove O_PREAPPEND from flags
    buf->preappend = (flags & O_PREAPPEND) ? 1 : 0; //set preappend flag
    buf->last_operation = 0;
    buf->file_offset = 0;
    buf->rb_stored = 0;
    buf->wb_stored = 0;

    buf->fd = open(pathname, buf->flags); //open file wo O_PREAPPEND
    if (buf->fd == -1) {//if file didnt open
        free(buf->read_buffer);
        free(buf->write_buffer);
        free(buf);
        return NULL;
    }
    return buf;
}

ssize_t buffered_read(buffered_file_t *bf, void *buf, size_t count) {
}

ssize_t buffered_write(buffered_file_t *bf, const void *buf, size_t count) {
}

int buffered_flush(buffered_file_t *bf) {
    
}

int buffered_close(buffered_file_t *bf) {
    
}
