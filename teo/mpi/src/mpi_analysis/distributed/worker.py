from mpi_analysis.core import calculate_metrics

def worker_main(comm):
    rank = comm.Get_rank()

    my_chunk = comm.scatter(None, root=0)

    metrics = calculate_metrics(my_chunk)
    my_result = {
        "worker_rank": rank,
        "record_count": len(my_chunk),
        "metrics": metrics,
    }

    comm.gather(my_result, root=0)
