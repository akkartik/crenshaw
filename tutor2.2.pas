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

{ Match a Specific Input Character }
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

{ Output a String with Tab }
procedure Emit(s: string);
begin
   Write(TAB, s);
end;

{ Output a String with Tab and CRLF }
procedure EmitLn(s: string);
begin
   Emit(s);
   WriteLn;
end;

{--------------------------------------------------------------}
{ Parse and translate a binary add/subtract operation }

procedure Init;
begin
   GetChar;
end;

procedure Term;
begin
   EmitLn('MOVE #' + GetDigit + ', D0')
end;

procedure Add;
begin
   Match('+');
   Term;
   EmitLn('ADD D1, D0');
end;

procedure Subtract;
begin
   Match('-');
   Term;
   EmitLn('SUB D1, D0');
   EmitLn('NEG D0');
end;

procedure Expression;
begin
   Term;
   EmitLn('MOVE D0, D1');
   case Look of
    '+': Add;
    '-': Subtract;
   else Expected('Addop');
   end;
end;

begin
   Init;
   Expression;
end.
