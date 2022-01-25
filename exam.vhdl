
D<= A & not Q;

process(A, B)
if rising_edge(B) then
    Q<=D