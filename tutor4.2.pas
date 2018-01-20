program Interpreter;

{--------------------------------------------------------------}
{ Variable Declarations }

var Look: char;              { Lookahead Character }

{--------------------------------------------------------------}
{ Helpers }

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

{--------------------------------------------------------------}
{ Recognizers }

function IsDigit(c: char): boolean;
begin
  IsDigit := c in ['0'..'9'];
end;

function IsAddOp(c: char): boolean;
begin
  IsAddOp := c in ['+', '-'];
end;

{--------------------------------------------------------------}
{ Input stream management }

{ Read New Character From Input Stream }
procedure GetChar;
begin
  Read(Look);
end;

{ Check that next character in input is as expected, and consume it }
procedure Match(x: char);
begin
  if Look = x then GetChar
  else Expected('''' + x + '''');
end;

function GetDigit: integer;
begin
  if not IsDigit(Look) then Expected('Integer');
  GetDigit := Ord(Look) - Ord('0');
  GetChar;
end;

{--------------------------------------------------------------}
{ Parse and evaluate an expression made of add/subtract operations }

{ 4 => 4 }
{ 1+2 => 3 }
{ 4-3 => 1 }
{ -3+4 => 1 }
function Expression: integer;
var Value: integer;
begin
  if IsAddOp(Look) then
    Value := 0
  else
    Value := GetDigit;
  while IsAddOp(Look) do begin
    case Look of
      '+': begin
             Match('+');
             Value := Value + GetDigit;
           end;
      '-': begin
             Match('-');
             Value := Value - GetDigit;
           end;
    else Expected('AddOp');
    end;
  end;
  Expression := Value;
end;

procedure Init;
begin
  GetChar;
end;

begin
  Init;
  Writeln(Expression);
end.
