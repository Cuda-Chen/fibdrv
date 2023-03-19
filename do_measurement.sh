#!/bin/bash
#This script tweak the system setting to minimize the unstable factors while
#analyzing the performance of fibdrv.
#
#originated from https://github.com/KYG-yaya573142/fibdrv/blob/master/do_measurement.sh
CPUID=3
ORIG_ASLR=`cat /proc/sys/kernel/randomize_va_space`
ORIG_GOV=`cat /sys/devices/system/cpu/cpu$CPUID/cpufreq/scaling_governor`
ORIG_TURBO=`cat /sys/devices/system/cpu/intel_pstate/no_turbo`

sudo bash -c "echo 0 > /proc/sys/kernel/randomize_va_space"
sudo bash -c "echo performance > /sys/devices/system/cpu/cpu$CPUID/cpufreq/scaling_governor"
sudo bash -c "echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo"

#measure the performance of fibdrv
make client_plot
make client_statistic
make unload
make load
rm -f plot_input_statistic
sudo taskset -c $CPUID ./client_statistic
sudo taskset -c $CPUID ./client_plot > plot_input
gnuplot scripts/plot-statistic.gp
gnuplot scripts/plot.gp
make unload

# restore the original system settings
sudo bash -c "echo $ORIG_ASLR >  /proc/sys/kernel/randomize_va_space"
sudo bash -c "echo $ORIG_GOV > /sys/devices/system/cpu/cpu$CPUID/cpufreq/scaling_governor"
sudo bash -c "echo $ORIG_TURBO > /sys/devices/system/cpu/intel_pstate/no_turbo"
