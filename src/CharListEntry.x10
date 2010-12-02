public class CharListEntry {

	public val char:Char;
	public val i:Int;
	public val j:Int;
	public var next:CharListEntry = null;
	public var prev:CharListEntry = null;

	public def this(char:Char, i:Int, j:Int) {
		this.char = char;
		this.i = i;
		this.j = j;
	}

	public def hasNext():Boolean {
		if (next != null)
			return true;
		return false;
	}

}
