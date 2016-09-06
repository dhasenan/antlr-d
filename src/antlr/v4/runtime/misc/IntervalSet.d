module antlr.v4.runtime.misc.IntervalSet;

import std.conv;
import std.array;
import std.container.rbtree;
import antlr.v4.runtime.Vocabulary;
import antlr.v4.runtime.Token;
import antlr.v4.runtime.misc.IntegerList;
import antlr.v4.runtime.misc.IntSet;
import antlr.v4.runtime.misc.Interval;

// Class IntervalSet
/**
 * @uml
 * This class implements the {@link IntSet} backed by a sorted array of
 * non-overlapping intervals. It is particularly efficient for representing
 * large collections of numbers, where the majority of elements appear as part
 * of a sequential range of numbers that are all part of the set. For example,
 * the set { 1, 2, 3, 4, 7, 8 } may be represented as { [1, 4], [7, 8] }.
 *
 * <p>
 * This class is able to represent sets containing any combination of values in
 * the range {@link Integer#MIN_VALUE} to {@link Integer#MAX_VALUE}
 * (inclusive).</p>
 */
class IntervalSet : IntSet
{

    public static IntervalSet COMPLETE_CHAR_SET;

    public static IntervalSet EMPTY_SET;

    private bool readonly;

    /**
     * @uml
     * The list of sorted, disjoint intervals.
     */
    private Interval[] intervals;

    /**
     * @uml
     * @override
     */
    public override string toString()
    {
        return toString(false);
    }

    public string toString(bool elemAreChar)
    {
        auto buf = appender!string;
        if (intervals is null || intervals.length == 0) {
            return "{}";
        }
        if (this.size() > 1) {
            buf.put("{");
        };
        foreach (int index, I; this.intervals) {
            int a = I.a;
            int b = I.b;
            if (a == b) {
                if (a == Token.EOF) buf.put("<EOF>");
                else if (elemAreChar) buf.put("'" ~ to!string(a) ~ "'");
                else buf.put(to!string(a));
            }
            else {
                if (elemAreChar) buf.put("'" ~ to!string(a) ~ "'..'" ~ to!string(b) ~ "'");
                else buf.put(to!string(a) ~ ".." ~ to!string(b));
            }
            if (index + 1 < intervals.length) {
                buf.put(", "); //  not last element
            }
        }
        if (this.size() > 1) {
            buf.put("}");
        }
        return buf.data;

    }

    public string toString(Vocabulary vocabulary)
    {
        auto buf = appender!string;
        if (intervals is null || this.intervals.isEmpty() ) {
            return "{}";
        }
        if (size() > 1) {
            buf.put("{");
        }
        foreach (int index, I; this.intervals) {
            int a = I.a;
            int b = I.b;
            if ( a==b ) {
                buf.put(elementName(vocabulary, a));
            }
            else {
                for (int i=a; i<=b; i++) {
                    if ( i>a ) buf.put(", ");
                    buf.put(elementName(vocabulary, i));
                }
            }
            if (index + 1 < intervals.length) {
                buf.put(", ");
            }
        }
        if (size() > 1) {
            buf.put("}");
        }
        return buf.data;

    }

    public string elementName(Vocabulary vocabulary, int a)
    {
        if (a == Token.EOF) {
            return "<EOF>";
        }
        else if (a == Token.EPSILON) {
            return "<EPSILON>";
        }
        else {
            return vocabulary.getDisplayName(a);
        }
    }

    public int size()
    {
        int n = 0;
        int numIntervals = intervals.size();
        if (numIntervals == 1) {
            Interval firstInterval = intervals.get(0);
            return firstInterval.b - firstInterval.a + 1;
        }
        for (int i = 0; i < numIntervals; i++) {
            Interval I = intervals[i];
            n += (I.b - I.a + 1);
        }
        return n;
    }

    public IntegerList toIntegerList()
    {
        IntegerList values = new IntegerList(size());
        int n = intervals.size();
        for (int i = 0; i < n; i++) {
            Interval I = intervals[i];
            int a = I.a;
            int b = I.b;
            for (int v=a; v<=b; v++) {
                values.add(v);
            }
        }
        return values;
    }

    public int[] toList()
    {
        int[] values;
        int n = intervals.size();
        for (int i = 0; i < n; i++) {
            Interval I = intervals.get(i);
            int a = I.a;
            int b = I.b;
            for (int v =a ; v <= b; v++) {
                values ~= v;
            }
        }
        return values;
    }

    public RedBlackTree!int toSet()
    {
        auto s = new RedBlackTree!int();
        foreach (Interval I; intervals) {
            int a = I.a;
            int b = I.b;
            for (int v=a; v<=b; v++) {
                s.insert(v);
            }
        }
        return s;
    }

    /**
     * @uml
     * Get the ith element of ordered set.  Used only by RandomPhrase so
     * don't bother to implement if you're not doing that for a new
     * ANTLR code gen target.
     */
    public int get(int i)
    {
        int n = intervals.size();
        int index = 0;
        for (int j = 0; j < n; j++) {
            Interval I = intervals.get(j);
            int a = I.a;
            int b = I.b;
            for (int v=a; v<=b; v++) {
                if ( index==i ) {
                    return v;
                }
                index++;
            }
        }
        return -1;
    }

    public int[] toArray()
    {
        return toIntegerList().toArray;
    }

    public void remove(int el)
    {
        assert(!readonly, "can't alter readonly IntervalSet");
        int n = intervals.size();
        for (int i = 0; i < n; i++) {
            Interval I = intervals.get(i);
            int a = I.a;
            int b = I.b;
            if ( el<a ) {
                break; // list is sorted and el is before this interval; not here
            }
            // if whole interval x..x, rm
            if ( el==a && el==b ) {
                intervals.remove(i);
                break;
            }
            // if on left edge x..b, adjust left
            if ( el==a ) {
                I.a++;
                break;
            }
            // if on right edge a..x, adjust right
            if ( el==b ) {
                I.b--;
                break;
            }
            // if in middle a..x..b, split interval
            if ( el>a && el<b ) { // found in this interval
                int oldb = I.b;
                I.b = el-1;      // [a..x-1]
                add(el+1, oldb); // add [x+1..b]
            }
        }
    }

    public bool isReadonly()
    {
        return readonly;
    }

    public void setReadonly(bool readonly)
    {
        // if (this.readonly && !readonly ) throw new IllegalStateException("can't alter readonly IntervalSet");
        this.readonly = readonly;
    }

}
