program Compiler;

{--------------------------------------------------------------}
{ Variable Declarations }

var Look: char;              { Lookahead Character }

{--------------------------------------------------------------}
{ Input stream management }

{ Read New Character From Input Stream }
procedure GetChar;
begin
  Read(Look);
end;

{--------------------------------------------------------------}
{ Read a digit into the Lookahead Character }

procedure Init;
begin
  GetChar;
end;

begin
  Init;
end.
