### Good to Know:
Dos2Unix everything recuresively with: find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix 

Evaluation on Linux server 
1. Open screen
	screen -S nameofscreen
2. Run script in screen 
	sudo ./runscript.sh
3. Put screen into the background
	CTRL + a + d
4. Log out
 (...)
5. Log in
6. Bring Screen to foreground
	screen -r


"TK:" marks the important parts in the code!



# Ephemeral QUIC API:

QuicSimpleServerSession::OnEphemeralMessageReceived(const std::string &message)
 ... in /proto-quic/src/net/tools/quic/quic_simple_server_session.cc and header /quic_simple_server_session.h
 => overrides QuicSpdySession::OnEphemeralMessageReceived(const std::string &message)


QuicSpdyClientBase::SendEphemeralMessage(const std::string &message, int deadline_in_microsecond)
 ... in /proto-quic/src/net/tools/quic/quic_spdy_client_base.cc and header /quic_spdy_client_base.h
	- for Baseline QUIC: comment out the whole method except 
						"SpdyHeaderBlock dummy_header;
						 SendRequest(dummy_header, message, /*fin=*/true);"
	- 
 

# Main Files:

Client main file: quic_simple_client_bin.cc in /proto-quic/src/net/tools/quic/quic_simple_client_bin.cc
	- setting application scenario parameters
	- generation of ephemeral messages (timestamp + padding with '*')
	- sending of ephemeral messages

Server main file: 


# Other important functions:

Called from 
QuicSimpleServerStream::OnDataAvailable()
... in /proto-quic/src/net/tools/quic/quic_simple_server_stream.cc
	- gathers bytes and append them to body -> body will be a message 
	- split message into packet_number and timestamp (ignoring the padding characters)
	- compute the one-way delay from client to server in ms granularity
	- log packet_number and one-way delay into delay_client_server.txt (!HARDCODED PATH HERE)
	- no response sent! (function SendResponse() commented out)
 
 
 Called from "SendEphemeralMessage":
 QuicSession::StopRetransmissions(QuicStreamId stream_id)
 ... in /proto-quic/src/net/quic/core/quic_session.cc 
 ->	calls QuicConnection::StopRetransmissions(QuicStreamId stream_id)
		... in /proto-quic/src/net/quic/core/quic_conncetion.cc
		->	calls QuicSentPacketManager::CancelRetransmissionsForStream(QuicStreamId stream_id)
				... in /proto-quic/src/net/quic/core/quic_sent_packet_manager.cc 
				-> basis function that cancels retransmissions for a specified stream
			
			
			
