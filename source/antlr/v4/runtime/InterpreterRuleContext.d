module antlr.v4.runtime.InterpreterRuleContext;

import antlr.v4.runtime.ParserRuleContext;

/**
 * This class extends {@link ParserRuleContext} by allowing the value of
 * {@link #getRuleIndex} to be explicitly set for the context.
 *
 * <p>
 * {@link ParserRuleContext} does not include field storage for the rule index
 * since the context classes created by the code generator override the
 * {@link #getRuleIndex} method to return the correct value for that context.
 * Since the parser interpreter does not use the context classes generated for a
 * parser, this class (with slightly more memory overhead per node) is used to
 * provide equivalent functionality.</p>
 */
class InterpreterRuleContext : ParserRuleContext
{

    protected int ruleIndex = -1;

    public this()
    {
    }

    public this(ParserRuleContext parent, int invokingStateNumber, int ruleIndex)
    {
        super(parent, invokingStateNumber);
        this.ruleIndex = ruleIndex;
    }

    /**
     * @uml
     * @override
     */
    public override int getRuleIndex()
    {
	return ruleIndex;
    }

}
