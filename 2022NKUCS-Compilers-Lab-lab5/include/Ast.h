#ifndef __AST_H__
#define __AST_H__

#include <fstream>
#include"Type.h"

class SymbolEntry;

class Node
{
private:
    static int counter;
    int seq;
public:
    Node();
    int getSeq() const {return seq;};
    virtual void output(int level) = 0;
    
};

class ExprNode : public Node
{
public:
    Type* type;
    SymbolEntry *symbolEntry;
    ExprNode(SymbolEntry *symbolEntry) : symbolEntry(symbolEntry){};
    virtual Type* getType() { return type; };
    
};



class BinaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr1, *expr2;
public:
    enum {ADD, SUB, AND, OR, LESS, BIGER,EQ ,BE,LE,NE,MUL,DIV,MOD};
    BinaryExpr(SymbolEntry *se, int op, ExprNode*expr1, ExprNode*expr2) : ExprNode(se), op(op), expr1(expr1), expr2(expr2){};
    void output(int level);
   
};

class UnaryExpr: public ExprNode
{
    public:
    int u_op;
    ExprNode *exp;
    enum{ADD,SUB,NOT};
    UnaryExpr(SymbolEntry *se, int u_op, ExprNode*exp) : ExprNode(se), u_op(u_op), exp(exp){};
    void output(int level);
    

};

class Constant : public ExprNode
{
public:
    Constant(SymbolEntry *se) : ExprNode(se){};
    void output(int level);
    
};

class Id : public ExprNode
{
public:
    Id(SymbolEntry *se) : ExprNode(se){};
    void output(int level);
   
};

class StmtNode : public Node
{};

class BlankStmt : public StmtNode
{
    public:
    void output(int level);
};
class FuncFParam :public Node
{
    public:
    Id* id;
    FuncFParam(Id*id):id(id){};
    void output(int level);
};



class BreakStmt: public StmtNode
{
public:
    void output(int level);
    BreakStmt(){};
};

class ContinueStmt: public StmtNode
{
public:
    void output(int level);
    ContinueStmt(){};
};


class FuncFParams: public Node
{
    public:
    std::vector<FuncFParam*> params;
    FuncFParams(){};
    FuncFParams(std::vector<FuncFParam*> params): params(params){};
    void output(int level);
};


class CompoundStmt : public StmtNode
{
private:
    StmtNode *stmt;
public:
    CompoundStmt(StmtNode *stmt) : stmt(stmt) {};
    void output(int level);
};

class SeqNode : public StmtNode
{
private:
    StmtNode *stmt1, *stmt2;
public:
    SeqNode(StmtNode *stmt1, StmtNode *stmt2) : stmt1(stmt1), stmt2(stmt2){};
    void output(int level);
};

class ExpStmt : public StmtNode
{
    public:
    std::vector<ExprNode*> exp_list;
    ExpStmt(std::vector<ExprNode*> exp_list):exp_list(exp_list){};
    void output(int level);

};

class IfStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
public:
    IfStmt(ExprNode *cond, StmtNode *thenStmt) : cond(cond), thenStmt(thenStmt){};
    void output(int level);
};

class IfElseStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
    StmtNode *elseStmt;
public:
    IfElseStmt(ExprNode *cond, StmtNode *thenStmt, StmtNode *elseStmt) : cond(cond), thenStmt(thenStmt), elseStmt(elseStmt) {};
    void output(int level);
};

class WhileStmt : public StmtNode{
    public:
    ExprNode *cond;
    StmtNode *Stmt;
public:
    WhileStmt(ExprNode *cond,StmtNode *Stmt) : cond(cond), Stmt(Stmt){};
    void output(int level);
};

class ReturnStmt : public StmtNode
{
private:
    ExprNode *retValue;
public:
    ReturnStmt(ExprNode*retValue) : retValue(retValue) {};
    void output(int level);
};

class AssignStmt : public StmtNode
{
private:
    ExprNode *lval;
    ExprNode *expr;
public:
    AssignStmt(ExprNode *lval, ExprNode *expr) : lval(lval), expr(expr) {};
    void output(int level);
};

class FunctionDef : public StmtNode
{
private:
    SymbolEntry *se;
    StmtNode *stmt;
    FuncFParams * params;
public:
    FunctionDef(SymbolEntry *se, StmtNode *stmt,FuncFParams *params) : se(se), stmt(stmt),params(params){};
    void output(int level);
};


class VarDef : public StmtNode
{
    public:
    Id *id;
    ExprNode *expr;
    VarDef(Id *id, ExprNode *expr) : id(id), expr(expr){};
    void output(int level);

};

class VarDefs:public StmtNode
{
    public:
    std::vector<VarDef*> v_list;
    VarDefs(std::vector<VarDef*> v_list):v_list(v_list){};
    void output(int level);
};

class VarDecl :public StmtNode
{
    public:
    VarDefs *v;
    VarDecl(VarDefs *v):v(v){};
    void output(int level);
    
};

class ConstDef: public StmtNode
{
    public:
    Id *id;
    ExprNode *expr;
    ConstDef(Id *id, ExprNode *expr) : id(id), expr(expr){};
    void output(int level);
};

class ConstDefs:public StmtNode
{
    public:
    std::vector<ConstDef*> c_list;
    ConstDefs(std::vector<ConstDef*> c_list):c_list(c_list){};
    void output(int level);
};

class ConstDecl :public StmtNode
{
    public:
    ConstDefs *c;
    ConstDecl(ConstDefs *c):c(c){};
    void output(int level);
    
};

class Decl: public StmtNode
{
    public:
    StmtNode* decl;
    Decl(StmtNode*decl):decl(decl){};
    void output(int level);

};

class FuncRParams : public StmtNode
{
    public:
    std::vector<ExprNode *> Exp_list;
    FuncRParams(std::vector<ExprNode *> Exp_list):Exp_list(Exp_list){};
    void output(int level);

};

class FuncExp : public ExprNode
{
    public:
    FuncRParams * params;
    FuncExp(SymbolEntry *se,FuncRParams * params):ExprNode(se),params(params){};
    void output(int level);

};

class ArrayIndices : public Node
{
    public:
    std::vector<int> len_list;
    ArrayIndices(std::vector<int> len_list):len_list(len_list){};
    void output(int level);
};

class Initival_list : public Node
{
    public:
    std::vector<ExprNode*> exp;
    Initival_list(std::vector<ExprNode*> exp):exp(exp){};

};




class Ast
{
private:
    Node* root;
public:
    Ast() {root = nullptr;}
    void setRoot(Node*n) {root = n;}
    void output();
};

#endif
