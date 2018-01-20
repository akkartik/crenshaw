program Compiler;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;

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
  IsAlpha := UpCase(c) in ['A'..'Z'];
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

{ <factor> ::= '(' <expression> ')' | <name> | <num> }
procedure Factor;
begin
  if Look = '(' then
    begin
      Match('(');
      Expression;
      Match(')');
    end
  else if IsAlpha(Look) then
    EmitLn('MOVE ' + GetAlpha + '(PC), D0')
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

function IsAddOp(c: char): boolean;
begin
  IsAddOp := c in ['+', '-'];
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
    else Expected('AddOp');
    end;
  end;
end;

begin
  Init;
  Expression;
end.
