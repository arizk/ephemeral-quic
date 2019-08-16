2. Install Ephemeral QUIC
	2.1 git clone https://github.com/arizk/ephemeral-quic.git
	2.2 cd proto-quic
	2.3 export PROTO_QUIC_ROOT=`pwd`/src
	2.4 export PATH=$PATH:`pwd`/depot_tools (do again when "gn: command not found" happens)
			to delete the path use:
			PATH=$(REMOVE_PART="/home/maki/ephemeral-quic/proto-quic/depot_tools" sh -c 'echo ": $PATH:" | sed "s@:$REMOVE_PART:@:@g;s@^:\(.*\):\$@\1@"')
	
	2.5 ./proto_quic_tools/sync.sh
	MAYBE? TODO error when updated to newer version of sync-script (install-sysroot.py: error: no such option: --running-as-hook)
	
	2.6 ./src/build/install-build-deps.sh
		2.6.0 needed first? (update depot_tools from original repo? inserted "install-build-deps-proto.sh")
		2.6.1 gclient sync (else, there is an error with gn.py) takes about 35+ minutes
	2.7 cd src
	
	2.8 gn gen --args="is_proto_quic=true" out/Default
	= generates .ninja files which can be build afterwards
	TODO set the is_proto_quic argument in file "ephemeral-quic/proto-quic/src/.gn"
	-> default_args = {
						is_proto_quic = true
						use_custom_libcxx = false
					}
	Failure: "gclient file might not be the file you want to use" (can be ignorored)
	-> this failure is gone when gclient sync was executed before
	
	Failure: "gn.py: Could not find gn exetuable"
	-> copy "clang-format" and "gn" files from latest proto-quic
		Failure: permission denied in depot_tools/gn.py 
		-> copy depot_tools from latest proto-quic
		= still the same error
		-> copy gn.py file from original proto-quic
		= ephemeral-quic gn.py-file is exactly the same file as in original code
		-> update depot tools by cloning them from git (= gclient works) [ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ]
		+ sudo chmod +750 ./buildtools/linux64/gn
		= generation successful
			Failure: ninja: error: '../../build/util/LASTCHANGE', needed by 'obj/base/build_date.inputdeps.stamp', missing and no known rule to make it
			-> 	replace '/build/util/' directory from ephemeral-quic with newer version of proto-quic
			= build process starts!
		
		NOT NEEDED! [+ running gclient sync (???) (gives warning: Conicting directory /home/maki/ephemeral-quic/proto-quic/src moved to /home/maki/ephemeral-quic/proto-quic/_bad_scm/srcl9zfGx.)
			Failure: ERROR unresolved dependencies //:gn_all(//build/toolchain/linux:clang_x64) needs //net:net_perftests(//build/toolchain/linux:clang_x64)
			--> suddenly, it builds after directory out/ was removed with "rm -rf" and then called with only "gn gen out/Default"
				BUT fails still with is_proto_quic argument]
		
	2.9 ninja -C out/Default quic_client quic_server
	Failure: ninja build version 1.5.1 too old, needs 1.7.1
	-> sudo apt-get install ninja-build=1.7.1-1~ubuntu16.04.1
	
	2.10 cd net/tools/quic/certs/
	2.11 ./generate_certificates.sh
	2.12 certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n ephemeral -i 2048-sha256-root.pem (further information: https://chromium.googlesource.com/chromium/src/+/master/docs/linux_cert_management.md )
	
3. Test if the quic_server and quic_client works
	3.1 Get test data
		3.1.1 mkdir /tmp/quic-data
		3.1.2 cd /tmp/quic-data
		3.1.3 wget -p --save-headers https://www.example.org
		3.1.4 manually add "X-Original-Url: https://www.example.org/" to header
		
	3.2 Run the server:
		./out/Default/quic_server --quic_response_cache_dir=/tmp/quic-data/www.example.org --certificate_file=net/tools/quic/certs/out/leaf_cert.pem --key_file=net/tools/quic/certs/out/leaf_cert.pkcs8
	
	3.3 Run the client:
		./out/Default/quic_client --host=127.0.0.1 --port=6121 https://www.example.org/
	
4. Run Experiments
	4.1 cd ../experiments
	
	(Compile the C++-Files for an executable)
	4.1.1 sudo g++ -o num_open_streams num_open_streams.cc
	4.1.2 sudo g++ -std=c++11 -o preprocess_message_receipt preprocess_message_receipt.cc
	4.1.3 sudo g++ -o delay delay.cc
	4.1.4 sudo g++ -o handle-udp-output handle-udp-output.cc
	4.1.5 sudo g++ -o extract-delay-udp-output extract-delay-udp -output.cc
	4.1.6 sudo g++ -o extract-competing-tcp-throughput extract-c ompeting-tcp-throughput.cc
	4.1.7 sudo g++ -o extract-congestion-window extract-congesti on-window.cc
	4.1.8 sudo g++ -o tcp-delay tcp-delay.cc
	
	4.2 sudo ./run-experiments.sh
	REMINDER: Use "dos2unix ./filename.sh" & "chmod +x ./filename.sh" for getting an executable bash script
	-> log information inside of "nohub.out"
	
	Some logging files missing:
		-> rename the following paths (".../lca2/Desktop/...")
		net/tools/quic/quic_simple_server_session.cc:      logging_delay_client.open("/home/lca2/Desktop/delay_client_server.txt", std::ios_base::app);
		net/tools/quic/quic_simple_server_stream.cc:      logging_delay_client.open("/home/lca2/Desktop/delay_client_server.txt", std::ios_base::app);
		
	
	TODO mininet failure (containernet is involved?):
		containernet> Traceback (most recent call last):
		File "network-ephemeral-rtt5-buffer100-bw1-loss10.py", line 200, in <module>
			createNetwork()
		File "network-ephemeral-rtt5-buffer100-bw1-loss10.py", line 186, in createNetwork
			CLI(net)
		File "/usr/local/lib/python2.7/dist-packages/mininet-2.3.1-py2.7.egg/mininet/cli.py", line 71, in __init__
			self.run()
		File "/usr/local/lib/python2.7/dist-packages/mininet-2.3.1-py2.7.egg/mininet/cli.py", line 104, in run
			self.cmdloop()
		File "/usr/lib/python2.7/cmd.py", line 130, in cmdloop
			line = raw_input(self.prompt)
		IOError: [Errno 9] Bad file descriptor
	
	xterm error
					Warning: This program is an suid-root program or is being run by the root user.
					The full text of the error or warning message cannot be safely formatted
					in this environment. You may get a more descriptive message by running the
					program as a non-root user or by removing the suid bit on the executable.
					xterm: Xt error: Can't open display: %s
(!!!)	-> install + start Xming (Server) on Windows (https://www.youtube.com/watch?v=QRsma2vkEQE)
		+ execute "set DISPLAY=127.0.0.1:0" on Windows console (e.g. Cmder)
		+ use ssh -XY maki@10.0.30.15 (for using an untrusted X-Forwarding Server)
		+ test with "xclock &" in terminal
		= xforwarding works from MAKI to local WINDOWS (has to be re-done after new startup)
	-> execute "xhost +local:"
	-> sudo apt-get install ssh xauth xorg
	= "xterm hi iu" working (sometimes?!) -> just wait, the xterm windows open after some time
	=> xterm not used anymore!



	
	inside Experiment Setup:
	1. update .../experiments/server.sh (4x file paths)
	2. update .../experiments/client.sh (1x file path)