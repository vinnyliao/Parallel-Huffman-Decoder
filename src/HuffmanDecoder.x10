import x10.io.ByteRailWriter;
import x10.io.File;
import x10.io.FileReader;
import x10.io.FileWriter;
import x10.util.ArrayList;
import x10.util.concurrent.atomic.AtomicInteger;

/**
 * A class that implements a parallel Huffman decoding algorithm.
 */
public class HuffmanDecoder {

	// hash of characters -> Huffman codes
	private var hash:Rail[HuffmanCode];

	// string to store the decoded text
	private var decodedText:String;

	// private variables to store the last decoded character
	private var cSerial:Char;
	private var c:Rail[Char];

	// rail containing the decoded strings of each worker
	private val cl:Rail[ArrayList[CharEntry]];

	// rail of array list locks
	private val cllock:Rail[AtomicInteger];

	private var input:Rail[Byte];
	private val filesize:Int;

	private val outputFileSerial:FileWriter;
	private val outputFileParallel:FileWriter;

	private val numAsyncs:Int;

	private val inputWriter:ByteRailWriter;

	public def this(encoded:File, decodedSerial:File, decodedParallel:File, hash:Rail[HuffmanCode], numAsyncs:Int) {
		val inputFile:FileReader = new FileReader(encoded);
		this.outputFileSerial = new FileWriter(decodedSerial);
		this.outputFileParallel = new FileWriter(decodedParallel);
		this.hash = hash;
		this.numAsyncs = numAsyncs;
		c = Rail.make[Char](numAsyncs);
		cl = Rail.make[ArrayList[CharEntry]](numAsyncs);
		cllock = Rail.make[AtomicInteger](numAsyncs);
		for ([i] in 0..numAsyncs-1) {
			cl(i) = new ArrayList[CharEntry]();
			cllock(i) = new AtomicInteger(i);
		}

		inputWriter = new ByteRailWriter();
		for (byte in inputFile.bytes()) {
			inputWriter.write(byte);
		}
		this.input = inputWriter.toRail();
		inputFile.close();

		filesize = input.length();

		decodedText = "";
	}

	public def decodeSerial() {
		var buffer:UByte = 0;
		var code:Rail[UByte] = Rail.make(32, (0 as UByte));
		var length:Int = 0;

		for (byte in input) {
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
				if (decodeCharSerial(code, length)) {
					outputFileSerial.writeChar(cSerial);
					code.reset((0 as UByte));
					length = 0;
				}
			}
		}

		outputFileSerial.close();
	}

	public def decodeParallel() {
		finish for ([i] in 0..numAsyncs-1) async {
			decodeChunk(i);
		}
		for ([i] in 0..numAsyncs-1) {
			for (e in cl(i)) {
				outputFileParallel.writeChar(e.char);
			}
		}

		outputFileParallel.close();
	}

	private def decodeChunk(id_:Int) {
		val chunkSize = filesize/numAsyncs;
		var id:Int = id_;
		var start:Int = chunkSize*id;
		var stop:Int = (id == numAsyncs-1) ? filesize-1 : start + chunkSize - 1;

		var buffer:UByte = 0;
		var code:Rail[UByte] = Rail.make(32, (0 as UByte));
		var length:Int = 0;
		var prevEntry:CharEntry = null;
		var temp:CharEntry = null;
		var eoc:Boolean = false;

		// decode assigned block
		for (var i:Int = start; i <= stop; i++) {
			buffer = input(i);

			for (var j:Int = 7; j >= 0; j--) {
				eoc = false;
				length++;
				for (var k:Int = 31; k >= 1; k--) {
					code(k) = code(k) << 1;
					if ( (code(k-1) & ((1 as UByte) << 7)) != 0 )
						code(k) += (1 as UByte);
				}
				code(0) = code(0) << 1;
				if ( (buffer & ((1 as UByte) << j)) != 0 ) {
					code(0) += (1 as UByte);
				}
				if (decodeCharParallel(code, length, id_)) {
					cl(id).add(new CharEntry(c(id_), i, j));
					code.reset((0 as UByte));
					length = 0;
					eoc = true;
				}
			}
		}

		// decode next block if necessary
		while (!eoc) {
			// if this was the last block, return; otherwise decode the next block
			if (id == numAsyncs-1) {
				return;
			} else {
				id++;
			}
			start = chunkSize*id;
			stop = (id == numAsyncs-1) ? filesize-1 : start + chunkSize - 1;
			var index:Int = 0;
			for (var i:Int = start; i <= stop; i++) {
				buffer = input(i);

				for (var j:Int = 7; j >= 0; j--) {
					eoc = false;
					length++;
					for (var k:Int = 31; k >= 1; k--) {
						code(k) = code(k) << 1;
						if ( (code(k-1) & ((1 as UByte) << 7)) != 0 )
							code(k) += (1 as UByte);
					}
					code(0) = code(0) << 1;
					if ( (buffer & ((1 as UByte) << j)) != 0 ) {
						code(0) += (1 as UByte);
					}
					if (decodeCharParallel(code, length, id_)) {
						if (index < cl(id).size()) {
							if (cl(id).get(index).char == c(id_)) {
								return;
							}
							while (index < cl(id).size() &&
									(
										cl(id).get(index).i < i ||
										(
											cl(id).get(index).i == i &&
											cl(id).get(index).j > j
										)
									)) {
								cl(id).removeAt(index);
							}
							if (index < cl(id).size()) {
								cl(id).addBefore(index, new CharEntry(c(id_), i, j));
							} else {
								cl(id).add(new CharEntry(c(id_), i, j));
							}
						} else {
							cl(id).add(new CharEntry(c(id_), i, j));
						}
						index++;
						code.reset((0 as UByte));
						length = 0;
						eoc = true;
					}
				}
			}
		}
		
	}

	private def decodeCharSerial(code:Rail[UByte], length:Int):Boolean {
		for ([i] in 0..hash.length()-1) {
			if (hash(i) != null && hash(i).equals(code, length)) {
				cSerial = Char.chr(i);
				return true;
			}
		}
		return false;
	}

	private def decodeCharParallel(code:Rail[UByte], length:Int, id:Int):Boolean {
		for ([i] in 0..hash.length()-1) {
			if (hash(i) != null && hash(i).equals(code, length)) {
				c(id) = Char.chr(i);
				return true;
			}
		}
		return false;
	}

}
