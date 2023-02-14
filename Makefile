CXX := $(shell which clang++)

# just a clean way to distinguish the two deployment environments
DEVELOPMENT_FLAGS := -g -std=c++20 -stdlib=libstdc++ -Weverything -Wno-newline-eof -Wno-c++98-compat -Wno-c++98-compat-pedantic -gdwarf-4 -fPIC
PRODUCTION_FLAGS := -O3 -fPIC

ifeq "$(DEPLOYMENT)" "production"
    CXXFLAGS= $(PRODUCTION_FLAGS)
else
    CXXFLAGS:= $(DEVELOPMENT_FLAGS)
endif

# language specific
SOURCE_FILES_SUFFIX := .cpp
HEADER_SUFFIX := .h

# source
LIB := libmod.so
LIBRARY_SOURCE_DIRECTORY := src
LIBRARY_OBJECTS_DIRECTORY := temp_obj_directory
LIBRARY_OBJECTS :=$(addprefix $(LIBRARY_OBJECTS_DIRECTORY)/, addition/addition.o multiplication/multiplication.o)
SHARED := -shared

# tests
TEST := executable
TESTS_SOURCE_DIRECTORY:= tests
TESTS_DIRECTORY_OBJECTS := temp_test_obj_directory
TOBJS :=$(addprefix $(TESTS_DIRECTORY_OBJECTS)/, test_addition/test_addition.o test_multiplication/test_multiplication.o driver.o)
LIBS := -lcppunit $(LIB)

MEM_CHECK_FILE := valgrind_results.txt

# build the library
build: clean $(LIB)

# compile everything needed for the library
$(LIB): lib_obj_dirs $(LIBRARY_OBJECTS)
	$(CXX) $(CXXFLAGS) $(SHARED) $(LIBRARY_OBJECTS) -o $(LIB)

# compile command for each source file
$(LIBRARY_OBJECTS_DIRECTORY)/%.o: $(LIBRARY_SOURCE_DIRECTORY)/%$(SOURCE_FILES_SUFFIX) $(LIBRARY_SOURCE_DIRECTORY)/%$(HEADER_SUFFIX)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# make temporary directory for the library objects
lib_obj_dirs:
	cp -R --attributes-only ./$(LIBRARY_SOURCE_DIRECTORY)/ ./$(LIBRARY_OBJECTS_DIRECTORY)
	find ./$(LIBRARY_OBJECTS_DIRECTORY) -type f -exec rm {} \;
	
# build the tests
test: clean $(LIB) $(TEST)

# build an executable that tests the library
$(TEST): test_lib_dirs $(TOBJS)
	$(CXX) $(CXXFLAGS) $(TOBJS) -o $(TEST) -L. $(LIBS) 

# compile command for each test file
$(TESTS_DIRECTORY_OBJECTS)/%.o: $(TESTS_SOURCE_DIRECTORY)/%$(SOURCE_FILES_SUFFIX) $(TESTS_SOURCE_DIRECTORY)/%$(HEADER_SUFFIX)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# make temporary directory for the test objects
test_lib_dirs:
	cp -R --attributes-only ./$(TESTS_SOURCE_DIRECTORY)/ ./$(TESTS_DIRECTORY_OBJECTS)
	find ./$(TESTS_DIRECTORY_OBJECTS) -type f -exec rm {} \;

clean:
	rm -f *~ *.o $(LIB) $(TEST) $(MEM_CHECK_FILE)
	rm -rf $(LIBRARY_OBJECTS_DIRECTORY) $(TESTS_DIRECTORY_OBJECTS)

memory_check: test
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=$(MEM_CHECK_FILE) ./$(TEST)
