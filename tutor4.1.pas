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

{--------------------------------------------------------------}
{ Input stream management }

{ Read New Character From Input Stream }
procedure GetChar;
begin
  Read(Look);
end;

function GetDigit: integer;
begin
  if not IsDigit(Look) then Expected('Integer');
  GetDigit := Ord(Look) - Ord('0');
  GetChar;
end;

{--------------------------------------------------------------}
{ Read a digit into the Lookahead Character }

{ 4 => 4 }
function Expression: integer;
begin
  Expression := GetDigit;
end;

procedure Init;
begin
  GetChar;
end;

begin
  Init;
  Writeln(Expression);
end.
