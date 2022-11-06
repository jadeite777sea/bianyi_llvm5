#include "Ast.h"
#include "SymbolTable.h"
#include <string>
#include "Type.h"

extern FILE *yyout;
int Node::counter = 0;

Node::Node()
{
    seq = counter++;
}

void Ast::output()
{
    fprintf(yyout, "program\n");
    if(root != nullptr)
        root->output(4);
}

void UnaryExpr::output(int level)
{
    std::string str;
    switch(u_op)
    {
        case ADD:
            str="+";
            break;
        case SUB:
            str="-";
            break;
        case NOT:
            str="!";
            break;
    }
    fprintf(yyout, "%*cUnaryExpr\tu_op: %s\n", level, ' ', str.c_str());
    this->exp->output(level+4);

}

void BinaryExpr::output(int level)
{
    std::string op_str;
    switch(op)
    {
        case ADD:
            op_str = "add";
            break;
        case SUB:
            op_str = "sub";
            break;
        case AND:
            op_str = "and";
            break;
        case OR:
            op_str = "or";
            break;
        case LESS:
            op_str = "less";
            break;
        case BIGER:
            op_str = "biger";
            break;
        case EQ:
            op_str = "equal";
            break;
        case BE:
            op_str="biger or equal";
            break;
        case LE:
            op_str="less or equal";
            break;
        case NE:
            op_str="not equal";
            break;
        case MUL:
            op_str="mul";
            break;
        case DIV:
            op_str="div";
            break;
        case MOD:
            op_str="mod";
            break;
    }
    fprintf(yyout, "%*cBinaryExpr\top: %s\n", level, ' ', op_str.c_str());
    expr1->output(level + 4);
    expr2->output(level + 4);
}

void Constant::output(int level)
{
    std::string type, value;
    type = symbolEntry->getType()->toStr();
    value = symbolEntry->toStr();
    fprintf(yyout, "%*cIntegerLiteral\tvalue: %s\ttype: %s\n", level, ' ',
            value.c_str(), type.c_str());
}

void Id::output(int level)
{
    std::string name, type;
    int scope;
    name = symbolEntry->toStr();
    type = symbolEntry->getType()->toStr();
    scope = dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getScope();
    fprintf(yyout, "%*cId\tname: %s\tscope: %d\ttype: %s\tkind: %d\n", level, ' ',
            name.c_str(), scope, type.c_str(),symbolEntry->kind);
}

void CompoundStmt::output(int level)
{
    fprintf(yyout, "%*cCompoundStmt\n", level, ' ');
    stmt->output(level + 4);
}

void SeqNode::output(int level)
{
    fprintf(yyout, "%*cSequence\n", level, ' ');
    stmt1->output(level + 4);
    stmt2->output(level + 4);
}

void VarDef ::output(int level)
{
    fprintf(yyout,"%*cVarDef\n",level,' ');
    this->id->output(level + 4);
    if(this->expr!=NULL)
    {
        this->expr->output(level+4);
    }
    else
    {

    }

}

void VarDefs:: output(int level)
{
    fprintf(yyout,"%*cVarDefs\n",level,' ');
    for(unsigned int i=0;i<this->v_list.size();i++)
    {
        v_list[i]->output(level+4);
    }

}

void VarDecl:: output(int level)
{
    fprintf(yyout,"%*cVarDecl\n",level,' ');
    this->v->output(level+4);
}


void ConstDef ::output(int level)
{
    fprintf(yyout,"%*cConstDef\n",level,' ');
    this->id->output(level + 4);
    if(this->expr!=NULL)
    {
        this->expr->output(level+4);
    }
    else
    {

    }

}

void ConstDefs:: output(int level)
{
    fprintf(yyout,"%*cConstDefs\n",level,' ');
    for(unsigned int i=0;i<this->c_list.size();i++)
    {
        c_list[i]->output(level+4);
    }

}

void ConstDecl:: output(int level)
{
    fprintf(yyout,"%*cConstDecl\n",level,' ');
    this->c->output(level+4);
}

void Decl::output(int level)
{
    fprintf(yyout,"%*cDecl\n",level,' ');
    this->decl->output(level+4);
}



void IfStmt::output(int level)
{
    fprintf(yyout, "%*cIfStmt\n", level, ' ');
    cond->output(level + 4);
    thenStmt->output(level + 4);
}

void IfElseStmt::output(int level)
{
    fprintf(yyout, "%*cIfElseStmt\n", level, ' ');
    cond->output(level + 4);
    thenStmt->output(level + 4);
    elseStmt->output(level + 4);
}

void WhileStmt::output(int level)
{
    fprintf(yyout, "%*cWhileStmt\n", level, ' ');
    cond->output(level + 4);
    Stmt->output(level + 4);
}
void ReturnStmt::output(int level)
{
    fprintf(yyout, "%*cReturnStmt\n", level, ' ');
    retValue->output(level + 4);
}

void AssignStmt::output(int level)
{
    fprintf(yyout, "%*cAssignStmt\n", level, ' ');
    lval->output(level + 4);
    expr->output(level + 4);
}

void FunctionDef::output(int level)
{
    std::string name, type;
    name = se->toStr();
    type = se->getType()->toStr();
    fprintf(yyout, "%*cFunctionDefine function name: %s, type: %s\n", level, ' ', 
            name.c_str(), type.c_str());
    if(params!=NULL)
        params->output(level+4);
    stmt->output(level + 4);
}

void FuncFParams::output(int level)
{ 
    fprintf(yyout, "%*cFuncFParams\n", level, ' ');
    for (unsigned int i=0;i<params.size();i++)
    {
        params[i]->output(level+4);
    }
}

void FuncFParam::output(int level)
{
    fprintf(yyout,"%*cFuncFParam\n",level,' ');
    id->output(level+4);

}

void FuncExp ::output(int level)
{
    fprintf(yyout,"%*cFuncExp\n",level,' ');
    
    std::string name, type;
    int scope;
    name = symbolEntry->toStr();
    type = symbolEntry->getType()->toStr();
    scope = dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getScope();
    fprintf(yyout, "%*cId\tname: %s\tscope: %d\ttype: %s\tkind: %d\n", level, ' ',
            name.c_str(), scope, type.c_str(),symbolEntry->kind);

    if(this->params!=NULL)
        this->params->output(level+4);
}


void FuncRParams::output(int level)
{
    fprintf(yyout,"%*cFuncRParams\n",level,' ');
    for(unsigned int i=0;i<this->Exp_list.size();i++)
    {
        this->Exp_list[i]->output(level+4);
    }


}

void ExpStmt::output(int level)
{
    fprintf(yyout,"%*cExpStmt\n",level,' ');
    for (unsigned int i=0;i<this->exp_list.size();i++)
    {
        exp_list[i]->output(level+4);
    }


}

void BlankStmt:: output(int level)
{
    fprintf(yyout,"%*cBlankStmt\n",level,' ');

}

void BreakStmt::output(int level)
{
    fprintf(yyout,"%*cBreakStmt\n",level,' ');

}

void ContinueStmt::output(int level)
{
    fprintf(yyout,"%*cContinueStmt\n",level,' ');

}






