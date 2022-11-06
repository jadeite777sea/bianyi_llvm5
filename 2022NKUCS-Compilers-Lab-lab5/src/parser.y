%code top{
    #include <iostream>
    #include <assert.h>
    #include "parser.h"
    using namespace std;
    extern Ast ast;
    Type* declType;
    int yylex();
    int yyerror( char const * );
}

%code requires {
    #include "Ast.h"
    #include "SymbolTable.h"
    #include "Type.h"
}

%union {
    double numtype;
    char* strtype;
    StmtNode* stmttype;
    VarDef* vardef_type;
    VarDefs* vardefs_type;
    ConstDef* constdef_type;
    ConstDefs* constdefs_type;
    ExprNode* exprtype;
    FuncFParams * funcpars_type;
    FuncFParam * funcpar_type;
    FuncExp* funcexp_type;
    FuncRParams *funcrparams_type;
    ExpStmt * expstmt_type;
    Type* type;
    UnaryExpr* unaryexp_type;
}

%start Program
%token <strtype> ID 
%token <numtype> INTEGER FLOATING
%token IF ELSE WHILE
%token CONST
%token INT VOID FLOAT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA LBRACKET RBRACKET
%token ADD SUB OR AND LESS ASSIGN EQ BIGER BE LE NE MUL DIV MOD NOT
%token RETURN CONTINUE BREAK

%nterm <stmttype> Stmts Stmt AssignStmt BlockStmt IfStmt ReturnStmt FuncDef  WhileStmt VarDecl ConstDecl Decl BlankStmt BreakStmt ContinueStmt
%nterm <vardef_type> VarDef
%nterm <vardefs_type> VarDefs
%nterm <constdef_type> ConstDef
%nterm <constdefs_type> ConstDefs
%nterm <exprtype> Exp AddExp Cond LOrExp PrimaryExp LVal RelExp LAndExp EQExp MULExp 
%nterm <unaryexp_type> UnaryExp
%nterm <funcpars_type> FuncFParams
%nterm <funcpar_type> FuncFParam
%nterm <funcexp_type> FuncExp
%nterm <funcrparams_type> FuncRParams
%nterm <expstmt_type> ExpStmt
%nterm <type> Type

%precedence THEN
%precedence ELSE
%%
Program
    : Stmts {
        ast.setRoot($1);
    }
    ;
Stmts
    : Stmt {$$=$1;}
    | Stmts Stmt{
        $$ = new SeqNode($1, $2);
    }
    ;
Stmt
    : AssignStmt {$$=$1;}
    | BlockStmt {$$=$1;}
    | IfStmt {$$=$1;}
    | ReturnStmt {$$=$1;}
    | FuncDef {$$=$1;}
    | Decl {$$=$1;}
    | WhileStmt {$$=$1;}
    | ExpStmt  {$$=$1;}
    | BlankStmt{$$=$1;}
    | BreakStmt {$$=$1;}
    | ContinueStmt {$$=$1;};
    ;
LVal
    : ID {
        SymbolEntry *se;
        se = identifiers->lookup($1);
        if(se == nullptr)
        {
            fprintf(stderr, "identifier \"%s\" is undefined\n", (char*)$1);
            delete [](char*)$1;
            assert(se != nullptr);
        }
        $$ = new Id(se);
        delete []$1;
    }
    ;
AssignStmt
    :
    LVal ASSIGN Exp SEMICOLON {
        SymbolEntry *sec;
        sec = $1->symbolEntry;
        if(sec != nullptr && sec->isConstant())
        {
            fprintf(stderr, "const identifier \"%s\" can not changed\n", (char*)$1);
            delete [](char*)$1;
            assert(sec == nullptr);
        }
        $$ = new AssignStmt($1, $3);
    }
    ;
//为了维持左递归结构
ExpStmt
    :
    Exp SEMICOLON
    {
        vector<ExprNode*> t;
        t.push_back($1);
        $$=new ExpStmt(t);
    }
    |
    Exp COMMA ExpStmt
    {
       $3->exp_list.insert($3->exp_list.begin(),$1);
       $$=$3;
    
    }
    ;
BlankStmt
    :
    SEMICOLON
    {
        $$=new BlankStmt();
    }
    ;

BlockStmt
    :   LBRACE 
        {identifiers = new SymbolTable(identifiers);} 
        Stmts RBRACE 
        {
            $$ = new CompoundStmt($3);
            SymbolTable *top = identifiers;
            identifiers = identifiers->getPrev();
            delete top;
        }
    ;
