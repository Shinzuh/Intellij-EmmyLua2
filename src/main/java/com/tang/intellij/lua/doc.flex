package com.tang.intellij.lua.comment.lexer;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import com.tang.intellij.lua.comment.psi.LuaDocTypes;

%%

%class _LuaDocLexer
%implements FlexLexer, LuaDocTypes


%unicode
%public

%function advance
%type IElementType

%eof{ return;
%eof}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// User code //////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

%{ // User code
    private int _typeLevel = 0;
    private boolean _typeReq = false;
    public _LuaDocLexer() {
        this((java.io.Reader) null);
    }

    private void beginType() {
        yybegin(xTYPE_REF);
        _typeLevel = 0;
        _typeReq = true;
    }
%}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////// LuaDoc lexems ////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EOL="\r"|"\n"|"\r\n"
LINE_WS=[\ \t\f]
WHITE_SPACE=({LINE_WS}|{EOL})+
STRING=[^\r\n\t\f]*
ID=[:jletter:] ([:jletterdigit:]|\.)*
AT=@
//三个-以上
DOC_DASHES = --+
//Strings
DOUBLE_QUOTED_STRING=\"([^\\\"]|\\\S|\\[\r\n])*\"?  //\"([^\\\"\r\n]|\\[^\r\n])*\"?
SINGLE_QUOTED_STRING='([^\\\']|\\\S|\\[\r\n])*'?    //'([^\\'\r\n]|\\[^\r\n])*'?

%state xTAG
%state xTAG_WITH_ID
%state xTAG_NAME
%state xCOMMENT_STRING
%state xPARAM
%state xTYPE_REF
%state xCLASS
%state xCLASS_EXTEND
%state xFIELD
%state xFIELD_ID
%state xGENERIC
%state xALIAS
%state xSUPPRESS
%state xDOUBLE_QUOTED_STRING
%state xSINGLE_QUOTED_STRING

%%

<YYINITIAL> {
    {EOL}                      { yybegin(YYINITIAL); return com.intellij.psi.TokenType.WHITE_SPACE;}
    {LINE_WS}+                 { return com.intellij.psi.TokenType.WHITE_SPACE; }
    {DOC_DASHES}               { return DASHES; }
    "@"                        { yybegin(xTAG_NAME); return AT; }
    .                          { yybegin(xCOMMENT_STRING); yypushback(yylength()); }
}

<xTAG, xTAG_WITH_ID, xTAG_NAME, xPARAM, xTYPE_REF, xCLASS, xCLASS_EXTEND, xFIELD, xFIELD_ID, xCOMMENT_STRING, xGENERIC, xALIAS, xSUPPRESS> {
    {EOL}                      { yybegin(YYINITIAL);return com.intellij.psi.TokenType.WHITE_SPACE;}
    {LINE_WS}+                 { return com.intellij.psi.TokenType.WHITE_SPACE; }
}

<xTAG_NAME> {
    {ID}                       { yybegin(xCOMMENT_STRING); return TAG_NAME; }
    [^]                        { return com.intellij.psi.TokenType.BAD_CHARACTER; }
}

<xSUPPRESS> {
    {ID}                       { return ID; }
    ","                        { return COMMA; }
    [^]                        { yybegin(YYINITIAL); yypushback(yylength()); }
}

<xALIAS> {
    {ID}                       { beginType(); return ID; }
    [^]                        { yybegin(YYINITIAL); yypushback(yylength()); }
}

<xGENERIC> {
    {ID}                       { return ID; }
    ":"                        { return EXTENDS;}
    ","                        { return COMMA; }
    [^]                        { yybegin(YYINITIAL); yypushback(yylength()); }
}

<xCLASS> {
    {ID}                       { yybegin(xCLASS_EXTEND); return ID; }
}
<xCLASS_EXTEND> {
    ":"                        { beginType(); return EXTENDS;}
    [^]                        { yybegin(xCOMMENT_STRING); yypushback(yylength()); }
}

<xPARAM> {
    {ID}                       { beginType(); return ID; }
    "..."                      { beginType(); return ID; } //varargs
}

<xFIELD> {
    "private"                  { yybegin(xFIELD_ID); return PRIVATE; }
    "protected"                { yybegin(xFIELD_ID); return PROTECTED; }
    "public"                   { yybegin(xFIELD_ID); return PUBLIC; }
    {ID}                       { beginType(); return ID; }
}
<xFIELD_ID> {
    {ID}                       { beginType(); return ID; }
}

<xTYPE_REF> {
    "@"                        { yybegin(xCOMMENT_STRING); return STRING_BEGIN; }
    ","                        { _typeReq = true; return COMMA; }
    "|"                        { _typeReq = true; return OR; }
    ":"                        { _typeReq = true; return EXTENDS;}
    "<"                        { _typeLevel++; return LT; }
    ">"                        { _typeLevel--; _typeReq = false; return GT; }
    "("                        { _typeLevel++; return LPAREN; }
    ")"                        { _typeLevel--; _typeReq = false; return RPAREN; }
    "{"                        { _typeLevel++; return LCURLY; }
    "}"                        { _typeLevel--; _typeReq = false; return RCURLY; }
    "\""                       { yybegin(xDOUBLE_QUOTED_STRING); yypushback(yylength()); }
    "'"                        { yybegin(xSINGLE_QUOTED_STRING); yypushback(yylength()); }
    "[]"                       { _typeReq = false; return ARR; }
    "fun"                      { return FUN; }
    "vararg"                   { _typeReq = true; return VARARG; }
    "..."|{ID}                 { if (_typeReq || _typeLevel > 0) { _typeReq = false; return ID; } else { yybegin(xCOMMENT_STRING); yypushback(yylength()); } }
}

<xDOUBLE_QUOTED_STRING> {
    {DOUBLE_QUOTED_STRING}    { yybegin(xTYPE_REF); return STRING_LITERAL; }
}

<xSINGLE_QUOTED_STRING> {
    {SINGLE_QUOTED_STRING}    { yybegin(xTYPE_REF); return STRING_LITERAL; }
}

<xTAG> {
    "@"                        { yybegin(xCOMMENT_STRING); return STRING_BEGIN; }
    "#"                        { return SHARP; }
    {ID}                       { return ID; }
    [^]                        { return com.intellij.psi.TokenType.BAD_CHARACTER; }
}
<xTAG_WITH_ID> {
    {ID}                       { yybegin(xCOMMENT_STRING); return ID; }
}

<xCOMMENT_STRING> {
    {STRING}                   { yybegin(YYINITIAL); return STRING; }
}

[^]                            { return com.intellij.psi.TokenType.BAD_CHARACTER; }