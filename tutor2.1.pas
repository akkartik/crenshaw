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
{ Parse and translate a number }

procedure Init;
begin
  GetChar;
end;

{ 1 => MOVE #1, D0 }
procedure Num;
begin
  EmitLn('MOVE #' + GetDigit + ', D0')
end;

begin
  Init;
  Num;
end.
