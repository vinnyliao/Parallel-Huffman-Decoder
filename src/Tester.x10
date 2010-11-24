import x10.io.File;

public class Tester {
		
	public static def main(args:Array[String]):Void {
		val input:File = new File("input.txt");
		val encoded:File = new File("encoded.txt");
		val decoded:File = new File("decoded.txt");
		
		val he:HuffmanEncoder = new HuffmanEncoder(input, encoded);
		
		he.countFreq();
		he.countChars();
		Console.OUT.println("Character Frequencies:");
		he.printFreq();
		he.makeHuffmanTree();
		he.generateCode();
		Console.OUT.println("Huffman Code:");
		he.printCode();
		Console.OUT.println("Encoding...");
		he.encode();
		
		Console.OUT.println("Decoding...");
		val hd:HuffmanDecoder = new HuffmanDecoder(encoded, decoded, he.getHash());
		val time = System.nanoTime();
		hd.decodeSerial();
		val runtime = (System.nanoTime() - time)/1000000;
		Console.OUT.println("Runtime: " + runtime + "ms");
		
    }
    
}
