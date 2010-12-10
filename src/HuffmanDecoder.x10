import x10.io.ByteRailWriter;
import x10.io.File;
import x10.io.FileReader;
import x10.io.FileWriter;
import x10.util.ArrayList;
import x10.util.concurrent.atomic.AtomicInteger;

/**
 * A class that implements the Huffman decoding algorithm in both sequential and parallel forms.
 */
public class HuffmanDecoder {

	private var hash:Rail[HuffmanCode];			// hash of characters -> Huffman codes
	private val cl:Rail[ArrayList[CharEntry]];	// rail containing the decoded strings of each chunk
	private val pos:Rail[AtomicInteger];		// rail containing the positions of each worker (byte within the input file)
	private var input:Rail[Byte];				// rail containing the contents of the encoded input file
	private val filesize:Int;					// size of the input file, in bytes
	private val outputFile:FileWriter;			// the output file
	private val numAsyncs:Int;					// number of parallel workers

	/**
	 * Constructs a HuffmanDecoder object.
	 * 
	 * encoded: the File from which to read the encoded text
	 * decoded: the File in which to output the decoded text
	 * hash: the Rail[HuffmanCode](256) which maps ASCII characters to HuffmanCode objects
	 * numAsyncs: the number of asyncs to use when decoding
	 */
	public def this(encoded:File, decoded:File, hash:Rail[HuffmanCode], numAsyncs:Int) {
		// put contents of the encoded input file in a ByteRailWriter
		val inputFile:FileReader = new FileReader(encoded);
		val inputWriter:ByteRailWriter = new ByteRailWriter();
		for (byte in inputFile.bytes()) {
			inputWriter.write(byte);
		}
		inputWriter.close();
		inputFile.close();

		// initialize global variables
		this.input = inputWriter.toRail();
		this.filesize = input.length();
		this.outputFile = new FileWriter(decoded);
		this.hash = hash;
		this.numAsyncs = numAsyncs;
		this.cl = Rail.make[ArrayList[CharEntry]](numAsyncs);
		this.pos = Rail.make[AtomicInteger](numAsyncs);
		for ([i] in 0..numAsyncs-1) {
			cl(i) = new ArrayList[CharEntry]();
			pos(i) = new AtomicInteger();
		}
	}

	/**
	 * Decodes the encoded input file, sequentially if numAsyncs == 0, or in parallel if numAsyncs > 0.
	 */
	public def decode() {
		if (numAsyncs < 0) {
			Console.OUT.println("Error: numAsyncs < 0");
		} else if (numAsyncs == 0) {
			decodeSerial();
		} else {
			decodeParallel();
		}
	}

	/**
	 * Runs the sequential Huffman decoding algorithm.
	 */
	private def decodeSerial() {
		// initialize buffer, code, and CharDecoder
		var buffer:UByte = 0;
		var code:Rail[UByte] = Rail.make(32, (0 as UByte)); // the longest code possible for ASCII input is 256 bits (32 bytes)
		var length:Int = 0; // this tells us how many bits to read in code
		val cd:CharDecoder = new CharDecoder(hash);

		// for each byte in the encoded input file
		for (byte in input) {
			// read the byte into buffer
			buffer = byte;

			// for each bit in the buffer
			for (var i:Int = 7; i >= 0; i--) {
				// shift code and read in the bit
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

				// if the code corresponds to a character
				if (cd.decode(code, length)) {
					// write the character to output and reset code
					outputFile.writeChar(cd.getChar());
					code.reset((0 as UByte));
					length = 0;
				}
			}
		}

		// close the output writer
		outputFile.close();
	}

	/**
	 * Runs the parallel Huffman decoding algorithm.
	 */
	private def decodeParallel() {
		// decode the file in chunks, storing decoded text for each chunk in its own decoded list
		finish for ([i] in 1..numAsyncs) async {
			decodeChunk(numAsyncs-i);
		}

		// write the decoded text from each chunk's decoded list to output
		for ([i] in 0..numAsyncs-1) {
			for (e in cl(i)) {
				outputFile.writeChar(e.char);
			}
		}

		// close the output writer
		outputFile.close();
	}

