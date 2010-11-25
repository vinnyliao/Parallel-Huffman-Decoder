import x10.io.File;

public class Tester {

	public static def main(args:Array[String]):Void {
		val input:File = new File("input.txt");
		val encoded:File = new File("encoded.txt");
		val decodedSerial:File = new File("decodedSerial.txt");
		val decodedParallel:File = new File("decodedParallel.txt");
		val numAsyncs = 2;

		val he:HuffmanEncoder = new HuffmanEncoder(input, encoded);

		he.countFreq();
		he.countChars();
		//Console.OUT.println("Character Frequencies:");
		//he.printFreq();
		he.makeHuffmanTree();
		he.generateCode();
		//Console.OUT.println("Huffman Code:");
		//he.printCode();
		Console.OUT.println("Encoding...");
		he.encode();

		Console.OUT.println("Decoding...");
		val hd:HuffmanDecoder = new HuffmanDecoder(encoded, decodedSerial, decodedParallel, he.getHash(), numAsyncs);
		var time:Long = System.nanoTime();
		hd.decodeSerial();
		var runtime:Long = (System.nanoTime() - time)/1000000;
		Console.OUT.println("Serial Runtime: " + runtime + "ms");

		time = System.nanoTime();
		hd.decodeParallel();
		runtime = (System.nanoTime() - time)/1000000;
		Console.OUT.println("Parallel Runtime: " + runtime + "ms");
	}

}