BreakStmt
    :
    BREAK SEMICOLON {
        $$ = new BreakStmt();
    }
    ;
ContinueStmt
    : CONTINUE SEMICOLON {
        $$ = new ContinueStmt();
    }
    ;

IfStmt
    : IF LPAREN Cond RPAREN Stmt %prec THEN {
        $$ = new IfStmt($3, $5);
    }
    | IF LPAREN Cond RPAREN Stmt ELSE Stmt {
        $$ = new IfElseStmt($3, $5, $7);
    }
    ;
WhileStmt
    : WHILE LPAREN Cond RPAREN Stmt{
        $$= new WhileStmt($3,$5);
    }
    ;
ReturnStmt
    :
    RETURN Exp SEMICOLON{
        $$ = new ReturnStmt($2);
    }
    ;
Exp
    :
    AddExp {$$ = $1;}
    ;
Cond
    :
    LOrExp {$$ = $1;}
    ;
PrimaryExp
    :
    LVal {
        $$ = $1;
    }
    | INTEGER {
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, $1);
        $$ = new Constant(se);
    }
    | FLOATING {
    SymbolEntry* se = new ConstantSymbolEntry(TypeSystem::floatType, $1);
    $$ = new Constant(se);
    }
    ;
UnaryExp
    :
    PrimaryExp
    {
        Type* exprType = $1->getType();
        SymbolEntry *se=new TemporarySymbolEntry(exprType,SymbolTable::getLabel());
        $$=new UnaryExpr(se,UnaryExpr::ADD,$1);
    }
    |
    ADD UnaryExp
    {

        SymbolEntry *se=new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$=new UnaryExpr(se,UnaryExpr::ADD,$2);
    }
    |
    SUB UnaryExp
    {
        Type* exprType = $2->getType();
        SymbolEntry *se=new TemporarySymbolEntry(exprType, SymbolTable::getLabel());
        $$=new UnaryExpr(se,UnaryExpr::SUB,$2);
    }
    | 
    NOT UnaryExp
    {
        SymbolEntry *se=new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$=new UnaryExpr(se,UnaryExpr::NOT,$2);
    }
    | 
    FuncExp
    {   
        Type* exprType = $1->symbolEntry->type;
        SymbolEntry *se=new TemporarySymbolEntry(exprType, SymbolTable::getLabel());
        $$=new UnaryExpr(se,UnaryExpr::ADD,$1);
    }  
    ;

    FuncExp
    :
    ID LPAREN RPAREN 
    {
        
        SymbolEntry *se;
        se = globals->lookup($1);
        $$=new FuncExp(se,NULL);

    }
    |
    ID LPAREN FuncRParams RPAREN
    {
        
        SymbolEntry *se;
        se = globals->lookup($1);
        $$=new FuncExp(se,$3);
    }
    ;

FuncRParams
    :
    Exp
    {
        vector<ExprNode *> t;
        t.push_back($1);
        $$=new FuncRParams(t);
    }
    |
    FuncRParams COMMA Exp
    {
        $1->Exp_list.push_back($3);
        $$=$1;
    }
    ;

MULExp
    :
    UnaryExp {$$ = $1;}
    |
    MULExp MUL UnaryExp
    {
        SymbolEntry *se= new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        if ($1->getType()->isFloat() || $3->getType()->isFloat())
        se->type=TypeSystem::floatType;
        $$ = new BinaryExpr(se, BinaryExpr::MUL, $1, $3);

    }
    |
    MULExp DIV UnaryExp
    {
        SymbolEntry *se= new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        if ($1->getType()->isFloat() || $3->getType()->isFloat())
        se->type=TypeSystem::floatType;
        $$ = new BinaryExpr(se, BinaryExpr::DIV, $1, $3);
    }
    ;
AddExp
    :
    MULExp {$$ = $1;}
    |
    AddExp ADD MULExp
    {
        SymbolEntry *se= new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        if ($1->getType()->isFloat() || $3->getType()->isFloat())
        se->type=TypeSystem::floatType;
        $$ = new BinaryExpr(se, BinaryExpr::ADD, $1, $3);
    }
    |
    AddExp SUB MULExp
    {
        SymbolEntry *se= new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        if ($1->getType()->isFloat() || $3->getType()->isFloat())
        se->type=TypeSystem::floatType;
        $$ = new BinaryExpr(se, BinaryExpr::SUB, $1, $3);
    }
    ;
