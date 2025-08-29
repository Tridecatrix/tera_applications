#!/usr/bin/env bash
    export LIBRARY_PATH=/home/users/u7300623/teraheap/allocator/lib:$LIBRARY_PATH
    export LD_LIBRARY_PATH=/home/users/u7300623/teraheap/allocator/lib/:$LD_LIBRARY_PATH
    export PATH=/home/users/u7300623/teraheap/allocator/include/:$PATH
    export C_INCLUDE_PATH=/home/users/u7300623/teraheap/allocator/include/:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH=/home/users/u7300623/teraheap/allocator/include/:$CPLUS_INCLUDE_PATH

    export LIBRARY_PATH=/home/users/u7300623/teraheap/tera_malloc/lib:$LIBRARY_PATH
    export LD_LIBRARY_PATH=/home/users/u7300623/teraheap/tera_malloc/lib/:$LD_LIBRARY_PATH
    export PATH=/home/users/u7300623/teraheap/tera_malloc/include/:$PATH
    export C_INCLUDE_PATH=/home/users/u7300623/teraheap/tera_malloc/include/:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH=/home/users/u7300623/teraheap/tera_malloc/include/:$CPLUS_INCLUDE_PATH
    "$@"