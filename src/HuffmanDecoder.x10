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
		var code:Rail[UByte] = Rail.make(32, (0 as UByte));
		var length:Int = 0;
		
		for (byte in input.bytes()) {
			buffer = byte;
			for (var i:Int = 7; i >= 0; i--) {
				length++;
				for (var j:Int = 31; j >= 1; j--) {
					code(j) = code(j) << 1;
					if ( (code(j-1) & ((1 as UByte) << 7)) != 0 )
						code(j) += (1 as UByte);
				}
				code(0) = code(0) << 1;
				if ( (buffer & ((1 as UByte) << i)) != 0 ) {
					code(0) += (1 as UByte);
				}
				if (decodeChar(code, length)) {
					output.writeChar(c);
					code.reset((0 as UByte));
					length = 0;
				}
			}
		}
		
		input.close();
		output.close();
	}
	
	public def decodeParallel() {
		
	}
	
	private def decodeChunk() {
		
	}
	
	private def decodeChar(code:Rail[UByte], length:Int):Boolean {
		for ([i] in 0..hash.length()-1) {
			if (hash(i) != null && hash(i).equals(code, length)) {
				c = Char.chr(i);
				return true;
			}
		}
		return false;
	}
	
}
