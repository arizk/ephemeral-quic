########################### Ephemeral QUIC ################################
# base
mn --clean
echo "***** CLEANED UP MININET *****"
./clean.sh
echo "***** REMOVED TEMPORARY FILES FROM PREVIOUS EXPERIMENTS *****"
nohup python network-ephemeral-rtt5-buffer100-bw1-loss10.py
sleep 5
pid=$(pgrep quic_client)
echo $pid
tail --pid=$pid -f /dev/null
echo "***** Process ID to identify the end of an experiment *****"
chmod +777 nohup.out # for esier handling of the file
sleep 5
pkill xterm
mn --clean 
#./nonshow_save_result.sh ephemeral-rtt5-buffer100-bw1-loss10
echo "***** RESULTS NOT SAVED *****"