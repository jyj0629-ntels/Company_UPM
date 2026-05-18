include ./makehead

DB_OBJS=$(RD_HOME)/bin/NLCMySQLAdp.o

CFLAGS += -std=c++0x

BUILD = ODA_SIM

OBJS = ODA_SIM.o 

all : $(BUILD)

$(BUILD) : $(OBJS)
	$(CC) -o $(BUILD) $(OBJS) $(CFLAGS) $(LFLAGS) 

clean :
	rm -f $(OBJS) $(BUILD) 

install :
	cp $(BUILD) $(PM_HOME)/BIN
