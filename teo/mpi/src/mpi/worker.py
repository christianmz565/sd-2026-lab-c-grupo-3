def worker_main(comm):
    rank = comm.Get_rank()

    my_chunk = comm.scatter(None, root=0)

    my_result = [{"worker_rank": rank, **row} for row in reversed(my_chunk)]

    comm.gather(my_result, root=0)
