import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.SocketException;


public class UdpListener {

	int received_packets;
	int lost_packets;
	int refound_packets;
	
	int next_packet;
	
	int sent_packets;

	private static final int UDP_LISTENER_PORT = 4711;
	private static final int MAX_UDP_PACKETLENGTH = 65535;

	private void listen() {
		
		
		try {
			DatagramPacket packet = new DatagramPacket(new byte[MAX_UDP_PACKETLENGTH], MAX_UDP_PACKETLENGTH);
			DatagramSocket socket = new DatagramSocket(UDP_LISTENER_PORT);
			while (true) {
				try {
					socket.receive(packet);
					InetSocketAddress add = (InetSocketAddress)packet.getSocketAddress();
					String payload = new String(packet.getData(), 0, packet.getLength());
					String[] lines = payload.split("\n", 2);
					int packet_number = Integer.parseInt(lines[0]);
					if (packet_number == 0) { // reset
					  received_packets = 0;
					  lost_packets = 0;
					  refound_packets = 0;
						next_packet = 0;
						sent_packets = 0;
					}
					received_packets++;
					
					if (packet_number < next_packet)
						refound_packets++;
					else  {
						lost_packets += packet_number - next_packet;
						next_packet = packet_number + 1;
					}
					String stat = String.format("Rcvd: %d, Lost: %d, found: %d, totally lost: %d", received_packets,lost_packets,refound_packets,lost_packets-refound_packets);
					
					System.out.println("From " + add.getHostName() + ":" + add.getPort() + " - " + lines[0] + " | " + stat);
					
					// send back info
					String text = sent_packets + "\n" + stat;
					packet = new DatagramPacket(text.getBytes("UTF-8"), text.length(), add);
					socket.send(packet);
					sent_packets++;
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		} catch (SocketException e) {
			System.err.println("Could not initialize UDP socket on port " + UDP_LISTENER_PORT);
			e.printStackTrace();
		}
		
		
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

		new UdpListener().listen();
	}


}
