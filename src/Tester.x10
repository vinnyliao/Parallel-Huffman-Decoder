import x10.io.File;

public class Tester {

	public static def main(args:Array[String]):Void {
		// test parameters
		val input:File = new File("input.txt");
		val test:File = new File("test.out");
		val encoded:File = new File("encoded.out");
		val decoded:File = new File("decoded.out");
		val numTrials:Int = 20;
		val numAsyncs:Rail[Int] = Rail.make[Int](6); // 0, 1, 2, 4, 8, 16
		numAsyncs(0) = 0;
		var n:Int = 1;
		for ([i] in 1..5) {
			numAsyncs(i) = n;
			n *= 2;
		}

		// encode input
		Console.OUT.println("Encoding...");
		val he:HuffmanEncoder = new HuffmanEncoder(input, encoded);
		he.countFreq();
		he.countChars();
		he.makeHuffmanTree();
		he.generateCode();
		he.encode();
		val hash:Rail[HuffmanCode] = he.getHash();
		Console.OUT.println("Done encoding.");

		// decode
		var hd:HuffmanDecoder;
		var time:Long = 0;
		var runtime:Long = 0;

		// test for correctness
		Console.OUT.println("Testing for correctness...");
		hd = new HuffmanDecoder(encoded, test, hash, 16);
		hd.decode();
		Console.OUT.println("Done testing for correctness.");
		
		// warm up run
		Console.OUT.println("Warming up for performance test...");
		hd = new HuffmanDecoder(encoded, decoded, hash, 1);
		hd.decode();
		Console.OUT.println("Done warming up for performance test.");

		// test
		Console.OUT.println("Using " + numTrials + " trials for each number of asyncs.");
		Console.OUT.println("\tasyncs\taverage runtime (ms)");
		for ([i] in 0..5) {
			runtime = 0;
			for ([j] in 1..numTrials) {
				hd = new HuffmanDecoder(encoded, decoded, hash, numAsyncs(i));
				time = System.nanoTime();
				hd.decode();
				runtime += (System.nanoTime() - time)/1000000;
			}
			Console.OUT.println("\t" + numAsyncs(i) + "\t" + (runtime/numTrials));
		}
	}

}
