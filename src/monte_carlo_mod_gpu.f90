module monte_carlo_mod
    use iso_fortran_env, only: int32, int64, real64
    use mpi
    implicit none
    
    private
    public :: compute_pi_mpi, wp, ip

    integer, parameter :: wp = real64
    integer, parameter :: ip = int64

contains

    subroutine compute_pi_mpi(comm, rank, size, total_points, local_count)
        integer, intent(in)       :: comm, rank, size
        integer(ip), intent(in)   :: total_points
        integer(ip), intent(out)  :: local_count
        
        integer(ip) :: i, n_local
        real(wp)    :: x, y
        integer(int64) :: seed_x, seed_y

        n_local = total_points / size
        local_count = 0

        ! OpenACC Parallel Region
        !$acc parallel loop reduction(+:local_count) private(x, y, seed_x, seed_y)
        do i = 1, n_local
            ! Stateless seeding based on rank and index
            seed_x = (rank * n_local + i) * 12345_ip + 5432_ip ! note: this is a bad rng
            seed_y = (rank * n_local + i) * 67890_ip + 4321_ip ! note: this too is a bad rng

            x = gpu_rand(seed_x)
            y = gpu_rand(seed_y)

            if ((x**2 + y**2) <= 1.0_wp) then
                local_count = local_count + 1
            end if
        end do
        !$acc end parallel loop

    end subroutine compute_pi_mpi

    ! hard-coded device-compatible Linear Congruential Generator (LCG) RNG
    function gpu_rand(state) result(val)
        !$acc routine(seq)
        integer(int64), intent(inout) :: state
        real(wp) :: val
        
        integer(int64), parameter :: a = 1103515245_int64
        integer(int64), parameter :: c = 12345_int64
        integer(int64), parameter :: m = 2147483648_int64

        state = mod(state * a + c, m)
        val = real(state, kind=wp) / real(m, kind=wp)
    end function gpu_rand

end module monte_carlo_mod