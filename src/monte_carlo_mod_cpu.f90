module monte_carlo_mod
    use iso_fortran_env, only: int32, int64, real64
    use mpi
    implicit none
    
    ! make everything private by default, only export what is needed
    private
    public :: compute_pi_mpi, wp, ip

    ! Define working precision shortcuts
    integer, parameter :: wp = real64
    integer, parameter :: ip = int64

contains

    subroutine compute_pi_mpi(comm, rank, size, total_points, local_count)
        integer, intent(in)       :: comm, rank, size
        integer(ip), intent(in)   :: total_points
        integer(ip), intent(out)  :: local_count
        
        integer(ip) :: i, n_local
        real(wp)    :: x, y
        
        ! calculate work per process
        n_local = total_points / size

        ! initialize the RNG 
        call init_rng(rank)

        ! perform the monte carlo simulation
        local_count = 0
        do i = 1, n_local
            call random_number(x)
            call random_number(y)
            
            if ((x**2 + y**2) <= 1.0_wp) then
                local_count = local_count + 1
            end if
        end do
        
    end subroutine compute_pi_mpi

    subroutine init_rng(rank)
        integer, intent(in) :: rank
        integer :: seed_size
        integer, allocatable :: seed_arr(:)
        
        call random_seed(size=seed_size)
        allocate(seed_arr(seed_size))
        
        ! seeding logic: Rank * Prime + Constant
        seed_arr = int(rank, kind=int32) * 9781 + 12345  ! note: this is a bad rand seed generator
        call random_seed(put=seed_arr)
    end subroutine init_rng

end module monte_carlo_mod