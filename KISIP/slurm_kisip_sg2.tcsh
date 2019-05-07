#!/bin/tcsh

# change to working directory
cd /home/phk/idl/KISIP_sg2

# get list of allocated nodes from SLURM and format to a hosts file for mpirun
setenv MACHINEFILE nodes.$SLURM_JOB_ID
srun -l /bin/hostname | sort -n | awk '{print $2}' > $MACHINEFILE

# run the actual job
mpirun -np $SLURM_NTASKS -machinefile $MACHINEFILE /home/phk/idl/KISIP_sg2/entry < /dev/null > log.txt


# clean up the hosts file
rm $MACHINEFILE
