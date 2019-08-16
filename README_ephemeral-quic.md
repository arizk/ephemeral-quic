### 0. open Cmder console

### 1. MAKI-Server No. 14 login
ssh maki@10.0.30.15
%maki!14

### 2. update code on server
EITHER use "rsync" to copy folder 	
OR use WinSCP to push new files to server

-------------------------

# Setup Ephemeral QUIC
(new)
1. Install Chromium ( https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions.md )
	1.1 Clone the depot_tools repository: (Info: https://dev.chromium.org/developers/how-tos/depottools )
		1.1.1 git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
		1.1.2 export PATH="$PATH:/path/to/depot_tools" (e.g. PATH="$PATH:/home/maki/depot_tools, use "pwd" for getting the absolute path for the depot_tools directory)
	1.2 Get the chromium code (takes some time, about 30+ Minutes)
		1.2.1 mkdir ~/chromium && cd ~/chromium
		1.2.2 fetch --nohooks chromium
	1.3 Install build dependencies and run the hooks
		1.3.1 cd src/
		1.3.2 ./build/install-build-deps.sh
		1.3.3 gclient runhooks
	1.4 Setting up the build
		1.4.1 gn gen out/Default
		
1. Install proto-quic from last branch instead? ( https://github.com/google/proto-quic/tree/merge-to-58.0.3005.0 )

------------------------ above needed to get gn to work?
		
2. Install Ephemeral QUIC
	2.1 git clone https://github.com/arizk/ephemeral-quic.git
	2.2 cd proto-quic
	2.3 export PROTO_QUIC_ROOT=`pwd`/src
	2.4 export PATH=$PATH:`pwd`/depot_tools
	2.5 ./proto_quic_tools/sync.sh
	2.6 ./src/build/install-build-deps.sh
		2.6.1 sudo chmod +750 ./src/buildtools/linux64/gn
		[2.6.2 sudo apt-get install ninja-build=1.7.1-1~ubuntu16.04.1 (else, version 1.5.1 is downloaded which does not work)]
	2.7 cd src
	2.8 gn gen out/Default 
	2.9 ninja -C out/Default quic_client quic_server
	
	2.10 cd net/tools/quic/certs/
	2.11 ./generate_certs.sh
	2.12 cd out/
	2.13 certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n ephemeral -i 2048-sha256-root.pem
	
3. Test if the quic_server and quic_client works
	3.1 Run the server:
		./out/Default/quic_server --quic_response_cache_dir=/tmp/quic-data/www.example.org --certificate_file=net/tools/quic/certs/out/leaf_cert.pem --key_file=net/tools/quic/certs/out/leaf_cert.pkcs8
	3.2 Run the client:
		./out/Default/quic_client --host=127.0.0.1 --port=6121 https://www.example.org/
	
4. Run Experiments
	4.0 update PATH problems (correct paths on local msi notebook yet)
		4.0.1 update .../experiments/server.sh (4x file paths)
		4.0.2 update .../experiments/client.sh (1x file path)
	4.1 cd ../experiments
	4.2 sudo ./run-experiments.sh
	
(for installation debugging information, see readme_fixing_ephemeral-quic.md in Masterthesis repo)

-------------------------

#Evaluationsscripte (falls benötigt)
1. Open Anaconda Prompt
2. cd "path to directory"
3. jupyter-notebook (execute on terminal)
4. Open "eval_plot.ipynb"
5. Run Cell