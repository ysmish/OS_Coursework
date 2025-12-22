CC = g++ # compiler
CCFLAGS = -Wall -Wextra -pthread -std=c++17 # flags
TARGET = ex4.out # output file after build

# This is my source files:
SRCS = main.cpp BoundedBuffer.cpp Producer.cpp Dispatcher.cpp Co_Editor.cpp Screen_Manager.cpp
# object files
OBJS = $(SRCS:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(CCFLAGS)

%.o: %.cpp
	$(CC) -c $< -o $@ $(CCFLAGS)

clean:
	rm -f $(OBJS) $(TARGET)