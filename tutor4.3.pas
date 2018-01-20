program Interpreter;

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

function GetInteger: integer;
begin
  if not IsDigit(Look) then Expected('Integer');
  GetInteger := Ord(Look) - Ord('0');
  GetChar;
end;

{--------------------------------------------------------------}
{ Parse and evaluate an arithmetic expression }

procedure Init;
begin
  GetChar;
end;

function Term: integer;
var Value: integer;
begin
  Value := GetInteger;
  while Look in ['*', '/'] do begin
    case Look of
      '*': begin
             Match('*');
             Value := Value * GetInteger;
           end;
      '/': begin
             Match('/');
             Value := Value div GetInteger;
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

begin
  Init;
  Writeln(Expression);
end.
