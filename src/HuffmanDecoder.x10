import x10.io.File;
import x10.io.FileReader;
import x10.io.FileWriter;

/**
 * A class that implements a parallel Huffman decoding algorithm.
 */
public class HuffmanDecoder {
		
	private var hash:Rail[HuffmanCode];
	private var stringHash:Rail[String];
	private var encodedText:String;
	private var decodedText:String;
	private var c:Char;
	private var input:FileReader;
	private var output:FileWriter;
	private val filesize:Long;
	
	public def this(input:File, output:File, hash:Rail[HuffmanCode]) {
		filesize = input.size();
		this.input = new FileReader(input);
		this.output = new FileWriter(output);
		this.hash = hash;
	}
	
	public def decodeSerial() {
		var buffer:UByte = 0;
		var code:UByte = 0;
		var length:Int = 0;
		val select:UByte = 1;
		
		for (byte in input.bytes()) {
			buffer = byte;
			for ([i] in 7..0) {
				code <<= 1;
				length++;
				if ( (buffer & (select << i)) == 1 ) {
					code++;
				}
				if (decodeChar(code, length)) {
					output.writeChar(c);
					code = 0;
					length = 0;
				}
			}
		}
	}
	
	public def decodeParallel() {
		
	}
	
	private def decodeChunk() {
		
	}
	
	private def decodeChar(byte:UByte, length:Int):Boolean {
		for ([i] in 0..hash.length()-1)
			if (hash(i).equals(byte, length)) {
				c = Char.chr(i);
				return true;
			}
		return false;
	}
	
	
	
	/**
	 * Constructs a HuffmanDecoder object.
	 */
	public def this(stringHash:Rail[String], encodedText:String) {
		this.stringHash = stringHash;
		this.encodedText = encodedText;
		decodedText = "";
		filesize = 0;
	}
	
	public def decodeText() {
		var begin:Int = 0;
		var end:Int = 1;
		while (end <= encodedText.length()) {
			if (decodeChar(encodedText.substring(begin, end))) {
				decodedText += c;
				begin = end;
			}
			end++;
		}
	}
	
	private def decodeChar(code:String):Boolean {
		for ([i] in 0..stringHash.length()-1)
			if (code.equals(stringHash(i))) {
				c = Char.chr(i);
				return true;
			}
		return false;
	}
	
	public def getDecodedText():String = decodedText;
	
}