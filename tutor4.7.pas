program Interpreter;

{--------------------------------------------------------------}
{ Constant Declarations }

const LF = ^J;  { Line-ending for *nix }
const CR = ^M;

{--------------------------------------------------------------}
{ Variable Declarations }

var Look: char;              { Lookahead Character }
var Table: Array['A'..'Z'] of integer;

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

function GetInteger: integer;
begin
  GetInteger := 0;
  if not IsDigit(Look) then Expected('Integer');
  while IsDigit(Look) do begin
    GetInteger := 10*GetInteger + Ord(Look)-Ord('0');
    GetChar;
  end;
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

procedure NewLine;
begin
  if Look = CR then
    GetChar;
  if Look = LF then
    Getchar;
end;

{--------------------------------------------------------------}
{ Parse and evaluate an algebraic expression, including brackets }

procedure InitTable;
var i: char;
begin
  for i := 'A' to 'Z' do
    Table[i] := 0;
end;

procedure Init;
begin
  InitTable;
  GetChar;
end;

function Expression: integer; Forward;

function Factor: integer;
begin
  if Look = '(' then begin
    Match('(');
    Factor := Expression;
    Match(')');
    end
  else if IsAlpha(Look) then
    Factor := Table[GetAlpha]
  else
    Factor := GetInteger;
end;

function Term: integer;
var Value: integer;
begin
  Value := Factor;
  while Look in ['*', '/'] do begin
    case Look of
      '*': begin
             Match('*');
             Value := Value * Factor;
           end;
      '/': begin
             Match('/');
             Value := Value div Factor;
           end;
    end;
  end;
  Term := Value;
end;

function IsAddop(c: char): boolean;
begin
  IsAddop := c in ['+', '-'];
end;

{ 4 => 4 }
{ 1+2 => 3 }
{ 4-3 => 1 }
{ -3+4 => 1 }
{ 2*3 => 6 }
{ 8/3 => 2 }  { division truncates }
{ 12*3 => 36 }
{ (2+3)*5 => 25 }
{ a=3
  !a
  => 3 }
{ a=3
  b=a+1
  !b
  => 4 }
function Expression: integer;
var Value: integer;
begin
  if IsAddOp(Look) then
    Value := 0
  else
    Value := Term;
  while IsAddOp(Look) do begin
    case Look of
      '+': begin
             Match('+');
             Value := Value + Term;
           end;
      '-': begin
             Match('-');
             Value := Value - Term;
           end;
    else Expected('Addop');
    end;
  end;
  Expression := Value;
end;

procedure Assignment;
var Name: char;
begin
  Name := GetAlpha;
  Match('=');
  Table[Name] := Expression;
end;

procedure Input;
begin
  Match('?');
  Read(Table[GetAlpha]);
end;

procedure Output;
begin
  Match('!');
  WriteLn(Table[GetAlpha]);
end;

begin
  Init;
  repeat
    case Look of
      '?': Input;
      '!': Output;
      else Assignment;
    end;
    NewLine;
  until Look = '.';
end.
