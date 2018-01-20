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
{ Read a digit into the Lookahead Character }

procedure Init;
begin
  GetChar;
end;

{ 4 => 4 }
function Expression: integer;
begin
  Expression := GetInteger;
end;

begin
  Init;
  Writeln(Expression);
end.
