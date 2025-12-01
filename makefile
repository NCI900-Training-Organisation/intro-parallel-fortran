SRC = src
BUILD_CPU = build/cpu
BUILD_GPU = build/gpu


# On Gadi, with nvidia-hpc-sdk loaded, mpif90 and mpifort are identical.
FC_CPU = mpif90
FC_GPU = mpif90

# CPU Flags
FLAGS_CPU = -O3 -module $(BUILD_CPU) -I $(BUILD_CPU) 

# GPU Flags
FLAGS_GPU = -O3 -acc -gpu=cc90,mem:managed -Minfo=acc -module $(BUILD_GPU) -I $(BUILD_GPU)

# targets
EXE_CPU = $(BUILD_CPU)/mpi_pi_cpu
EXE_GPU = $(BUILD_GPU)/mpi_pi_gpu

# default: Build both
all: cpu gpu

# CPU Build 

cpu: $(EXE_CPU)

$(EXE_CPU): $(BUILD_CPU)/monte_carlo_mod_cpu.o $(BUILD_CPU)/main.o
	$(FC_CPU) $(FLAGS_CPU) -o $@ $^

# compile CPU mod
$(BUILD_CPU)/monte_carlo_mod_cpu.o: $(SRC)/monte_carlo_mod_cpu.f90
	@mkdir -p $(BUILD_CPU)
	$(FC_CPU) $(FLAGS_CPU) -c $< -o $@

# compile main (linked to CPU mod)
$(BUILD_CPU)/main.o: $(SRC)/main.f90 $(BUILD_CPU)/monte_carlo_mod_cpu.o
	@mkdir -p $(BUILD_CPU)
	$(FC_CPU) $(FLAGS_CPU) -c $< -o $@


# GPU Build 

gpu: $(EXE_GPU)

$(EXE_GPU): $(BUILD_GPU)/monte_carlo_mod_gpu.o $(BUILD_GPU)/main.o
	$(FC_GPU) $(FLAGS_GPU) -o $@ $^

# compile GPU 
$(BUILD_GPU)/monte_carlo_mod_gpu.o: $(SRC)/monte_carlo_mod_gpu.f90
	@mkdir -p $(BUILD_GPU)
	$(FC_GPU) $(FLAGS_GPU) -c $< -o $@

# compile main (linked to GPU mod)
$(BUILD_GPU)/main.o: $(SRC)/main.f90 $(BUILD_GPU)/monte_carlo_mod_gpu.o
	@mkdir -p $(BUILD_GPU)
	$(FC_GPU) $(FLAGS_GPU) -c $< -o $@


# cleanup
clean:
	rm -rf build