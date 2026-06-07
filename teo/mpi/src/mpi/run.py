from mpi4py import MPI

from mpi.master import master_main
from mpi.worker import worker_main


def main():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()

    if rank == 0:
        master_main(comm)
    else:
        worker_main(comm)


if __name__ == "__main__":
    main()