RelExp
    :
    AddExp {$$ = $1;}
    |
    RelExp LESS AddExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::LESS, $1, $3);
    }
    |
    RelExp BIGER AddExp
    {

        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::BIGER, $1, $3);
    }
    |
    RelExp BE AddExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::BE, $1, $3);
    }
    |
    RelExp LE AddExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::LE, $1, $3);
    }
    ;
EQExp
    :
    RelExp {$$ = $1;}
    |
    EQExp EQ RelExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::EQ, $1, $3);
    }
    |
    EQExp NE RelExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::NE, $1, $3);
    }
    ;
LAndExp
    :
    EQExp {$$ = $1;}
    |
    LAndExp AND EQExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::AND, $1, $3);
    }
    ;
LOrExp
    :
    LAndExp {$$ = $1;}
    |
    LOrExp OR LAndExp
    {
        
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::OR, $1, $3);
    }
    ;
Type
    : INT {
        $$ = TypeSystem::intType;
        declType = TypeSystem::intType;
    }
    | VOID {
        $$ = TypeSystem::voidType;
    }
    | FLOAT {
        $$ = TypeSystem::floatType;
        declType = TypeSystem::floatType;
    }
    ;
VarDef
    :
    ID 
    {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(1,declType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new VarDef(new Id(se),NULL);
        delete []$1;
    }
    |
    ID ASSIGN Exp
    {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(1,declType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new VarDef(new Id(se),$3);
        delete []$1;
    } 
    ;

VarDefs
    :
    VarDef
    {
        vector<VarDef*> t;
        t.push_back($1);
        $$=new VarDefs(t);

    }
    |
    VarDefs COMMA VarDef
    {
        $1->v_list.push_back($3);
        $$=$1;
    }
    ;
    
VarDecl
    :
    Type VarDefs SEMICOLON
    {
        
        $$=new VarDecl($2);

    }
    ;

ConstDef 
    :
    ID
    {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(0,declType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new ConstDef(new Id(se),NULL);
        delete []$1;
    }
    |
    ID ASSIGN Exp
    {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(0,declType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new ConstDef(new Id(se),$3);
        delete []$1;
    }
    ;
ConstDefs
    :
    ConstDef
    {
        vector<ConstDef*> t;
        t.push_back($1);
        $$=new ConstDefs(t);
    }
    |
    ConstDefs COMMA ConstDef 
    {
        $1->c_list.push_back($3);
        $$=$1;
    }
    ;
ConstDecl
    :
    CONST Type ConstDefs SEMICOLON
    {
        $$=new ConstDecl($3);

    }
    ;
Decl
    :
    ConstDecl
    {
        $$=new Decl($1);
    }
    |
    VarDecl
    {
        $$=new Decl($1);
    }
    ;

FuncFParam
    :
    Type ID {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(1,$1, $2, identifiers->getLevel());
        identifiers->install($2, se);
        $$ = new FuncFParam(new Id(se));
        //delete 之后还能输出吗?可以
        delete []$2;
    }
    ;
FuncFParams
    :
    FuncFParam {
        $$=new FuncFParams();
        $$->params.push_back($1);
    }
    |
    FuncFParams COMMA FuncFParam
    {
       $1->params.push_back($3);
       $$=$1;
    }
    ;

FuncDef
    :
    Type ID LPAREN 
    {
        Type *funcType;
        funcType = new FunctionType($1,{});
        SymbolEntry *se = new IdentifierSymbolEntry(1,funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        //identifiers = new SymbolTable(identifiers);
    }
    RPAREN BlockStmt
    {
        
        SymbolEntry *se;
        se = identifiers->lookup($2);
        assert(se != nullptr);
        $$ = new FunctionDef(se, $6,NULL);
        //SymbolTable *top = identifiers;
        //identifiers = identifiers->getPrev();
        //delete top;
        delete []$2;
    }
    |
    Type ID LPAREN FuncFParams RPAREN
    {
        Type *funcType;
        vector<Type*> t;
        for(unsigned int i=0;i<$4->params.size();i++)
        {
            t.push_back($4->params[i]->id->symbolEntry->type);
        }
        funcType = new FunctionType($1,t);
        SymbolEntry *se = new IdentifierSymbolEntry(1,funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        identifiers = new SymbolTable(identifiers);
    }
    BlockStmt
    {
        SymbolEntry *se;
        se = identifiers->lookup($2);
        assert(se != nullptr);
        $$ = new FunctionDef(se, $7,$4);
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;
        delete []$2;
    }
    ;
%%

int yyerror(char const* message)
{
    std::cerr<<message<<std::endl;
    return -1;
}







