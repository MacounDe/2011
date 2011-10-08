import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.SocketException;
import java.util.ArrayList;


public class UdpSender {

	

	private static final int UDP_LISTENER_PORT = 4711;
	private static final int MAX_UDP_PACKETLENGTH = 65507;
    ArrayList<String> fifo = new ArrayList<String>();
    

	Runnable sender = new Runnable() {

		@Override
		public void run() {

		    String muchData = "";
		    for (int i = 0; i < 500; i++) {
		     muchData+=  "X";
		    }
		     
			try {
				DatagramPacket packet;
				final DatagramSocket socket = new DatagramSocket();
				InetSocketAddress dest = new InetSocketAddress("localhost", UDP_LISTENER_PORT);
				socket.connect(dest);
				
				new Thread(new Runnable(){

					@Override
					public void run() {
						DatagramPacket inPacket = new DatagramPacket(new byte[MAX_UDP_PACKETLENGTH], MAX_UDP_PACKETLENGTH);
						
						while (true) {

							try {
								socket.receive(inPacket);
								String payload = new String(inPacket.getData(), 0, inPacket.getLength());
								String[] lines = payload.split("\n", 2);
								if (lines.length > 1)
									System.out.println(lines[1]);
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						
					}}).start();
				
				//write
				while (true) {
					
					try {
						while (fifo.size() > 0) {
							String text = fifo.remove(0) + "\n" + muchData;
							packet = new DatagramPacket(text.getBytes("UTF-8"), text.length(), dest);
							socket.send(packet);
						}
					} catch (UnsupportedEncodingException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					
				}
				
				
			} catch (SocketException e) {
				System.err.println("Could not initialize UDP socket on port " + UDP_LISTENER_PORT);
				e.printStackTrace();
			} 
			
		}
		
	};
	
	
	
	private void send() {
		
		int i = 0;
		while (true) {
			fifo.add(""+i);
			try {
				Thread.sleep(10);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			i++;
		}
		
		
		
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		UdpSender sender = new UdpSender();
		new Thread(sender.sender).start();
		sender.send();
	}


}
