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

	// rail containing the decoded strings of each worker
	private val cl:Rail[ArrayList[CharEntry]];
	
	private val pos:Rail[AtomicInteger];

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
		cl = Rail.make[ArrayList[CharEntry]](numAsyncs);
		pos = Rail.make[AtomicInteger](numAsyncs);
		for ([i] in 0..numAsyncs-1) {
			cl(i) = new ArrayList[CharEntry]();
			pos(i) = new AtomicInteger();
		}

		inputWriter = new ByteRailWriter();
		for (byte in inputFile.bytes()) {
			inputWriter.write(byte);
		}
		this.input = inputWriter.toRail();
		inputWriter.close();
		inputFile.close();

		filesize = input.length();

		decodedText = "";
	}

	public def decodeSerial() {
		var buffer:UByte = 0;
		var code:Rail[UByte] = Rail.make(32, (0 as UByte));
		var length:Int = 0;
		val cd:CharDecoder = new CharDecoder(hash);

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
				if (cd.decode(code, length)) {
					outputFileSerial.writeChar(cd.getChar());
					code.reset((0 as UByte));
					length = 0;
				}
			}
		}

		outputFileSerial.close();
	}

	public def decodeParallel() {
		finish for ([i] in 1..numAsyncs) async {
			decodeChunk(numAsyncs-i);
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
		pos(id_).set(start-1);

		var buffer:UByte = 0;
		var code:Rail[UByte] = Rail.make(32, (0 as UByte));
		var length:Int = 0;
		val cd:CharDecoder = new CharDecoder(hash);
		var temp:CharEntry = null;
		var eoc:Boolean = false;

		// decode assigned block
		for (var i:Int = start; i <= stop; i++) {
			pos(id_).incrementAndGet();
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
				if (cd.decode(code, length)) {
					temp = new CharEntry(cd.getChar(), i, j);
					atomic cl(id).add(temp);
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
				pos(id_).set(filesize);
				return;
			} else {
				id++;
			}
			start = chunkSize*id;
			stop = (id == numAsyncs-1) ? filesize-1 : start + chunkSize - 1;
			var index:Int = 0;
			for (var i:Int = start; i <= stop; i++) {
				// increment our position
				pos(id_).incrementAndGet();

				// make sure we don't pass a higher ranked worker
				for ([j] in id..numAsyncs-1) {
					if (pos(j).get() != filesize) {
						while (i >= pos(j).get()) {
							; // wait
						}
					}
				}

				// load the next byte
				buffer = input(i);

				// for each bit in the byte
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
					if (cd.decode(code, length)) {
						temp = new CharEntry(cd.getChar(), i, j);
						if (index < cl(id).size()) {
							if (cl(id).get(index).i == i && cl(id).get(index).j == j && cl(id).get(index).char == cd.getChar()) {
								pos(id_).set(filesize);
								return;
							}
							// remove all incorrect entries from the list up to this point in the file
							while (index < cl(id).size() &&
									(
										cl(id).get(index).i < i ||
										(
											cl(id).get(index).i == i &&
											cl(id).get(index).j >= j
										)
									)) {
								atomic cl(id).removeAt(index);
							}
							// insert or add the correct entry to the list);
							if (index < cl(id).size()) {
								atomic addBefore(cl(id), index, temp);
							} else {
								atomic cl(id).add(temp);
							}
						} else {
							// add the correct entry to the list
							atomic cl(id).add(temp);
						}
						index++;
						code.reset((0 as UByte));
						length = 0;
						eoc = true;
					}
				}
			}
			while (cl(id).getLast() != temp) {
				atomic cl(id).removeLast();
			}
		}
		pos(id_).set(filesize);

		return;
	}

	private def addBefore(al:ArrayList[CharEntry], index:Int, ce:CharEntry) {
		val last:Int = al.size() - 1;
		al.add(al.get(last));
		for (var i:Int = last; i > index; i--) {
			al.set(al.get(i-1), i);
		}
		al.set(ce, index);
	}

}
