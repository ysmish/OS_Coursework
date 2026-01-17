CC = g++ # compiler
CCFLAGS = -Wall -Wextra -pthread -std=c++17 # flags
TARGET = ex3.out # output file after build

# these are the source files
SRCS = main.cpp BoundedBuffer.cpp Producer.cpp Dispatcher.cpp CoEditor.cpp ScrManager.cpp
# object files
OBJS = $(SRCS:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(CCFLAGS)

%.o: %.cpp
	$(CC) -c $< -o $@ $(CCFLAGS)

clean:
	rm -f $(OBJS) $(TARGET)