program mpi_pi_modern
    ! import the module we created
    use monte_carlo_mod
    use mpi
    implicit none

    ! Variables
    integer :: ierr, rank, size
    integer(ip) :: local_count, total_count
    integer(ip), parameter :: N = 10000000_ip
    
    real(wp) :: start_t, end_t, pi_approx


    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

    ! start Timer
    call MPI_Barrier(MPI_COMM_WORLD, ierr) ! sync before timing
    start_t = MPI_Wtime()

    if (rank == 0) print *, "Starting simulation with N =", N

    call compute_pi_mpi(MPI_COMM_WORLD, rank, size, N, local_count)

    call MPI_Reduce(local_count, total_count, 1, MPI_INTEGER8, MPI_SUM, 0, MPI_COMM_WORLD, ierr)

 
    end_t = MPI_Wtime()

  
    if (rank == 0) then
        ! calculate Pi: (Total Hits / Total Points) * 4
        pi_approx = (real(total_count, kind=wp) / real((N/size)*size, kind=wp)) * 4.0_wp
        
        print *, "--------------------------------"
        print *, "Total Count:", total_count
        print *, "Approx Pi:  ", pi_approx
        print *, "Runtime:    ", end_t - start_t, "seconds"
        print *, "--------------------------------"
    end if

    call MPI_Finalize(ierr)

end program mpi_pi_modern