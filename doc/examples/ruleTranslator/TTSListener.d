module TTSListener;

import RuleTranslatorBaseListener;
import RuleTranslatorParser: RuleTranslatorParser;
import RuleWriter: RuleWriter;
import antlr.v4.runtime.ParserRuleContext;
import antlr.v4.runtime.tree.ErrorNode;
import antlr.v4.runtime.tree.TerminalNode;
import std.algorithm.iteration;
import std.array;
import std.format;
import std.stdio;
import std.string;
import std.container : SList;

/**
 * This class provides an empty implementation of {@link RuleTranslatorListener},
 * which can be extended to create a listener which only needs to handle a subset
 * of the available methods.
 */
public class TTSListener : RuleTranslatorBaseListener {

    debug __gshared short counter;

    private auto stack = SList!(string[])();

    struct RuleSetting
    {
        string language;
        string rule_ID;
        string class_name;
        string baseName;
    }

    private RuleSetting ruleSetting;

    private string parameters;

    private ushort indentLevel;

    private bool funcdefFlag;

    public RuleWriter writer;

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterFile_input(RuleTranslatorParser.File_inputContext ctx) {
        writer.put("module ");
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitFile_input(RuleTranslatorParser.File_inputContext ctx) {
        writer.indentLevel = -- indentLevel;
        writer.putnl("\n}");
        writer.print;
        writer.clear;
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterRule_setting(RuleTranslatorParser.Rule_settingContext ctx) { }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitRule_setting(RuleTranslatorParser.Rule_settingContext ctx) {
        if (ruleSetting.language)
            writer.putnl(format("%s.%s;\n",
                                ruleSetting.language,
                                ruleSetting.class_name ? ruleSetting.class_name : ruleSetting.rule_ID
                                )
                         );
        else
            writer.putnl(format("%s;\n",
                                ruleSetting.class_name ? ruleSetting.class_name : ruleSetting.rule_ID
                                )
                         );
        writer.putnl("import std.array;");
        writer.putnl("import std.array;");
        writer.putnl("import std.conv;");
        writer.putnl("import std.datetime;");
        writer.putnl("import rule.Repository;");
        writer.putnl("import rule.GeneratedRule;");
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterClass_name(RuleTranslatorParser.Class_nameContext ctx) {
        ruleSetting.class_name = "";
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitClass_name(RuleTranslatorParser.Class_nameContext ctx) {
        ruleSetting.class_name =  ctx.getText;
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterRule_ID(RuleTranslatorParser.Rule_IDContext ctx) {
        ruleSetting.rule_ID = "";
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitRule_ID(RuleTranslatorParser.Rule_IDContext ctx) {
        ruleSetting.rule_ID = ctx.getText;
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterLanguage(RuleTranslatorParser.LanguageContext ctx) {
        ruleSetting.language = "";
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitLanguage(RuleTranslatorParser.LanguageContext ctx) {
        ruleSetting.language = ctx.getText;
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterImport_stmt(RuleTranslatorParser.Import_stmtContext ctx) {
        string app;
        foreach(el; ctx.children[2..$])
            app ~= el.getText;
        writer.putnl(format("import %s;", app));
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterBase_rules(RuleTranslatorParser.Base_rulesContext ctx) {
        ruleSetting.baseName = ctx.getText;
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitBase_rules(RuleTranslatorParser.Base_rulesContext ctx) { }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterImport_stmts(RuleTranslatorParser.Import_stmtsContext ctx) { }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitImport_stmts(RuleTranslatorParser.Import_stmtsContext ctx) {
        if(ruleSetting.class_name)
            writer.putnl(format("\nclass %s : %s\n{\n", ruleSetting.class_name, ruleSetting.baseName));
        else
            writer.putnl(format("\nclass %s : GeneratedRule\n{\n", ruleSetting.rule_ID));
        writer.indentLevel = ++ indentLevel;
    }


    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitFunctionName(RuleTranslatorParser.FunctionNameContext ctx) {
        writer.put(ctx.getText);
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterFuncdef(RuleTranslatorParser.FuncdefContext ctx) {
        writer.putnl("");
        writer.put("void ");
        funcdefFlag = true;
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitFuncdef(RuleTranslatorParser.FuncdefContext ctx) {
        writer.indentLevel = -- indentLevel;
        writer.putnl("}");
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterParameters(RuleTranslatorParser.ParametersContext ctx) {
        parameters = ctx.getText;
        if (funcdefFlag)
            {
                auto spl = splitter(ctx.getText[1..($-1)], ',');
                writer.putnl('(' ~ spl.map!(a => "T_" ~ a).join(", ") ~ ')');
                writer.putnl("    (" ~ spl.map!(a => "T_" ~ a ~ ' ' ~ a).join(", ") ~ ')');
                writer.putnl("{");
                writer.indentLevel = ++ indentLevel;
                funcdefFlag = false;
            }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterString_stmt(RuleTranslatorParser.String_stmtContext ctx) {
        if (!stack.empty) {
            stack.front ~= format("append(%s)", ctx.children[0].getText);
            debug {
                writefln("%s enterString_stmt:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterIf_stmt(RuleTranslatorParser.If_stmtContext ctx) {
        writer.put("if (");
        debug {
            writefln("%s enterIf_stmt:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitIf_stmt(RuleTranslatorParser.If_stmtContext ctx) {
        writer.indentLevel = -- indentLevel;
        writer.putnl("}");
        debug {
            writefln("%s exitIf_stmt:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }


    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterDotted_name(RuleTranslatorParser.Dotted_nameContext ctx) {
        if (!stack.empty) {
            stack.front ~= ctx.getText;
            debug {
                writefln("%s enterDotted_name:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterCondition(RuleTranslatorParser.ConditionContext ctx) {
        string[] conditionBuf;
        stack.insert(conditionBuf);
        debug {
            writefln("%s enterCondition:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitCondition(RuleTranslatorParser.ConditionContext ctx) {
        writer.put(stack.front.join);
        writer.putnl(")");
        stack.removeFront;
        writer.putnl("{");
        writer.indentLevel = ++ indentLevel;
        debug {
            writefln("%s exitCondition:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterNot(RuleTranslatorParser.NotContext ctx) {
        stack.front ~= "!";
        debug {
            writefln("%s enterNot:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterFunct_parameters(RuleTranslatorParser.Funct_parametersContext ctx) {
        if (!stack.empty) {
            string[] s;
            stack.insert(s);
            debug {
                writefln("%s enterFunct_parameters:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitFunct_parameters(RuleTranslatorParser.Funct_parametersContext ctx) {
        if (!stack.empty) {
            auto x = stack.front.join(", ");
            stack.removeFront;
            stack.front ~= "(" ~ x ~ ")";
            debug {
                writefln("%s exitFunct_parameters:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterTfpdef_number(RuleTranslatorParser.Tfpdef_numberContext ctx) {
        if (!stack.empty) {
            stack.front ~= ctx.getText;
            debug {
                writefln("%s enterTfpdef_number:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterTfpdef_name(RuleTranslatorParser.Tfpdef_nameContext ctx) {
        if (!stack.empty) {
            stack.front ~= ctx.getText;
            debug {
                writefln("%s enterTfpdef_name:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterTfpdef_string(RuleTranslatorParser.Tfpdef_stringContext ctx) {
        if (!stack.empty) {
            stack.front ~= ctx.getText;
            debug {
                writefln("%s enterTfpdef_string:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterTfpdef_funct_stm(RuleTranslatorParser.Tfpdef_funct_stmContext ctx) {
        if (!stack.empty) {
            string[] s;
            stack.insert(s);
            debug {
                writefln("%s enterTfpdef_funct_stm:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitTfpdef_funct_stm(RuleTranslatorParser.Tfpdef_funct_stmContext ctx) {
        if (!stack.empty) {
            auto x = stack.front.join;
            stack.removeFront;
            stack.front ~= x;
            debug {
                writefln("%s exitTfpdef_funct_stm:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterElse_e(RuleTranslatorParser.Else_eContext ctx) {
        writer.indentLevel = -- indentLevel;
        writer.putnl("}");
        writer.putnl("else");
        writer.putnl("{");
        writer.indentLevel = ++ indentLevel;
        debug {
            writefln("%s enterElse_e:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterElif_e(RuleTranslatorParser.Elif_eContext ctx) {
        writer.indentLevel = -- indentLevel;
        writer.putnl("}");
        writer.put("else if (");
        debug {
            writefln("%s enterElif_e:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterOr_e(RuleTranslatorParser.Or_eContext ctx) {
        if (!stack.empty) {
            stack.front ~= " || ";
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterAnd_e(RuleTranslatorParser.And_eContext ctx) {
        if (!stack.empty) {
            stack.front ~= " && ";
            debug {
                writefln("%s enterAnd_e:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterLess_than(RuleTranslatorParser.Less_thanContext ctx) {
        if (!stack.empty) {
            stack.front ~= " < ";
            debug {
                writefln("%s enterLess_than:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterGreater_than(RuleTranslatorParser.Greater_thanContext ctx) {
        if (!stack.empty) {
            stack.front ~= " > ";
            debug {
                writefln("%s enterGreater_than:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterGreater_equal(RuleTranslatorParser.Greater_equalContext ctx) {
        if (!stack.empty) {
            stack.front ~= " >= ";
            debug {
                writefln("%s enterGreater_equal:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterLess_equal(RuleTranslatorParser.Less_equalContext ctx) {
        if (!stack.empty) {
            stack.front ~= " <= ";
            debug {
                writefln("%s enterLess_equal:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterEquals(RuleTranslatorParser.EqualsContext ctx) {
        if (!stack.empty) {
            stack.front ~= " == ";
            debug {
                writefln("%s enterEquals:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterNot_equal(RuleTranslatorParser.Not_equalContext ctx) {
        if (!stack.empty) {
            stack.front ~= " != ";
            debug {
                writefln("%s enterNot_equal:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterDot_e(RuleTranslatorParser.Dot_eContext ctx) {
        if (!stack.empty) {
            stack.front ~= ".";
            debug {
                writefln("%s enterDot_e:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterSmall_stmt(RuleTranslatorParser.Small_stmtContext ctx) {
        string[] conditionBuf;
        stack.insert(conditionBuf);
        debug {
            writefln("%s enterSmall_stmt:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitSmall_stmt(RuleTranslatorParser.Small_stmtContext ctx) {
        if (!stack.empty) {
            writer.put(stack.front.join);
            writer.putnl(";");
            stack.removeFront;
            debug {
                writefln("%s exitSmall_stmt:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterNumber_e(RuleTranslatorParser.Number_eContext ctx) {
        if (!stack.empty) {
            stack.front ~= ctx.getText;
            debug {
                writefln("%s enterNumber_e:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterAtom_dotted_name(RuleTranslatorParser.Atom_dotted_nameContext ctx)
    {       
        if (!stack.empty)
            //stack.front ~= ctx.getText;
        debug {
            writefln("%s enterAtom_dotted_name:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterString_e(RuleTranslatorParser.String_eContext ctx) {
        if (!stack.empty)
            stack.front ~= ctx.getText;
        debug {
            writefln("%s enterString_e:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterAtom_funct_stmt(RuleTranslatorParser.Atom_funct_stmtContext ctx) {
        if (!stack.empty) {
            string[] s;
            stack.insert(s);
            debug {
                writefln("%s enterAtom_funct_stmt:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void exitAtom_funct_stmt(RuleTranslatorParser.Atom_funct_stmtContext ctx) {
        if (!stack.empty) {
            auto x = stack.front;
            stack.removeFront;
            stack.front ~= x;
            debug {
                writefln("%s exitAtom_funct_stmt:", counter++);
                foreach(el; stack.opSlice)
                    writefln("\t%s", el);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterTrue_e(RuleTranslatorParser.True_eContext ctx) {
        if (!stack.empty)
            stack.front ~= "true";
        debug {
            writefln("%s enterTrue_e:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    override public void enterFalse_e(RuleTranslatorParser.False_eContext ctx) {
        if (!stack.empty)
            stack.front ~= "false";
        debug {
            writefln("%s enterFalse_e:", counter++);
            foreach(el; stack.opSlice)
                writefln("\t%s", el);
        }
    }
}
