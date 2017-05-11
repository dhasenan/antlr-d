module antlr.v4.runtime.atn.LexerMoreAction;

import antlr.v4.runtime.Lexer;
import antlr.v4.runtime.atn.LexerAction;
import antlr.v4.runtime.atn.LexerActionType;
import antlr.v4.runtime.misc.MurmurHash;
import antlr.v4.runtime.misc.Utils;

// Singleton LexerMoreAction
/**
 * TODO add class description
 */
class LexerMoreAction : LexerAction
{

    /**
     * The single instance of LexerMoreAction.
     */
    private static __gshared LexerMoreAction instance_;

    /**
     * @uml
     * {@inheritDoc}
     *  @return This method returns {@link LexerActionType#MORE}.
     */
    public LexerActionType getActionType()
    {
        return LexerActionType.MORE;
    }

    public bool isPositionDependent()
    {
        return false;
    }

    public void execute(Lexer lexer)
    {
        lexer.more();
    }

    public int hashCode()
    {
	int hash = MurmurHash.initialize();
        hash = MurmurHash.update(hash, Utils.rank(getActionType));
        return MurmurHash.finish(hash, 1);
    }

    /**
     * @uml
     * - @SuppressWarnings("EqualsWhichDoesntCheckParameterClass")
     */
    public bool equals(Object obj)
    {
        return obj == this;
    }

    /**
     * @uml
     * @override
     */
    public override string toString()
    {
        return "more";
    }

    /**
     * Creates the single instance of LexerMoreAction.
     */
    private shared static this()
    {
        instance_ = new LexerMoreAction;
    }

    /**
     * Returns: A single instance of LexerMoreAction.
     */
    public static LexerMoreAction instance()
    {
        return instance_;
    }

}