	/**
	 * Runs the Huffman decoding algorithm of a parallel worker.
	 * 
	 * id_: the id of the worker
	 */
	private def decodeChunk(id_:Int) {
		// the first chunk to decode is our assigned chunk
		var id:Int = id_;

		// partition the input and determine our chunk's boundaries
		val chunkSize = filesize/numAsyncs;
		var start:Int = chunkSize*id;
		var stop:Int = (id == numAsyncs-1) ? filesize-1 : start + chunkSize - 1;

		// broadcast our position as start-1. (we increment once we actually start.)
		pos(id_).set(start-1);

		// initialize buffer, code, CharDecoder
		var buffer:UByte = 0;
		var code:Rail[UByte] = Rail.make(32, (0 as UByte)); // the longest code possible for ASCII input is 256 bits (32 bytes)
		var length:Int = 0; // this tells us how many bits to read in code
		val cd:CharDecoder = new CharDecoder(hash);

		// initialize temp and eoc
		var temp:CharEntry = null; // this is used to store a decoded CharEntry
		var eoc:Boolean = false; // this tells us if the last bit was the last bit of a decoded CharEntry

		// decode our assigned chunk
		// for each byte in our assigned chunk
		for (var i:Int = start; i <= stop; i++) {
			// increment our position
			pos(id_).incrementAndGet();

			// read the byte into buffer
			buffer = input(i);

			// for each bit in the buffer
			for (var j:Int = 7; j >= 0; j--) {
				// shift code and read in the bit
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

				// if the code corresponds to a character
				if (cd.decode(code, length)) {
					// create a new CharEntry and add it to the chunk's decoded list
					temp = new CharEntry(cd.getChar(), i, j);
					atomic cl(id).add(temp);

					// reset code and set eoc to true
					code.reset((0 as UByte));
					length = 0;
					eoc = true;
				} else {
					// set eoc to false
					eoc = false;
				}
			}
		}

		// if the last bit of the last chunk we were at was not the end of a character, the next chunk must be incorrect
		while (!eoc) {
			// if there are no chunks left
			if (id == numAsyncs-1) {
				// broadcast our position as past the end of the file and return
				pos(id_).set(filesize);
				return;
			}

			// set the chunk to decode as the next chunk
			id++;

			// determine this chunk's boundaries
			start = chunkSize*id;
			stop = (id == numAsyncs-1) ? filesize-1 : start + chunkSize - 1;

			// initialize our location in this chunk's decoded list
			var index:Int = 0;

			// for each byte
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

				// read the byte into buffer
				buffer = input(i);

				// for each bit in the buffer
				for (var j:Int = 7; j >= 0; j--) {
					// shift code and read in the bit
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

					// if the code corresponds to a character
					if (cd.decode(code, length)) {
						// create a new CharEntry
						temp = new CharEntry(cd.getChar(), i, j);

						// if there is an existing entry at our current position in the chunk's decoded list
						if (index < cl(id).size()) {
							// if the existing entry is equal to our entry
							if (cl(id).get(index).i == i && cl(id).get(index).j == j && cl(id).get(index).char == cd.getChar()) {
								// broadcast our position as past the end of the file and return
								pos(id_).set(filesize);
								return;
							}
							// remove all incorrect entries from the list up to our position in the file
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
							// insert/add the correct entry to the list
							if (index < cl(id).size()) {
								atomic addBefore(cl(id), index, temp);
							} else {
								atomic cl(id).add(temp);
							}
						} else {
							// add the correct entry to the list
							atomic cl(id).add(temp);
						}

						// increment our position in the chunk's decoded list
						index++;

						// reset code and set eoc to true
						code.reset((0 as UByte));
						length = 0;
						eoc = true;
					} else {
						// set eoc to false
						eoc = false;
					}
				}
			}

			// when we've reached the end of a chunk, check that the last entry in the chunk's decoded list is the last entry we decoded
			// remove entries from the end of the decoded list until this is true
			while (cl(id).getLast() != temp) {
				atomic cl(id).removeLast();
			}
		}

		// broadcast our position as past the end of the file and return
		pos(id_).set(filesize);
		return;
	}

	/**
	 * Inserts a CharEntry in an ArrayList[CharEntry] at the given index.
	 * Note: We needed to make this because x10.util.ArrayList.addBefore() does not work in X10 version 2.1.
	 * 
	 * al: the ArrayList[CharEntry] to insert into
	 * index: the index of the ArrayList[CharEntry] to insert into
	 * ce: the CharEntry to insert
	 */
	private def addBefore(al:ArrayList[CharEntry], index:Int, ce:CharEntry) {
		val last:Int = al.size() - 1;
		al.add(al.get(last));
		for (var i:Int = last; i > index; i--) {
			al.set(al.get(i-1), i);
		}
		al.set(ce, index);
	}

}
