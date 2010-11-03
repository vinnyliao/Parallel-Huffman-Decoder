/**
 * A class that implements the Huffman encoding algorithm.
 */
public class HuffmanEncoder {

	private val MAX_ASCII = 256;
	private var freqArray:Rail[int];
	private var nChars:int;
	private var text:String;
	private var encodedText:String;
	private var nodeArray:Rail[HuffmanNode];
	private var heap:BinaryHuffmanNodeHeap;
	private var tree:HuffmanNode;
	private var hash:Rail[String];

	/**
	 * Constructs a HuffmanAlgorithm object.
	 */
	public def this() {
		freqArray = Rail.make[int](MAX_ASCII);
		nChars = 0;
		encodedText = "";
	}

	/**
	 * Sets the text to be encoded.
	 */
	public def setText(text:String) {
		this.text = text;
	}

	/**
	 * Counts the frequency of each character in the text and stores the count in an array.
	 */
	public def countFreq() {
		for ([i] in 0..text.length()-1)
			freqArray(text.charAt(i).ord())++;
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
		nodeArray = Rail.make[HuffmanNode](nChars); // initiate array for buildHeap
		var n:int = 0;
		for ([i] in 0..MAX_ASCII-1)
			if (freqArray(i) != 0) {
				nodeArray(n) = new HuffmanLeafNode(Char.chr(i), freqArray(i)); // fill array
				n++;
			}
		heap = new BinaryHuffmanNodeHeap(nodeArray); // buildHeap
		
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

	/**
	 * Encodes the text with the generated Huffman code.
	 */
	public def encodeText() {
		hash = tree.hash;
		for ([i] in 0..text.length()-1) {
			encodedText += hash(text.charAt(i).ord());
		}
	}

	/**
	 * Prints the encoded text.
	 */
	public def printText() {
		Console.OUT.println(encodedText);
	}

	/**
	 * Returns the Huffman tree.
	 */
	public def getTree():HuffmanNode = tree;

	/**
	 * Returns the hash.
	 */
	public def getHash():Rail[String] = hash;

	/**
	 * Returns the encoded text.
	 */
	public def getEncodedText():String = encodedText;
	
}
