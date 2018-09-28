#!/bin/bash

today=$(date --date='00:00:00 today' +%s)
yesterday=$(date --date='00:00:00 yesterday' +%s)
output=$(date --date='yesterday' +%Y%m%d )-$(hostname -s)

condor_history=$(/usr/bin/condor_history -const "EnteredCurrentStatus >= $yesterday && EnteredCurrentStatus < $today && RemoteWallclockTime !=0" -format "clusterid=%v; " ClusterId \
-format "CE_JobId=%v; " RoutedFromJobId -format "owner=%s; " Owner -format "VO=%s; " x509UserProxyVOName -format "userDN=%s; " x509userproxysubject \
-format "userFQAN=%s; " x509UserProxyFirstFQAN -format "exec_host=%s; " LastRemoteHost \
-format "request_cpus=%d; " RequestCPUs -format "cputime=%f; " RemoteUserCpu -format "syscputime=%f; " RemoteSysCpu -format "jobduration=%f; " JobDuration \
-format "walltime+suspensiontime=%f; " RemoteWallclockTime -format "suspensiontime=%f; " CumulativeSuspensionTime \
-format "cputmult=%v; " MATCH_EXP_PICScaling -format "pmem=%v; " ResidentSetSize_RAW -format "vmem=%d; " ImageSize_RAW -format "disk=%d; " DiskUsage_RAW \
-format "ExitCode=%v; " ExitCode -format "ExitSignal=%v; " ExitSignal -format "LastStatus=%v; " LastJobStatus -format "JobStatus=%v; " JobStatus \
-format "startdate=%d; " JobStartDate -format "enddate=%d\n" EnteredCurrentStatus)

while read line; do
    epoch_date=$(echo $line | awk -Fenddate= '{print $2}')
    pbs_date=$(date +"%Y-%m-%d %H:%M:%S" -d@$epoch_date)
    timeline=$(echo "timestamp=$pbs_date; $line")
    echo ${timeline//pmem=undefined/pmem=0}
done <<< "$condor_history" > /var/lib/condor/accounting/$output

