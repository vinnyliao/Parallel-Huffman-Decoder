import x10.io.File;
import x10.io.FileReader;
import x10.io.FileWriter;

/**
 * A class that implements the Huffman encoding algorithm.
 */
public class HuffmanEncoder {

	private val MAX_ASCII = 256;
	private var freqArray:Rail[Int];
	private var nChars:Int;
	private var tree:HuffmanNode;
	private var hash:Rail[HuffmanCode];
	private var input:FileReader;
	private var output:FileWriter;

	/**
	 * Constructs a HuffmanEncoder object.
	 */
	public def this(input:File, output:File) {
		freqArray = Rail.make[Int](MAX_ASCII);
		nChars = 0;
		this.input = new FileReader(input);
		this.output = new FileWriter(output);
	}

	/**
	 * Counts the frequency of each character in the text and stores the count in an array.
	 */
	public def countFreq() {
		for (char in input.chars()) {
			freqArray(char.ord())++;
		}
	}

	/**
	 * Counts the number of distinct characters in the text.
	 */
	public def countChars() {
		nChars = 0;
		for ([i] in 0..MAX_ASCII-1)
			if (freqArray(i) != 0)
				nChars++;
	}

	/**
	 * Prints characters and their frequencies to the terminal.
	 */
	public def printFreq() {
		for ([i] in 0..MAX_ASCII-1)
			if (freqArray(i) != 0) {
				val line = "'" + Char.chr(i) + "' = " + freqArray(i);
				Console.OUT.println(line);
			}
	}

	/**
	 * Creates a Huffman tree.
	 */
	public def makeHuffmanTree() {
		// initialize heap
		var nodeArray:Rail[HuffmanNode] = Rail.make[HuffmanNode](nChars); // initiate array for buildHeap
		var n:Int = 0;
		for ([i] in 0..MAX_ASCII-1)
			if (freqArray(i) != 0) {
				nodeArray(n) = new HuffmanLeafNode(Char.chr(i), freqArray(i)); // fill array
				n++;
			}
		var heap:BinaryHuffmanNodeHeap = new BinaryHuffmanNodeHeap(nodeArray); // buildHeap
		
		// perform algorithm
		var left:HuffmanNode;
		var right:HuffmanNode;
		for ([i] in 0..nChars-2) {
			left = heap.deleteMin();
			right = heap.deleteMin();
			heap.insert(new HuffmanFullNode(left, right));
		}
		
		// create Huffman tree
		tree = heap.findMin();
	}

	/**
	 * Generates the Huffman code via the Huffman tree.
	 */
	public def generateCode() {
		tree.generateCode();
	}

	/**
	 * Prints the Huffman code to the terminal via the Huffman tree.
	 */
	public def printCode() {
		tree.printCode();
	}

	public def encode() {
		var c:HuffmanCode;
		var buffer:UByte = 0;
		val select:UByte = 1;
		var index:Int = 7;
		
		hash = tree.hash;
		for (char in input.chars()) {
			c = hash(char.ord());
			for ([i] in c.length-1..0) {
				if ( (c.code & (select << i)) > 0) {
					buffer += (select << index);
				}
				index--;
				if (index == -1) {
					output.writeByte(buffer);
					buffer = 0;
					index = 7;
				}
			}
		}
		
		if (index != 7)
			output.writeByte(buffer);
	}

	/**
	 * Returns the hash.
	 */
	public def getHash():Rail[HuffmanCode] = hash;
	
}
