########################### Single Experiment ################################
experiment='network-mininet' #do not forget to change PID!
# base
mn --clean
echo "***** CLEANED UP MININET *****"
./clean.sh
echo "***** CLEANED UP FROM PREVIOUS EXPERIMENTS *****"
start=`date +%s`
echo "Start time:" $(date) "of experiment" $experiment
nohup python $experiment.py
sleep 5
chmod +777 nohup.out # for esier handling of the file
pid=$(pgrep quic_client) #for ephemeral 
#pid=$(ps -ef | grep baseline_quic_client  | grep -v xterm | grep -v grep | awk '{print $2}') #for baseline
echo $pid
tail --pid=$pid -f /dev/null
sleep 5
echo "***** EXPERIMENT RUN ENDED *****"
end=`date +%s`
runtime=$((end-start))
printf 'Execution time: %dh:%dm:%ds\n' $(($runtime/3600)) $(($runtime%3600/60)) $(($runtime%60))
pkill xterm
pkill python
pkill -f quic
mn --clean 
./process_results.sh $experiment
echo "***** RESULTS SAVED *****"
