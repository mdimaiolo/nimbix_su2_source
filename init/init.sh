#! /bin/bash

su2_env_vars () {
    export SU2_HOME=/usr/local/SU2
    export SU2_RUN=/usr/local/nimbix_su2/install/bin
    export PATH=$PATH:$SU2_RUN
    export PYTHONPATH=$PYTHONPATH:$SU2_RUN
}

# Ensure the current working directory
su2dir=/usr/local/SU2
wkdir=/usr/local/nimbix_su2
cd $su2dir

# Set the inital environmental variables
export MPICC=/usr/bin/mpicc
export MPICXX=/usr/bin/mpicxx
export CC=$MPICC
export CXX=$MPICXX

# Check if SU2 has already been compiled & installed
if [ ! -d $wkdir/nimbix_build ]; then
    echo "SU2 install not found."
    echo "SU2 v7.1.1 compilate and install for NIMBIX"

    # Set the appropriate flags for the desired install options
    flags="-Dcustom-mpi=true -Denable-pywrapper=true -Denable-autodiff=true -Denable-directdiff=true"

    # Compile and verify the above flags compiled correctly
    verified=false
    build_counter=0
	
	while [ "$build_counter" -le 3 ] || [ "$verified" = false ]; do
	
		# Keep track of the build attempts to prevent an infinite loop
		((build_counter++))
				
		# Create a directory for meson
		mkdir -p $wkdir/nimbix_build
		sudo chown -R root:root $wkdir/nimbix_build
		sudo chmod -R 0777 $wkdir/nimbix_build
		
		# Compile with meson
		# (note that meson adds 'bin' to the --prefix directory during build)
		./meson.py $wkdir/nimbix_build $flags --prefix=$wkdir/install |& tee -a build_log.txt
		
		# Verify CC env var
		if grep -q "Using 'CC' from environment with value:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify CXX env var
		if grep -q "Using 'CXX' from environment with value:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify C compiler
		if grep -q "C compiler for the host machine:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify C linker
		if grep -q "C linker for the host machine:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify C++ compiler
		if grep -q "C++ compiler for the host machine:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify C++ linker
		if grep -q "C++ linker for the host machine:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify python3
		if grep -q "Program python3 found: YES" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify swig
		if grep -q "Program swig found: YES" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify mpi4py
		if grep -q "Using mpi4py from" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify pkg-config
		if grep -q "Found pkg-config:" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify python
		if grep -q "Dependency python found: YES" build_log.txt; then
			verified=true
		else
			verified=false
		fi
		# Verify install.sh
		if grep -q "Program install.sh found: YES" build_log.txt; then
			verified=true
		else
			verified=false
		fi	

		# Re-run meson if compile not verified
		if [ "$verified" = false ]; then
		
			# Remove the nimbix_build directory 
			echo "Meson build unverified. Removing nimbix_build directory."
			sudo rm -R $wkdir/nimbix_build
			
		elif [ "$verified" = true ]; then
		
			echo "Meson build verified."
		
			su2_env_vars

			# Install with ninja
			./ninja -C $wkdir/nimbix_build install
			
			build_counter=10
			
			break
			
		fi	
		
    done
	
	if [ $build_counter -eq 4 ]; then
	
		# Exit the script if build unsuccessful
		echo "Unable to correctly compile SU2 after 3 attempts."
		exit 1
	
	fi

else
	echo "SU2 previously compiled successfully."
	su2_env_vars
fi

sudo ln -s /usr/bin/python3 /usr/bin/python

echo "Changing to /data/SU2 directory to begin data processing."

cd /data/SU2

sudo chmod -R 0777 /data/SU2
