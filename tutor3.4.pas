program Compiler;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
const LF = ^J;  { Line-ending for *nix }

{--------------------------------------------------------------}
{ Variable Declarations }

var Look: char;              { Lookahead Character }

{--------------------------------------------------------------}
{ Helpers }

{ Read New Character From Input Stream }
procedure GetChar;
begin
  Read(Look);
end;

{ Report an Error }
procedure Error(s: string);
begin
  WriteLn;
  WriteLn(^G, 'Error: ', s, '.');
end;

{ Report Error and Halt }
procedure Abort(s: string);
begin
  Error(s);
  Halt;
end;

{ Report What Was Expected and Halt }
procedure Expected(s: string);
begin
  Abort(s + ' Expected');
end;

{ Check that next character in input is as expected, and consume it }
procedure Match(x: char);
begin
  if Look = x then GetChar
  else Expected('''' + x + '''');
end;

function IsDigit(c: char): boolean;
begin
  IsDigit := c in ['0'..'9'];
end;

{ Read a digit }
function GetDigit: char;
begin
  if not IsDigit(Look) then Expected('Integer');
  GetDigit := Look;
  GetChar;
end;

function IsAlpha(c: char): boolean;
begin
  IsAlpha := upcase(c) in ['A'..'Z'];
end;

{ Read a single-character Identifier }
function GetAlpha: char;
begin
  if not IsAlpha(Look) then Expected('Name');
  GetAlpha := UpCase(Look);
  GetChar;
end;

{ Output a String with Tab }
procedure Emit(s: string);
begin
  Write(TAB, s);
end;

{ Output a String with Tab and LF }
procedure EmitLn(s: string);
begin
  Emit(s);
  WriteLn;
end;

{--------------------------------------------------------------}
{ Parse and translate an arithmetic expression, handling brackets }

procedure Init;
begin
  GetChar;
end;

procedure Expression; Forward;

{ <ident> ::= <name> ['(' ')'] }
procedure Ident;
var Name: char;
begin
  Name := GetAlpha;
  if Look = '(' then
    begin
      Match('(');
      Match(')');
      EmitLn('BSR ' + Name);
    end
  else
    EmitLn('MOVE ' + Name + '(PC), D0')
end;

{ <factor> ::= '(' <expression> ')' | <ident> | <num> }
procedure Factor;
begin
  if Look = '(' then
    begin
      Match('(');
      Expression;
      Match(')');
    end
  else if IsAlpha(Look) then
    Ident
  else
    EmitLn('MOVE #' + GetDigit + ', D0');
end;

procedure Multiply;
begin
  Match('*');
  Factor;
  EmitLn('MULS (SP)+, D0');
end;

procedure Divide;
begin
  Match('/');
  Factor;
  EmitLn('MOVE (SP)+, D1');
  EmitLn('DIVS D1, D0');
end;

{ <term> ::= <factor> ['*'|'/' <factor>]* }
procedure Term;
begin
  Factor;
  while Look in ['*', '/'] do begin
    EmitLn('MOVE D0, -(SP)');
    case Look of
      '*': Multiply;
      '/': Divide;
    else Expected('Mulop');
    end;
  end;
end;

procedure Add;
begin
  Match('+');
  Term;
  EmitLn('ADD (SP)+, D0');
end;

procedure Subtract;
begin
  Match('-');
  Term;
  EmitLn('SUB (SP)+, D0');
  EmitLn('NEG D0');
end;

function IsAddop(c: char): boolean;
begin
  IsAddop := c in ['+', '-'];
end;

{ <expression> ::= ('+'|'-' <term>) | (<term> ['+'|'-' <term>]*) }
{ 1 => MOVE #1, D0 }
{ 1+2 => MOVE #1, D0
         MOVE D0, -(SP)
         MOVE #2, D0
         ADD (SP)+, D0 }
{ 4-3 => MOVE #4, D0
         MOVE D0, -(SP)
         MOVE #3, D0
         SUB (SP)+, D0
         NEG D0 }
{ 1+4-3 => MOVE #1, D0
           MOVE D0, -(SP)
           MOVE #4, D0
           ADD (SP)+, D0
           MOVE D0, -(SP)
           MOVE #3, D0
           SUB (SP)+, D0
           NEG D0 }
{ 2*3 => MOVE #2, D0
         MOVE D0, -(SP)
         MOVE #3, D0
         MULS (SP)+, D0 }
{ 2*3 + 4 => MOVE #2, D0
             MOVE D0, -(SP)
             MOVE #3, D0
             MULS (SP)+, D0
             MOVE D0, -(SP)
             MOVE #4, D0
             ADD (SP)+, D0 }
{ 2*3 + 4*5 => MOVE #2, D0
               MOVE D0, -(SP)
               MOVE #3, D0
               MULS (SP)+, D0
               MOVE D0, -(SP)
                 MOVE #4, D0
                 MOVE D0, -(SP)
                 MOVE #5, D0
                 MULS (SP)+, D0
               ADD (SP)+, D0 }
{ 2*(3+4) => MOVE #2, D0
             MOVE D0, -(SP)
              MOVE #3, D0
              MOVE D0, -(SP)
              MOVE #4, D0
              ADD (SP)+, D0
             MULS (SP)+, D0 }
{ -1 => CLR D0
        MOVE D0, -(SP)
        MOVE #1, D0
        SUB (SP)+, D0
        NEG D0 }
{ 3+(-1) => MOVE #3, D0
            MOVE D0, -(SP)
            CLR D0
            MOVE D0, -(SP)
            MOVE #1, D0
            SUB (SP)+, D0
            NEG D0
            ADD (SP)+, D0 }
{ a => MOVE A(PC), D0 }  { A is a label to global segment }
{ a() => BSR A }
procedure Expression;
begin
  if IsAddOp(Look) then
    EmitLn('CLR D0')
  else
    Term;
  while IsAddOp(Look) do begin
    { D0 contains the running total at each iteration }
    EmitLn('MOVE D0, -(SP)');
    case Look of
      '+': Add;
      '-': Subtract;
    else Expected('Addop');
    end;
  end;
end;

{ <assignment> ::= <name> '=' <expression> }
{ a=3 => MOVE #3, D0
         LEA A(PC), A0
         MOVE D0, (A0) }
{ a=a+1 => MOVE A(PC), D0
           MOVE D0, -(SP)
           MOVE #1, D0
           ADD (SP)+, D0
           LEA A(PC), A0
           MOVE D0, (A0) }
procedure Assignment;
var Name: char;
begin
   Name := GetAlpha;
   Match('=');
   Expression;
   EmitLn('LEA ' + Name + '(PC), A0');
   EmitLn('MOVE D0, (A0)')
end;
{--------------------------------------------------------------}

begin
  Init;
  Assignment;
  if Look <> LF then Expected('Newline');
end.
