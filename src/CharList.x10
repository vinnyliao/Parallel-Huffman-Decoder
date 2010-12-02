import x10.io.ByteRailWriter;

public class CharList {

	public var head:CharListEntry;
	public var tail:CharListEntry;

	public def this() {
		head = null;
		tail = null;
	}

	public atomic def addToTail(e:CharListEntry) {
		if (tail != null)
			tail.next = e;
		else
			head = e;
		e.prev = tail;
		tail = e;
	}

	public atomic def addToHead(e:CharListEntry) {
		if (head != null)
			head.prev = e;
		else
			tail = e;
		e.next = head;
		head = e;
	}

	public atomic def removeFromTail() {
		if (tail != null) {
			if (tail.prev != null)
				tail = tail.prev;
			tail.next = null;
		}
	}

	public atomic def removeFromHead() {
		if (head != null) {
			if (head.next != null)
				head = head.next;
			head.prev = null;
		}
	}

	public def getByteRail():Rail[Byte] {
		val brw = new ByteRailWriter();
		var i:CharListEntry;
		for (i = head; i != null; i = i.next) {
			brw.write(i.char.ord() as Byte);
		}
		return brw.toRail();
	}
	
}
